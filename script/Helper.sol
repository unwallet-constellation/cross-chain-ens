// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Helper {
    // Supported Networks
    enum SupportedNetworks {
        ETHEREUM_SEPOLIA,
        AVALANCHE_FUJI,
        POLYGON_MUMBAI,
        OPTIMISM_SEPOLIA,
        BASE_SEPOLIA
    }

    mapping(SupportedNetworks enumValue => string humanReadableName) public networks;

    mapping(SupportedNetworks enumValue => uint64 officialChainId) public chainIds;

    enum PayFeesIn {
        Native,
        LINK
    }

    // CCIP Chain IDs
    uint64 constant ccipChainIdEthereumSepolia = 16015286601757825753;
    uint64 constant ccipChainIdAvalancheFuji = 14767482510784806043;
    uint64 constant ccipChainIdPolygonMumbai = 12532609583862916517;
    uint64 constant ccipChainIdOptimismSepolia = 5224473277236331295;
    uint64 constant ccipChainIdBaseSepolia = 10344971235874465080;

    // Router addresses
    address constant routerEthereumSepolia = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
    address constant routerAvalancheFuji = 0x0477cA0a35eE05D3f9f424d88bC0977ceCf339D4;
    address constant routerPolygonMumbai = 0x81660Dc846f0528A7Ce003c1F7774d7c4135F344;
    address constant routerOptimismSepolia = 0x114A20A10b43D4115e5aeef7345a1A71d2a60C57;
    address constant routerBaseSepolia = 0xD3b06cEbF099CE7DA4AcCf578aaebFDBd6e88a93;

    // Link addresses (can be used as fee)
    address constant linkEthereumSepolia = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    address constant linkAvalancheFuji = 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846;
    address constant linkPolygonMumbai = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
    address constant linkOptimismSepolia = 0xE4aB69C077896252FAFBD49EFD26B5D171A32410;
    address constant linkBaseSepolia = 0xE4aB69C077896252FAFBD49EFD26B5D171A32410;

    // Wrapped native addresses
    address constant wethEthereumSepolia = 0x097D90c9d3E0B50Ca60e1ae45F6A81010f9FB534;
    address constant wavaxAvalancheFuji = 0xd00ae08403B9bbb9124bB305C09058E32C39A48c;
    address constant wmaticPolygonMumbai = 0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889;
    address constant wethOptimismSepolia = 0x4200000000000000000000000000000000000006;
    address constant wethBaseSepolia = 0x4200000000000000000000000000000000000006;

    // CCIP-BnM addresses
    address constant ccipBnMEthereumSepolia = 0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05;
    address constant ccipBnMAvalancheFuji = 0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4;
    address constant ccipBnMPolygonMumbai = 0xf1E3A5842EeEF51F2967b3F05D45DD4f4205FF40;
    address constant ccipBnMOptimismSepolia = 0x8aF4204e30565DF93352fE8E1De78925F6664dA7;
    address constant ccipBnMBaseSepolia = 0x88A2d74F47a237a62e7A51cdDa67270CE381555e;

    // CCIP-LnM addresses
    address constant ccipLnMEthereumSepolia = 0x466D489b6d36E7E3b824ef491C225F5830E81cC1;
    address constant clCcipLnMAvalancheFuji = 0x70F5c5C40b873EA597776DA2C21929A8282A3b35;
    address constant clCcipLnMPolygonMumbai = 0xc1c76a8c5bFDE1Be034bbcD930c668726E7C1987;
    address constant clCcipLnMOptimismSepolia = 0x044a6B4b561af69D2319A2f4be5Ec327a6975D0a;
    address constant clCcipLnMBaseSepolia = 0xA98FA8A008371b9408195e52734b1768c0d1Cb5c;

    constructor() {
        // Assigning humanReadableName's
        networks[SupportedNetworks.ETHEREUM_SEPOLIA] = "Ethereum Sepolia";
        networks[SupportedNetworks.AVALANCHE_FUJI] = "Avalanche Fuji";
        networks[SupportedNetworks.POLYGON_MUMBAI] = "Polygon Mumbai";
        networks[SupportedNetworks.OPTIMISM_SEPOLIA] = "Optimism Sepolia";
        networks[SupportedNetworks.BASE_SEPOLIA] = "Base Sepolia";

        // Assigning officialChainId's
        chainIds[SupportedNetworks.ETHEREUM_SEPOLIA] = 11155111;
        chainIds[SupportedNetworks.AVALANCHE_FUJI] = 43113;
        chainIds[SupportedNetworks.POLYGON_MUMBAI] = 80001;
        chainIds[SupportedNetworks.OPTIMISM_SEPOLIA] = 11155420;
        chainIds[SupportedNetworks.BASE_SEPOLIA] = 84532;
    }

    function getDummyTokensFromNetwork(uint64 officialChainId) internal returns (address ccipBnM, address ccipLnM) {
        if (officialChainId == chainIds[SupportedNetworks.ETHEREUM_SEPOLIA]) {
            return (ccipBnMEthereumSepolia, ccipLnMEthereumSepolia);
        } else if (officialChainId == chainIds[SupportedNetworks.AVALANCHE_FUJI]) {
            return (ccipBnMAvalancheFuji, clCcipLnMAvalancheFuji);
        } else if (officialChainId == chainIds[SupportedNetworks.POLYGON_MUMBAI]) {
            return (ccipBnMPolygonMumbai, clCcipLnMPolygonMumbai);
        } else if (officialChainId == chainIds[SupportedNetworks.OPTIMISM_SEPOLIA]) {
            return (ccipBnMOptimismSepolia, clCcipLnMOptimismSepolia);
        } else if (officialChainId == chainIds[SupportedNetworks.BASE_SEPOLIA]) {
            return (ccipBnMBaseSepolia, clCcipLnMBaseSepolia);
        }
    }

    function getConfigFromNetwork(uint64 officialChainId)
        internal
        returns (address router, address linkToken, address wrappedNative, uint64 chainId)
    {
        if (officialChainId == chainIds[SupportedNetworks.ETHEREUM_SEPOLIA]) {
            return (routerEthereumSepolia, linkEthereumSepolia, wethEthereumSepolia, ccipChainIdEthereumSepolia);
        } else if (officialChainId == chainIds[SupportedNetworks.AVALANCHE_FUJI]) {
            return (routerAvalancheFuji, linkAvalancheFuji, wavaxAvalancheFuji, ccipChainIdAvalancheFuji);
        } else if (officialChainId == chainIds[SupportedNetworks.POLYGON_MUMBAI]) {
            return (routerPolygonMumbai, linkPolygonMumbai, wmaticPolygonMumbai, ccipChainIdPolygonMumbai);
        } else if (officialChainId == chainIds[SupportedNetworks.OPTIMISM_SEPOLIA]) {
            return (routerOptimismSepolia, linkOptimismSepolia, wethOptimismSepolia, ccipChainIdOptimismSepolia);
        } else if (officialChainId == chainIds[SupportedNetworks.BASE_SEPOLIA]) {
            return (routerBaseSepolia, linkBaseSepolia, wethBaseSepolia, ccipChainIdBaseSepolia);
        }
    }

    function labelHash(string memory label) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(label));
    }

    function namehash(string memory label) public pure returns (bytes32) {
        return namehash(0x00, label);
    }

    function namehash(bytes32 node, string memory label) public pure returns (bytes32) {
        return namehash(node, labelHash(label));
    }

    function namehash(bytes32 node, bytes32 labelhash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(node, labelhash));
    }
}
