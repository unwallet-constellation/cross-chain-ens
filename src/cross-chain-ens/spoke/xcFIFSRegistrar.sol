// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import "../interfaces/ENS.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import { IRouterClient } from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import { Client } from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";

/**
 * A registrar that allocates subdomains to the first person to claim them.
 */
contract FIFSRegistrar {
    IRouterClient public router;
    uint64 public destinationChainSelector;
    address public registrarHub;
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

    constructor(address _router, address _feeToken, address _registrarHub, uint64 _destinationChainSelector) {
        router = IRouterClient(_router);
        feeToken = _feeToken;
        registrarHub = _registrarHub;
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
            receiver: abi.encode(registrarHub), // ABI-encoded receiver address
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
            registrarHub,
            message,
            fees
        );

        // Return the message ID
        return messageId;
    }

    /**
     * Register a name, or change the owner of an existing registration.
     * @param _label The hash of the label to register.
     * @param _owner The address of the new owner.
     */
    function register(bytes32 _label, address _owner) public {
        CCIPPayload memory message = CCIPPayload(
            msg.sender,
            this.register.selector,
            abi.encode(_label, _owner)
        );
    
        sendMessage(message);
    }
}