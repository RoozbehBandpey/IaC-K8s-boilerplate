# Deep Learning Infrastructure

Under the name deep learning infrastructure, we refer to all Azure resources
that are span up to facilitate ML experimentation. This includes lower-level
components such as storage and compute, configured within the IT4AD private
network, as well as resources operating at a higher level such as Azure Machine
Learning workspaces.

To promote central and non-redundant management of lower-level components you'll
find the following separation of resources in each environment.

* Shared Infrastructure

  * Storage Account ML Workspace: This is a shared storage account that is used
    by the ML-workspace instance related logs such as experiment logs and
    snapshots. A blob container is available per workspace, recognizable by its
    workspace id.
  * Storage account Data: this is a shared storage account that is used for the
    management of shared datasets, metrics and initialization networks.
  * Container Registry Staging: a shared registry for docker images that are yet
    to be tested.
  * Container Registry: the shared registry where docker images are pushed to
    that are considered 'healthy' i.e. tested. Model developers can pull
    training images from this registry.
  * Application Insights: provides monitoring capabilities up till code level;
    best supported when using Azure ML for inferencing services.
  * KeyVault: adds an additional security and management layer for keys &
    secrets, with increased access control, monitoring and eleminating the need
    to hosts keys in application code.

* Machine Learning resources by work package

  * Workspace instance: the top-level resource of the service; it provides asset
    management of compute resources, datastores, experiments and models.
    Moreover, provides access to experiment & pipeline run results and
    comparisons.
  * ML Compute instance: a managed cluster (Azure Batch) of virtual machines.

## ML Workspace configuration

All workspaces are pre-configured with a compute cluster and pre-registered
datastores.

Each workspace has a compute cluster that is pre-configured to scale up to a
configured number of nodes, specified as part of a variable group in ADO
available per environment. Job management and queueing capabilities are provided
for unattended run execution.

In Azure Machine Learning there is the concept of datastores, which allows for
the registration of Azure storage for management by Azure ML. By referencing
data in a datastore on experiment run submission, keys and datastore mounting
are provided as-a-service.

Each workspace has been pre-configured to connect with a set of datastores. A
[configuration
file](../arm-templates/mlworkspace/datastore_config.json)
prescribes which datastore should be attached during deployment to which
workspaces. Datastores can also be added programetically through the Azure ML
SDK or CLI post-deployment.

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
There is one parameter file for each environment (dev, int, pro), which should be called `{resourcename}.parameters.{environment}.json`. So if you have a template for a storage account defined in an ARM template called `storageaccount.json` you should find (at least) three additional files called `storageaccount.parameters.dev.json`, `storageaccount.parameters.int.json` and `storageaccount.parameters.pro.json`.

## Infrastructure Automated Build & Release

A CI/CD pipeline in ADO is available to incrementally deploy updates to the
existing environment(s), and is defined under
[ado-pipe-staged-infra-release.yml](ado-pipe-staged-infra-release.yml).

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

* [ado-template-mlenv.yml](ado-template-mlenv.yml)
* [ado-template-mlenv-sharedinfra.yml](ado-template-mlenv-sharedinfra.yml)
* [ado-template-mlenv-workspace.yml](ado-template-mlenv-workspace.yml)

## Custom Roles

To provide more finegrained and scoped access to resources by developers, a
custom role has been defined for a model developer. This role allows operations
on ML workspaces and limited operations on both storage accounts as well as
container registries.


