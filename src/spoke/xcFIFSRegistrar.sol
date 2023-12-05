// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../utils/CCIPSenderBase.sol";

contract xcFIFSRegistrar is CCIPSenderBase {
    constructor(address _router, uint64 _destinationChainSelector, address _receiverAddress, address _feeToken)
        CCIPSenderBase(_router, _destinationChainSelector, _receiverAddress, _feeToken)
    {}

    receive() external payable {}

    /**
     * Register a name, or change the owner of an existing registration.
     * @param _label The hash of the label to register.
     * @param _owner The address of the new owner.
     */
    function register(bytes32 _label, address _owner) public {
        _sendMessage(this.register.selector, abi.encode(_label, _owner));
    }
}
