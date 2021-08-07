# get Command Line Args
nameSpace=$1
secretName=$2

# Check if secret exists
secrets=$(kubectl get secrets --namespace $nameSpace -o jsonpath="{.items[*]['metadata.name']}")


if [[ $secretName == *"$secrets"* ]]; then
  	echo "Secret $secretName exists!"
	echo "##vso[task.setvariable variable=tls_secret_name]$secretName"
else
    echo "Secret $secretName does not exist! creating"
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -out $secretName'.crt' -keyout $secretName'.key' -subj "/CN=project-aks-dev-dns-48b692a2.hcp.koreacentral.azmk8s.io/O=$secretName"
    kubectl create secret tls $secretName --namespace $nameSpace --key $secretName.'key' --cert $secretName'.crt'
	echo "##vso[task.setvariable variable=tls_secret_name]$secretName"
fi
