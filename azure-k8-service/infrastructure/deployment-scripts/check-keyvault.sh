# get Command Line Args
baseName=$1
environment=$2
resourceGroupName=$3

# Check if KeyVault exists
az keyvault show -n "$baseName-kv-$environment" -g $resourceGroupName
# Use recover mode keep ML ws's access policies
if [ $? -eq 0 ]; then
    echo "keyvault recovery deployment"
    echo "##vso[task.setvariable variable=createmode]recover"
else
    echo "keyvault default deployment"
    echo "##vso[task.setvariable variable=createmode]default"
fi