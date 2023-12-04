// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "./Helper.sol";
import {ENSRegistryCCIP} from "../src/hub/ENSRegistryCCIP.sol";
import {FIFSRegistrarCCIP} from "../src/hub/FIFSRegistrarCCIP.sol";
import {ReverseRegistrarCCIP} from "../src/hub/ReverseRegistrarCCIP.sol";

contract DeployHub is Script, Helper {

    function deploy_ENSRegistryCCIP(address router) internal returns(ENSRegistryCCIP registry) {
        registry = new ENSRegistryCCIP(router);
        console.log(
            "ENSRegistryCCIP deployed with address: ",
            address(registry)
        );
    }

    function deploy_FIFSRegistrarCCIP(
        ENSRegistryCCIP registry, 
        bytes32 node, 
        address router
    ) internal returns(FIFSRegistrarCCIP registrar) {
        registrar = new FIFSRegistrarCCIP(
            registry,
            node,
            router
        );
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
        console.log(
            "ReverseRegistrarCCIP deployed with address: ",
            address(reverseRegistrar)
        );
    }

    function run(SupportedNetworks destination) external {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(senderPrivateKey);

        (address router, , , ) = getConfigFromNetwork(destination);
        console.log(
            "Deploying contracts on hub chain: ",
            networks[destination]
        );

        ENSRegistryCCIP registry = deploy_ENSRegistryCCIP(router);
        FIFSRegistrarCCIP registrar = deploy_FIFSRegistrarCCIP(registry, 0x00, router);
        ReverseRegistrarCCIP reverseRegistrar = deploy_ReverseRegistrarCCIP(registry, router);

        // PublicResolverCCIP
        // TODO @realnimish

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
