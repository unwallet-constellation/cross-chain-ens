// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../utils/CCIPReceiverBase.sol";
import "./ens-original/ENSRegistry.sol";

/**
 * The CCIP enabled ENS registry contract for Hub side.
 */
contract ENSRegistryCCIP is ENSRegistry, CCIPReceiverBase {
    constructor(address _router) ENSRegistry() CCIPReceiverBase(_router) {}

    function _executeFunction(bytes4 func, bytes memory params) internal override {
        if (func == this.setRecord.selector) {
            (bytes32 node, address owner, address resolver, uint64 ttl) =
                abi.decode(params, (bytes32, address, address, uint64));
            setRecord(node, owner, resolver, ttl);
        } else if (func == this.setSubnodeRecord.selector) {
            (bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) =
                abi.decode(params, (bytes32, bytes32, address, address, uint64));
            setSubnodeRecord(node, label, owner, resolver, ttl);
        } else if (func == this.setOwner.selector) {
            (bytes32 node, address owner) = abi.decode(params, (bytes32, address));
            setOwner(node, owner);
        } else if (func == this.setSubnodeOwner.selector) {
            (bytes32 node, bytes32 label, address owner) = abi.decode(params, (bytes32, bytes32, address));
            setSubnodeOwner(node, label, owner);
        } else if (func == this.setResolver.selector) {
            (bytes32 node, address resolver) = abi.decode(params, (bytes32, address));
            setResolver(node, resolver);
        } else if (func == this.setTTL.selector) {
            (bytes32 node, uint64 ttl) = abi.decode(params, (bytes32, uint64));
            setTTL(node, ttl);
        } else if (func == this.setApprovalForAll.selector) {
            (address operator, bool approved) = abi.decode(params, (address, bool));
            setApprovalForAll(operator, approved);
        } else {
            revert("Unknown function selector");
        }
    }

    function _msgSender() internal view virtual override(Context, CCIPReceiverBase) returns (address) {
        return CCIPReceiverBase._msgSender();
    }

    function isCCIPWhitelisted(uint64 _sourceChainSelector, address sender) public pure override returns (bool) {
        return true;
    }
}
