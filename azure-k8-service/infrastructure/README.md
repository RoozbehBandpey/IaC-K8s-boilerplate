# project recommender infrastructure deployments

Under the name recommendation engine infrastructure, we refer to all Azure resources
that are span up to facilitate facilitate Action ML recommendation engine. This includes lower-level
components such as storage and compute, configured within the private
network, as well as resources operating at a higher level such as Azure Kubernetes Service.

To promote central and non-redundant management of lower-level components you'll
find the following separation of resources in each environment.

* Shared Infrastructure

  * Container Registry Staging: a shared registry for docker images that are yet
    to be tested.
  * Container Registry: the shared registry where docker images are pushed to
    that are considered 'healthy' i.e. tested. Developers can pull
    images from this registry.
  * Application Insights: provides monitoring capabilities up till code level;
    best supported when using Azure ML for inferencing services.
  * KeyVault: adds an additional security and management layer for keys &
    secrets, with increased access control, monitoring and eleminating the need
    to hosts keys in application code.

* Kubernetes resources

  * Azure Kubernetes Service: the top-level resource of the service; it provides asset
    management of compute resources, datastores, nodepools and pods.
  * Nodepools and pods ...

## Kubernetes configuration

### AKS manual deployment
* [General Kubectl deployment](./aks-kubectl-deployment/README.md)
* [habse and recommender API (V1)](./hbase-apiv1/README.md)
* [Harness & Universal Recommender deployment](./harness/README.md)


## Azure Resource Manager Templates

The best practice for deploying and managing infrastructure on Azure is through
Azure Resource Manager (ARM) templates. ARM templates allow for the adoption of
infrastructure- and configuration of code concepts, to avoid environment drift.
To learn more about ARM templates, refer to the [Azure
docs](https://docs.microsoft.com/en-us/azure/azure-resource-manager/).

In the folder [arm-templates](../arm-templates), you find ARM
templates for each of the above mentioned resources.

Deployments through ARM templates respect the concept of idempotence. When a
deployment is done multiple times using ARM, the infrastructure end state will
be the same.

### Parameter Files
For each resource defined in an ARM template, you will find multiple additional parameter files. <br>
There is one parameter file for each environment (dev, int, prd), which should be called `{resourcename}.parameters.{environment}.json`. So if you have a template for a storage account defined in an ARM template called `storageaccount.json` you should find (at least) three additional files called `storageaccount.parameters.dev.json`, `storageaccount.parameters.int.json` and `storageaccount.parameters.pro.json`.

## Infrastructure Automated Build & Release

A CI/CD pipeline in ADO is available to incrementally deploy updates to the
existing environment(s), and is defined under
[ado-pipe-staged-infra-release.yml](./infrastructure/deploy-infra/arm/ado-pipe-staged-infra-release.yml).

When working with ARM for automation scenarios, deployments are by default
performed in an incremental way. Meaning, if the resources described in the ARM
templates do not exist yet in the resource group, they will be created. If the
task is run again, only changes are applied on the existing infrastructure.

The infrastructure ADO pipeline consists of the following high-level stages:
building and validating the infrastructure-as-code templates; deploying the
infrastructure to an integration environment; validating the functional working
of the environment, testing the functional working of custom roles, cleaning up
the integration environment again (cost-aspect), deploying to dev/staging/etc.

Stages are run sequentially, with downstream stages to execute only if upstream
stages succeeded.

### ADO pipeline templates

Azure DevOps allows for templating parts of the pipelines, allowing for re-use.
Both shared infrastructure and workspace deployment steps are parameterized and
available as templates. The template `mlenv` can be used to deploy an entire
environment with shared infrastructure and n workspaces.

* [ado-template-k8env.yml](infrastructure/deploy-infra/arm/ado-template-k8env.yml)
* [ado-template-k8env-sharedinfra.yml](infrastructure/deploy-infra/arm/ado-template-k8env-sharedinfra.yml)

