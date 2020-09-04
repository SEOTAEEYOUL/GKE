# Redis


![Redis HA](https://miro.medium.com/max/700/1*7AfXYNub6eC9j21-JZ-f-A.png)


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

#### Redis Pod 접속 후 정보 확인
* 접속  
```
taeeyoul@cloudshell:~/workspace/app/redis (ttc-team-14)$ ka exec redis-master-0 -c redis -it bash
I have no name!@redis-master-0:/$ redis-cli -a ttc2020!
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
127.0.0.1:6379> 
```

* keyspace 보기  
```
127.0.0.1:6379> info keyspace
# Keyspace
db0:keys=1542,expires=146,avg_ttl=274258985
```

* cluster 보기  
```
127.0.0.1:6379> info cluster
# Cluster
cluster_enabled:0
```

* 접속한 clients 보기  
```
127.0.0.1:6379> info clients
# Clients
connected_clients:7
client_recent_max_input_buffer:124440
client_recent_max_output_buffer:0
blocked_clients:0
tracking_clients:0
clients_in_timeout_table:0
```

* 서버 정보 보기  
```
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
```

* 접속 종료  
```
127.0.0.1:6379> quit
I have no name!@redis-master-0:/$
```

