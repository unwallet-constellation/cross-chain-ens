// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import "../utils/CCIPSenderBase.sol";
import "../interfaces/IReverseRegistrar.sol";

bytes32 constant lookup = 0x3031323334353637383961626364656600000000000000000000000000000000;
bytes32 constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;

// @task: Expose other functions as well (if required)
contract xcReverseRegistrar is CCIPSenderBase, IReverseRegistrar {

    constructor(address _router, uint64 _destinationChainSelector, address _receiverAddress, address _feeToken) 
        CCIPSenderBase(_router, _destinationChainSelector, _receiverAddress, _feeToken) {}

    receive() external payable {}

    function setDefaultResolver(address resolver) external {
        _sendMessage(
            this.setDefaultResolver.selector,
            abi.encode(resolver)
        );
    }

    function claim(address owner) external returns (bytes32) {
        _sendMessage(
            this.claim.selector,
            abi.encode(owner)
        );

        return node(msg.sender);
    }

    function claimForAddr(
        address addr,
        address owner,
        address resolver
    ) external returns (bytes32) {
        _sendMessage(
            this.claimForAddr.selector,
            abi.encode(addr, owner, resolver)
        );

        return node(addr);
    }

    function claimWithResolver(
        address owner,
        address resolver
    ) external returns (bytes32) {
        _sendMessage(
            this.claimWithResolver.selector,
            abi.encode(owner, resolver)
        );

        return node(msg.sender);
    }

    function setName(string memory name) external returns (bytes32) {
        _sendMessage(
            this.setName.selector,
            abi.encode(name)
        );

        return node(msg.sender);
    }

    function setNameForAddr(
        address addr,
        address owner,
        address resolver,
        string memory name
    ) external returns (bytes32) {
        _sendMessage(
            this.setNameForAddr.selector,
            abi.encode(addr, owner, resolver, name)
        );

        return node(addr);
    }

    function node(address addr) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(ADDR_REVERSE_NODE, sha3HexAddress(addr))
            );
    }

    /**
     * @dev An optimised function to compute the sha3 of the lower-case
     *      hexadecimal representation of an Ethereum address.
     * @param addr The address to hash
     * @return ret The SHA3 hash of the lower-case hexadecimal encoding of the
     *         input address.
     */
    function sha3HexAddress(address addr) private pure returns (bytes32 ret) {
        assembly {
            for {
                let i := 40
            } gt(i, 0) {

            } {
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
            }

            ret := keccak256(0, 40)
        }
    }
}
