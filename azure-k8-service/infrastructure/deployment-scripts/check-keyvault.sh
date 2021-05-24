# get Command Line Args
baseName=$1
location=$2
resourceGroupName=$3

# Check if KeyVault exists
az keyvault show -n "$baseName" -g $resourceGroupName
# Use recover mode keep ML ws's access policies
if [ $? -eq 0 ]; then
    echo "keyvault recovery deployment"
    echo "##vso[task.setvariable variable=createmode]recover"
    az keyvault recover -n "$baseName" -g "$resourceGroupName" -l "$location"
else
    echo "keyvault default deployment"
    echo "##vso[task.setvariable variable=createmode]default"
    az keyvault create -n "$baseName" -g "$resourceGroupName" -l "$location"
fi