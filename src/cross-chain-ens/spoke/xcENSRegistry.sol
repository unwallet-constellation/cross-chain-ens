// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import "../interfaces/ENS.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import { IRouterClient } from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import { Client } from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";

/**
 * The ENS registry contract.
 */
contract xcENSRegistry is ENS {
    IRouterClient public router;
    uint64 public destinationChainSelector;
    address public ensHub;
    address public feeToken;

    struct CCIPPayload {
        address caller;
        bytes4 func;
        bytes params;
    }

    // Event emitted when a message is sent to another chain.
    event MessageSent(
        bytes32 indexed messageId, // The unique ID of the message.
        uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
        address receiver, // The address of the receiver on the destination chain.
        CCIPPayload message, // The message being sent.
        uint256 fees // The fees paid for sending the message.
    );

    // Permits modifications only by the owner of the specified node.
    modifier authorised(bytes32 node) {
        // Check is done on the hub-chain
        _;
    }

    /**
     * @dev Constructs a new ENS registry.
     */
    constructor(address _router, address _feeToken, address _ensHub, uint64 _destinationChainSelector) {
        router = IRouterClient(_router);
        feeToken = _feeToken;
        ensHub = _ensHub;
        destinationChainSelector = _destinationChainSelector;
    }

    /**
     * @notice Sends data to receiver on the destination chain.
     * @dev Assumes your contract has sufficient native asset (e.g, ETH on Ethereum, MATIC on Polygon...).
     * @param message The string message to be sent.
     * @return messageId The ID of the message that was sent.
     */
    function sendMessage(
        CCIPPayload memory message
    ) internal returns (bytes32 messageId) {
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(ensHub), // ABI-encoded receiver address
            data: abi.encode(message), // ABI-encoded string message
            tokenAmounts: new Client.EVMTokenAmount[](0), // Empty array indicating no tokens are being sent
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 400_000, strict: false}) // Additional arguments, setting gas limit and non-strict sequency mode
            ),
            feeToken: feeToken // zero address indicates native asset will be used for fees
        });

        // Get the fee required to send the message
        uint256 fees = router.getFee(destinationChainSelector, evm2AnyMessage);
        uint256 native_fees = 0;

        if (feeToken == address(0)) {
            native_fees = fees;
        } else {
            LinkTokenInterface(feeToken).increaseApproval(address(router), fees);
        }

        messageId = router.ccipSend{value: native_fees}(
            destinationChainSelector,
            evm2AnyMessage
        );

        // Emit an event with message details
        emit MessageSent(
            messageId,
            destinationChainSelector,
            ensHub,
            message,
            fees
        );

        // Return the message ID
        return messageId;
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
    ) external virtual override {
        CCIPPayload memory message = CCIPPayload(
            msg.sender,
            ENS.setRecord.selector,
            abi.encode(_node, _owner, _resolver, _ttl)
        );

        sendMessage(message);
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
        CCIPPayload memory message = CCIPPayload(
            msg.sender,
            ENS.setSubnodeRecord.selector,
            abi.encode(_node, _label, _owner, _resolver, _ttl)
        );

        sendMessage(message);
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
        CCIPPayload memory message = CCIPPayload(
            msg.sender,
            ENS.setOwner.selector,
            abi.encode(_node, _owner)
        );

        sendMessage(message);
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
        CCIPPayload memory message = CCIPPayload(
            msg.sender,
            ENS.setSubnodeOwner.selector,
            abi.encode(_node, _label, _owner)
        );

        sendMessage(message);
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
    ) public virtual override authorised(_node) {
        CCIPPayload memory message = CCIPPayload(
            msg.sender,
            ENS.setResolver.selector,
            abi.encode(_node, _resolver)
        );

        sendMessage(message);
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
        CCIPPayload memory message = CCIPPayload(
            msg.sender,
            ENS.setTTL.selector,
            abi.encode(_node, _ttl)
        );

        sendMessage(message);
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
        CCIPPayload memory message = CCIPPayload(
            msg.sender,
            ENS.setApprovalForAll.selector,
            abi.encode(_operator, _approved)
        );

        sendMessage(message);
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

    receive() external payable {}
}