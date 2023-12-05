// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Context.sol";
// import { CCIPReceiver } from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {CCIPReceiver} from "./CCIPReceiverPatch.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";

// todo: Make it Ownable so that whitelist feature could be implemented
abstract contract CCIPReceiverBase is Context, CCIPReceiver {
    address private ccipSender;

    struct CCIPPayload {
        address caller;
        bytes4 func;
        bytes params;
    }

    modifier authenticateCCIP(Client.Any2EVMMessage memory _any2EvmMessage) {
        uint64 sourceChainSelector = _any2EvmMessage.sourceChainSelector;
        address sender = abi.decode(_any2EvmMessage.sender, (address));

        require(isCCIPWhitelisted(sourceChainSelector, sender), "Not whitelisted");
        _;
    }

    constructor(address _router) CCIPReceiver(_router) {}

    function _ccipReceive(Client.Any2EVMMessage memory _any2EvmMessage)
        internal
        override
        authenticateCCIP(_any2EvmMessage)
    {
        CCIPPayload memory ccipPayload = abi.decode(_any2EvmMessage.data, (CCIPPayload));

        _setMsgSender(ccipPayload.caller);
        _executeFunction(ccipPayload.func, ccipPayload.params);
        // _postExecution();
    }

    function isCCIPWhitelisted(uint64 _sourceChainSelector, address sender) public view virtual returns (bool);

    function _executeFunction(bytes4 selector, bytes memory params) internal virtual;

    function _setMsgSender(address _addr) internal {
        ccipSender = _addr;
    }

    // function _postExecution() internal virtual {
    //     _setMsgSender(address(0));
    // }

    function _msgSender() internal view virtual override returns (address) {
        address sender = msg.sender; // super._msgSender()
        if (sender == getRouter()) {
            sender = ccipSender;
        }
        return sender;
    }
}
