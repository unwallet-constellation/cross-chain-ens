// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import "../utils/CCIPReceiverBase.sol";
import "./ens-original/FIFSRegistrar.sol";

/**
 * The CCIP enabled ENS registry contract for Hub side.
 */
contract FIFSRegistrarCCIP is FIFSRegistrar, CCIPReceiverBase {
    constructor(ENS ensAddr, bytes32 node, address _router) FIFSRegistrar(ensAddr, node) CCIPReceiverBase(_router) {}

    function _executeFunction(bytes4 func, bytes memory params) internal override {
        if (func == this.register.selector) {
            (bytes32 label, address owner) = abi.decode(params, (bytes32, address));
            register(label, owner);
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
