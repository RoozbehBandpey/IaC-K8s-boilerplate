# get Command Line Args
baseName=$1
environment=$2

# Check if KeyVault exists
echo "$baseName-kv-$environment" -g "$baseName-rg-$environment"
# Use recover mode keep ML ws's access policies
# if [ $? -eq 0 ]; then
#     echo "keyvault recovery deployment"
#     echo "##vso[task.setvariable variable=createmode]recover"
# else
#     echo "keyvault default deployment"
#     echo "##vso[task.setvariable variable=createmode]default"
# fi