# Kubernetes Storage

One of the most important principals of kubernetes is workload portability. The idea is to abstract away the implementation from actual workload, meaning decoupling apps from infrastructure. This would potentially enable developers to write once and run anywhere and prevent vendor lock-in.

### The challenge with stateful services
Pods and replica sets abstract way compute and memory but they dint really address stateful services, the problem with state is that containers are inherently ephemeral, meaning there is no way to persist state inside of a container once a container is terminated everything that is written inside of that container is gone. Additionally containers cannot really share data across their boundaries., 

Focusing on workload potability kubernetes will address storage challenge storage types that have standardized file path, meaning the os will take care of writing file and block and the application does not need to be aware of how to do those things. Whereas for the other data sources the application has to have the logic implemented, some sort of SDk build inb the application that understands how to read and write in to theses different sources.

**Standardized data path (Posix, iSCSI)**
* File storage
    * NFS, SMB, etc
* Block storage
    * GCE PD, AWS EBS, iSCSI, Fibre, Channel, etc.
* File on Block Storage

**None Standardized Data Path**
* Object Storage
    * AWS S3, GCE GCS, etc.
* SQL Databases
    * MySQL, SQL Server, Postgre, stc.
* NoSQL Databases
    * MongoDB, ElasticSearch, etc.
* Pub Sub Systems
    * Apache Kafka, Google cloud Pub/Sub, AWS SNS, etc.
* Time series Databases
    * InfluxDB, Graphite, etc.
* etc


### Kubernetes Volume Plugins
A way to reference block device or mounted filesystem and make it available to all the containers inside of a pod. The lifecycle of the volume could be same as the life-cycle of the pod or it could extend beyond that

Kubernetes has many volume plugins

**Remote Storage**

* GCE Persistent Disk
* AWS Elastic Block Store
* Azure File Storage
* Azure Data Disk
* Dell EMC ScaleIO
* iSCSI
* Flocker
* NFS
* vSphere
* GlusterFS
* Ceph File and RBD
* Cinder
* Quobyte Volume
* FibreChannel
* VMware Photon PD

**Ephemeral Storage**
* EmptyDir
* Expose Kubernetes API
    * Secret
    * ConfigMap
    * DownwardAPI

**Local Persistent Volume (Beta)**

**Out-of-Tree**
* Flex (exec a binary)
* CSI

**Other**
* Host path


#### Ephemeral Storage