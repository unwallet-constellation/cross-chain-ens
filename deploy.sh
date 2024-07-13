#!/usr/bin/env bash
set -eu


########################
##       PARAMS       ##
########################

### Hub ###
HUB_CHAIN_ID=43113
HUB_RPC_URL=avalancheFuji

### Spokes ###
SPOKE_CHAIN_IDS=(84532 11155420)
SPOKE_RPC_URLS=(baseSepolia optimismSepolia)

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

# Parse arguments:
#   --dry-run: Prints previous deployment addresses without executing the deployment
[[ "${1-}" == "--dry-run" ]] && DRY_RUN=1 || DRY_RUN=0

########################
##       SCRIPT       ##
########################

# 0. Helper to get & store deployed contract addresses from the `run-latest.json` file broadcasted by forge
declare -A contractAddresses
function exportContractAddress() {
  local chainId=$1
  local contractName=$2
  local contractAddress=$(jq -r --arg name "$contractName" 'first(.transactions[] | select(.contractName==$name).contractAddress)' broadcast/Deploy.s.sol/$chainId/run-latest.json)
  export ${contractName}=${contractAddress}
  contractAddresses[$contractName,$chainId]=$contractAddress
}

# 1. Deploy the hub contracts
if [ $DRY_RUN -eq 0 ]; then
  forge script ./script/Deploy.s.sol:DeployHub -v --broadcast --rpc-url $HUB_RPC_URL --sig "run(uint64)" -- $HUB_CHAIN_ID
fi

# 2. Export the hub contract addresses
for name in "${HUB_CONTRACT_NAMES[@]}"; do exportContractAddress $HUB_CHAIN_ID $name; done

# 3. Deploy the spoke contracts
if [ $DRY_RUN -eq 0 ]; then
  for i in "${!SPOKE_CHAIN_IDS[@]}"; do
    forge script ./script/Deploy.s.sol:DeploySpoke -v --broadcast --rpc-url ${SPOKE_RPC_URLS[$i]} --sig "run(uint64, uint64)" -- ${SPOKE_CHAIN_IDS[$i]} $HUB_CHAIN_ID
  done
fi

# 4. Export the spoke contract addresses
for i in "${!SPOKE_CHAIN_IDS[@]}"; do
  for name in "${SPOKE_CONTRACT_NAMES[@]}"; do exportContractAddress ${SPOKE_CHAIN_IDS[$i]} $name; done
done

# 5. Build JSON output
declare -A jsonOutput
for key in "${!contractAddresses[@]}"; do
  IFS=',' read -r -a array <<< "$key"
  jsonOutput[${array[0]}]=${jsonOutput[${array[0]}]-}"\n    ${array[1]}: \"${contractAddresses[$key]}\","
done

# 6. Print JSON output
echo -e "\nDeployed contract addresses (JSON):"
for key in "${!jsonOutput[@]}"; do
  echo -e "  $key: {${jsonOutput[$key]%,}\n  },"
done