# Container monitoring
In order to have better visibility over pods and services we have to set up a monitoring solution for our cluster. Prometheus is an open-source monitoring framework. It provides out-of-the-box monitoring capabilities for Kubernetes.

Prometheus supports following concepts:
* **Metric Collection**: Prometheus uses the pull model to retrieve metrics over HTTP. There is an option to push metrics to Prometheus using `Pushgateway` for use cases where Prometheus cannot Scrape the metrics. One such example is collecting custom metrics from short-lived kubernetes jobs & Cronjobs

* **Metric Endpoint**: The systems that you want to monitor using Prometheus should expose the metrics on an `/metrics` endpoint. Prometheus uses this endpoint to pull the metrics in regular intervals.

* **PromQL**: Prometheus comes with `PromQL`, a very flexible query language that can be used to query the metrics in the Prometheus dashboard. Also, the PromQL query will be used by Prometheus UI and Grafana to visualize metrics.

* **Prometheus Exporters**: Exporters are libraries which converts existing metric from third-party apps to Prometheus metrics format. There are many official and community Prometheus exporters . One example is, Prometheus node exporter. It exposes all Linux system-level metrics in Prometheus format.

* **TSDB (time-series database)**: Prometheus uses TSDB for storing all the data. By default, all the data gets stored locally. However, there are options to integrate remote storage for Prometheus TSDB.


Latest Prometheus is available as a docker image in its official docker hub account. We will use that, but from our own registry.

```shell
az acr credential show -n mmcacrdev --query "passwords[0].value" -o tsv
docker login mmcacrdev.azurecr.io -u mmcacrdev -p
docker pull prom/prometheus

docker tag prom/prometheus mmcacrdev.azurecr.io/prometheus:v1

docker push mmcacrdev.azurecr.io/prometheus:v1
```
 
Now `Prometheus` image is available from `mmcacrdev.azurecr.io/prometheus:v1`
 
### Create a Namespace & ClusterRole
Create a Kubernetes namespace for all our monitoring components

```shell
$ kubectl create namespace monitoring
# Out
namespace/monitoring created
```

Create an RBAC policy with read access to required API groups and bind the policy to the monitoring namespace.
>NOTE: Prometheus uses Kubernetes APIs to read all the available metrics from Nodes, Pods, Deployments, etc.

It is defined in [clusterRole.yaml](./k8_yaml_files/clusterRole.yaml) 

```shell
kubectl create -f clusterRole.yaml
```

### Create a Config Map To Externalize Prometheus Configurations
All configurations for Prometheus are part of `prometheus.yaml` file and all the alert rules for Alertmanager are configured in `prometheus.rules`.

* prometheus.yaml: This is the main Prometheus configuration which holds all the scrape configs, service discovery details, storage locations, data retention configs, etc)
* prometheus.rules: This file contains all the Prometheus alerting rules
By externalizing Prometheus configs to a Kubernetes config map, you don’t have to build the Prometheus image whenever you need to add or remove a configuration. You need to update the config map and restart the Prometheus pods to apply the new configuration.

```shell
kubectl create -f config-map.yaml
```

the config for collecting metrics from a collection of endpoints is called a `job`

We have the following scrape jobs in our Prometheus scrape configuration.

* kubernetes-apiservers: It gets all the metrics from the API servers.
* kubernetes-nodes: It collects all the kubernetes node metrics.
* kubernetes-pods: All the pod metrics get discovered if the pod metadata is annotated with prometheus.io scrape and prometheus.io/port annotations.
* kubernetes-cadvisor: Collects all cAdvisor metrics.
* kubernetes-service-endpoints: All the Service endpoints are scrapped if the service metadata is annotated with prometheus.io/scrape and prometheus.io/port annotations. It can be used for black-box monitoring.

### Create a Prometheus Deployment

we are mounting the Prometheus config map as a file inside `/etc/prometheus`

we are not using any persistent storage volumes for Prometheus storage as it is a basic setup. When setting up Prometheus for production uses cases, make sure you add persistent storage to the deployment.

```shell
kubectl apply -f prometheus-deployment.yaml 
```

### Setting Up Kube State Metrics
Kube state metrics service exposes all the metrics on `/metrics` URI. Prometheus can scrape all the metrics exposed by kube state metrics.

* Monitor node status, node capacity (CPU and memory)
* Monitor replica-set compliance (desired/available/unavailable/updated status of replicas per deployment)
* Monitor pod status (waiting, running, ready, etc)
* Monitor the resource requests and limits.
* Monitor Job & Cronjob Status

### Kube State Metrics Setup
kube state metrics is available as a public docker image. You will have to deploy the following Kubernetes objects for kube state metrics to work.

1. A Service Account
2. Cluster Role – For kube state metrics to access all the Kubernetes API objects.
3. Cluster Role Binding – Binds the service account with the cluster role.
4. Kube State Metrics Deployment
5. Service – To expose the metrics
All the above kube state metrics objects will be deployed in the `kube-system` namespace
```
kubectl apply -f kube-state-metrics-configs/


kubectl get deployments kube-state-metrics -n kube-system
```


### Connecting To Prometheus Dashboard Using Kubectl port forwarding

```
kubectl get pods --namespace=monitoring
kubectl port-forward prometheus-deployment-c87cb6bb8-swdf8 8080:9090 -n monitoring
```


Now, if you access http://localhost:8080 on your browser, you will get the Prometheus home page.


### Ingress
The Ingress Controller sits in front of many services within a cluster and is the (most of the time) the only service of type LoadBalancer with a public IP in Kubernetes, routing traffic to your services and - depending on the implementation - can also add functionality like SSL termination, path rewrites, name based virtual hosts, IP whitelisting etc.

Let's install the ingress controller:

```
# create ingress namespace
$ kubectl create namespace ingress

namespace/ingress created

$ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

"ingress-nginx" has been added to your repositories

$ helm install recommender-ingress ingress-nginx/ingress-nginx --version 3.7.1 --set controller.service.externalTrafficPolicy=Local --namespace ingress

kubectl --namespace ingress get services