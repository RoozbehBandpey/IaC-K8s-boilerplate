# get Command Line Args
acrName=$1
keyvaultName=$2

ACRPWD=$(az acr credential show -n $acrName --query "passwords[0].value" -o tsv)
az keyvault secret set --vault-name $keyvaultName --name acr-secret --value $ACRPWD
