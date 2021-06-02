# Architecture

This reference architecture details several configurations to consider when running microservices on Azure Kubernetes Services. Topics include configuring network policies, pod autoscaling, and distributed tracing across a microservice-based application.


![AKS network design](./diagrams/images/aks_service_mesh_networking.png)

## Components
This architecture deploys the following components:

### Azure DevOps
In this project Azure DevOps is used for issue tracking, code repository, build and release pipelines and storing build artefacts. Most of the infrastructure is deployed with a declarative method, specifically azure pipelines with YAML definition along with ARM templates for each environment. For CLuster CI/CD we have used Flux to automatically synchronize cluster and repository changes. 

Developers use Local Process with Kubernetes to run their local development within the context of the development Kubernetes cluster. Connecting to the cluster while debugging the service allows quick testing and development in the azure kubernetes context.

3. GitHub Actions builds the KPI service container images and pushes them to Azure Container Registries. GitHub Actions also updates the latest tag of repositories for continuous integration (CI), or tags repositories for release.

4. GitHub Actions automated testing generates work items for Azure Boards, making all work items manageable in one place.

5. Visual Studio Code extensions support Azure Boards and GitHub integration. Associating Azure Boards work items with GitHub repos ties requirements to code, driving the development loop forward.

6. Commits merged into the integration branch trigger GitHub Actions builds and Docker pushes to the DevTest container registries. Each KPI has its own repository in Container Registries, paralleling the GitHub repositories. CI builds are usually tagged with latest, representing the most recent successful KPI service builds.

7. Azure Pipelines runs the Kubernetes apply command to trigger deployment of the updated Container Registry images to the DevTest Kubernetes clusters. Azure can authenticate AKS to run unattended Container Registry pulls, simplifying the continuous deployment (CD) process.

Azure Pipelines uses Azure Key Vault to securely consume secrets like credentials and connection strings required for release and deployment configurations.

8. When a version of the application is ready for quality assurance (QA) testing, Azure Pipelines triggers a QA release. The pipeline tags all appropriate images with the next incremental version, updates the Kubernetes manifest to reflect the image tags, and runs the apply command. In this example, while a developer may be iterating on a service in isolation, only builds integrated via CI/CD are moved over to deployment.

9. After testing has approved a version of the service for deployment, GitHub Actions promotes a release from the DevTest Container Registry to a Production Container Registry. GitHub Actions tags the images with the appropriate version and pushes them into the Production Container Registry, following container registry best practices.

10. Azure Pipelines creates a release to Production. The pipeline imposes approval gates and pre-stage and post-stage conditions to protect the Production environment from inadvertent or incorrect deployment.

The architecture uses Azure Cosmos DB for I/O operation of each KPI runs.
### Azure Active Directory
For managing Outside-in and Inside-out access 
 to manage access through Azure Active Directory For MVP we have choosen service principals but it is highl;y recommended to move to managed identities
### Azure Key Vault
### Azure Container Registry
Public imagews might be subject to unexpected availability issues which can cause operational issues if the image isn't available when service need it therefore all public image, are imported it into  container registry.
### Azure Virtual Network

Separate subnets Minimizes direct exposure of Azure resources to the public internet.
Subnets
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

#### Azure Key Vault Secret Store CSI provider
#### Flux
A developer commits changes to source code, such as configuration YAML files, which are stored in a git repository. The changes are then pushed to a git server.

flux runs in pod in alongside the workload. flux has read-only access to the git repository to make sure that flux is only applying changes as requested by developers.

flux recognizes changes in configuration and applies those changes using kubectl commands.

Developers do not have direct access to the Kubernetes API through kubectl. Have branch policies on your git server. That way, multiple developers can approve a change before it’s applied to production.
#### Helm
#### System and user node pool separation
#### AKS-managed Azure AD for role-based access control (RBAC)
Kubernetes supports role-based access control (RBAC) through:

A set of permissions. Defined by a Role or ClusterRole object for cluster-wide permissions.

Bindings that assign users and groups who are allowed to do the actions. Defined by a RoleBinding or CluserRoleBinding object.

Kubernetes has some built-in roles such as cluster-admin, edit, view, and so on. Bind those roles to Azure Active Directory users and groups to use enterprise directory to manage access.
#### Azure AD pod-managed identities
#### Azure Policy Add-on for AKS
#### Azure Container Networking Interface (CNI)
#### Azure Monitor for containers
AcrPull. The cluster’s ability to pull images from the specified Azure Container Registries.
### Azure Bastion
Subnet to host Azure Bastion
This subnet is a placeholder for Azure Bastion. You can use Bastion to securely access Azure resources without exposing the resources to the internet. This subnet is used for management and operations only.
### Azure Firewall
The firewall instance secures outbound network traffic
Since most treaffic is a web traffic the architecture requires A firewall (WAF) service to help govern HTTP traffic flows.
### Azure DevOps