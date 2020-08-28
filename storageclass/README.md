# StorageClass

#### PersistentVolume이 지원하는 액세스 모드
| 모드| 설명|
| --- |:--- |
| ReadWriteOnce | 볼륨은 단일 노드에 의한 읽기-쓰기로 마운트될 수 있습니다. |
| ReadOnlyMany | 볼륨은 여러 노드에 의한 읽기 전용으로 마운트될 수 있습니다. |
| ReadWriteMany | 볼륨은 여러 노드에 의한 읽기-쓰기로 마운트될 수 있습니다. </br> Compute Engine 영구 디스크에서 지원하는 PersistentVolume은 이 액세스 모드를 지원하지 않습니다. |

### 영역설정
```
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ gcloud config set compute/zone asia-northeast3
Updated property [compute/zone].
```  

### Create a Cloud Filestore volume  

#### Enable the required Google APIs
```
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ gcloud services enable file.googleapis.com
Operation "operations/acf.61d4c240-643c-4c06-9b4e-3d75bc96f995" finished successfully
```

#### Create a Cloud Filestore instance with 1TB of storage capacity  
- 주의 : 1TB 이하로는 만들어 지지 않음 
```
ORG=[YOUR_ORG]
BILLING_ACCOUNT=[YOUR_BILLING_ACCOUNT_NAME]
PROJECT="ttc-team-14"
ZONE="asia-northeast3-a"
FS="ttc-fs"
gcloud beta filestore instances create ${FS} \
    --project=${PROJECT} \
    --zone=${ZONE} \
    --tier=STANDARD \
    --file-share=name="volumes",capacity=1TB \
    --network=name="default"
Waiting for [operation-1598588704642-5ade86fe1d66f-21df1de3-90dd6971] to 
Waiting for [operation-1598588704642-5ade86fe1d66f-21df1de3-90dd6971] to finish...done.
taeeyoul@cloudshell:~/workspace/storageclass/nfs-client-provisioner (ttc-team-14)$ gcloud beta filestore instances delete ttc-fs --zone $ZONE
You are about to delete Cloud Filestore instance
projects/ttc-team-14/locations/asia-northeast3-a/instances/ttc-fs.
Are you sure?
Do you want to continue (Y/n)?  y
Waiting for [operation-1598590422104-5ade8d64039db-c36e77f8-193d6afb] to finish...done.
gcloud beta filestore instances create ${FS} \
    --project=${PROJECT} \
    --zone=${ZONE} \
    --tier=STANDARD \
    --file-share=name="volumes",capacity=1TB \
    --network=name="vpc-team14"
```

#### Retrieve the IP address of the Cloud Filestore instance  
```
FSADDR=$(gcloud beta filestore instances describe ${FS} \
     --project=${PROJECT} \
     --zone=${ZONE} \
     --format="value(networks.ipAddresses[0])")
```

```
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ FSADDR=$(gcloud beta filestore instances describe ${FS} \
     --project=${PROJECT} \
     --zone=${ZONE} \
     --format="value(networks.ipAddresses[0])")
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ echo $FSADDR
10.209.54.42
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ gcloud beta filestore instances describe ${FS} \
>      --project=${PROJECT} \
>      --zone=${ZONE}
createTime: '2020-08-28T04:25:06.326170658Z'
fileShares:
- capacityGb: '1024'
  name: volumes
name: projects/ttc-team-14/locations/asia-northeast3-a/instances/ttc-fs
networks:
- ipAddresses:
  - 10.209.54.42
  network: default
  reservedIpRange: 10.209.54.40/29
state: READY
tier: STANDARD
```

#### Deploy the NFS-Client Provisioner
```
helm install stable/nfs-client-provisioner --name ttc-infra --set nfs.server=${FSADDR} --set nfs.path=/volumes
watch kubectl get po -l app=nfs-client-provisioner
```

#### Make a Persistent Volume Claim  
```
helm install --name postgresql --set persistence.storageClass=nfs-client stable/postgresql
watch kubectl get po -l app=postgresql
```

```
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ tar -xzvf nfs-client-provisioner-1.2.9.tgz
nfs-client-provisioner/Chart.yaml
nfs-client-provisioner/values.yaml
nfs-client-provisioner/templates/_helpers.tpl
nfs-client-provisioner/templates/clusterrole.yaml
nfs-client-provisioner/templates/clusterrolebinding.yaml
nfs-client-provisioner/templates/deployment.yaml
nfs-client-provisioner/templates/persistentvolume.yaml
nfs-client-provisioner/templates/persistentvolumeclaim.yaml
nfs-client-provisioner/templates/podsecuritypolicy.yaml
nfs-client-provisioner/templates/role.yaml
nfs-client-provisioner/templates/rolebinding.yaml
nfs-client-provisioner/templates/serviceaccount.yaml
nfs-client-provisioner/templates/storageclass.yaml
nfs-client-provisioner/.helmignore
nfs-client-provisioner/OWNERS
nfs-client-provisioner/README.md
nfs-client-provisioner/ci/test-values.yaml
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ cd nfs-client-provisioner
taeeyoul@cloudshell:~/workspace/storageclass/nfs-client-provisioner (ttc-team-14)$ ls
Chart.yaml*  ci/  OWNERS*  README.md*  templates/  values.yaml*
taeeyoul@cloudshell:~/workspace/storageclass/nfs-client-provisioner (ttc-team-14)$ vi values.yaml
nfs:
  server: 10.209.54.42
  # path: /ifs/kubernetes
  path: /volumes
  mountOptions:
taeeyoul@cloudshell:~/workspace/storageclass/nfs-client-provisioner (ttc-team-14)$ echo $FSADDR
10.209.54.42

taeeyoul@cloudshell:~/workspace/storageclass/nfs-client-provisioner (ttc-team-14)$ helm install nfs-cp . -n ttc-infra -f values.yaml
NAME: nfs-cp
LAST DEPLOYED: Fri Aug 28 04:39:31 2020
NAMESPACE: ttc-infra
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

* Pod 생성 실패 - FSADDR 를 잘못 기술한 경우
```
taeeyoul@cloudshell:~/workspace/storageclass/nfs-client-provisioner (ttc-team-14)$ ki describe pod nfs-cp-nfs-client-provisioner-757b47d9b5-47xtp
Name:           nfs-cp-nfs-client-provisioner-757b47d9b5-47xtp
Namespace:      ttc-infra
Priority:       0
Node:           gke-cluster-team14-worker-pool-fee3fe68-3xfh/10.10.0.18
Start Time:     Fri, 28 Aug 2020 05:17:25 +0000
Labels:         app=nfs-client-provisioner
                pod-template-hash=757b47d9b5
                release=nfs-cp
Annotations:    <none>
Status:         Pending
IP:
IPs:            <none>
Controlled By:  ReplicaSet/nfs-cp-nfs-client-provisioner-757b47d9b5
Containers:
  nfs-client-provisioner:
    Container ID:
    Image:          quay.io/external_storage/nfs-client-provisioner:v3.1.0-k8s1.11
    Image ID:
    Port:           <none>
    Host Port:      <none>
    State:          Waiting
      Reason:       ContainerCreating
    Ready:          False
    Restart Count:  0
    Limits:
      cpu:     100m
      memory:  128Mi
    Requests:
      cpu:     100m
      memory:  128Mi
    Environment:
      PROVISIONER_NAME:  cluster.local/nfs-cp-nfs-client-provisioner
      NFS_SERVER:        10.209.54.42
      NFS_PATH:          /volumes
    Mounts:
      /persistentvolumes from nfs-client-root (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from nfs-cp-nfs-client-provisioner-token-nlxkp (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
Volumes:
  nfs-client-root:
    Type:      NFS (an NFS mount that lasts the lifetime of a pod)
    Server:    10.209.54.42
    Path:      /volumes
    ReadOnly:  false
  nfs-cp-nfs-client-provisioner-token-nlxkp:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  nfs-cp-nfs-client-provisioner-token-nlxkp
    Optional:    false
QoS Class:       Guaranteed
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type     Reason       Age                  From                                                   Message
  ----     ------       ----                 ----                                                   -------
  Normal   Scheduled    4m48s                default-scheduler                                      Successfully assigned ttc-infra/nfs-cp-nfs-client-provisioner-757b47d9b5-47xtp to gke-cluster-team14-worker-pool-fee3fe68-3xfh
  Warning  FailedMount  28s (x2 over 2m45s)  kubelet, gke-cluster-team14-worker-pool-fee3fe68-3xfh  Unable to attach or mount volumes: unmounted volumes=[nfs-client-root], unattached volumes=[nfs-client-root nfs-cp-nfs-client-provisioner-toke
n-nlxkp]: timed out waiting for the condition
  Warning  FailedMount  25s                  kubelet, gke-cluster-team14-worker-pool-fee3fe68-3xfh  MountVolume.SetUp failed for volume "nfs-client-root" : mount failed: exit status 1
Mounting command: systemd-run
Mounting arguments: --description=Kubernetes transient mount for /var/lib/kubelet/pods/940947c4-579e-42d7-8bd5-803481bf3ad4/volumes/kubernetes.io~nfs/nfs-client-root --scope -- /home/kubernetes/containerized_mounter/mounter mount -t nfs 10.20
9.54.42:/volumes /var/lib/kubelet/pods/940947c4-579e-42d7-8bd5-803481bf3ad4/volumes/kubernetes.io~nfs/nfs-client-root
Output: Running scope as unit: run-r730aebef03cc4fe99c4d05dddbc73d9c.scope
Mount failed: mount failed: exit status 32
Mounting command: chroot
Mounting arguments: [/home/kubernetes/containerized_mounter/rootfs mount -t nfs 10.209.54.42:/volumes /var/lib/kubelet/pods/940947c4-579e-42d7-8bd5-803481bf3ad4/volumes/kubernetes.io~nfs/nfs-client-root]
Output: mount.nfs: Connection timed out
taeeyoul@cloudshell:~/workspace/storageclass/nfs-client-provisioner (ttc-team-14)$ ki describe pod nfs-cp-nfs-client-provisioner-757b47d9b5-47xtp
Name:           nfs-cp-nfs-client-provisioner-757b47d9b5-47xtp
Namespace:      ttc-infra
Priority:       0
Node:           gke-cluster-team14-worker-pool-fee3fe68-3xfh/10.10.0.18
Start Time:     Fri, 28 Aug 2020 05:17:25 +0000
Labels:         app=nfs-client-provisioner
                pod-template-hash=757b47d9b5
                release=nfs-cp
Annotations:    <none>
Status:         Pending
IP:
IPs:            <none>
Controlled By:  ReplicaSet/nfs-cp-nfs-client-provisioner-757b47d9b5
Containers:
  nfs-client-provisioner:
    Container ID:
    Image:          quay.io/external_storage/nfs-client-provisioner:v3.1.0-k8s1.11
    Image ID:
    Port:           <none>
    Host Port:      <none>
    State:          Waiting
      Reason:       ContainerCreating
    Ready:          False
# Default values for nfs-client-provisioner.
    Restart Count:  0
    Limits:
      cpu:     100m
      memory:  128Mi
    Requests:
      cpu:     100m
      memory:  128Mi
    Environment:
      PROVISIONER_NAME:  cluster.local/nfs-cp-nfs-client-provisioner
      NFS_SERVER:        10.209.54.42
      NFS_PATH:          /volumes
    Mounts:
      /persistentvolumes from nfs-client-root (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from nfs-cp-nfs-client-provisioner-token-nlxkp (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             False
  ContainersReady   False
  PodScheduled      True
Volumes:
  nfs-client-root:
    Type:      NFS (an NFS mount that lasts the lifetime of a pod)
    Server:    10.209.54.42
    Path:      /volumes
    ReadOnly:  false
  nfs-cp-nfs-client-provisioner-token-nlxkp:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  nfs-cp-nfs-client-provisioner-token-nlxkp
    Optional:    false
QoS Class:       Guaranteed
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type     Reason       Age                 From                                                   Message
  ----     ------       ----                ----                                                   -------
  Normal   Scheduled    5m9s                default-scheduler                                      Successfully assigned ttc-infra/nfs-cp-nfs-client-provisioner-757b47d9b5-47xtp to gke-cluster-team14-worker-pool-fee3fe68-3xfh
  Warning  FailedMount  49s (x2 over 3m6s)  kubelet, gke-cluster-team14-worker-pool-fee3fe68-3xfh  Unable to attach or mount volumes: unmounted volumes=[nfs-client-root], unattached volumes=[nfs-client-root nfs-cp-nfs-client-provisioner-token
-nlxkp]: timed out waiting for the condition
  Warning  FailedMount  46s                 kubelet, gke-cluster-team14-worker-pool-fee3fe68-3xfh  MountVolume.SetUp failed for volume "nfs-client-root" : mount failed: exit status 1
Mounting command: systemd-run
Mounting arguments: --description=Kubernetes transient mount for /var/lib/kubelet/pods/940947c4-579e-42d7-8bd5-803481bf3ad4/volumes/kubernetes.io~nfs/nfs-client-root --scope -- /home/kubernetes/containerized_mounter/mounter mount -t nfs 10.20
9.54.42:/volumes /var/lib/kubelet/pods/940947c4-579e-42d7-8bd5-803481bf3ad4/volumes/kubernetes.io~nfs/nfs-client-root
Output: Running scope as unit: run-r730aebef03cc4fe99c4d05dddbc73d9c.scope
Mount failed: mount failed: exit status 32
Mounting command: chroot
Mounting arguments: [/home/kubernetes/containerized_mounter/rootfs mount -t nfs 10.209.54.42:/volumes /var/lib/kubelet/pods/940947c4-579e-42d7-8bd5-803481bf3ad4/volumes/kubernetes.io~nfs/nfs-client-root]
Output: mount.nfs: Connection timed out
```

* pod 배포 확인  
```
taeeyoul@cloudshell:~/workspace/storageclass/nfs-client-provisioner (ttc-team-14)$ ki get pod -lrelease=nfs-cp
NAME                                             READY   STATUS    RESTARTS   AGE
nfs-cp-nfs-client-provisioner-6b69b4d57c-mfgjk   1/1     Running   0          6m53s
```

* 정상배포된 Pod 내용 보기  
```
taeeyoul@cloudshell:~/workspace/storageclass/nfs-client-provisioner (ttc-team-14)$ ki describe pod nfs-cp-nfs-client-provisioner-6b69b4d57c-mfgjk
Name:         nfs-cp-nfs-client-provisioner-6b69b4d57c-mfgjk
Namespace:    ttc-infra
Priority:     0
Node:         gke-cluster-team14-worker-pool-fee3fe68-3xfh/10.10.0.18
Start Time:   Fri, 28 Aug 2020 05:24:20 +0000
Labels:       app=nfs-client-provisioner
              pod-template-hash=6b69b4d57c
              release=nfs-cp
Annotations:  <none>
Status:       Running
IP:           192.168.2.82
IPs:
  IP:           192.168.2.82
Controlled By:  ReplicaSet/nfs-cp-nfs-client-provisioner-6b69b4d57c
Containers:
  nfs-client-provisioner:
    Container ID:   docker://97510fc1e5c499dc2fc3c94d2164f07943268e1d84920c6d8a9b7bbee7f034cc
    Image:          quay.io/external_storage/nfs-client-provisioner:v3.1.0-k8s1.11
    Image ID:       docker-pullable://quay.io/external_storage/nfs-client-provisioner@sha256:cdbccbf53d100b36eae744c1cb07be3d0d22a8e64bb038b7a3808dd29c174661
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Fri, 28 Aug 2020 05:26:20 +0000
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     100m
      memory:  128Mi
    Requests:
      cpu:     100m
      memory:  128Mi
    Environment:
      PROVISIONER_NAME:  cluster.local/nfs-cp-nfs-client-provisioner
      NFS_SERVER:        10.92.102.162
      NFS_PATH:          /volumes
    Mounts:
      /persistentvolumes from nfs-client-root (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from nfs-cp-nfs-client-provisioner-token-spnm7 (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  nfs-client-root:
    Type:      NFS (an NFS mount that lasts the lifetime of a pod)
    Server:    10.92.102.162
    Path:      /volumes
    ReadOnly:  false
  nfs-cp-nfs-client-provisioner-token-spnm7:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  nfs-cp-nfs-client-provisioner-token-spnm7
    Optional:    false
QoS Class:       Guaranteed
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason     Age    From                                                   Message
  ----    ------     ----   ----                                                   -------
  Normal  Scheduled  8m14s  default-scheduler                                      Successfully assigned ttc-infra/nfs-cp-nfs-client-provisioner-6b69b4d57c-mfgjk to gke-cluster-team14-worker-pool-fee3fe68-3xfh
  Normal  Pulling    6m19s  kubelet, gke-cluster-team14-worker-pool-fee3fe68-3xfh  Pulling image "quay.io/external_storage/nfs-client-provisioner:v3.1.0-k8s1.11"
  Normal  Pulled     6m15s  kubelet, gke-cluster-team14-worker-pool-fee3fe68-3xfh  Successfully pulled image "quay.io/external_storage/nfs-client-provisioner:v3.1.0-k8s1.11"
  Normal  Created    6m14s  kubelet, gke-cluster-team14-worker-pool-fee3fe68-3xfh  Created container nfs-client-provisioner
  Normal  Started    6m14s  kubelet, gke-cluster-team14-worker-pool-fee3fe68-3xfh  Started container nfs-client-provisioner
```  
  

#### Default StorageClass 변경  
```
aeeyoul@cloudshell:~/workspace/storageclass/nfs-client-provisioner (ttc-team-14)$ kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
storageclass.storage.k8s.io/standard patched
taeeyoul@cloudshell:~/workspace/storageclass/nfs-client-provisioner (ttc-team-14)$ ki get sc
NAME                   PROVISIONER                                   AGE
nfs-client (default)   cluster.local/nfs-cp-nfs-client-provisioner   5m24s
standard               kubernetes.io/gce-pd                          7d21h
ttc-sc                 kubernetes.io/gce-pd                          2d4h
```

### NFS Storage  
#### GCP Persistent Disk 프로비저닝  
```
gcloud compute disks create --size=2GB --zone=asia-northeast3-a nfs-disk
```
  
#### GKE에서 NFS 서버 설정  
```
gcloud container clusters get-credentials cluster-team14 —zone asia-northeast3 —project TTC-Team-14
kubectl create -f nfs-server-deplo.yaml
kubectl create -f nfs-clusterip-svc.yaml
kubectl create -f nfs-pv-pvc.yaml
```


### Regional Storage Class 생성  
#### manifest file  
```
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ cat region-sc.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: ttc-sc
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-standard
  replication-type: regional-pd
volumeBindingMode: WaitForFirstConsumer
allowedTopologies:
- matchLabelExpressions:
  - key: failure-domain.beta.kubernetes.io/zone
    values:
    - asia-northeast3-a
    - asia-northeast3-b
    - asia-northeast3-c
```

#### default StroageClass 변경
```
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ kubectl get sc
NAME                 PROVISIONER            AGE
standard (default)   kubernetes.io/gce-pd   5d17h
tcc-sc               kubernetes.io/gce-pd   6s
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ kubectl get sc standard -o yaml
allowVolumeExpansion: true
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
  creationTimestamp: "2020-08-20T07:38:57Z"
  labels:
    addonmanager.kubernetes.io/mode: EnsureExists
  name: standard
  resourceVersion: "268"
  selfLink: /apis/storage.k8s.io/v1/storageclasses/standard
  uid: 099bb4f3-f266-4a03-bddb-29016cbb33ed
parameters:
  type: pd-standard
provisioner: kubernetes.io/gce-pd
reclaimPolicy: Delete
volumeBindingMode: Immediate
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ kubectl get sc tcc-sc -o yaml
allowedTopologies:
- matchLabelExpressions:
  - key: failure-domain.beta.kubernetes.io/zone
    values:
    - asia-northeast3-a
    - asia-northeast3-b
    - asia-northeast3-c
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  creationTimestamp: "2020-08-26T00:43:36Z"
  name: tcc-sc
  resourceVersion: "2444548"
  selfLink: /apis/storage.k8s.io/v1/storageclasses/tcc-sc
  uid: 1e775e05-aceb-4f47-a33d-2db701b426f7
parameters:
  replication-type: regional-pd
  type: pd-standard
provisioner: kubernetes.io/gce-pd
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

```
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
storageclass.storage.k8s.io/standard patched
```

```
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ kubectl patch storageclass ttc-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
storageclass.storage.k8s.io/ttc-sc patched
```

```
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ kubectl get sc
NAME               PROVISIONER            AGE
standard           kubernetes.io/gce-pd   5d17h
ttc-sc (default)   kubernetes.io/gce-pd   25s
```


```
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ kubectl get pvc
NAME        STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
test1-pvc   Pending                                      ttc-sc         12m
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ kubectl describe pvc
Name:          test1-pvc
Namespace:     default
StorageClass:  ttc-sc
Status:        Pending
Volume:
Labels:        <none>
Annotations:   volume.beta.kubernetes.io/storage-provisioner: kubernetes.io/gce-pd
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:
Access Modes:
VolumeMode:    Filesystem
Mounted By:    <none>
Events:
  Type     Reason              Age                  From                         Message
  ----     ------              ----                 ----                         -------
  Warning  ProvisioningFailed  107s (x12 over 12m)  persistentvolume-controller  Failed to provision volume with StorageClass "ttc-sc": googleapi: Error 400: Invalid value for field 'resource.sizeGb': '1'. 
Disk size cannot be smaller than 200 GB., invalid
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ kubectl get pvc
NAME        STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
test1-pvc   Pending                                      ttc-sc         12m
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ kubectl delete pvc test1-pvc
persistentvolumeclaim "test1-pvc" deleted
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ kubectl create -f test-pvc.yaml
persistentvolumeclaim/test1-pvc created
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ kubectl get pvc
NAME        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
test1-pvc   Bound    pvc-0ca502e5-3be3-4227-b87b-42632f6f4041   200Gi      RWO            ttc-sc         5s
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ ls -lt
total 8
-rw-r--r-- 1 taeeyoul taeeyoul 209 Aug 26 01:32 test-pvc.yaml
-rw-r--r-- 1 taeeyoul taeeyoul 512 Aug 26 01:10 region-sc.yaml
```
