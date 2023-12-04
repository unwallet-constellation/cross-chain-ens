// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "./Helper.sol";
import {ENSRegistryCCIP} from "../src/hub/ENSRegistryCCIP.sol";
import {FIFSRegistrarCCIP} from "../src/hub/FIFSRegistrarCCIP.sol";
import {ReverseRegistrarCCIP} from "../src/hub/ReverseRegistrarCCIP.sol";
import {PublicResolverCCIP} from "../src/hub/PublicResolverCCIP.sol";

contract DeployHub is Script, Helper {
    address senderPublicKey;

    function labelHash(string memory label) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(label));
    }

    function namehash(string memory label) internal pure returns (bytes32) {
        return namehash(0x00, label);
    }

    function namehash(bytes32 node, string memory label) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(node, labelHash(label)));
    }

    function deploy_ENSRegistryCCIP(address router) internal returns(ENSRegistryCCIP registry) {
        registry = new ENSRegistryCCIP(router);
        console.log(
            "ENSRegistryCCIP deployed with address: ",
            address(registry)
        );
    }

    function deploy_FIFSRegistrarCCIP(
        ENSRegistryCCIP registry, 
        bytes32 labelhash, 
        address router
    ) internal returns(FIFSRegistrarCCIP registrar) {
        registrar = new FIFSRegistrarCCIP(
            registry,
            labelhash,
            router
        );

        registry.setSubnodeOwner(0x00, labelhash, address(registrar));

        console.log(
            "FIFSRegistrarCCIP deployed with address: ",
            address(registrar)
        );
    }

    function deploy_ReverseRegistrarCCIP(
        ENSRegistryCCIP registry,
        address router 
    ) internal returns (ReverseRegistrarCCIP reverseRegistrar) {
        reverseRegistrar = new ReverseRegistrarCCIP(
            registry,
            router
        );

        registry.setSubnodeOwner(0x00, labelHash("reverse"), senderPublicKey);
        registry.setSubnodeOwner(
            namehash("reverse"), 
            labelHash("addr"), 
            address(reverseRegistrar)
        );

        console.log(
            "ReverseRegistrarCCIP deployed with address: ",
            address(reverseRegistrar)
        );
    }

    function deploy_PublicResolverCCIP(
        uint256 coinType,
        ENSRegistryCCIP ensAddr, 
        address trustedController,
        address trustedReverseRegistrar,
        address router
    ) internal returns (PublicResolverCCIP resolver) {
        resolver = new PublicResolverCCIP(
            coinType,
            ensAddr, 
            trustedController,
            trustedReverseRegistrar,
            router
        );

        console.log(
            "PublicResolverCCIP deployed with address: ",
            address(resolver)
        );
    }

    function run(SupportedNetworks destination) external {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        senderPublicKey = vm.addr(senderPrivateKey);

        vm.startBroadcast(senderPrivateKey);

        (address router, , , ) = getConfigFromNetwork(destination);
        console.log(
            "Deploying contracts on hub chain: ",
            networks[destination]
        );

        string memory tld = "eth";
        
        ENSRegistryCCIP registry = deploy_ENSRegistryCCIP(router);
        FIFSRegistrarCCIP registrar = deploy_FIFSRegistrarCCIP(registry, labelHash(tld), router);
        ReverseRegistrarCCIP reverseRegistrar = deploy_ReverseRegistrarCCIP(registry, router);
        PublicResolverCCIP resolver = deploy_PublicResolverCCIP(60, registry, senderPublicKey, address(reverseRegistrar), router);

        vm.stopBroadcast();
    }
}

contract DeploySpoke is Script, Helper {
    function run(SupportedNetworks destination) external {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(senderPrivateKey);

        (address router, , , ) = getConfigFromNetwork(destination);
        console.log(
            "Deploying contracts on spoke chain: ",
            networks[destination]
        );

        // TODO @realnimish

        vm.stopBroadcast();
    }
}
