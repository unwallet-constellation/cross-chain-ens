# Unwallet.me – Cross-Chain ENS Contracts (CCIP)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Solidity](https://img.shields.io/badge/Solidity-purple)
![Foundry](https://img.shields.io/badge/Foundry-gray)
![Chainlink CCIP](https://img.shields.io/badge/Chainlink_CCIP-blue)

> Next-Gen Onboarding. Seedless Smart Wallets meet Multichain Domains.

These are the contracts for the _[Unwallet.me](https://unwallet.me/)_ hackathon project at [Chainlink Constellation 2023](https://chain.link/hackathon). The repository is based on the [Chainlink CCIP Foundry Starter Kit](https://github.com/smartcontractkit/ccip-starter-kit-foundry).

## Architecture Diagram

<img src="https://cdn.discordapp.com/attachments/1182275401817526403/1182377339385028730/image.png?ex=658479b5&is=657204b5&hm=f95cdd5d0cafb6f58dc6d488e355591abb885a3b73b858b1f797858b971bde6b&" width="500px" height="500px" alt="Architecture Diagram" />

## Getting Started

> **Pre-requisites:**
>
> - [Foundry](https://book.getfoundry.sh/getting-started/installation)

```bash
# 1. Install dependencies (both)
forge install
npm install

# 2. Compile contracts
forge build
```

## Environment

In the next section you can see a couple of basic Chainlink CCIP use case examples. But before that, you need to set up some environment variables.

Create a new file by copying the `.env.example` file, and name it `.env`. Fill in your wallet's private key, and all respective RPC URLs for at least two blockchains.

```shell
PRIVATE_KEY=""

ETHERSCAN_OPTIMISM_KEY=""
POLYGONSCAN_KEY=""

ETHEREUM_SEPOLIA_RPC_URL="https://ethereum-sepolia.publicnode.com"
AVALANCHE_FUJI_RPC_URL="https://avalanche-fuji-c-chain.publicnode.com"
POLYGON_MUMBAI_RPC_URL="https://polygon-mumbai-bor.publicnode.com"
BASE_SEPOLIA_RPC_URL="https://base-sepolia.publicnode.com"
OPTIMISM_SEPOLIA_RPC_URL="https://optimism-sepolia.publicnode.com"
```

Once that is done, to load the variables in the `.env` file, run the following command:

```shell
source .env
```

## Deploy

> [!INFO]  
> Make sure to claim testnet gas from all respective chains and `LINK` tokens from this [faucet](https://docs.chain.link/resources/acquire-link?parent=ccip) on the respective spoke chains with your deployer account first.

To deploy the full cross-chain ENS protocol (hub & spokes), run the following command below.

> [!IMPORTANT]  
> The script requires bash version 4.0 or higher and the `jq` command line tool. On macOs, it's recommended to install both via [Homebrew](https://brew.sh/).

```shell
./deploy.sh

# Only output contract addresses from a previous deployment
./deploy.sh --dry-run

# Verify contracts
./verify.sh
```

It uses `./script/Deploy.s.sol` via the `forge script` command. See the file for more details and for configuring chains.
