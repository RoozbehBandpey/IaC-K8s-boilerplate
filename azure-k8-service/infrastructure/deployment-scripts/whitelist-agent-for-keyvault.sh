# Are we removing rather than setting?
if [[ $1 == "-r" ]]; then
    if [[ -z "$3" ]]; then
        echo "Build agent IP address is empty, no whitelist entry to remove from key vault: '$2'"
    else
        echo "Removing key vault '$2' network rule for DevOps build agent IP address: '$3'"

        # Remember to specify CIDR /32 for removal
        az keyvault network-rule remove -n $2 --ip-address $3/32
    fi
    exit 0
fi

keyVaultName=$1

########################################################################
##### This is the known secret which we request from the key vault #####
########################################################################

knownSecret="instrumentationkeymmc-appinsights-dev"

echo "Attempting to get value for known secret from key vault: '$keyVaultName'"

# Attempt to show secret - if it doesn't work, we are echoed our IP address on stderror, so capture it
# secretOutput=$("$azcmd" keyvault secret show -n "$knownSecret" --vault-name "$keyVaultName" 2>&1)
buildAgentIpAddress=($(curl ifconfig.co))
# echo "Hosted build agent IP Address: '$buildAgentIpAddress'"
set -euo pipefail

if [[ ! -z "$buildAgentIpAddress" ]]; then
    # Temporarily whitelist Azure DevOps IP for key vault access.
    # Note use of /32 for CIDR = 1 IP address. If we omit this Azure adds it anyway and fails to match on the IP when attempting removal.
    echo "Azure DevOps IP address '$buildAgentIpAddress' is blocked. Attempting to whitelist..."
    az keyvault network-rule add -n $keyVaultName --ip-address $buildAgentIpAddress/32

    # Capture the IP address as an ADO variable, so that this can be undone in a later step
    echo "##vso[task.setvariable variable=buildAgentIpAddress]$buildAgentIpAddress"
else
    # We didn't find the IP address - are we already whitelisted?
    secretValue=$(echo $secretOutput | grep -o "value")

    if [[ -z "$secretValue" ]]; then
        echo "Unexpected response from key vault whitelist request, json attribute 'value' not found. Unable to whitelist build agent - response was: '$secretOutput'"
        exit 1
    fi
fi