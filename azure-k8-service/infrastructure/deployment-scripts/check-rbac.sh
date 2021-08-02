# get Command Line Args
spObjectID=$1
roleDefinitionName=$2
resourceGroupName=$3


subscriptionId=$(az account list --query "[?isDefault].id | [0]" -o tsv)

scope="/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}"

roles=$(az role assignment list --assignee $spObjectID --scope $scope --role $roleDefinitionName --query "[] | length(@)")

if [[ $roles -eq 0 ]]; then
    echo "RBAC for $spObjectID with role of $roleDefinitionName does not exist!"
    echo "##vso[task.setvariable variable=rbacCreate]true"
else
    echo "RBAC for $spObjectID with role of $roleDefinitionName already exist!"
    echo "##vso[task.setvariable variable=rbacCreate]false"
fi
