# get Command Line Args
secretName=$1
acrName=$1

all_namespaces=$(kubectl get namespaces -o jsonpath="{.items[*]['metadata.name']}")

if [[ $all_namespaces == *"$nameSpace"* ]]; then
  	echo "Namespace $nameSpace exists!"
else
    echo "Namespace $nameSpace does not exist! creating"
    kubectl create namespace $nameSpace
fi