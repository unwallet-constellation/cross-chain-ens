// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "./Helper.sol";

import {FIFSRegistrarCCIP} from "../src/hub/FIFSRegistrarCCIP.sol";
import {PublicResolverCCIP} from "../src/hub/PublicResolverCCIP.sol";
import {xcFIFSRegistrar} from "../src/spoke/xcFIFSRegistrar.sol";
import {xcPublicResolver} from "../src/spoke/xcPublicResolver.sol";

interface IRegistrar {
    function register(bytes32 label, address owner) external;
}

interface IResolver {
    function setAddr(bytes32 node, address a) external;
    function setAddr(bytes32 node, uint256 coinType, bytes memory a) external;
    function addr(bytes32 node) external view returns (address payable);
    function addr(bytes32 node, uint256 coinType) external view returns (bytes memory);
}

contract RegisterName is Script, Helper {
    modifier soloRun() virtual {
        _startBroadcast();
        _;
        _stopBroadcast();
    }

    function _startBroadcast() internal virtual {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(senderPrivateKey);
    }

    function _stopBroadcast() internal virtual {
        vm.stopBroadcast();
    }

    function register(address registrarAddr, string memory label, address owner) public soloRun {
        IRegistrar registrar = IRegistrar(registrarAddr);
        registrar.register(labelHash(label), owner);
    }

    function setAddr(address resolverAddr, bytes32 node, address addr) public soloRun {
        IResolver resolver = IResolver(resolverAddr);
        resolver.setAddr(node, addr);
    }

    function setAddr(address resolverAddr, bytes32 node, uint256 coinType, address addr) public soloRun {
        IResolver resolver = IResolver(resolverAddr);

        bytes memory addrBytes = addressToBytes(addr);
        resolver.setAddr(node, coinType, addrBytes);
    }

    function addr(address resolverAddr, bytes32 node) public view returns (address payable) {
        IResolver resolver = IResolver(resolverAddr);
        return resolver.addr(node);
    }

    function addr(address resolverAddr, bytes32 node, uint256 coinType) public view returns (address payable) {
        IResolver resolver = IResolver(resolverAddr);
        bytes memory addrBytes = resolver.addr(node, coinType);
        return bytesToAddress(addrBytes);
    }

    function bytesToAddress(bytes memory b) internal pure returns (address payable a) {
        require(b.length == 20);
        assembly {
            a := div(mload(add(b, 32)), exp(256, 12))
        }
    }

    function addressToBytes(address a) internal pure returns (bytes memory b) {
        b = new bytes(20);
        assembly {
            mstore(add(b, 32), mul(a, exp(256, 12)))
        }
    }
}
