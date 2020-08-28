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

#### Create a Cloud Filestore instance with 100GB of storage capacity  
```
ORG=[YOUR_ORG]
BILLING_ACCOUNT=[YOUR_BILLING_ACCOUNT_NAME]
PROJECT="TTC-Team-14"
ZONE="asia-northeast3"
FS="ttc-fs"
gcloud beta filestore instances create ${FS} \
    --project=${PROJECT} \
    --zone=${ZONE} \
    --tier=STANDARD \
    --file-share=name="volumes",capacity=100GB \
    --network=name="default"
```

#### Retrieve the IP address of the Cloud Filestore instance  
```
FSADDR=$(gcloud beta filestore instances describe ${FS} \
     --project=${PROJECT} \
     --zone=${ZONE} \
     --format="value(networks.ipAddresses[0])")
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

### NFS Storage  
#### GCP Persistent Disk 프로비저닝  
```
gcloud compute disks create --size=2GB --zone=asia-northeast3 nfs-disk
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
