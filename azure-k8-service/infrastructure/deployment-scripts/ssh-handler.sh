# get Command Line Args
keyVaultName=$1
secretName=$2

# Check if secret exists
secret_exists=$(az keyvault secret list --vault-name $keyVaultName --query "contains([].id, 'https://$keyVaultName.vault.azure.net/secrets/$secretName')")


if [ $secret_exists == true ]; then
    echo "Secret '$secretName' exists! fetching..."
	secret_val=$(az keyvault secret show --name $secretName --vault-name $keyVaultName --query "value" -o tsv)
    echo "##vso[task.setvariable variable=ssh_value]$secret_val"
else
	echo "Secret '$secretName' do not exist! creating..."
    ssh-keygen  -f ~/.ssh/id_rsa_infra -q -P ""
    ssh_value=$(<~/.ssh/id_rsa_infra.pub)
	echo "##vso[task.setvariable variable=ssh_value]$ssh_value"
	az keyvault secret set --vault-name $keyVaultName --name $secretName -f ~/.ssh/id_rsa_infra.pub >/dev/null
fi