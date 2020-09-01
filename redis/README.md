# Redis

### Redis Service 변경  
- redis service 가 master 만 바라 보도록 수정  
```
taeeyoul@cloudshell:~/workspace/ttc-app/redis$ ka get pod -o wide -lrole=master
NAME             READY   STATUS    RESTARTS   AGE   IP             NODE                                           NOMINATED NODE   READINESS GATES
redis-master-0   3/3     Running   0          19h   192.168.2.10   gke-cluster-team14-worker-pool-4ba9331e-3tn1   <none>           <none>
taeeyoul@cloudshell:~/workspace/ttc-app/redis$ ka get svc,ep redis
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)              AGE
service/redis   ClusterIP   172.16.214.64   <none>        6379/TCP,26379/TCP   4d22h
NAME              ENDPOINTS                              AGE
endpoints/redis   192.168.2.10:26379,192.168.2.10:6379   4d22h
```

### ttc-app 배포하기  
- pvc 없이 사용하도록 배포함  

#### 설치 명령
```
taeeyoul@cloudshell:~/workspace/ttc-app/redis (ttc-team-14)$ helm install redis . -n ttc-app -f values.yaml
NAME: redis
LAST DEPLOYED: Thu Aug 27 08:04:05 2020
NAMESPACE: ttc-app
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
** Please be patient while the chart is being deployed **
Redis can be accessed via port 6379 on the following DNS name from within your cluster:
redis.ttc-app.svc.cluster.local for read only operations
For read/write operations, first access the Redis Sentinel cluster, which is available in port 26379 using the same domain name above.
To get your password run:
    export REDIS_PASSWORD=$(kubectl get secret --namespace ttc-app redis -o jsonpath="{.data.redis-password}" | base64 --decode)
To connect to your Redis server:
1. Run a Redis pod that you can use as a client:
   kubectl run --namespace ttc-app redis-client --rm --tty -i --restart='Never' \
    --env REDIS_PASSWORD=$REDIS_PASSWORD \
   --image docker.io/bitnami/redis:6.0.6-debian-10-r10 -- bash
2. Connect using the Redis CLI:
   redis-cli -h redis -p 6379 -a $REDIS_PASSWORD # Read only operations
   redis-cli -h redis -p 26379 -a $REDIS_PASSWORD # Sentinel access
To connect to your database from outside the cluster execute the following commands:
    kubectl port-forward --namespace ttc-app svc/redis-master 6379:6379 &
    redis-cli -h 127.0.0.1 -p 6379 -a $REDIS_PASSWORD
```  
  
```
taeeyoul@cloudshell:~/workspace/tcc-app/redis-ha (ttc-team-14)$ helm install redis-ha . -n ttc-app -f values.yaml
NAME: redis-ha
LAST DEPLOYED: Wed Aug 26 00:07:55 2020
NAMESPACE: ttc-app
STATUS: deployed
REVISION: 1
NOTES:
Redis can be accessed via port 6379 and Sentinel can be accessed via port 26379 on the following DNS name from within your cluster:
redis-ha.ttc-app.svc.cluster.local
To connect to your Redis server:
1. Run a Redis pod that you can use as a client:
   kubectl exec -it redis-ha-server-0 sh -n ttc-app
2. Connect using the Redis CLI:
  redis-cli -h redis-ha.ttc-app.svc.cluster.local
taeeyoul@cloudshell:~/workspace/tcc-app/redis-ha (ttc-team-14)$ pwd
/home/taeeyoul/workspace/tcc-app/redis-ha
```


#### 배포된 Pod 확인  
```
eeyoul@cloudshell:~/workspace/ttc-app/redis (ttc-team-14)$ kubectl -n ttc-app get pod -lapp=redis --show-labels
NAME             READY   STATUS    RESTARTS   AGE     LABELS
redis-master-0   3/3     Running   0          2m38s   app=redis,chart=redis-10.7.16,controller-revision-hash=redis-master-567fb8d95f,release=redis,role=master,statefulset.kubernetes.io/pod-name=redis-master
-0
redis-slave-0    3/3     Running   0          2m37s   app=redis,chart=redis-10.7.16,controller-revision-hash=redis-slave-5d45db4f9b,release=redis,role=slave,statefulset.kubernetes.io/pod-name=redis-slave-0
redis-slave-1    3/3     Running   0          56s     app=redis,chart=redis-10.7.16,controller-revision-hash=redis-slave-5d45db4f9b,release=redis,role=slave,statefulset.kubernetes.io/pod-name=redis-slave-1
taeeyoul@cloudshell:~/workspace/ttc-app/redis (ttc-team-14)$
```

#### Master,Slave 확인  
```
taeeyoul@cloudshell:~/workspace/ttc-app/redis (ttc-team-14)$ kubectl -n ttc-app get pod -lapp=redis -lrole=master
NAME             READY   STATUS    RESTARTS   AGE
redis-master-0   3/3     Running   0          4m8s
taeeyoul@cloudshell:~/workspace/ttc-app/redis (ttc-team-14)$ kubectl -n ttc-app get pod -lapp=redis -lrole=slave
NAME            READY   STATUS    RESTARTS   AGE
redis-slave-0   3/3     Running   0          4m13s
redis-slave-1   3/3     Running   0          2m32s
taeeyoul@cloudshell:~/workspace/ttc-app/redis (ttc-team-14)$ kubectl -n ttc-app get pvc
NAME                        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
redis-data-redis-master-0   Bound    pvc-b3500ee9-b7ef-4fc3-af6c-db0bb6b228e3   8Gi        RWO            standard       38m
redis-data-redis-slave-0    Bound    pvc-33f61ac1-d38d-4988-a957-f76cc69949c8   8Gi        RWO            standard       38m
redis-data-redis-slave-1    Bound    pvc-86b318bb-9bde-4699-bf41-c2dda86bd558   8Gi        RWO            standard       37m
taeeyoul@cloudshell:~/workspace/ttc-app/redis (ttc-team-14)$ kubectl -n ttc-app get svc -lapp=redis
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)              AGE
redis            ClusterIP   172.16.0.66     <none>        6379/TCP,26379/TCP   6m20s
redis-headless   ClusterIP   None            <none>        6379/TCP,26379/TCP   6m20s
redis-metrics    ClusterIP   172.16.238.81   <none>        9121/TCP             6m20s
taeeyoul@cloudshell:~/workspace/ttc-app/redis (ttc-team-14)$ kubectl -n ttc-app get pod,svc,ep -lapp=redis
NAME                 READY   STATUS    RESTARTS   AGE
pod/redis-master-0   3/3     Running   0          7m11s
pod/redis-slave-0    3/3     Running   0          7m10s
pod/redis-slave-1    3/3     Running   0          5m29s
NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)              AGE
service/redis            ClusterIP   172.16.0.66     <none>        6379/TCP,26379/TCP   7m11s
service/redis-headless   ClusterIP   None            <none>        6379/TCP,26379/TCP   7m11s
service/redis-metrics    ClusterIP   172.16.238.81   <none>        9121/TCP             7m11s
NAME                       ENDPOINTS                                                           AGE
endpoints/redis            192.168.0.7:26379,192.168.2.6:26379,192.168.3.2:26379 + 3 more...   7m11s
endpoints/redis-headless   192.168.0.7:26379,192.168.2.6:26379,192.168.3.2:26379 + 3 more...   7m11s
endpoints/redis-metrics    192.168.0.7:9121,192.168.2.6:9121,192.168.3.2:9121                  7m11s
```


## Sample 배포하기

```
taeeyoul@cloudshell:~ (ttc-team-14)$ gcloud config set compute/zone asia-northeast3
Updated property [compute/zone].
taeeyoul@cloudshell:~ (ttc-team-14)$ gcloud config list
[component_manager]
disable_update_check = True
[compute]
gce_metadata_read_timeout_sec = 5
zone = asia-northeast3
[core]
account = taeeyoul@gmail.com
disable_usage_reporting = True
project = ttc-team-14
[metrics]
environment = devshell
Your active configuration is: [cloudshell-24793]
taeeyoul@cloudshell:~ (ttc-team-14)$ gcloud container clusters create guestbook --num-nodes=4
WARNING: Currently VPC-native is not the default mode during cluster creation. In the future, this will become the default mode and can be disabled using `--no-enable-ip-alias` flag. Use `--[no-]enable-ip-alias` flag to sup
press this warning.
WARNING: Newly created clusters and node-pools will have node auto-upgrade enabled by default. This can be disabled using the `--no-enable-autoupgrade` flag.
WARNING: Starting with version 1.18, clusters will have shielded GKE nodes by default.
WARNING: Your Pod address range (`--cluster-ipv4-cidr`) can accommodate at most 1008 node(s).
This will enable the autorepair feature for nodes. Please see https://cloud.google.com/kubernetes-engine/docs/node-auto-repair for more information on node autorepairs.
ERROR: (gcloud.container.clusters.create) ResponseError: code=403, message=Insufficient regional quota to satisfy request: resource "IN_USE_ADDRESSES": request requires '12.0' and is short '7.0'. project has a quota of '8.0
' with '5.0' available. View and manage quotas at https://console.cloud.google.com/iam-admin/quotas?usage=USED&project=ttc-team-14.
taeeyoul@cloudshell:~ (ttc-team-14)$ gcloud container clusters list
NAME            LOCATION         MASTER_VERSION  MASTER_IP      MACHINE_TYPE   NODE_VERSION   NUM_NODES  STATUS
cluster-team14  asia-northeast3  1.16.13-gke.1   34.64.109.235  e2-standard-2  1.16.13-gke.1  3          RUNNING
```

#### Redis   Count  
```
taeeyoul@cloudshell:~/workspace/app/redis (ttc-team-14)$ ka exec redis-master-0 -c redis -it bash
I have no name!@redis-master-0:/$ redis-cli -a ttc2020!
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
127.0.0.1:6379> info keyspace
# Keyspace
db0:keys=1542,expires=146,avg_ttl=274258985
127.0.0.1:6379> info cluster
# Cluster
cluster_enabled:0
127.0.0.1:6379> info clients
# Clients
connected_clients:7
client_recent_max_input_buffer:124440
client_recent_max_output_buffer:0
blocked_clients:0
tracking_clients:0
clients_in_timeout_table:0
127.0.0.1:6379> info Server
# Server
redis_version:6.0.6
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:3d86d7b63053cc40
redis_mode:standalone
os:Linux 4.19.112+ x86_64
arch_bits:64
multiplexing_api:epoll
atomicvar_api:atomic-builtin
gcc_version:8.3.0
process_id:1
run_id:683a2038230f0e5485e2db4ad9c3b41e154d8dec
tcp_port:6379
uptime_in_seconds:89523
uptime_in_days:1
hz:10
configured_hz:10
lru_clock:4769453
executable:/redis-server
config_file:/opt/bitnami/redis/etc/redis.conf
127.0.0.1:6379> quit
I have no name!@redis-master-0:/$
```

