# Requirements

## Azure CLI

We will be using the Azure command line interface to create and interact with resources running in Azure. To install it, go to <https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest> and choose your platform.

When finished, login to your Azure account from the command line:

```shell
$ az login
You have logged in. Now let us find all the subscriptions to which you have access...
```

A browser window will open, login to Azure and go back to the command prompt. Your active subscription will be shown as JSON, e.g.:

```json
{
  "cloudName": "AzureCloud",
  "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "isDefault": false,
  "name": "Your Subscription Name",
  "state": "Enabled",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "user": {
    "name": "xxx@example.com",
    "type": "user"
  }
}
```

If you have multiple subscriptions, make sure your are working with the correct one!

```shell
$ az account show
{
  "cloudName": "AzureCloud",
  "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "isDefault": false,
  "name": "Your Subscription Name",
  "state": "Enabled",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "user": {
    "name": "xxx@example.com",
    "type": "user"
  }
}
```

If that is not the correct one, follow these steps below:

```shell
$ az account list -o table
[the list of available subscriptions is printed]

$ az account set -s <SUBSCRIPTIONID_YOU_WANT_TO_USE>
```

## Install Kubectl

`kubectl` is the commandline interface for Kubernetes. You will need the tool to interact with the cluster, e.g. to create a pod, deployment or service.

If you already have the Azure CLI on your machine, you can just install it using the following command:

```shell
$ az aks install-cli
```

Or refer to the documentation for you specific platform.

[Install kubectl on Linux](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-with-curl-on-linux)

[Install kubectl on macOS](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-macos)

[Install kubectl on Windows](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-on-windows-using-chocolatey-or-scoop)

## Install Helm

`Helm` is the package manager for Kubernetes. We will need it for installing several 3rd party components for our solution:

https://helm.sh/docs/intro/install/

## Terraform

`Terraform` is an open-source "infrastructure as code" software tool created by HashiCorp. It is a tool for building, changing, and versioning infrastructure safely and efficiently. We will use terraform to create several PaaS services like Azure SQL Db, CosmosDB etc. in this workshop.

https://www.terraform.io/downloads.html


# Create your first Kubernetes Cluster

In this section we will create a Kubernetes cluster using the Azure CLI, configure your local access credentials to control your cluster using kubectl, take some first steps and run our first pod.

## Create the cluster

To have a clean overview of what is being provisioned under the hood, we create a new resource
group and and create our Kubernetes cluster within.

```shell
az group create --name k8-training-rg --location westeurope
az aks create --resource-group k8-training-rg --name k8-training-aks-cluster --enable-managed-identity --generate-ssh-keys --kubernetes-version 1.19.7
```

Let's inspect the created resources:
After completion you should see following in command line:
```json
{- Finished ..
  "aadProfile": null,
  "addonProfiles": null,
  "agentPoolProfiles": [
    {
      "availabilityZones": null,
      "count": 3,
      "enableAutoScaling": null,
      "enableNodePublicIp": false,
      "maxCount": null,
      "maxPods": 110,
      "minCount": null,
      "mode": "System",
      "name": "nodepool1",
      "nodeLabels": {},
      "nodeTaints": null,
      "orchestratorVersion": "1.19.7",
      "osDiskSizeGb": 128,
      "osType": "Linux",
      "provisioningState": "Succeeded",
      "scaleSetEvictionPolicy": null,
      "scaleSetPriority": null,
      "spotMaxPrice": null,
      "tags": null,
      "type": "VirtualMachineScaleSets",
      "vmSize": "Standard_DS2_v2",
      "vnetSubnetId": null
    }
  ],
  "apiServerAccessProfile": null,
  "autoScalerProfile": null,
  "diskEncryptionSetId": null,
  "dnsPrefix": "k8-trainin-k8-training-rg-9121c7",
  "enablePodSecurityPolicy": null,
  "enableRbac": true,
  "fqdn": "k8-trainin-k8-training-rg-9121c7-5d857650.hcp.westeurope.azmk8s.io",
  "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourcegroups/k8-training-rg/providers/Microsoft.ContainerService/managedClusters/k8-training-aks-cluster",
  "identity": {
    "principalId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "type": "SystemAssigned"
  },
  "identityProfile": {
    "kubeletidentity": {
      "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
      "objectId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
      "resourceId": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourcegroups/MC_k8-training-rg_k8-training-aks-cluster_westeurope/providers/Microsoft.ManagedIdentity/userAssignedIdentities/k8-training-aks-cluster-agentpool"
    }
  },
  "kubernetesVersion": "1.19.7",
  "linuxProfile": {
    "adminUsername": "azureuser",
    "ssh": {
      "publicKeys": [
        {
          "keyData": "ssh-rsa XXXXXXXXX...== xxx@example.com\n"
        }
      ]
    }
  },
  "location": "westeurope",
  "maxAgentPools": 100,
  "name": "k8-training-aks-cluster",
  "networkProfile": {
    "dnsServiceIp": "10.0.0.10",
    "dockerBridgeCidr": "172.17.0.1/16",
    "loadBalancerProfile": {
      "allocatedOutboundPorts": null,
      "effectiveOutboundIps": [
        {
          "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/MC_k8-training-rg_k8-training-aks-cluster_westeurope/providers/Microsoft.Network/publicIPAddresses/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
          "resourceGroup": "MC_k8-training-rg_k8-training-aks-cluster_westeurope"
        }
      ],
      "idleTimeoutInMinutes": null,
      "managedOutboundIps": {
        "count": 1
      },
      "outboundIpPrefixes": null,
      "outboundIps": null
    },
    "loadBalancerSku": "Standard",
    "networkMode": null,
    "networkPlugin": "kubenet",
    "networkPolicy": null,
    "outboundType": "loadBalancer",
    "podCidr": "10.244.0.0/16",
    "serviceCidr": "10.0.0.0/16"
  },
  "nodeResourceGroup": "MC_k8-training-rg_k8-training-aks-cluster_westeurope",
  "privateFqdn": null,
  "provisioningState": "Succeeded",
  "resourceGroup": "k8-training-rg",
  "servicePrincipalProfile": {
    "clientId": "msi",
    "secret": null
  },
  "sku": {
    "name": "Basic",
    "tier": "Free"
  },
  "tags": null,
  "type": "Microsoft.ContainerService/ManagedClusters",
  "windowsProfile": null
}
```

![Created resource groups](./img/rg-created.png)

The `az aks create` command created a second resource group named
`MC_k8-training-rg_k8-training-aks-cluster_westeurope` containing all resources provisioned for our AKS
cluster.

The resource group we explicitly created only holds the AKS resource.

![Automatically created resource group](./img/auto-rg.png)

All other resource for the cluster are created in it's own resource group. This resource group and
all it's containing resources will be deleted when the cluster is destroyed.

## Establish access to the cluster

Now it's time to access our cluster. To authenticate us against the cluster Kubernetes uses client
certificates and access tokens. To obtain these access credentials for our newly created cluster we
use the `az aks get-credentials` command:

```shell
$ az aks get-credentials --resource-group k8-training-rg --name k8-training-aks-cluster
Merged "k8-training-aks-cluster" as current context in /Users/roozbehbandpey/.kube/config

$ kubectl version # check client and server version of kubernetes
Client Version: version.Info{Major:"1", Minor:"20", GitVersion:"v1.20.2", GitCommit:"faecb196815e248d3ecfb03c680a4507229c2a56", GitTreeState:"clean", BuildDate:"2021-01-14T18:56:46Z", GoVersion:"go1.15.6", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.7", GitCommit:"14f897abdc7b57f0850da68bd5959c9ee14ce2fe", GitTreeState:"clean", BuildDate:"2021-01-22T17:29:38Z", GoVersion:"go1.15.5", Compiler:"gc", Platform:"linux/amd64"}
```

`kubectl version` prints both the version of the locally running commandline tool as well as the
Kubernetes version running on our cluster. To inspect the access credentials and cluster
configuration stored for us in our `~/.kube/config` file run `kubectl config view`.

We've setup access to our Kubernetes cluster. Now we can start exploring and working with our
cluster.

## Access the dashboard

AKS no longer comes with the kubernetes-dashboard installed by default. Lucky
for us there is a one-liner to quickly install the dashboard into our
cluster:

```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml
```

Now, accessing the dashboard requires us to create a `ServiceAccount` with the
_cluster-admin_ `ClusterRole`.

To create these `Resources` within our Kubernetes cluster we will first declare the desired
configuration for our `ServiceAccount` in a yaml file and apply the desired configuration to our
cluster using the `kubectl apply` command.

```yaml
# dashboard-admin.yaml

# Create a ServiceAccount that we can use to access the Dashboard
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user # Create a ServiceAccount named admin-user
  namespace: kubernetes-dashboard

# This separates multiple resource definitions in a single file
---
# Bind the cluster-admin ClusterRole to the admin-user ServiceAccount
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: admin-user
    namespace: kubernetes-dashboard
```

Create a new `dashboard-admin.yaml` file and paste the above content.

> **INFO:** you will be creating lots of YAML files today - hooray! :) Create a folder called `yaml` in the root directory of your repo and save all files you create within that location. You can apply the manifests via kubectl from that folder.

We can apply the configuration using the following line:

```shell
$ kubectl apply -f dashboard-admin.yaml
serviceaccount/admin-user created
clusterrolebinding.rbac.authorization.k8s.io/admin-user created
```

We need to discover the created users secret access token, to gain access to the dashboard.

```shell
$ kubectl -n kubernetes-dashboard get secret
NAME                               TYPE                                  DATA   AGE
admin-user-token-22554             kubernetes.io/service-account-token   3      32s
default-token-8fjcr                kubernetes.io/service-account-token   3      76s
kubernetes-dashboard-certs         Opaque                                0      76s
kubernetes-dashboard-csrf          Opaque                                1      76s
kubernetes-dashboard-key-holder    Opaque                                2      75s
kubernetes-dashboard-token-zmvj4   kubernetes.io/service-account-token   3      76s
```

Find the secret that belongs to the `admin-user-token` and let `kubectl describe` it to see the content of the secret:

```shell
$ kubectl -n kubernetes-dashboard describe secret admin-user-token-smw2j
Name:         admin-user-token-22554
Namespace:    kubernetes-dashboard
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: admin-user
              kubernetes.io/service-account.uid: 02a8e2e7-c25d-48a2-b8b8-f6ce99e77a5d

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1765 bytes
namespace:  20 bytes
token:      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

> Watch out! You token will have a different random 5 character suffix.

Copy the token to your clipboard for the next step.

Now we start the kubernetes proxy to access the remote api safely on our local machine:

```shell
$ kubectl proxy
Starting to serve on 127.0.0.1:8001
```

The process keeps running until you interrupt it using `Ctrl-C`. Let's keep it running for now.

[Access the dashboard](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)
and login using the token you've acquired for the _admin-user_ `ServiceAccount`.

![Dashboard Login](./img/dashboard-login.png)

Take your time to explore the dashboard. Make use of the `Namespace` selector to navigate the
different namespaces.

![Dashboard Overview](./img/all-namespaces-dashboard.png)

> **Security Note:** The dashboard component is considered a "security risk", because it is an additional way to access your cluster - and you have to take care of securing it. Normally, you would not install the dashboard component in production clusters. There is an option for disabling the dashboard, even after installation: `az aks disable-addons -a kube-dashboard -n my_cluster_name -g my_cluster_resource_group`.

## Run your first pod

Now we will run our first pod on our kubernetes cluster. Let's keep the `kubectl proxy` command
running and execute this in new tab in your console.

```shell
$ kubectl run -i -t pod1 --image=busybox --restart=Never --rm=true
If you don't see a command prompt, try pressing enter.
/ #
```

We've just started a `Pod` named _pod1_ based on the _busybox_ image.

To understand the different flags we've added to the command take a look at the built in
documentation to `kubectl run`.

```shell
$ kubectl run --help
Create and run a particular image in a pod.

Examples:
  # Start a nginx pod.
  kubectl run nginx --image=nginx

...
```

## Questions

What do the different flags (`-i`, `-t`, `--restart=Never`, `--rm=True`) used in the `kubectl run`
command do?