## Cross-Chain ENS via Chainlink CCIP

These contracts are part of the _Unwallet_ hackathon project at [Chainlink Constellation 2023](https://chain.link/hackathon). The repository is based on the [Chainlink CCIP Foundry Starter Kit](https://github.com/smartcontractkit/ccip-starter-kit-foundry).

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)

## Getting Started

1. Install packages

```
forge install
```

and

```
npm install
```

2. Compile contracts

```
forge build
```

## Usage

In the next section you can see a couple of basic Chainlink CCIP use case examples. But before that, you need to set up some environment variables.

Create a new file by copying the `.env.example` file, and name it `.env`. Fill in your wallet's PRIVATE_KEY, and RPC URLs for at least two blockchains

```shell
PRIVATE_KEY=""
ETHEREUM_SEPOLIA_RPC_URL=""
OPTIMISM_GOERLI_RPC_URL=""
AVALANCHE_FUJI_RPC_URL=""
ARBITRUM_TESTNET_RPC_URL=""
POLYGON_MUMBAI_RPC_URL=""
```

Once that is done, to load the variables in the `.env` file, run the following command:

```shell
source .env
```

Make yourself familiar with the [`Helper.sol`](./script/Helper.sol) smart contract. It contains all the necessary Chainlink CCIP config. If you ever need to adjust any of those parameters, go to the Helper contract.

This contract also contains some enums, like `SupportedNetworks`:

```solidity
enum SupportedNetworks {
    ETHEREUM_SEPOLIA,   // 0
    OPTIMISM_GOERLI,    // 1
    AVALANCHE_FUJI,     // 2
    ARBITRUM_GOERLI,    // 3
    POLYGON_MUMBAI      // 4
}
```

This means that if you want to perform some action from `AVALANCHE_FUJI` blockchain to `ETHEREUM_SEPOLIA` blockchain, for example, you will need to pass `2 (uint8)` as a source blockchain flag and `0 (uint8)` as a destination blockchain flag.

Similarly, there is an `PayFeesIn` enum:

```solidity
enum PayFeesIn {
    Native,  // 0
    LINK     // 1
}
```

So, if you want to pay for Chainlink CCIP fees in LINK token, you will pass `1 (uint8)` as a function argument.

### Deploy

To deploy the cross-chain ENS smart contracts to the hub chain (_Avalanche Fuji_ in this example), run:

```shell
forge script ./script/CrossChainENS.s.sol:DeployHub -vvv --broadcast --rpc-url avalancheFuji --sig "run(uint8)" -- 2
```

To deploy the respective contracts to the spoke chains (_Polygon Mumbai_ and _Optimism Goerli_ in this example), run:

```shell
forge script ./script/CrossChainENS.s.sol:DeploySpoke -vvv --broadcast --rpc-url polygonMumbai --sig "run(uint8, uint8)" -- 4 2
forge script ./script/CrossChainENS.s.sol:DeploySpoke -vvv --broadcast --rpc-url optimismGoerli --sig "run(uint8, uint8)" -- 1 2
```

> [!IMPORTANT]  
> Make sure to claim `LINK` tokens from the [faucet](https://docs.chain.link/resources/link-token-contracts?parent=ccip) on the respective spoke chain with deployer account before deploying the contracts.
