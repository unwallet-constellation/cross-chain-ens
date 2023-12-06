#!/usr/bin/env bash
set -eu

DRY_RUN=0
if [ -n "${1-}" ] && [ "$1" == "--dry-run" ]; then
  DRY_RUN=1
fi

### Hub ###
HUB_CHAIN_ID=43113
HUB_RPC_URL=avalancheFuji

### Spokes ###
SPOKE_CHAIN_IDS=(80001 420)
SPOKE_RPC_URLS=(polygonMumbai optimismGoerli)

# Helper to get deployed contract addresses from the run-latest.json file created by forge
declare -A contractAddresses
function exportContractAddress() {
  local chainId=$1
  local contractName=$2
  local contractAddress=$(jq -r --arg name "$contractName" 'first(.transactions[] | select(.contractName==$name).contractAddress)' broadcast/Deploy.s.sol/$chainId/run-latest.json)
  export ${contractName}=${contractAddress}
  contractAddresses[$contractName,$chainId]=$contractAddress
}

# Deploy the hub contracts
if [ $DRY_RUN -eq 0 ]; then
  forge script ./script/Deploy.s.sol:DeployHub -v --broadcast --rpc-url $HUB_RPC_URL --sig "run(uint64)" -- $HUB_CHAIN_ID
fi

# Export the hub contract addresses
declare -a hubContractNames=("ENSRegistryCCIP" "FIFSRegistrarCCIP" "ReverseRegistrarCCIP" "PublicResolverCCIP")
for name in "${hubContractNames[@]}"; do exportContractAddress $HUB_CHAIN_ID $name; done

# Deploy the spoke contracts
if [ $DRY_RUN -eq 0 ]; then
  for i in "${!SPOKE_CHAIN_IDS[@]}"; do
    forge script ./script/Deploy.s.sol:DeploySpoke -v --broadcast --rpc-url ${SPOKE_RPC_URLS[$i]} --sig "run(uint64, uint64)" -- ${SPOKE_CHAIN_IDS[$i]} $HUB_CHAIN_ID
  done
fi

# Export the spoke contract addresses
declare -a spokeContractNames=("xcENSRegistry" "xcFIFSRegistrar" "xcReverseRegistrar" "xcPublicResolver")
for i in "${!SPOKE_CHAIN_IDS[@]}"; do
  for name in "${spokeContractNames[@]}"; do exportContractAddress ${SPOKE_CHAIN_IDS[$i]} $name; done
done

# Build JSON output
declare -A jsonOutput
for key in "${!contractAddresses[@]}"; do
  IFS=',' read -r -a array <<< "$key"
  jsonOutput[${array[0]}]=${jsonOutput[${array[0]}]-}"\n    ${array[1]}: \"${contractAddresses[$key]}\","
done

# Print JSON output
echo -e "\nDeployed contract addresses (JSON):"
for key in "${!jsonOutput[@]}"; do
  echo -e "  $key: {${jsonOutput[$key]%,}\n  },"
done