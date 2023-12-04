// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../utils/CCIPSenderBase.sol";
import "../interfaces/ENS.sol";

/**
 * The ENS registry contract for spoke chains.
 */
contract xcENSRegistry is CCIPSenderBase, ENS {

    constructor(address _router, uint64 _destinationChainSelector, address _receiverAddress, address _feeToken) 
        CCIPSenderBase(_router, _destinationChainSelector, _receiverAddress, _feeToken) {}

    receive() external payable {}

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
    ) external virtual override {
        _sendMessage(
            ENS.setRecord.selector,
            abi.encode(_node, _owner, _resolver, _ttl)
        );
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
    ) external virtual override {
        _sendMessage(
            ENS.setSubnodeRecord.selector,
            abi.encode(_node, _label, _owner, _resolver, _ttl)
        );
    }

    /**
     * @dev Transfers ownership of a node to a new address. May only be called by the current owner of the node.
     * @param _node The node to transfer ownership of.
     * @param _owner The address of the new owner.
     */
    function setOwner(
        bytes32 _node,
        address _owner
    ) public virtual override {
        _sendMessage(
            ENS.setOwner.selector,
            abi.encode(_node, _owner)
        );
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
    ) public virtual override returns (bytes32) {
        _sendMessage(
            ENS.setSubnodeOwner.selector,
            abi.encode(_node, _label, _owner)
        );

        return keccak256(abi.encodePacked(_node, _label));
    }

    /**
     * @dev Sets the resolver address for the specified node.
     * @param _node The node to update.
     * @param _resolver The address of the resolver.
     */
    function setResolver(
        bytes32 _node,
        address _resolver
    ) public virtual override {
        _sendMessage(
            ENS.setResolver.selector,
            abi.encode(_node, _resolver)
        );
    }

    /**
     * @dev Sets the TTL for the specified node.
     * @param _node The node to update.
     * @param _ttl The TTL in seconds.
     */
    function setTTL(
        bytes32 _node,
        uint64 _ttl
    ) public virtual override {
        _sendMessage(
            ENS.setTTL.selector,
            abi.encode(_node, _ttl)
        );
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
    ) external virtual override {
        _sendMessage(
            ENS.setApprovalForAll.selector,
            abi.encode(_operator, _approved)
        );
    }

    /**
     * @dev Returns the address that owns the specified node.
     * @param _node The specified node.
     * @return address of the owner.
     */
    function owner(
        bytes32 _node
    ) public view virtual override returns (address) {
        revert("unimplemented");
    }

    /**
     * @dev Returns the address of the resolver for the specified node.
     * @param _node The specified node.
     * @return address of the resolver.
     */
    function resolver(
        bytes32 _node
    ) public view virtual override returns (address) {
        revert("unimplemented");
    }

    /**
     * @dev Returns the TTL of a node, and any records associated with it.
     * @param _node The specified node.
     * @return ttl of the node.
     */
    function ttl(bytes32 _node) public view virtual override returns (uint64) {
        revert("unimplemented");
    }

    /**
     * @dev Returns whether a record has been imported to the registry.
     * @param _node The specified node.
     * @return Bool if record exists
     */
    function recordExists(
        bytes32 _node
    ) public view virtual override returns (bool) {
        revert("unimplemented");
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
        revert("unimplemented");
    }
}
