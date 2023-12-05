// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import "@openzeppelin/contracts/utils/Context.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

abstract contract CCIPSenderBase is Context {
    IRouterClient public router;
    uint64 public destinationChainSelector;
    address public receiverAddress;
    address public feeToken;

    struct CCIPPayload {
        address caller;
        bytes4 func;
        bytes params;
    }

    // Event emitted when a message is sent to another chain.
    event MessageSent( // The unique ID of the message.
        // The chain selector of the destination chain.
        // The address of the receiver on the destination chain.
        // The message being sent.
        // The fees paid for sending the message.
        bytes32 indexed messageId,
        uint64 indexed destinationChainSelector,
        address receiver,
        CCIPPayload message,
        uint256 fees
    );

    constructor(address _router, uint64 _destinationChainSelector, address _receiverAddress, address _feeToken) {
        router = IRouterClient(_router);
        destinationChainSelector = _destinationChainSelector;
        receiverAddress = _receiverAddress;
        feeToken = _feeToken;
    }

    function _sendMessage(bytes4 _funcSelector, bytes memory _params) internal returns (bytes32 messageId) {
        return _sendMessage(_funcSelector, _params, _defaultGasLimit());
    }

    function _sendMessage(bytes4 _funcSelector, bytes memory _params, uint256 _gasLimit)
        internal
        returns (bytes32 messageId)
    {
        CCIPPayload memory ccipPayload = CCIPPayload(_msgSender(), _funcSelector, _params);

        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(receiverAddress),
            data: abi.encode(ccipPayload),
            tokenAmounts: new Client.EVMTokenAmount[](0), // Empty array indicating no tokens are being sent
            extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: _gasLimit, strict: false})),
            feeToken: feeToken // zero address indicates native asset will be used for fees
        });

        // Get the fee required to send the message
        uint256 fees = router.getFee(destinationChainSelector, evm2AnyMessage);
        uint256 nativeFees = 0;

        if (feeToken == address(0)) {
            nativeFees = fees;
        } else {
            LinkTokenInterface(feeToken).increaseApproval(address(router), fees);
        }

        messageId = router.ccipSend{value: nativeFees}(destinationChainSelector, evm2AnyMessage);

        // Emit an event with message details
        emit MessageSent(messageId, destinationChainSelector, receiverAddress, ccipPayload, fees);

        // Return the message ID
        return messageId;
    }

    function _setRouter(address _newRouter) internal {
        router = IRouterClient(_newRouter);
    }

    function _setDestinationChainSelector(uint64 _destinationChainSelector) internal {
        destinationChainSelector = _destinationChainSelector;
    }

    function _setReceiverAddress(address _receiverAddress) internal {
        receiverAddress = _receiverAddress;
    }

    function _defaultGasLimit() internal view virtual returns (uint256) {
        return 400_000;
    }
}
