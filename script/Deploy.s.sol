// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "./Helper.sol";
import {ENSRegistryCCIP} from "../src/hub/ENSRegistryCCIP.sol";
import {FIFSRegistrarCCIP} from "../src/hub/FIFSRegistrarCCIP.sol";
import {ReverseRegistrarCCIP} from "../src/hub/ReverseRegistrarCCIP.sol";
import {PublicResolverCCIP} from "../src/hub/PublicResolverCCIP.sol";
import {xcENSRegistry} from "../src/spoke/xcENSRegistry.sol";
import {xcFIFSRegistrar} from "../src/spoke/xcFIFSRegistrar.sol";
import {xcReverseRegistrar} from "../src/spoke/xcReverseRegistrar.sol";
import {xcPublicResolver} from "../src/spoke/xcPublicResolver.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

contract DeployHub is Script, Helper {
    address internal senderPublicKey;

    function deploy_ENSRegistryCCIP(address router) internal returns (ENSRegistryCCIP registry) {
        registry = new ENSRegistryCCIP(router);
        console.log("ENSRegistryCCIP deployed with address: ", address(registry));
    }

    function deploy_FIFSRegistrarCCIP(ENSRegistryCCIP registry, bytes32 labelhash, address router)
        internal
        returns (FIFSRegistrarCCIP registrar)
    {
        registrar = new FIFSRegistrarCCIP(registry, labelhash, router);

        registry.setSubnodeOwner(0x00, labelhash, address(registrar));

        console.log("FIFSRegistrarCCIP deployed with address: ", address(registrar));
    }

    function deploy_ReverseRegistrarCCIP(ENSRegistryCCIP registry, address router)
        internal
        returns (ReverseRegistrarCCIP reverseRegistrar)
    {
        reverseRegistrar = new ReverseRegistrarCCIP(registry, router);

        registry.setSubnodeOwner(0x00, labelHash("reverse"), senderPublicKey);
        registry.setSubnodeOwner(namehash("reverse"), labelHash("addr"), address(reverseRegistrar));

        console.log("ReverseRegistrarCCIP deployed with address: ", address(reverseRegistrar));
    }

    function deploy_PublicResolverCCIP(
        uint256 coinType,
        ENSRegistryCCIP ensAddr,
        address trustedController,
        address trustedReverseRegistrar,
        address router
    ) internal returns (PublicResolverCCIP resolver) {
        resolver = new PublicResolverCCIP(coinType, ensAddr, trustedController, trustedReverseRegistrar, router);

        console.log("PublicResolverCCIP deployed with address: ", address(resolver));
    }

    function run(uint64 destination) external {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        senderPublicKey = vm.addr(senderPrivateKey);

        vm.startBroadcast(senderPrivateKey);

        (address router,,,) = getConfigFromNetwork(destination);
        console.log("Deploying contracts on hub chain: ", destination);

        string memory tld = "unwallet";

        ENSRegistryCCIP registry = deploy_ENSRegistryCCIP(router);
        // solhint-disable-next-line no-unused-vars
        FIFSRegistrarCCIP registrar = deploy_FIFSRegistrarCCIP(registry, labelHash(tld), router);
        ReverseRegistrarCCIP reverseRegistrar = deploy_ReverseRegistrarCCIP(registry, router);
        // solhint-disable-next-line no-unused-vars
        PublicResolverCCIP resolver =
            deploy_PublicResolverCCIP(60, registry, senderPublicKey, address(reverseRegistrar), router);

        vm.stopBroadcast();
    }
}

contract DeploySpoke is Script, Helper {
    address internal router;
    uint64 internal hubChainSelector;
    address internal linkToken;
    uint256 internal fundValue;

    function fundAddress(address addr, uint256 value) public {
        LinkTokenInterface(linkToken).transfer(addr, value);
    }

    function deploy_ENSRegistry(address registryHub) public returns (xcENSRegistry registry) {
        registry = new xcENSRegistry(router, hubChainSelector, registryHub, linkToken);

        console.log("xcENSRegistry deployed with address: ", address(registry));

        fundAddress(address(registry), fundValue);
    }

    function deploy_FIFSRegistrar(address registrarHub) public returns (xcFIFSRegistrar registrar) {
        registrar = new xcFIFSRegistrar(router, hubChainSelector, registrarHub, linkToken);

        console.log("xcFIFSRegistrar deployed with address: ", address(registrar));

        fundAddress(address(registrar), fundValue);
    }

    function deploy_ReverseRegistrar(address reverseRegistarHub) public returns (xcReverseRegistrar reverseRegistar) {
        reverseRegistar = new xcReverseRegistrar(router, hubChainSelector, reverseRegistarHub, linkToken);

        console.log("xcReverseRegistrar deployed with address: ", address(reverseRegistar));

        fundAddress(address(reverseRegistar), fundValue);
    }

    function deploy_PublicResolver(address publicResolverHub, uint256 coinType)
        public
        returns (xcPublicResolver publicResolver)
    {
        publicResolver = new xcPublicResolver(coinType, router, hubChainSelector, publicResolverHub, linkToken);

        console.log("xcPublicResolver deployed with address: ", address(publicResolver));

        fundAddress(address(publicResolver), fundValue);
    }

    function run(uint64 destination, uint64 hub) external {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        fundValue = 1 ether; // vm.envOr("SPOKE_FUND_VALUE", 1 ether);

        vm.startBroadcast(senderPrivateKey);

        (router, linkToken,,) = getConfigFromNetwork(destination);
        console.log("Deploying contracts on spoke chain: ", destination);

        (,,, hubChainSelector) = getConfigFromNetwork(hub);

        address registryHub = vm.envAddress("ENSRegistryCCIP");
        console.log("Using ENSRegistryCCIP: ", registryHub);
        // solhint-disable-next-line no-unused-vars
        xcENSRegistry registry = deploy_ENSRegistry(registryHub);

        address registrarHub = vm.envAddress("FIFSRegistrarCCIP");
        console.log("Using FIFSRegistrarCCIP: ", registrarHub);
        // solhint-disable-next-line no-unused-vars
        xcFIFSRegistrar registrar = deploy_FIFSRegistrar(registrarHub);

        address reverseRegistarHub = vm.envAddress("ReverseRegistrarCCIP");
        console.log("Using ReverseRegistrarCCIP: ", reverseRegistarHub);
        // solhint-disable-next-line no-unused-vars
        xcReverseRegistrar reverseRegistrar = deploy_ReverseRegistrar(reverseRegistarHub);

        address publicResolverHub = vm.envAddress("PublicResolverCCIP");
        console.log("Using PublicResolverCCIP: ", publicResolverHub);
        uint256 coinType = 1; // vm.envOr("SPOKE_RESOLVER_COIN_TYPE", 1);
        // solhint-disable-next-line no-unused-vars
        xcPublicResolver resolver = deploy_PublicResolver(publicResolverHub, coinType);

        vm.stopBroadcast();
    }
}
