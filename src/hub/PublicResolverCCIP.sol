// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../utils/CCIPReceiverBase.sol";
import "./ens-original/PublicResolver.sol";

/**
 * The CCIP enabled ENS PublicResolver contract for Hub side.
 */
contract PublicResolverCCIP is PublicResolver, CCIPReceiverBase {
    constructor(
        uint256 coinType,
        ENS ensAddr,
        address trustedController,
        address trustedReverseRegistrar,
        address router
    )
        AddrResolver(coinType)
        PublicResolver(ensAddr, trustedController, trustedReverseRegistrar)
        CCIPReceiverBase(router)
    {}

    function _executeFunction(bytes4 func, bytes memory params) internal override {
        if (func == bytes4(keccak256("setAddr(bytes32,uint256,bytes)"))) {
            // https://github.com/ethereum/solidity/issues/3556
            (bytes32 node, uint256 coinType, bytes memory a) = abi.decode(params, (bytes32, uint256, bytes));
            setAddr(node, coinType, a);
        } else if (func == this.setName.selector) {
            (bytes32 node, string memory newName) = abi.decode(params, (bytes32, string));
            setName(node, newName);
        } else if (func == this.setInterface.selector) {
            (bytes32 node, bytes4 interfaceId, address implementer) = abi.decode(params, (bytes32, bytes4, address));
            setInterface(node, interfaceId, implementer);
        } else if (func == this.approve.selector) {
            (bytes32 node, address delegate, bool approved) = abi.decode(params, (bytes32, address, bool));
            approve(node, delegate, approved);
        } else if (func == this.setApprovalForAll.selector) {
            (address operator, bool approved) = abi.decode(params, (address, bool));
            setApprovalForAll(operator, approved);
        } else if (func == this.clearRecords.selector) {
            bytes32 node = abi.decode(params, (bytes32));
            clearRecords(node);
        } else if (func == this.multicall.selector) {
            // @dev: Non-trivial conversion required from calldata to memory
            // bytes[] memory data = abi.decode(params, (bytes[]));
            // multicall(data);
            revert("Not supported at the moment");
        } else if (func == this.multicallWithNodeCheck.selector) {
            // @dev: Non-trivial conversion required from calldata to memory
            // (bytes32 nodehash, bytes[] memory data) = abi.decode(params, (bytes32, bytes[]));
            // multicallWithNodeCheck(nodehash, data);
            revert("Not supported at the moment");
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

    function supportsInterface(bytes4 interfaceId) public view override(CCIPReceiver, PublicResolver) returns (bool) {
        return CCIPReceiver.supportsInterface(interfaceId) || PublicResolver.supportsInterface(interfaceId);
    }
}
