# Container Registry

### 이미지를 Container Registry에 추가하기

#### Docker가 Container Registry에 대한 요청을 인증하는 데 gcloud 명령줄 도구를 사용하도록 구성
```
taeeyoul@cloudshell:~ (ttc-team-14)$ gcloud auth configure-docker
WARNING: Your config file at [/home/taeeyoul/.docker/config.json] contains these credential helper entries:

{
  "credHelpers": {
    "gcr.io": "gcloud",
    "us.gcr.io": "gcloud",
    "eu.gcr.io": "gcloud",
    "asia.gcr.io": "gcloud",
    "staging-k8s.gcr.io": "gcloud",
    "marketplace.gcr.io": "gcloud"
  }
}
Adding credentials for all GCR repositories.
WARNING: A long list of credential helpers may cause delays running 'docker build'. We recommend passing the registry name to configure only the registry you are using.
gcloud credential helpers already registered correctly.
```

#### gcloud를 사용자 인증 정보 도우미로 사용 설정
```
taeeyoul@cloudshell:~ (ttc-team-14)$ gcloud auth configure-docker
WARNING: Your config file at [/home/taeeyoul/.docker/config.json] contains these credential helper entries:
{
  "credHelpers": {
    "gcr.io": "gcloud",
    "us.gcr.io": "gcloud",
    "eu.gcr.io": "gcloud",
    "asia.gcr.io": "gcloud",
    "staging-k8s.gcr.io": "gcloud",
    "marketplace.gcr.io": "gcloud"
  }
}
Adding credentials for all GCR repositories.
WARNING: A long list of credential helpers may cause delays running 'docker build'. We recommend passing the registry name to configure only the registry you are using.
gcloud credential helpers already registered correctly.
taeeyoul@cloudshell:~ (ttc-team-14)$

taeeyoul@cloudshell:~/workspace/app/nodejs-bot (ttc-team-14)$ docker-credential-gcloud list
{
  "https://asia.gcr.io": "_dcgcloud_token",
  "https://eu.gcr.io": "_dcgcloud_token",
  "https://gcr.io": "_dcgcloud_token",
  "https://marketplace.gcr.io": "_dcgcloud_token",
  "https://staging-k8s.gcr.io": "_dcgcloud_token",
  "https://us.gcr.io": "_dcgcloud_token"
}
```

#### 레지스트리 이름으로 이미지에 태그 지정  
```
PROJECT-ID="ttc-team-14"
docker tag [SOURCE_IMAGE] [HOSTNAME]/[PROJECT-ID]/[IMAGE]
docker tag quickstart-image gcr.io/$PROJECT-ID/quickstart-image:tag1
```



#### 이미지를 Container Registry로 내보내기  
```
docker push gcr.io/$PROJECT-ID$/quickstart-image:tag1
```

#### Docker 이미지 조회  
```
taeeyoul@bastion-1:~$ gcloud container images list-tags gcr.io/ttc-team-14/nodejs-bot
DIGEST        TAGS   TIMESTAMP
238748ed8324  1.0.5  2020-08-31T13:49:01
taeeyoul@bastion-1:~$ gcloud container images list-tags asia.gcr.io/ttc-team-14/nodejs-bot
DIGEST        TAGS   TIMESTAMP
d8184d0e330c  1.0.5  2020-08-31T14:08:27
238748ed8324         2020-08-31T13:49:01
taeeyoul@bastion-1:~$ 
```

#### Access 권한 확인
```
taeeyoul@bastion-1:~$ gcloud auth configure-docker
WARNING: `docker` not in system PATH.
`docker` and `docker-credential-gcloud` need to be in the same PATH in order to work correctly together.
gcloud's Docker credential helper can be configured but it will not work until this is corrected.
Adding credentials for all GCR repositories.
WARNING: A long list of credential helpers may cause delays running 'docker build'. We recommend passing the registry name to configure o
nly the registry you are using.
After update, the following will be written to your Docker config file
 located at [/home/taeeyoul/.docker/config.json]:
 {
  "credHelpers": {
    "eu.gcr.io": "gcloud",
    "staging-k8s.gcr.io": "gcloud",
    "marketplace.gcr.io": "gcloud",
    "gcr.io": "gcloud",
    "us.gcr.io": "gcloud",
    "asia.gcr.io": "gcloud"
  }
}
Do you want to continue (Y/n)?  y
Docker configuration file updated.
taeeyoul@bastion-1:~$ docker-credential-gcloud list
{
  "https://asia.gcr.io": "_dcgcloud_token",
  "https://eu.gcr.io": "_dcgcloud_token",
  "https://gcr.io": "_dcgcloud_token",
  "https://marketplace.gcr.io": "_dcgcloud_token",
  "https://staging-k8s.gcr.io": "_dcgcloud_token",
  "https://us.gcr.io": "_dcgcloud_token"
}
taeeyoul@bastion-1:~$ 
```

#### 실행 예
```
$ docker tag nodejs-bot:1.0.5 asia.gcr.io/ttc-team-14/nodejs-bot:1.0.5

$ docker push asia.gcr.io/ttc-team-14/nodejs-bot:1.0.5
The push refers to repository [asia.gcr.io/ttc-team-14/nodejs-bot]
d08aa8e75b2e: Pushed
f1b358bcb239: Layer already exists
308b8069b351: Layer already exists
d79421f91b4f: Layer already exists
dc2608e9ff86: Layer already exists
4cb9e1e309a2: Layer already exists
e11630e2f130: Layer already exists
b35a18c287e6: Layer already exists
568488242087: Layer already exists
67e76c0d1db1: Layer already exists
d48ffad66bd3: Layer already exists
463b0ff55c5a: Layer already exists
8d32af54f7d5: Layer already exists
c4af30e8cc62: Layer already exists
423b21f89a9f: Layer already exists
98972e858333: Layer already exists
024281f9b85d: Layer already exists
a6b73b581551: Layer already exists
743f359d6bca: Layer already exists
c68666386fd1: Layer already exists
893deafe0c1c: Layer already exists
d70f8d206b8c: Layer already exists
f1a8123bcac1: Layer already exists
92ebe764b8fe: Layer already exists
5466d7ed16df: Layer already exists
d3a1a59af124: Layer already exists
208d8e01d24e: Layer already exists
0411d6076223: Layer already exists
44669b5acef3: Layer already exists
1b20cc177430: Layer already exists
25857ebc984f: Layer already exists
633e276a3c9a: Layer already exists
8b2b07470f3d: Layer already exists
fb13d3572bfc: Layer already exists
ca77c0b5dc98: Layer already exists
0b8d787f4b20: Layer already exists
92268a4eb34b: Layer already exists
607b18137231: Layer already exists
b15e3013f0cb: Layer already exists
eec4606a245d: Layer already exists
89169d87dbe2: Layer already exists
1.0.5: digest: sha256:d8184d0e330c143437060c5842543fdad42d63d1efeb0619b6553e3ed0464401 size: 8853

$ gcloud container images list-tags asia.gcr.io/ttc-team-14/nodejs-bot
DIGEST        TAGS   TIMESTAMP
d8184d0e330c  1.0.5  2020-08-31T05:08:27
238748ed8324         2020-08-31T04:49:01
No resources found in ttc-team-14 namespace.

$ docker pull gcr.io/ttc-team-14/nodejs-bot:1.0.5
1.0.5: Pulling from ttc-team-14/nodejs-bot
Digest: sha256:238748ed8324a8486c5c587e9b15531c1336ee19f2fcb111c2f1ef72aaca9a08
Status: Image is up to date for gcr.io/ttc-team-14/nodejs-bot:1.0.5
gcr.io/ttc-team-14/nodejs-bot:1.0.5

$ docker pull asia.gcr.io/ttc-team-14/nodejs-bot:1.0.5
1.0.5: Pulling from ttc-team-14/nodejs-bot
Digest: sha256:d8184d0e330c143437060c5842543fdad42d63d1efeb0619b6553e3ed0464401
Status: Image is up to date for asia.gcr.io/ttc-team-14/nodejs-bot:1.0.5
asia.gcr.io/ttc-team-14/nodejs-bot:1.0.5

$ docker images
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
asia.gcr.io/ttc-team-14/nodejs-bot   1.0.5               607ce02caa7f        4 minutes ago       548MB
nodejs-bot                           1.0.5               607ce02caa7f        4 minutes ago       548MB
gcr.io/ttc-team-14/nodejs-bot        1.0.5               5cc09b2684e5        23 minutes ago      548MB
centos                               7.6.1810            f1cb7c7d58b7        17 months ago       202MB
```

#### Container Registry에서 이미지 가져오기
```
docker pull gcr.io/[PROJECT-ID]/quickstart-image:tag1
```


#### 삭제
```
gcloud container images delete gcr.io/[PROJECT-ID]/quickstart-image:tag1 --force-delete-tags
```

---  
  

#### Cluster 정보 보기  
```
taeeyoul@cloudshell:~/workspace/app/nodejs-bot (ttc-team-14)$ gcloud container clusters describe cluster-team14 --resion asia-northeast3
ERROR: (gcloud.container.clusters.describe) unrecognized arguments:
  --resion (did you mean '--region'?)
  asia-northeast3
  To search the help text of gcloud commands, run:
  gcloud help -- SEARCH_TERMS
taeeyoul@cloudshell:~/workspace/app/nodejs-bot (ttc-team-14)$ gcloud container clusters describe cluster-team14 --region asia-northeast3
addonsConfig:
  dnsCacheConfig: {}
  horizontalPodAutoscaling: {}
  httpLoadBalancing: {}
  kubernetesDashboard:
    disabled: true
  networkPolicyConfig:
    disabled: true
authenticatorGroupsConfig: {}
autoscaling: {}
clusterIpv4Cidr: 192.168.0.0/16
createTime: '2020-08-20T07:35:40+00:00'
currentMasterVersion: 1.16.13-gke.1
currentNodeCount: 3
currentNodeVersion: 1.16.13-gke.1
databaseEncryption:
  state: DECRYPTED
defaultMaxPodsConstraint:
  maxPodsPerNode: '110'
description: TTC-Team-14
endpoint: 34.64.109.235
initialClusterVersion: 1.16.13-gke.1
instanceGroupUrls:
- https://www.googleapis.com/compute/v1/projects/ttc-team-14/zones/asia-northeast3-a/instanceGroupManagers/gke-cluster-team14-worker-pool-b758b7c5-grp
- https://www.googleapis.com/compute/v1/projects/ttc-team-14/zones/asia-northeast3-b/instanceGroupManagers/gke-cluster-team14-worker-pool-4ba9331e-grp
- https://www.googleapis.com/compute/v1/projects/ttc-team-14/zones/asia-northeast3-c/instanceGroupManagers/gke-cluster-team14-worker-pool-fee3fe68-grp
icpAlloationPolicy:
  clusterIpv4Cidr: 192.168.0.0/16
  clusterIpv4CidrBlock: 192.168.0.0/16
  clusterSecondaryRangeName: gke-cluster-team14-pods-cf7eb391
  servicesIpv4Cidr: 172.16.0.0/16
  servicesIpv4CidrBlock: 172.16.0.0/16
  servicesSecondaryRangeName: gke-cluster-team14-services-cf7eb391
  useIpAliases: true
labelFingerprint: dd808d82
legacyAbac: {}
location: asia-northeast3
locations:
- asia-northeast3-a
- asia-northeast3-b
- asia-northeast3-c
loggingService: logging.googleapis.com/kubernetes
maintenancePolicy:
  resourceVersion: e3b0c442
masterAuth:
  clusterCaCertificate: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURLekNDQWhPZ0F3SUJBZ0lSQU9XeGo2YjNDd0hpdWsrZml2RTBtc0V3RFFZSktvWklodmNOQVFFTEJRQXcKTHpFdE1Dc0dBMVVFQXhNa05HTmhOekF3TWpJdFl6QTFPUzAwWW1VMExUZ3pOamN0T1Rsa1lqTXpPRGd6TXpWawpNQjRYRF
RJd01EZ3lNREEyTXpVME1Wb1hEVEkxTURneE9UQTNNelUwTVZvd0x6RXRNQ3NHQTFVRUF4TWtOR05oCk56QXdNakl0WXpBMU9TMDBZbVUwTFRnek5qY3RPVGxrWWpNek9EZ3pNelZrTUlJQklqQU5CZ2txaGtpRzl3MEIKQVFFRkFBT0NBUThBTUlJQkNnS0NBUUVBeHllUjZwVjJZS0VvQTlqM1Q3WDQ1T3VvOFE5Z0lGVm1S
ejhacmpYZQpDU3JJT2NIQXVZeGhxaFR0N1AzcWtXeFJxMVNwQi9QTjI0OFo2NGl0aGYrNUxYL1dJV1FxWUIvMm9HanFCMUEyCm1QL1VJMGo4MW5UWTlxbkZYMmhqYktLWDRvZ2EwSW5qbEtkUG12T3N1djdqQVRMWXVxMFdZSHJjdUJMU0pxdnoKcm82MUNiSWo5S3pvMXRnSGdUZGdsOG1pTVVaNjU2cms0MFhrRWE0Y29KWG
dLMWNSdjFCR0YvcDNEVUp0T0FndApzckZ1YmlEY0hPMkl1UFJxZVFvalUxQjRzblNxUUcwWXlHN3JXNFp6UTdCNVhiOThVdkhYRFhIY252dWpUdVA5CllVTTMrcXplZ1RLL1NQcjZlTWtYalJqbkNiQWhwcHhBZnpSQ201bVViWTArU3dJREFRQUJvMEl3UURBT0JnTlYKSFE4QkFmOEVCQU1DQWdRd0R3WURWUjBUQVFIL0JB
VXdBd0VCL3pBZEJnTlZIUTRFRmdRVXdVSkVEQWg2WFN3SgpRbWt2TmRHRW5PaXRTblV3RFFZSktvWklodmNOQVFFTEJRQURnZ0VCQUFqeWNlVHF4M0dHcVhJZDA1YlBQN3FRCmNqaVdPU09QUkMxdWZiVGtPbUhHbHhyVEtJN2NsVWpWRmFOaTdpTEZrNUJCb0tDSDNwQ1pBNkFhUEQyNkJOaEoKN3lBSElEQXc3SW15WnFPdV
JhYUh6STJhdU1CUjNwTFpTZXg5TFZwRHpuNk85cTZHWFpra24yOXlqK0lybzR2ZQpIR2ZjcEYxV2pkbkV4cDBUZ2xnQWJYRDdpdGhwTjAvUGFiYXlIYk13ZUlJdkhqVlU5VW95cGg5bTZIaXovcVNtCi9RbGV0b1VHNTdkc2R5YVZyVHZNdFhmaGdjNmIwUko0OFBieXRYK2JYUTZqeEs1MGcyeHhETms0Z0NuVGFOWHYKTGM0
UEdkcHlsTUhsK0Y3VFV2cmZRcFJSYzlkRE9sRzBGVnF4bHJ1TSsyRmM2NUhiRHpka2JDWlpiVG5vWG44PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
masterAuthorizedNetworksConfig: {}
monitoringService: monitoring.googleapis.com/kubernetes
name: cluster-team14
network: vpc-team14
networkConfig:
  defaultSnatStatus: {}
  enableIntraNodeVisibility: true
  network: projects/ttc-team-14/global/networks/vpc-team14
  subnetwork: projects/ttc-team-14/regions/asia-northeast3/subnetworks/az-a-pub1
networkPolicy: {}
nodeConfig:
  diskSizeGb: 30
  diskType: pd-standard
  imageType: COS
  labels:
    role: worker
  machineType: e2-standard-2
  metadata:
    disable-legacy-endpoints: 'true'
  oauthScopes:
  - https://www.googleapis.com/auth/devstorage.read_only
  - https://www.googleapis.com/auth/logging.write
  - https://www.googleapis.com/auth/monitoring
  - https://www.googleapis.com/auth/servicecontrol
  - https://www.googleapis.com/auth/service.management.readonly
  - https://www.googleapis.com/auth/trace.append
  serviceAccount: default
  shieldedInstanceConfig:
    enableIntegrityMonitoring: true
  workloadMetadataConfig:
    mode: GKE_METADATA
nodePools:
- autoscaling:
    enabled: true
    maxNodeCount: 3
    minNodeCount: 1
  config:
    diskSizeGb: 30
    diskType: pd-standard
    imageType: COS
    labels:
      role: worker
    machineType: e2-standard-2
    metadata:
      disable-legacy-endpoints: 'true'
    oauthScopes:
    - https://www.googleapis.com/auth/devstorage.read_only
    - https://www.googleapis.com/auth/logging.write
    - https://www.googleapis.com/auth/monitoring
    - https://www.googleapis.com/auth/servicecontrol
    - https://www.googleapis.com/auth/service.management.readonly
    - https://www.googleapis.com/auth/trace.append
    serviceAccount: default
    shieldedInstanceConfig:
      enableIntegrityMonitoring: true
    workloadMetadataConfig:
      mode: GKE_METADATA
  initialNodeCount: 1
  instanceGroupUrls:
  - https://www.googleapis.com/compute/v1/projects/ttc-team-14/zones/asia-northeast3-a/instanceGroupManagers/gke-cluster-team14-worker-pool-b758b7c5-grp
  - https://www.googleapis.com/compute/v1/projects/ttc-team-14/zones/asia-northeast3-b/instanceGroupManagers/gke-cluster-team14-worker-pool-4ba9331e-grp
  - https://www.googleapis.com/compute/v1/projects/ttc-team-14/zones/asia-northeast3-c/instanceGroupManagers/gke-cluster-team14-worker-pool-fee3fe68-grp
  locations:
  - asia-northeast3-a
  - asia-northeast3-b
  - asia-northeast3-c
  management:
    autoRepair: true
    autoUpgrade: true
  maxPodsConstraint:
    maxPodsPerNode: '110'
  name: worker-pool
  podIpv4CidrSize: 24
  selfLink: https://container.googleapis.com/v1/projects/ttc-team-14/locations/asia-northeast3/clusters/cluster-team14/nodePools/worker-pool
  status: RUNNING
  upgradeSettings:
    maxSurge: 1
  version: 1.16.13-gke.1
releaseChannel:
  channel: REGULAR
resourceLabels:
  role: worker
selfLink: https://container.googleapis.com/v1/projects/ttc-team-14/locations/asia-northeast3/clusters/cluster-team14
servicesIpv4Cidr: 172.16.0.0/16
shieldedNodes: {}
status: RUNNING
subnetwork: az-a-pub1
workloadIdentityConfig:
  workloadPool: ttc-team-14.svc.id.goog
zone: asia-northeast3
taeeyoul@cloudshell:~/workspace/app/nodejs-bot (ttc-team-14)$
```
