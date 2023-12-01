// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import "forge-std/Script.sol";
import "./Helper.sol";
import {ENSRegistryCCIP} from "../src/hub/ENSRegistryCCIP.sol";
import {FIFSRegistrarCCIP} from "../src/hub/FIFSRegistrarCCIP.sol";
import {ReverseRegistrarCCIP} from "../src/hub/ReverseRegistrarCCIP.sol";

contract DeployHub is Script, Helper {
    function run(SupportedNetworks destination) external {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(senderPrivateKey);

        (address router, , , ) = getConfigFromNetwork(destination);
        console.log(
            "Deploying contracts on hub chain: ",
            networks[destination]
        );

        // ENSRegistryCCIP
        ENSRegistryCCIP registry = new ENSRegistryCCIP(router);
        console.log(
            "ENSRegistryCCIP deployed with address: ",
            address(registry)
        );

        // FIFSRegistrarCCIP
        FIFSRegistrarCCIP registrar = new FIFSRegistrarCCIP(
            registry,
            bytes32(0x00),
            router
        );
        console.log(
            "FIFSRegistrarCCIP deployed with address: ",
            address(registrar)
        );

        // ReverseRegistrarCCIP
        ReverseRegistrarCCIP reverseRegistrar = new ReverseRegistrarCCIP(
            registry,
            router
        );
        console.log(
            "ReverseRegistrarCCIP deployed with address: ",
            address(reverseRegistrar)
        );

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
