# get Command Line Args
baseName=$1
environment=$2

# Check if KeyVault exists
# az keyvault show -n "$baseName-kv-$environment"
deleted=$(az keyvault list-deleted --query "contains([].name, '$baseName-kv-$environment')")
# Use recover mode keep ML ws's access policies
if [ $deleted == true ]; then
    echo "keyvault '$baseName-kv-$environment' was soft deleted! recovery deployment"
    echo "##vso[task.setvariable variable=createmode]recover"
else
    echo "keyvault '$baseName-kv-$environment' was not soft deleted! default deployment"
    echo "##vso[task.setvariable variable=createmode]default"
fi