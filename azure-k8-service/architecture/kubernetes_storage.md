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
Is basically temporary scratch space that is stollen from host underlying machine, it is exposed to all the containers of a pod. If you want to share files between containers of a pods you setup an `emptyDir` volume. The pod definition has to specify the volume type (in-line reference not via PV/PVC). Data exists only during pod lifecycle, following is an example pod definition.


```yml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - image: k8s.gcr.io/container1
    name: container1
    volumeMounts:
    - mountPath: /shared
      name: shared-scratch-space
  - image: k8s.gcr.io/container2
    name: container2
    volumeMounts:
    - mountPath: /shared
      name: shared-scratch-space
  volumes:
  - name: shared-scratch-space
    emptyDir: {}
```

`container1` and `container2` both of them mount a single volume which is an `emptyDir` called `shared-scratch-space` into a mount path inside a container at `/shared` if either of these containers write into that path it's visible by the other confiner.

>NOTE: If we move this pod YAML definition into any cluster it will work exactly the same ways.

Secret, ConfigMap and DownwardAPI are basically creating emptyDir and pre populate it with data from Kubernetes API. For example a secret volume allows that a secret from kubernetes API to be exposed a file to pod. 

#### Remote Storage
It exist beyond the lifecycle of any pod. This allows data to be persisted so you can actually have stateful services. They ca be refered either in-line or via PV/PVC objects. Remote storage is what enables kubernetes to be able to shuffle your workload around because it decouples your storage from your compute. The pod that is serving up your service can be terminated on nay node for any reason and the sate for that application is available from remote storage regardless of where your pod gets scheduled. Following is the yaml definition of a pod using remote storage


```yml
apiVersion: v1
kind: Pod
metadata:
  name: sleepypod
spec:
  volumes:
    - name: data
      gcePersistentDisk:
        pdName: panda-disk
        fsType: ext4
  containers:
    - name: sleepycontainer
      image: gcr.io/google_containers/busybox
      command:
        - sleep
        - "6000"
      volumeMounts:
        - name: data
          mountPath: /data
          readOnly: false
```
We have a single `busybox` container, it starts and after `6000` seconds it will go to sleep. We have GCE persistent disk and we specify the name and the file system, then we specify where it should be mounted in this case `/data`. Now that this container is started any data that is written to that path is persisted to that persistent disk. If the pod is terminated and moved from one machine to another machine that data comes along with it. And Kubernetes will automatically take care of attaching the column to the correct node and mounting to make it available inside the containers. 

>WARNING: Do not reference volumes directly in the pod, the above yaml wont work anywhere except google cloud platform, where GCE persistent disks are amiable

To address this problem we have to understand PV/PVC

#### Persistent Volume & Persistent Volume Claims


