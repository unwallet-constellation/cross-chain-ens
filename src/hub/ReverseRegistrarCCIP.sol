// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../utils/CCIPReceiverBase.sol";
import "./ens-original/ReverseRegistrar.sol";

/**
 * The CCIP enabled ENS reverse registrar contract for Hub side.
 */
contract ReverseRegistrarCCIP is ReverseRegistrar, CCIPReceiverBase {
    constructor(ENS ensAddr, address _router) ReverseRegistrar(ensAddr) CCIPReceiverBase(_router) {}

    function _executeFunction(bytes4 func, bytes memory params) internal override {
        if (func == this.claim.selector) {
            address owner = abi.decode(params, (address));
            claim(owner);
        } else if(func == this.claimForAddr.selector) {
            (address addr, address owner, address resolver) = abi.decode(params, (address, address, address));
            claimForAddr(addr, owner, resolver);
        } else if(func == this.claimWithResolver.selector) {
            (address owner, address resolver) = abi.decode(params, (address, address));
            claimWithResolver(owner, resolver);
        } else if(func == this.renounceOwnership.selector) {
            renounceOwnership();
        } else if(func == this.setController.selector) {
            (address controller, bool enabled) = abi.decode(params, (address, bool));
            setController(controller, enabled);
        } else if(func == this.setDefaultResolver.selector) {
            address resolver = abi.decode(params, (address));
            setDefaultResolver(resolver);
        } else if(func == this.setName.selector) {
            string memory name = abi.decode(params, (string));
            setName(name);
        } else if(func == this.setNameForAddr.selector) {
            (address addr, address owner, address resolver, string memory name) = abi.decode(params, (address, address, address, string));
            setNameForAddr(addr, owner, resolver, name);
        } else if(func == this.transferOwnership.selector) {
            address newOwner = abi.decode(params, (address));
            transferOwnership(newOwner);
        } else {
            revert("Unknown function selector");
        }
    }

    function _msgSender() internal view virtual override(Context, CCIPReceiverBase) returns (address) {
        return CCIPReceiverBase._msgSender();
    }

    function isCCIPWhitelisted(uint64 sourceChainSelector, address sender) public pure override returns (bool) {
        return true;
    }
}
