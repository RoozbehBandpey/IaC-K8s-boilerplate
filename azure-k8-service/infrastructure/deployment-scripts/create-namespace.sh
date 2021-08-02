# get Command Line Args
nameSpace=$1
cleanup=$2

all_namespaces=$(kubectl get namespaces -o jsonpath="{.items[*]['metadata.name']}")

if [[ $all_namespaces == *"$nameSpace"* ]]; then
  	echo "Found existing namespace: $nameSpace"
	if [[ $cleanup == "--force" ]]; then
		echo "Deleting namescpae '$nameSpace'!"
		kubectl delete namespace $nameSpace --v=4
		echo "Creating namescpae '$nameSpace'!"
		kubectl create namespace $nameSpace --v=4
	fi
else
    echo "Creating new namespace: $nameSpace"
    kubectl create namespace $nameSpace --v=4
fi