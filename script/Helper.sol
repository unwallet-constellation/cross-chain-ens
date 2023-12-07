// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Helper {
    // Supported Networks
    enum SupportedNetworks {
        ETHEREUM_SEPOLIA,
        AVALANCHE_FUJI,
        ARBITRUM_GOERLI,
        POLYGON_MUMBAI,
        OPTIMISM_GOERLI,
        BASE_GOERLI
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
    uint64 constant ccipChainIdArbitrumTestnet = 6101244977088475029;
    uint64 constant ccipChainIdPolygonMumbai = 12532609583862916517;
    uint64 constant ccipChainIdOptimismGoerli = 2664363617261496610;
    uint64 constant ccipChainIdBaseGoerli = 5790810961207155433;

    // Router addresses
    address constant routerEthereumSepolia = 0xD0daae2231E9CB96b94C8512223533293C3693Bf;
    address constant routerAvalancheFuji = 0x554472a2720E5E7D5D3C817529aBA05EEd5F82D8;
    address constant routerArbitrumTestnet = 0x88E492127709447A5ABEFdaB8788a15B4567589E;
    address constant routerPolygonMumbai = 0x70499c328e1E2a3c41108bd3730F6670a44595D1;
    address constant routerOptimismGoerli = 0xEB52E9Ae4A9Fb37172978642d4C141ef53876f26;
    address constant routerBaseGoerli = 0xA8C0c11bf64AF62CDCA6f93D3769B88BdD7cb93D;

    // Link addresses (can be used as fee)
    address constant linkEthereumSepolia = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    address constant linkAvalancheFuji = 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846;
    address constant linkArbitrumTestnet = 0xd14838A68E8AFBAdE5efb411d5871ea0011AFd28;
    address constant linkPolygonMumbai = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
    address constant linkOptimismGoerli = 0xdc2CC710e42857672E7907CF474a69B63B93089f;
    address constant linkBaseGoerli = 0x6D0F8D488B669aa9BA2D0f0b7B75a88bf5051CD3;

    // Wrapped native addresses
    address constant wethEthereumSepolia = 0x097D90c9d3E0B50Ca60e1ae45F6A81010f9FB534;
    address constant wavaxAvalancheFuji = 0xd00ae08403B9bbb9124bB305C09058E32C39A48c;
    address constant wethArbitrumTestnet = 0x32d5D5978905d9c6c2D4C417F0E06Fe768a4FB5a;
    address constant wmaticPolygonMumbai = 0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889;
    address constant wethOptimismGoerli = 0x4200000000000000000000000000000000000006;
    address constant wethBaseGoerli = 0x4200000000000000000000000000000000000006;

    // CCIP-BnM addresses
    address constant ccipBnMEthereumSepolia = 0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05;
    address constant ccipBnMArbitrumTestnet = 0x0579b4c1C8AcbfF13c6253f1B10d66896Bf399Ef;
    address constant ccipBnMAvalancheFuji = 0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4;
    address constant ccipBnMPolygonMumbai = 0xf1E3A5842EeEF51F2967b3F05D45DD4f4205FF40;
    address constant ccipBnMOptimismGoerli = 0xaBfE9D11A2f1D61990D1d253EC98B5Da00304F16;
    address constant ccipBnMBaseGoerli = 0xbf9036529123DE264bFA0FC7362fE25B650D4B16;

    // CCIP-LnM addresses
    address constant ccipLnMEthereumSepolia = 0x466D489b6d36E7E3b824ef491C225F5830E81cC1;
    address constant clCcipLnMArbitrumTestnet = 0x0E14dBe2c8e1121902208be173A3fb91Bb125CDB;
    address constant clCcipLnMAvalancheFuji = 0x70F5c5C40b873EA597776DA2C21929A8282A3b35;
    address constant clCcipLnMPolygonMumbai = 0xc1c76a8c5bFDE1Be034bbcD930c668726E7C1987;
    address constant clCcipLnMOptimismGoerli = 0x835833d556299CdEC623e7980e7369145b037591;
    address constant clCcipLnMBaseGoerli = 0x73ed16c1a61b098fd6924CCE5cC6a9A30348D944;

    constructor() {
        // Assigning humanReadableName's
        networks[SupportedNetworks.ETHEREUM_SEPOLIA] = "Ethereum Sepolia";
        networks[SupportedNetworks.AVALANCHE_FUJI] = "Avalanche Fuji";
        networks[SupportedNetworks.ARBITRUM_GOERLI] = "Arbitrum Goerli";
        networks[SupportedNetworks.POLYGON_MUMBAI] = "Polygon Mumbai";
        networks[SupportedNetworks.OPTIMISM_GOERLI] = "Optimism Goerli";
        networks[SupportedNetworks.BASE_GOERLI] = "Base Goerli";

        // Assigning officialChainId's
        chainIds[SupportedNetworks.ETHEREUM_SEPOLIA] = 11155111;
        chainIds[SupportedNetworks.AVALANCHE_FUJI] = 43113;
        chainIds[SupportedNetworks.ARBITRUM_GOERLI] = 421613;
        chainIds[SupportedNetworks.POLYGON_MUMBAI] = 80001;
        chainIds[SupportedNetworks.OPTIMISM_GOERLI] = 420;
        chainIds[SupportedNetworks.BASE_GOERLI] = 84531;
    }

    function getDummyTokensFromNetwork(uint64 officialChainId) internal returns (address ccipBnM, address ccipLnM) {
        if (officialChainId == chainIds[SupportedNetworks.ETHEREUM_SEPOLIA]) {
            return (ccipBnMEthereumSepolia, ccipLnMEthereumSepolia);
        } else if (officialChainId == chainIds[SupportedNetworks.ARBITRUM_GOERLI]) {
            return (ccipBnMArbitrumTestnet, clCcipLnMArbitrumTestnet);
        } else if (officialChainId == chainIds[SupportedNetworks.AVALANCHE_FUJI]) {
            return (ccipBnMAvalancheFuji, clCcipLnMAvalancheFuji);
        } else if (officialChainId == chainIds[SupportedNetworks.POLYGON_MUMBAI]) {
            return (ccipBnMPolygonMumbai, clCcipLnMPolygonMumbai);
        } else if (officialChainId == chainIds[SupportedNetworks.OPTIMISM_GOERLI]) {
            return (ccipBnMOptimismGoerli, clCcipLnMOptimismGoerli);
        } else if (officialChainId == chainIds[SupportedNetworks.BASE_GOERLI]) {
            return (ccipBnMBaseGoerli, clCcipLnMBaseGoerli);
        }
    }

    function getConfigFromNetwork(uint64 officialChainId)
        internal
        returns (address router, address linkToken, address wrappedNative, uint64 chainId)
    {
        if (officialChainId == chainIds[SupportedNetworks.ETHEREUM_SEPOLIA]) {
            return (routerEthereumSepolia, linkEthereumSepolia, wethEthereumSepolia, ccipChainIdEthereumSepolia);
        } else if (officialChainId == chainIds[SupportedNetworks.ARBITRUM_GOERLI]) {
            return (routerArbitrumTestnet, linkArbitrumTestnet, wethArbitrumTestnet, ccipChainIdArbitrumTestnet);
        } else if (officialChainId == chainIds[SupportedNetworks.AVALANCHE_FUJI]) {
            return (routerAvalancheFuji, linkAvalancheFuji, wavaxAvalancheFuji, ccipChainIdAvalancheFuji);
        } else if (officialChainId == chainIds[SupportedNetworks.POLYGON_MUMBAI]) {
            return (routerPolygonMumbai, linkPolygonMumbai, wmaticPolygonMumbai, ccipChainIdPolygonMumbai);
        } else if (officialChainId == chainIds[SupportedNetworks.OPTIMISM_GOERLI]) {
            return (routerOptimismGoerli, linkOptimismGoerli, wethOptimismGoerli, ccipChainIdOptimismGoerli);
        } else if (officialChainId == chainIds[SupportedNetworks.BASE_GOERLI]) {
            return (routerBaseGoerli, linkBaseGoerli, wethBaseGoerli, ccipChainIdBaseGoerli);
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
