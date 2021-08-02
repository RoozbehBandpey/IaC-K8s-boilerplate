# Kubernetes Storage
Summary of [Saad Ali's talk in KubeCon](https://www.youtube.com/watch?v=uSxlgK1bCuA)

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
It exist beyond the lifecycle of any pod. This allows data to be persisted so you can actually have stateful services. They ca be refereed either in-line or via PV/PVC objects. Remote storage is what enables kubernetes to be able to shuffle your workload around because it decouples your storage from your compute. The pod that is serving up your service can be terminated on nay node for any reason and the sate for that application is available from remote storage regardless of where your pod gets scheduled. Following is the yaml definition of a pod using remote storage.


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
It addresses workload portability for storage across clusters. Decouples storage implementation from storage consumption. You cluster administrators can be aware of storage that exists within that cluster but you end user should not haver to. What cluster administrator can do is that they can come along and create persistent volume objects within kubernetes API to represent volumes that can then be used by users. Inside the persistent volume object they define the actual storage that will be used. 

This is basically the cluster administrator going ahead and provisioning these volumes to make them available for consumption

```yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: myPV1
spec:
  accessMode:
    - ReadWriteOnce
      capacity:
        storage: 10Gi
        persistentVolumeReclaimPolicy: Retain
        gcePersistentDisk:
          fsType: ext4
          pdName: panda-disk
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: myPV2
spec:
  accessMode:
    - ReadWriteOnce
      capacity:
        storage: 100Gi
        persistentVolumeReclaimPolicy: Retain
        gcePersistentDisk:
          fsType: ext4
          pdName: panda-disk2
```

Now that somebody comes along and they want to use the storage then have to create a persistent volume claim object. It does not contain any specific implementation details it simply a generic description oif type of storage that user wants 

```yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myPVC
  namespace: testns
spec:
  accessMode:
    - ReadWriteOnce
      resources:
        requests: 100Gi
```
Now when user creates this PVC objects, kubernetes automatically figures out what PVs are available and binds the claim to one of the PV that is available

The beauty of this is that nows your workload and pod definition can be portable so instead of reference the `gce` persistent disk directly the user simply reference the persistent volume claim now if you where to move this pod yaml to a cluster that doe nt have gce disks it will still work as long as the cluster administrator has made some PVs available to the user, if I was working on AWS I could expose persistent volume that points to amazon `EBS` disks if I was running on-prem I could expose Gluster file system etc., 

#### Dynamic Provisioning & Storage Classes

Having cluster administrator prep provision volume is both painful and wasteful. Dynamic provisioning create new volumes on-demand (when requested by user), eliminates the need for cluster administrators to pre-provision storage. The way this works is through another kubernetes API object called storage class.


```yml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: slow
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-standard
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: fast
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
```


* Dynamic provisioning "enabled" by creating StorageClass
* `StorageClass` defines the parameters used during creation
* `StorageClass` parameters opaque to Kubernetes so storage providers can expose any number of custom parameters for the cluster admin use

The creation of storage class is signal to cluster administrator that dictates enablement of dynamic provisioning. So as a cluster adminstrator instead of creating PV objects what I can do is to create storage class that points to spesific volume plugin in this case `gce-pd` and spesicy set of parameters to use when that volume is provisioned so think of this as a tempolatye for when a new volume needs to be created. 

The benefit is you can create same storage classes on your own cluster which may be runnin g on prem and point to your own volume plugin. The cluster administrator must know they type of storage class objects that are avilable. 

How do you actually create volume?

As end user very little changes, you still request storage in same way. Meaning you create a claim for a generic storage. But the only difference is that you have to spesify the storage class that youy want

```yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myPVC
  namespace: testns
spec:
  accessMode:
    - ReadWriteOnce
      resources:
        requests: 
          storage: 100Gi
      storageClassName: fast
```

As end user we don't care wheather it's ssd or hdd, number of iops etc., I just go look at the storage classes that all exist there on cluster and specify oine to use. once that Persistent Volume Claim is used what kubernetes will do is it will look at storage classes object call out to volume plugin that storage class references to create a new volume, one a new volume is created kubernetes will automatically create a presistant volume api object to represent that volume and bind thew persistent volume claim with persistent volume. 

And then you can reference the volume in exactly the same way as before. And this is portable across clusters.

```yml
apiVersion: v1
kind: Pod
metadata:
  name: sleepypod
spec:
  volumes:
    - name: data
      PersistentVolumeClaim:
        claimName: myvpc
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

You can also choose specific storage class as default, if you do so what does aloows is the end user no longer has to specify storage class in their persistent colume claim object. 

* Default Sorage Classes enable dynamic provisioning even when StorageClass not specified
* Pre-installed Default Storage Classes
  * Amazon AWS-EBS colume
  * Google Cloud (GCE/GKE) - GCE PD
  * Openstack - Cinder Volume

```yml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: slow
  annotation:
    storageclass.beta.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-standard
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: fast
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
```

> Question: Does the abstraction of CSI being out of tree affect performance, latency, IO?
> Answer: No! Because kubernetes is not ion data path, kubernetes strictly is in controll path. The responsibility of kubernetes is to set up a volume and expose it either as file or blovk into thje container and then get out of ther way so when you read and write from a file system, you are wrting through kernel to the undserlying storage system.

### Container Storage Interface

