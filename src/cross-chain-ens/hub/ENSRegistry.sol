// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import "../interfaces/ENS.sol";
import { CCIPReceiver } from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import { Client } from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";

/**
 * The ENS registry contract.
 */
contract ENSRegistry is ENS, CCIPReceiver {
    struct Record {
        address owner;
        address resolver;
        uint64 ttl;
    }

    struct CCIPPayload {
        address caller;
        bytes4 func;
        bytes params;
    }

    mapping(bytes32 => Record) records;
    mapping(address => mapping(address => bool)) operators;

    address private ccipSender; // Used as a sender override in modifier authorised

    // Permits modifications only by the owner of the specified node.
    modifier authorised(bytes32 _node) {
        address owner = records[_node].owner;
        address sender = _getMsgSender();
        require(owner == sender || operators[owner][sender]);
        _;
    }

    modifier authenticateCCIP(Client.Any2EVMMessage memory _any2EvmMessage) {
        uint64 sourceChainSelector = _any2EvmMessage.sourceChainSelector;
        address sender = abi.decode(_any2EvmMessage.sender, (address)); // abi-decoding of the sender address
        require(isWhitelisted(sourceChainSelector, sender), "Not whitelisted");
        _;
    }

    /**
     * @dev Constructs a new ENS registry.
     */
    constructor(address _router) CCIPReceiver(_router) {
        records[0x0].owner = msg.sender;
    }

    /// handle a received message from spoke chain
    function _ccipReceive(
        Client.Any2EVMMessage memory _any2EvmMessage
    ) internal override authenticateCCIP(_any2EvmMessage){
        CCIPPayload memory message = abi.decode(_any2EvmMessage.data, (CCIPPayload)); // abi-decoding of the sent string message

        ccipSender = message.caller;
        bytes4 func = message.func;

        if (func == this.setRecord.selector) {
            (bytes32 node, address owner, address resolver, uint64 ttl) = abi.decode(message.params, (bytes32, address, address, uint64));
            setRecord(node, owner, resolver, ttl);
        } else if(func == this.setSubnodeRecord.selector) {
            (bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) = abi.decode(message.params, (bytes32, bytes32, address, address, uint64));
            setSubnodeRecord(node, label, owner, resolver, ttl);
        } else if(func == this.setOwner.selector) {
            (bytes32 node, address owner) = abi.decode(message.params, (bytes32, address));
            setOwner(node, owner);
        } else if(func == this.setSubnodeOwner.selector) {
            (bytes32 node, bytes32 label, address owner) = abi.decode(message.params, (bytes32, bytes32, address));
            setSubnodeOwner(node, label, owner);
        } else if(func == this.setResolver.selector) {
            (bytes32 node, address resolver) = abi.decode(message.params, (bytes32, address));
            setResolver(node, resolver);
        } else if(func == this.setTTL.selector) {
            (bytes32 node, uint64 ttl) = abi.decode(message.params, (bytes32, uint64));
            setTTL(node, ttl);
        } else if(func == this.setApprovalForAll.selector) {
            (address operator, bool approved) = abi.decode(message.params, (address, bool));
            setApprovalForAll(operator, approved);
        } else {
            revert("Unknown function selector");
        }

        // Message memory detail = Message(sourceChainSelector, sender, message);
        // emit MessageReceived(messageId, sourceChainSelector, sender, message);
    }

    /**
     * @dev Sets the record for a node.
     * @param _node The node to update.
     * @param _owner The address of the new owner.
     * @param _resolver The address of the resolver.
     * @param _ttl The TTL in seconds.
     */
    function setRecord(
        bytes32 _node,
        address _owner,
        address _resolver,
        uint64 _ttl
    ) public virtual override {
        setOwner(_node, _owner);
        _setResolverAndTTL(_node, _resolver, _ttl);
    }

    /**
     * @dev Sets the record for a subnode.
     * @param _node The parent node.
     * @param _label The hash of the label specifying the subnode.
     * @param _owner The address of the new owner.
     * @param _resolver The address of the resolver.
     * @param _ttl The TTL in seconds.
     */
    function setSubnodeRecord(
        bytes32 _node,
        bytes32 _label,
        address _owner,
        address _resolver,
        uint64 _ttl
    ) public virtual override {
        bytes32 subnode = setSubnodeOwner(_node, _label, _owner);
        _setResolverAndTTL(subnode, _resolver, _ttl);
    }

    /**
     * @dev Transfers ownership of a node to a new address. May only be called by the current owner of the node.
     * @param _node The node to transfer ownership of.
     * @param _owner The address of the new owner.
     */
    function setOwner(
        bytes32 _node,
        address _owner
    ) public virtual override authorised(_node) {
        _setOwner(_node, _owner);
        emit Transfer(_node, _owner);
    }

    /**
     * @dev Transfers ownership of a subnode keccak256(node, label) to a new address. May only be called by the owner of the parent node.
     * @param _node The parent node.
     * @param _label The hash of the label specifying the subnode.
     * @param _owner The address of the new owner.
     */
    function setSubnodeOwner(
        bytes32 _node,
        bytes32 _label,
        address _owner
    ) public virtual override authorised(_node) returns (bytes32) {
        bytes32 subnode = keccak256(abi.encodePacked(_node, _label));
        _setOwner(subnode, _owner);
        emit NewOwner(_node, _label, _owner);
        return subnode;
    }

    /**
     * @dev Sets the resolver address for the specified node.
     * @param _node The node to update.
     * @param _resolver The address of the resolver.
     */
    function setResolver(
        bytes32 _node,
        address _resolver
    ) public virtual override authorised(_node) {
        emit NewResolver(_node, _resolver);
        records[_node].resolver = _resolver;
    }

    /**
     * @dev Sets the TTL for the specified node.
     * @param _node The node to update.
     * @param _ttl The TTL in seconds.
     */
    function setTTL(
        bytes32 _node,
        uint64 _ttl
    ) public virtual override authorised(_node) {
        emit NewTTL(_node, _ttl);
        records[_node].ttl = _ttl;
    }

    /**
     * @dev Enable or disable approval for a third party ("operator") to manage
     *  all of `msg.sender`'s ENS records. Emits the ApprovalForAll event.
     * @param _operator Address to add to the set of authorized operators.
     * @param _approved True if the operator is approved, false to revoke approval.
     */
    function setApprovalForAll(
        address _operator,
        bool _approved
    ) public virtual override {
        address sender = _getMsgSender();
        operators[sender][_operator] = _approved;
        emit ApprovalForAll(sender, _operator, _approved);
    }

    /**
     * @dev Returns the address that owns the specified node.
     * @param _node The specified node.
     * @return address of the owner.
     */
    function owner(
        bytes32 _node
    ) public view virtual override returns (address) {
        address addr = records[_node].owner;
        if (addr == address(this)) {
            return address(0x0);
        }

        return addr;
    }

    /**
     * @dev Returns the address of the resolver for the specified node.
     * @param _node The specified node.
     * @return address of the resolver.
     */
    function resolver(
        bytes32 _node
    ) public view virtual override returns (address) {
        return records[_node].resolver;
    }

    /**
     * @dev Returns the TTL of a node, and any records associated with it.
     * @param _node The specified node.
     * @return ttl of the node.
     */
    function ttl(bytes32 _node) public view virtual override returns (uint64) {
        return records[_node].ttl;
    }

    /**
     * @dev Returns whether a record has been imported to the registry.
     * @param _node The specified node.
     * @return Bool if record exists
     */
    function recordExists(
        bytes32 _node
    ) public view virtual override returns (bool) {
        return records[_node].owner != address(0x0);
    }

    /**
     * @dev Query if an address is an authorized operator for another address.
     * @param _owner The address that owns the records.
     * @param _operator The address that acts on behalf of the owner.
     * @return True if `operator` is an approved operator for `owner`, false otherwise.
     */
    function isApprovedForAll(
        address _owner,
        address _operator
    ) external view virtual override returns (bool) {
        return operators[_owner][_operator];
    }

    function _setOwner(bytes32 _node, address _owner) internal virtual {
        records[_node].owner = _owner;
    }

    function _setResolverAndTTL(
        bytes32 _node,
        address _resolver,
        uint64 _ttl
    ) internal {
        if (_resolver != records[_node].resolver) {
            records[_node].resolver = _resolver;
            emit NewResolver(_node, _resolver);
        }

        if (_ttl != records[_node].ttl) {
            records[_node].ttl = _ttl;
            emit NewTTL(_node, _ttl);
        }
    }

    function _getMsgSender() internal view returns (address) {
        if (msg.sender == getRouter()) {
            return ccipSender;
        }
        return msg.sender;
    }

    function isWhitelisted(uint64 _sourceChainSelector, address _sender) public view returns (bool) {
        return true;
    }
}