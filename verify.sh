#!/usr/bin/env bash
set -eu


########################
##       PARAMS       ##
########################

### Hub ###
HUB_CHAIN_ID=43113
HUB_RPC_URL=avalancheFuji

### Spokes ###
SPOKE_CHAIN_IDS=(80001 420)
SPOKE_RPC_URLS=(polygonMumbai optimismGoerli)

### Smart Contracts ###
declare -a HUB_CONTRACT_NAMES=("ENSRegistryCCIP" "FIFSRegistrarCCIP" "ReverseRegistrarCCIP" "PublicResolverCCIP")
declare -a SPOKE_CONTRACT_NAMES=("xcENSRegistry" "xcFIFSRegistrar" "xcReverseRegistrar" "xcPublicResolver")


########################
##       CHECKS       ##
########################

# Check bash version
if (( ${BASH_VERSION%%.*} < 4 )); then
  echo "Error: Bash version 4 or later is required (see README.md)" >&2
  exit 1
fi

# Check if `jq` is installed
if ! command -v jq &> /dev/null; then
  echo "Error: jq is required (see README.md)" >&2
  exit 1
fi

# Check if `forge` is installed
if ! command -v forge &> /dev/null; then
  echo "Error: forge is required (see README.md)" >&2
  exit 1
fi


########################
##       SCRIPT       ##
########################

# 0. Helper to get & store deployed contract addresses from the `run-latest.json` file broadcasted by forge
function getContractAddress() {
  local chainId=$1
  local contractName=$2
  local contractAddress=$(jq -r --arg name "$contractName" 'first(.transactions[] | select(.contractName==$name).contractAddress)' broadcast/Deploy.s.sol/$chainId/run-latest.json)
  echo ${contractAddress}
}

# 1. Verify all hub contracts
for contractName in "${HUB_CONTRACT_NAMES[@]}"; do
  contractAddress=$(getContractAddress $HUB_CHAIN_ID $contractName)
  forge verify-contract $contractAddress $contractName --chain-id $HUB_CHAIN_ID
done

# 2. Verify all spoke contracts
for i in "${!SPOKE_CHAIN_IDS[@]}"; do
  spokeChainId=${SPOKE_CHAIN_IDS[$i]}
  spokeRpcUrl=${SPOKE_RPC_URLS[$i]}
  for contractName in "${SPOKE_CONTRACT_NAMES[@]}"; do
    contractAddress=$(getContractAddress $spokeChainId $contractName)
    forge verify-contract $contractAddress $contractName --chain-id $spokeChainId
  done
done
