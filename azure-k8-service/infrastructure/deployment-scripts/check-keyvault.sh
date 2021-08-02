# get Command Line Args
keyVaultName=$1


# Check if KeyVault exists
deleted=$(az keyvault list-deleted --query "contains([].name, $keyVaultName)")
# Use recover mode
if [ $deleted == true ]; then
    echo "keyvault $keyVaultName was soft deleted! recovery deployment"
    echo "##vso[task.setvariable variable=createmode]recover"
else
    echo "keyvault $keyVaultName was not soft deleted! default deployment"
    echo "##vso[task.setvariable variable=createmode]default"
fi