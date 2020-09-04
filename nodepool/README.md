# Node Pool

### Link  
[노드 풀 추가 및 관리](https://cloud.google.com/kubernetes-engine/docs/how-to/node-pools?hl=ko)  
[gcloud container node-pools create](https://cloud.google.com/sdk/gcloud/reference/container/node-pools/create?hl=ko)  


#### 클러스터 인증 정보 가져오기   
```
taeeyoul@cloudshell:~ (ttc-team-14)$ gcloud container clusters get-credentials cluster-team14 --region asia-northeast3 --project ttc-team-14
Fetching cluster endpoint and auth data.
```

#### 클러스터의 노드 풀 보기  
```
taeeyoul@cloudshell:~ (ttc-team-14)$ gcloud container node-pools list --cluster cluster-team14 --region asia-northeast3
NAME             MACHINE_TYPE   DISK_SIZE_GB  NODE_VERSION
ttc-worker-pool  e2-standard-4  30            1.16.13-gke.1
```


#### 노드 풀 크기 조정  

1) Quota 가 부족할 경우 오류
```
taeeyoul@cloudshell:~ (ttc-team-14)$ gcloud container clusters resize cluster-team14 --node-pool ttc-worker-pool --num-nodes=6 --region asia-northeast3
Pool [ttc-worker-pool] for [cluster-team14] will be resized to 6.
Do you want to continue (Y/n)?  y
ERROR: (gcloud.container.clusters.resize) PERMISSION_DENIED: Insufficient regional quota to satisfy request: resource "CPUS": request requires '60.0' and is short '25.0'. project has a quota of '4
8.0' with '35.0' available. View and manage quotas at https://console.cloud.google.com/iam-admin/quotas?usage=USED&project=ttc-team-14.
taeeyoul@cloudshell:~ (ttc-team-14)$ gcloud container clusters resize cluster-team14 --node-pool ttc-worker-pool --num-nodes=4 --region asia-northeast3
Pool [ttc-worker-pool] for [cluster-team14] will be resized to 4.
Do you want to continue (Y/n)?  y
ERROR: (gcloud.container.clusters.resize) PERMISSION_DENIED: Insufficient regional quota to satisfy request: resource "CPUS": request requires '36.0' and is short '1.0'. project has a quota of '48
.0' with '35.0' available. View and manage quotas at https://console.cloud.google.com/iam-admin/quotas?usage=USED&project=ttc-team-14.
taeeyoul@cloudshell:~ (ttc-team-14)$
```

2) 정상동작  
```
$ gcloud container clusters resize cluster-team14 --node-pool ttc-worker-pool --num-nodes=2 --region asia-northeast3                                             
Pool [ttc-worker-pool] for [cluster-team14] will be resized to 2.
Do you want to continue (Y/n)?  y
Resizing cluster-team14...done.
Updated [https://container.googleapis.com/v1/projects/ttc-team-14/zones/asia-northeast3/clusters/cluster-team14].
$ k get node
NAME                                               STATUS   ROLES    AGE     VERSION
gke-cluster-team14-ttc-worker-pool-99daac28-7pzb   Ready    <none>   3m59s   v1.16.13-gke.1
gke-cluster-team14-ttc-worker-pool-99daac28-cqhh   Ready    <none>   63m     v1.16.13-gke.1
gke-cluster-team14-ttc-worker-pool-abf04385-3pmh   Ready    <none>   63m     v1.16.13-gke.1
gke-cluster-team14-ttc-worker-pool-abf04385-vs40   Ready    <none>   4m3s    v1.16.13-gke.1
gke-cluster-team14-ttc-worker-pool-db5a2aa3-d2j8   Ready    <none>   4m      v1.16.13-gke.1
gke-cluster-team14-ttc-worker-pool-db5a2aa3-hn7m   Ready    <none>   63m     v1.16.13-gke.1
$ gcloud container clusters resize cluster-team14 --node-pool ttc-worker-pool --num-nodes=1 --region asia-northeast3 -q
Resizing cluster-team14...done.
Updated [https://container.googleapis.com/v1/projects/ttc-team-14/zones/asia-northeast3/clusters/cluster-team14].
k get node
NAME                                               STATUS                        ROLES    AGE     VERSION
gke-cluster-team14-ttc-worker-pool-99daac28-cqhh   Ready                         <none>   66m     v1.16.13-gke.1
gke-cluster-team14-ttc-worker-pool-abf04385-3pmh   NotReady,SchedulingDisabled   <none>   66m     v1.16.13-gke.1
gke-cluster-team14-ttc-worker-pool-abf04385-vs40   Ready                         <none>   7m19s   v1.16.13-gke.1
gke-cluster-team14-ttc-worker-pool-db5a2aa3-hn7m   Ready                         <none>   66m     v1.16.13-gke.1
.
.
.
$ k get node
NAME                                               STATUS   ROLES    AGE     VERSION
gke-cluster-team14-ttc-worker-pool-99daac28-cqhh   Ready    <none>   68m     v1.16.13-gke.1
gke-cluster-team14-ttc-worker-pool-abf04385-vs40   Ready    <none>   9m37s   v1.16.13-gke.1
gke-cluster-team14-ttc-worker-pool-db5a2aa3-hn7m   Ready    <none>   68m     v1.16.13-gke.1
```


#### 기본 Image Type 정보 가져오기
```
taeeyoul@cloudshell:~ (ttc-team-14)$ gcloud container get-server-config --region asia-northeast3
Fetching server config for asia-northeast3
channels:
- channel: RAPID
  defaultVersion: 1.17.9-gke.1503
  validVersions:
  - 1.17.9-gke.1503
- channel: REGULAR
  defaultVersion: 1.16.13-gke.1
  validVersions:
  - 1.16.13-gke.1
- channel: STABLE
  defaultVersion: 1.15.12-gke.2
  validVersions:
  - 1.15.12-gke.9
  - 1.15.12-gke.2
defaultClusterVersion: 1.15.12-gke.2
defaultImageType: COS
validImageTypes:
- COS
- CLOUD_ML
- CLOUD_ML_GCI
- UBUNTU
- COS_CONTAINERD
- UBUNTU_CONTAINERD
- WINDOWS_SAC
- WINDOWS_LTSC
validMasterVersions:
- 1.16.13-gke.1
- 1.15.12-gke.16
- 1.15.12-gke.13
- 1.15.12-gke.9
- 1.15.12-gke.2
validNodeVersions:
- 1.16.13-gke.1
- 1.16.11-gke.5
- 1.16.10-gke.8
- 1.16.9-gke.6
- 1.16.9-gke.2
- 1.16.8-gke.15
- 1.16.8-gke.12
- 1.16.8-gke.9
- 1.15.12-gke.16
- 1.15.12-gke.13
- 1.15.12-gke.9
- 1.15.12-gke.6
.
.
.
- 1.10.9-gke.5
- 1.10.9-gke.3
- 1.10.9-gke.0
- 1.10.7-gke.13
- 1.10.7-gke.11
- 1.10.7-gke.9
- 1.10.7-gke.6
- 1.10.7-gke.2
- 1.10.7-gke.1
- 1.10.6-gke.13
- 1.10.6-gke.11
- 1.10.6-gke.9
- 1.10.6-gke.6
- 1.10.6-gke.4
- 1.10.6-gke.3
- 1.10.6-gke.2
- 1.10.6-gke.1
- 1.10.5-gke.4
- 1.10.5-gke.3
- 1.10.5-gke.2
- 1.10.5-gke.0
- 1.10.4-gke.3
- 1.10.4-gke.2
- 1.10.4-gke.0
- 1.10.2-gke.4
- 1.10.2-gke.3
- 1.10.2-gke.1
- 1.9.7-gke.11
- 1.9.7-gke.7
- 1.9.7-gke.6
- 1.9.7-gke.5
- 1.9.7-gke.4
- 1.9.7-gke.3
- 1.9.7-gke.1
- 1.9.7-gke.0
- 1.9.6-gke.2
- 1.9.6-gke.1
- 1.9.3-gke.0
- 1.8.12-gke.3
- 1.8.12-gke.2
- 1.8.12-gke.1
- 1.8.12-gke.0
- 1.8.10-gke.2
- 1.8.10-gke.0
- 1.8.9-gke.1
- 1.8.8-gke.0
- 1.7.15-gke.0
- 1.7.12-gke.2
- 1.6.13-gke.1
```
