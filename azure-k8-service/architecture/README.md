# Architecture

This reference architecture details several configurations to consider when running microservices on Azure Kubernetes Services. Topics include configuring network policies, pod autoscaling, and distributed tracing across a microservice-based application.


![AKS network design](./diagrams/images/aks_service_mesh_networking.png)

## Components
This architecture deploys the following components:
The workload used in this architecture is stateless. so there is no need for an external storage for storing the state of workload

### Azure DevOps
In this project Azure DevOps is used for issue tracking, code repository, build and release pipelines and storing build artefacts. Most of the infrastructure is deployed with a declarative method, specifically azure pipelines with YAML definition along with ARM templates for each environment. For CLuster CI/CD we have used Flux to automatically synchronize cluster and repository changes. 

1. Developers use Local Process with Kubernetes to run their local development within the context of the development environment Kubernetes cluster. Connecting to the cluster while debugging the service allows quick testing and development in the azure kubernetes.

2. A developer makes changes to the Recommender REST API source code.
3. The code change is committed to Azure DevOps repository
4. After a pull request approval continuous integration (CI) process will start
5. Azure DevOps repo triggers a DevOps pipeline project build
6. The build job uses a DevOps agent pool to perform a container build process
7. A container image is created from the code in source control, and is then pushed to an Azure Container Registry.
8. Through continuous deployment (CD), flux uses one or more operators in the cluster to trigger deployments inside Kubernetes
    * Flux runs in pod in alongside the workload. flux has read-only access to the git repository to make sure that flux is only applying changes as requested by developers.
    * Flux recognizes changes in configuration and applies those changes using kubectl commands.
    * Developers do not have direct access to the Kubernetes API through kubectl. 
9. A Grafana instance provides visual dashboards of the application performance based on the data from Azure Monitor.
### Azure Active Directory
For managing Outside-in and Inside-out access 
 to manage access through Azure Active Directory For MVP we have choosen service principals but it is highl;y recommended to move to managed identities
### Azure Key Vault
### Azure Container Registry
Public imagews might be subject to unexpected availability issues which can cause operational issues if the image isn't available when service need it therefore all public image, are imported it into  container registry.
### Azure Virtual Network
This architecture uses separate subnets which minimizes direct exposure of Azure resources to the public internet.
Three subnets are deployed
1. On to hold the Azure firewall
2. Azure Bastion
3. holds the AKS system
Azure Private Link allocates specific private IP addresses to access Azure Container Registry and Key Vault from Private Endpoints within the AKS system and user node pool subnet.
### Azure Cosmos DB
### Azure Log analytics
### Azure Application Gateway
WAF secures incoming traffic from common web traffic attacks. The instance has a public frontend IP configuration that receives user requests. By design, Application Gateway requires a dedicated subnet.
### Azure Kubernetes Service
#### Ingresses
Since the puiblic facing resources are deployed within their own vurtual network, and the incomming trafic is from Application Gateway, it makes sense to incorporate an External ingress controller. Application Gateway has built-in autoscaling capabilities, unlike in-cluster ingress controllers that must be scaled out if they consume an undesired amount of compute resources. External ingress controllers simplify traffic ingestion into AKS clusters, improve safety and performance, and save resources. This architecture uses the Azure Application Gateway Ingress Controller (AGIC) for ingress control. Using Application Gateway to handle all traffic eliminates the need for an extra load balancer. Because pods establish direct connections against Application Gateway, the number of required hops is reduced, which results in better performance.

AGIC requires CNI networking to be enabled


The client sends an HTTPS request to the domain name: bicycle.contoso.com. T

Application Gateway has an integrated web application firewall (WAF) and negotiates the TLS handshake for bicycle.contoso.com. Application Gateway execute routing rules that forward the traffic to the configured backend. The TLS certificate is stored in Azure Key Vault and it has been made availabe within cluster via CSI.


The ingress controller receives the encrypted traffic through the AGIC load balancer. The controller forwards the traffic to the workload pods over HTTP. The certificates are stored in Azure Key Vault and mounted into the cluster using the Container Storage Interface (CSI) driver.
#### Egress
all egress traffic from the cluster moves through Azure Firewall. Azure Firewall decides whether to block or allow the egress traffic. That decision is based on the specific rules defined in the Azure Firewall or the built-in threat intelligence rules.

For the situations when the cluster needs to communicate with other Azure resources. For instance, pulling an updated image from the container registry. The recommended approach is by using Azure Private Link. The advantage is that specific subnets reach the service directly. Also, traffic between the cluster and the service isn't exposed to public internet. For this purpose, Service Endpoint on the subnet must be enabled in order to access the service.

#### Azure Container Networking Interface (CNI)
For Pod-to-pod traffics, Kubernetes NetworkPolicy is used to restrict network traffic between pods. Azure Network Policy is deplyed, along with Azure Container Networking Interface (CNI). In this model, every pod gets an IP address from the subnet address space. Resources within the same network can access the pods directly through their IP address. A big advantrage of CNI is elimination of additional network overlays. It also offers better security control because it enables the use Azure Network Policy. 


#### Azure Key Vault Secret Store CSI provider
To facilitate the retrieval process, in this architecture we have used Secrets Store CSI driver. When the pod needs a secret, the driver connects with the specified store, retrieves secret on a volume, and mounts that volume in the cluster. The pod can then get the secret from the volume file system.

The CSI driver has many providers to support various managed stores. In this implementation, we’ve chosen the Azure Key Vault with Secrets Store CSI Driver to retrieve the TLS certificate from Azure Key Vault and load it in the pod running the ingress controller. It's done during pod creation and the volume stores both public and the private keys.
#### Flux
A developer commits changes to source code, such as configuration YAML files, which are stored in a git repository. The changes are then pushed to a git server.

flux runs in pod in alongside the workload. flux has read-only access to the git repository to make sure that flux is only applying changes as requested by developers.

flux recognizes changes in configuration and applies those changes using kubectl commands.

Developers do not have direct access to the Kubernetes API through kubectl. Have branch policies on your git server. That way, multiple developers can approve a change before it’s applied to production.
#### Helm
#### System and user node pool separation
To prevent misconfigured or rogue application pods from accidentally killing system pods
we have isolated critical system pods from application pods. For deployment the `CriticalAddonsOnly=true:NoSchedule` must be set to prevent application pods from being scheduled on system node pools.
#### AKS-managed Azure AD for role-based access control (RBAC)
Kubernetes supports role-based access control (RBAC) through:

A set of permissions. Defined by a Role or ClusterRole object for cluster-wide permissions.

Bindings that assign users and groups who are allowed to do the actions. Defined by a RoleBinding or CluserRoleBinding object.

Kubernetes has some built-in roles such as cluster-admin, edit, view, and so on. Bind those roles to Azure Active Directory users and groups to use enterprise directory to manage access.
#### Azure AD pod-managed identities
Azure Active Directory pod-managed identities uses Kubernetes primitives to associate managed identities for Azure resources and identities in Azure Active Directory (AAD) with pods. Administrators create identities and bindings as Kubernetes primitives that allow pods to access Azure resources that rely on AAD as an identity provider.
#### Azure Policy Add-on for AKS
In this reference implementation Azure Policy is enabled when the AKS cluster is created and assigns the restrictive initiative in Audit mode to gain visibility into non-compliance.

The implementation also sets additional policies that are not part of any built-in initiatives. Those policies are set in Deny mode. For example, there is a policy in place to make sure images are only pulled from the deployed ACR. Consider creating your own custom initiatives. Combine the policies that are applicable for your workload into a single assignment.
#### Azure Container Networking Interface (CNI)
#### Azure Monitor for containers
AcrPull. The cluster’s ability to pull images from the specified Azure Container Registries.
### Azure Bastion
Subnet to host Azure Bastion
This subnet is a placeholder for Azure Bastion. You can use Bastion to securely access Azure resources without exposing the resources to the internet. This subnet is used for management and operations only.
### Azure Firewall
The firewall instance secures outbound network traffic
Since most treaffic is a web traffic the architecture requires A firewall (WAF) service to help govern HTTP traffic flows.

### Network topology
This architecture uses a hub-spoke network topology. The hub and spoke(s) are deployed in separate virtual networks connected through peering. Some advantages of this topology are:

Segregated management. It allows for a way to apply governance and control the blast radius. It also supports the concept of landing zone with separation of duties.

Minimizes direct exposure of Azure resources to the public internet.

Organizations often operate with regional hub-spoke topologies. Hub-spoke network topologies can be expanded in the future and provide workload isolation.

All web applications should require a web application firewall (WAF) service to help govern HTTP traffic flows.

A natural choice for workloads that span multiple subscriptions.

It makes the architecture extensible. To accommodate new features or workloads, new spokes can be added instead of redesigning the network topology.

Certain resources, such as a firewall and DNS can be shared across networks.

### Plan the IP addresses

The address space of the virtual network should be large enough to hold all subnets. Account for all entities that will receive traffic. IP addresses for those entities will be allocated from the subnet address space. Consider these points.

Upgrade

AKS updates nodes regularly to make sure the underlying virtual machines are up to date on security features and other system patches. During an upgrade process, AKS creates a node that temporarily hosts the pods, while the upgrade node is cordoned and drained. That temporary node is assigned an IP address from the cluster subnet.

For pods, you might need additional addresses depending on your strategy. For rolling updates, you'll need addresses for the temporary pods that run the workload while the actual pods are updated. If you use the replace strategy, pods are removed, and the new ones are created. So, addresses associated with the old pods are reused.

Scalability

Take into consideration the node count of all system and user nodes and their maximum scalability limit. Suppose you want to scale out by 400%. You'll need four times the number of addresses for all those scaled-out nodes.

In this architecture, each pod can be contacted directly. So, each pod needs an individual address. Pod scalability will impact the address calculation. That decision will depend on your choice about the number of pods you want to grow.

Azure Private Link addresses

Factor in the addresses that are required for communication with other Azure services over Private Link. In this architecture, we have two addresses assigned for the links to Azure Container Registry and Key Vault.

Certain addresses are reserved for use by Azure. They can't be assigned.

The preceding list isn't exhaustive. If your design has other resources that will impact the number of available IP addresses, accommodate those addresses.

This architecture is designed for a single workload. For multiple workloads, you may want to isolate the user node pools from each other and from the system node pool. That choice may result in more subnets that are smaller in size. Also, the ingress resource might be more complex. You might need multiple ingress controllers that will require extra addresses.

For the complete set of considerations for this architecture, see AKS baseline Network Topology.

For information related to planning IP for an AKS cluster, see Plan IP addressing for your cluster.

### What address ranges can I use in my VNets?
We recommend that you use the address ranges enumerated in RFC 1918, which have been set aside by the IETF for private, non-routable address spaces:

10.0.0.0 - 10.255.255.255 (10/8 prefix)
172.16.0.0 - 172.31.255.255 (172.16/12 prefix)
192.168.0.0 - 192.168.255.255 (192.168/16 prefix)
Other address spaces may work but may have undesirable side effects.

In addition, you cannot add the following address ranges:

224.0.0.0/4 (Multicast)
255.255.255.255/32 (Broadcast)
127.0.0.0/8 (Loopback)
169.254.0.0/16 (Link-local)
168.63.129.16/32 (Internal DNS)



