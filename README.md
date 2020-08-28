# GKE

[GKE 빠른 시작](https://cloud.google.com/kubernetes-engine/docs/quickstart)  
[Ingress](https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-features?hl=ko)  
[GKE Sample](https://github.com/GoogleCloudPlatform/kubernetes-engine-samples)  
  - [Redis 및 PHP로 방명록 만들기](https://cloud.google.com/kubernetes-engine/docs/tutorials/guestbook?hl=ko)
  - [Persistent Disk 및 Cloud SQL로 GKE에 WordPress 배포](https://cloud.google.com/kubernetes-engine/docs/tutorials/persistent-disk?hl=ko)
[Kubernetes Applications](https://github.com/kubernetes-sigs/application/blob/master/README.md)



### 셸 선택
  * 빠른 시작을 하려면 Cloud Shell 또는 로컬 셸을 사용
  * Cloud Shell에는 gcloud 명령줄 도구와 kubectl 명령줄 도구가 사전 설치되어 있음
    * gcloud 도구는 Google Cloud의 기본 명령줄 인터페이스를 제공
    * kubectl은 Kubernetes 클러스터를 대상으로 명령어를 실행할 수 있는 기본 명령줄 인터페이스

#### 기본 프로젝트 설정
```
gcloud config set project project-id
```

#### 기본 컴퓨팅 영역 설정
```
gcloud config set compute/zone compute-zone
```

```
taeeyoul@cloudshell:~ (ttc-team-14)$ gcloud config list
[component_manager]
disable_update_check = True
[compute]
gce_metadata_read_timeout_sec = 5
[core]
account = taeeyoul@gmail.com
disable_usage_reporting = True
project = ttc-team-14
[metrics]
environment = devshell
Your active configuration is: [cloudshell-22589]
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

Your active configuration is: [cloudshell-22589]
```

### GKE 클러스터 만들기

#### 단일 노드 클러스터
```
gcloud container clusters create cluster-name --num-nodes=1
```

### 클러스터의 사용자 인증 정보 가져오기
```
gcloud container clusters get-credentials __cluster-name__
```


#### Pod,SVC 배포
```
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:1.0
deployment.apps/hello-server created
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl expose deployment hello-server --type LoadBalancer \
>   --port 80 --target-port 8080
service/hello-server exposed
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl get pod,svc,ep
NAME                                READY   STATUS    RESTARTS   AGE
pod/hello-server-5bfd595c65-gv85q   1/1     Running   0          31s
NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/hello-server   LoadBalancer   172.16.166.93   <pending>     80:30968/TCP   11s
service/kubernetes     ClusterIP      172.16.0.1      <none>        443/TCP        18h
NAME                     ENDPOINTS           AGE
endpoints/hello-server   192.168.2.3:8080    11s
endpoints/kubernetes     34.64.109.235:443   18h
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl get pod,svc,ep
NAME                                READY   STATUS    RESTARTS   AGE
pod/hello-server-5bfd595c65-gv85q   1/1     Running   0          2m7s
NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
service/hello-server   LoadBalancer   172.16.166.93   34.64.175.157   80:30968/TCP   107s
service/kubernetes     ClusterIP      172.16.0.1      <none>          443/TCP        18h
NAME                     ENDPOINTS           AGE
endpoints/hello-server   192.168.2.3:8080    107s
endpoints/kubernetes     34.64.109.235:443   18h
```

  
#### Scale-out (kubectl scale ...)
```
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl get pod
NAME                            READY   STATUS    RESTARTS   AGE
hello-server-5bfd595c65-242n2   1/1     Running   0          2m5s
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl scale deployment hello-server --replicas=3
kdeployment.apps/hello-server scaled
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl get pod
NAME                            READY   STATUS              RESTARTS   AGE
hello-server-5bfd595c65-242n2   1/1     Running             0          2m11s
hello-server-5bfd595c65-hnngm   0/1     ContainerCreating   0          2s
hello-server-5bfd595c65-qk744   0/1     ContainerCreating   0          2s
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl get pod
NAME                            READY   STATUS    RESTARTS   AGE
hello-server-5bfd595c65-242n2   1/1     Running   0          2m25s
hello-server-5bfd595c65-hnngm   1/1     Running   0          16s
hello-server-5bfd595c65-qk744   1/1     Running   0          16s
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl top pod
NAME                            CPU(cores)   MEMORY(bytes)
hello-server-5bfd595c65-242n2   1m           1Mi
hello-server-5bfd595c65-hnngm   0m           1Mi
hello-server-5bfd595c65-qk744   0m           1Mi
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl top node
NAME                                           CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
gke-cluster-team14-worker-pool-4ba9331e-k3ss   131m         6%     880Mi           14%
gke-cluster-team14-worker-pool-b758b7c5-zsnc   85m          4%     730Mi           12%
gke-cluster-team14-worker-pool-fee3fe68-ht5w   82m          4%     711Mi           11%
```
  
```
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl expose deployment hello-server --type ClusterIP   --port 80 --target-port 8080
service/hello-server exposed
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl get pod,svc,ep
NAME                                READY   STATUS    RESTARTS   AGE
pod/hello-server-5bfd595c65-242n2   1/1     Running   0          36m
pod/hello-server-5bfd595c65-hnngm   1/1     Running   0          34m
pod/hello-server-5bfd595c65-qk744   1/1     Running   0          34m
NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/hello-server   ClusterIP   172.16.201.99   <none>        80/TCP    33s
service/kubernetes     ClusterIP   172.16.0.1      <none>        443/TCP   19h
NAME                     ENDPOINTS                                             AGE
endpoints/hello-server   192.168.0.3:8080,192.168.1.10:8080,192.168.2.4:8080   33s
endpoints/kubernetes     34.64.109.235:443                                     19h
```

##### 접속하기  
http://34.64.175.157  
```
[tyseo@ip-192-168-2-94 ~]$ curl http://34.64.175.157
Hello, world!
Version: 1.0.0
Hostname: hello-server-5bfd595c65-gv85q
[tyseo@ip-192-168-2-94 ~]$
```

### 삭제하기
#### 서비스 삭제
```
kubectl delete service hello-server
```

```
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl get deploy,pod,svc
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hello-server   1/1     1            1           5m44s
NAME                                READY   STATUS    RESTARTS   AGE
pod/hello-server-5bfd595c65-gv85q   1/1     Running   0          5m44s
NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
service/hello-server   LoadBalancer   172.16.166.93   34.64.175.157   80:30968/TCP   5m24s
service/kubernetes     ClusterIP      172.16.0.1      <none>          443/TCP        18h
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl delete svc hello-server
kservice "hello-server" deleted
                              
taeeyoul@cloudshell:~ (ttc-team-14)$
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl delete deploy hello-server
deployment.apps "hello-server" deleted
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl get deploy,svc
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   172.16.0.1   <none>        443/TCP   18h
taeeyoul@cloudshell:~ (ttc-team-14)$
```

---


### Ingress  
* Google Cloud VPC 네트워크와 긴밀하게 통합되는 엔터프라이즈급 부하 분산 기능을 제공 
* FrontendConfig 및 BackendConfig 커스텀 리소스 정의(CRD)를 사용하면 부하 분산기를 추가로 맞춤설정할 수 있음 
  * FrontendConfig : 인그레스 객체에서 참조  
  * BackendConfig는 서비스 객체에서 참조  
* FrontendConfig CRD와 BackendConfig CRD는 해당하는 인그레스 및 서비스 리소스와 동일한 수명 주기를 공유하며 종종 함께 배포됨

![Ingress BackendConfig 및 FrontendConfig 개요](https://cloud.google.com/kubernetes-engine/images/ingress-configs.svg?hl=ko)

* Deployment  
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello
spec:
  selector:
    matchLabels:
      # purpose: bsc-config-demo
      app: hello
  replicas: 3
  template:
    metadata:
      labels:
        # purpose: bsc-config-demo
        app: hello
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operatior: In
                  values:
                  - hello
              topologyKey: kubernetes.io/hostname
            weight: 100
      containers:
      - name: hello
        image: gcr.io/google-samples/hello-app:1.0
```

* podAntiAffinity 추가 후  
```
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl get deploy,pod,svc
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hello   3/3     3            3           3d
NAME                        READY   STATUS    RESTARTS   AGE
pod/hello-cf68b44cc-jz6k2   1/1     Running   0          30m
pod/hello-cf68b44cc-lch9v   1/1     Running   0          30m
pod/hello-cf68b44cc-x9qzp   1/1     Running   0          30m
NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/hello-service   ClusterIP   172.16.164.82   <none>        80/TCP    3d
service/kubernetes      ClusterIP   172.16.0.1      <none>        443/TCP   3d20h
```


* FrontendConfig  
```
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  annotations:
    networking.gke.io/v1beta1.FrontendConfig: "frontendconfig"
...
```
  
* BackendConfig   
```
apiVersion: networking.k8s.io/v1beta
kind: Ingress
metadata:
  name: hello-ingress
spec:
  rules:
  - http:
      paths:
      - path: /*
        backend:
          serviceName: hello-service
          servicePort: 80
```

* Service  
```
apiVersion: v1
kind: Service
metadata:
  name: hello-service
  labels:
    # purpose: bsc-config-demo
    app: hello
  annotations:
    cloud.google.com/backend-config: '{"ports": {"80":"hello-backendconfig"}}'
    cloud.google.com/neg: '{"ingress": true}'
spec:
  type: ClusterIP
  selector:
    # purpose: bsc-config-demo
    app: hello
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
```

* Ingress  
```
apiVersion: networking.k8s.io/v1beta
kind: Ingress
metadata:
  name: hello-ingress
spec:
  rules:
  - http:
      paths:
      - path: /*
        backend:
          serviceName: hello-service
          servicePort: 80
```

#### Ingress 생성 및 조회하기
```
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl create -f hello-deploy.yaml
deployment.apps/hello created
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl apply -f hello-backendconfig.yaml
backendconfig.cloud.google.com/hello-backendconfig created
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl apply -f hello-service.yaml
service/hello-service configured
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl apply -f hello-ingress.yaml
ingress.networking.k8s.io/hello-ingress created
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl get backendconfig,deploy,svc,ep,ing
NAME                                                 AGE
backendconfig.cloud.google.com/hello-backendconfig   23m
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hello   2/2     2            2           112s
NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/hello-service   ClusterIP   172.16.164.82   <none>        80/TCP    18m
service/kubernetes      ClusterIP   172.16.0.1      <none>        443/TCP   20h
NAME                      ENDPOINTS                           AGE
endpoints/hello-service   192.168.0.4:8080,192.168.2.5:8080   18m
endpoints/kubernetes      34.64.109.235:443                   20h
NAME                               HOSTS   ADDRESS         PORTS   AGE
ingress.extensions/hello-ingress   *       35.227.225.26   80      17m
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl describe ingress hello-ingress | grep ingress.kubernetes.io/backends
Annotations:  ingress.kubernetes.io/backends: {"k8s-be-32171--011a2b9a78e503d3":"HEALTHY","k8s1-011a2b9a-default-hello-service-80-741e0899":"HEALTHY"}
taeeyoul@cloudshell:~ (ttc-team-14)$ export BES="k8s-be-32171--011a2b9a78e503d3"
taeeyoul@cloudshell:~ (ttc-team-14)$ gcloud compute backend-services describe ${BES} --global | grep -e "drainingTimeoutSec" -e "timeoutSec"
  drainingTimeoutSec: 0
timeoutSec: 30
taeeyoul@cloudshell:~ (ttc-team-14)$ curl http://35.227.225.26
Hello, world!
Version: 1.0.0
Hostname: hello-67b75894d7-brcmp
taeeyoul@cloudshell:~ (ttc-team-14)$
```

#### BackendConfig 를 사용한 CloudCDN 사용 설정  
```
apiVersion: cloud.google.com/v1beta1
kind: BackendConfig
metadata:
  name: my-backendconfig
spec:
  cdn:
    enabled: cdnEnabled
    cachePolicy:
      includeHost: includeHost
      includeProtocol:includeProtocol
      includeQueryString: includeQueryString
      queryStringBlacklist:queryStringBlacklist
      queryStringWhitelist: queryStringWhitelist
```


#### project 정보 보기   
```
taeeyoul@cloudshell:~/workspace/storageclass (ttc-team-14)$ gcloud compute project-info describe --project ttc-team-14
commonInstanceMetadata:
  fingerprint: CnKkevO8fME=
  items:
  - key: gke-cluster-team14-cf7eb391-secondary-ranges
    value: services:vpc-team14:az-a-pub1:gke-cluster-team14-services-cf7eb391,pods:vpc-team14:az-a-pub1:gke-cluster-team14-pods-cf7eb391
  - key: sshKeys
    value: |-
      gke-cf7eb391bc03ba32d851:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKz66WCcL4RqJg2pkUhSYF6w/OdeJ4ilvrEq7ZYn5zCRExxhazaa+PndycHPd0gjKUxSU7uz1vI6uLQ2Y+hOpHQl2XgU1ek9QidZ8sDDWQQguidE0RGIktjVFEV+m+XxdWAHk3cm1glb8CdxjPrt8351cQvrplzGMmVHfZFreEx8U
EpIvbR6socVQ2h/zkSnMUrCSwlqD+JRsfGG6BvLWzBe/uYeYCP/Z3WtVXuP7repRQwwC5y8J9xzNOC7IS9BIjkuRIE95y50OCriZsk6dLakjhez+hUR2y2MZ4JI5gTVuBd7FUFiON42RtxD+IKTgAVkNQdIq5OTmcAhBwFQql gke-cf7eb391bc03ba32d851@gke-cf7eb391bc03ba32d851
      gke-cf7eb391bc03ba32d851:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCNfW2ucaYXfzmXN8T5KazWwX3dsxZCcoER0EJwU1NYqxnbpNZtc6mxJVhJ8dg0AUhH9vb1wsug0xzQ4qLpWwOLHF7iN/drN7V5OZzFjk0YiubjEm757OZydznreV3r2zFiugEXP1Us3anaiBdAQXa8intq7f6JKjBe6d37CH74JJ3
aHBWHEBpovqkmf4Wak/Saz+dR6zvrOr5/ZZcgFiu/VuUBE8YXd4eELr2GsWngO9X9K5S4XE8/sC4NPmq4+xnVQEdzXayiZcskzasjA/ce+XKuh+Lh2sV49Md38b1C/GEtet+19nf/Izt7T/Ypizrw0IYHNPeJADrCv1hQMLl9 gke-cf7eb391bc03ba32d851@gke-cf7eb391bc03ba32d851
      gke-cf7eb391bc03ba32d851:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDoS9Cq8CecC5YFZPuJ4sncCEPMHTJYQbU4ppR678H4R/MY5WooEsWo4nTdVvavjxFrZQv/jXLYZ0OP4wmVctFmWzbkI0SSMNGi5MQFWsTwwIP0mpX/WS0t7CdnspGNTEwq7DOiueFUpYV3luj/5tLIDY5S3Uug/LeQwzMitKTFUXF
6De5b8P9QiuQZ64v1WHsQcRC+6ydhfMK5/y0l3o0Y6LZbV4NxBoFkrfC1KcPD+Q6o3jNHCCWHhomx5bvcKD5vuTFaT8xMLwBWg+JKUv9d4iBSzzZnGeKzg91X4JspHKtzCexrOSkoxtpmKQ+KVWb1/VyBmzWsNfT4Qneg/tX/ gke-cf7eb391bc03ba32d851@gke-cf7eb391bc03ba32d851
  - key: ssh-keys
    value: |
      taeeyoul:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAH+2jnw8xSXOBsNh5Ro3QUFCb+Hn7OyWr6cV2yvtVE+Yw0YzVY1ruQF+aZTdVWN+cGyqpbMZaVBaNtVXlKAvvW/uS/JEkTuF8ZSJadT0QqZM5+tynCOzfY7VtdXFEYLFdgGKpC/4BVnF9Wr/NHVZfNzEPtSiQUI20l6UdA/UJcQWeAcsV9cvCl/sr9PEd3k
J0TOESSCgq0YKOzKdT7k0wwWL7tMyEKAFQy1UopSKs5FUl9GQJ6biT2jbtlA0QXZf67l3DmE32gnKculneuwMNBAapQj0mDITMbtd1O2pWmhMeCnBMmvqTwRz4BCQt1uTMmp6cF19+l72dFqDV8pF708= google-ssh {"userName":"taeeyoul@gmail.com","expireOn":"2020-08-20T07:46:05+0000"}
      taeeyoul:ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGtuFrUY7aJ66U8z7NjXMnCtrA3rhFX9Ta3o32mPEkSONANbjSR7S1VVvgEf/nTluLwzdl0FLC9BSQSh1MAdLlM= google-ssh {"userName":"taeeyoul@gmail.com","expireOn":"2020-08-20
T07:46:04+0000"}
      taeeyoul:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCe2O9hncN8zWP1ocVZ2i2cqBFOd/iKXrbZ/WauL9JxNsXUANGBlnqWaMLtAv7s57fXhoUaAhOPNZBrnN04fBrYx9j6IFskbHwcX2zV0GnDjoLpScHWh/xev8NhzEa009DTOetQjoSwn1113fNiH1WrbFJOyZET7/4IeTti6lhbmZ+gDBo/MR4UhJcB+N0
PWvv5EdOCKI7H2jHSrKnH9ahWW/2T7W1Vs9i1HdwksWA8jYRAHfmGJerLf8vBmFPHzvAVB1/MtcrjOmFW92ZS4yj8zZLHKSArQG3MW2OGuKwkwjZW+ZNmGK0ZBuprLujZCHTtR2LhkyRiybK6HI4jT1Mv google-ssh {"userName":"taeeyoul@gmail.com","expireOn":"2020-08-20T07:45:11+0000"}
      taeeyoul:ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBNi90npVG9S6kKSDpuKoR1zB5Dbymy3A4Zp7ji0AiXYjy3t8x6GmRvDBtLWJSHntNXAqASLpI7xq86v9Rw0YmWQ= google-ssh {"userName":"taeeyoul@gmail.com","expireOn":"2020-08-20
T07:45:10+0000"}
      taeeyoul:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCe2O9hncN8zWP1ocVZ2i2cqBFOd/iKXrbZ/WauL9JxNsXUANGBlnqWaMLtAv7s57fXhoUaAhOPNZBrnN04fBrYx9j6IFskbHwcX2zV0GnDjoLpScHWh/xev8NhzEa009DTOetQjoSwn1113fNiH1WrbFJOyZET7/4IeTti6lhbmZ+gDBo/MR4UhJcB+N0
PWvv5EdOCKI7H2jHSrKnH9ahWW/2T7W1Vs9i1HdwksWA8jYRAHfmGJerLf8vBmFPHzvAVB1/MtcrjOmFW92ZS4yj8zZLHKSArQG3MW2OGuKwkwjZW+ZNmGK0ZBuprLujZCHTtR2LhkyRiybK6HI4jT1Mv google-ssh {"userName":"taeeyoul@gmail.com","expireOn":"2020-08-20T07:44:39+0000"}
      taeeyoul:ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBNi90npVG9S6kKSDpuKoR1zB5Dbymy3A4Zp7ji0AiXYjy3t8x6GmRvDBtLWJSHntNXAqASLpI7xq86v9Rw0YmWQ= google-ssh {"userName":"taeeyoul@gmail.com","expireOn":"2020-08-20
T07:44:36+0000"}
  kind: compute#metadata
creationTimestamp: '2020-08-13T23:18:10.240-07:00'
defaultNetworkTier: PREMIUM
defaultServiceAccount: 563465074075-compute@developer.gserviceaccount.com
id: '4384854555588530765'
kind: compute#project
name: ttc-team-14
quotas:
- limit: 25000.0
  metric: SNAPSHOTS
  usage: 0.0
- limit: 50.0
  metric: NETWORKS
  usage: 2.0
- limit: 500.0
  metric: FIREWALLS
  usage: 8.0
- limit: 10000.0
  metric: IMAGES
  usage: 0.0
- limit: 700.0
  metric: STATIC_ADDRESSES
  usage: 3.0
- limit: 500.0
  metric: ROUTES
  usage: 2.0
- limit: 375.0
  metric: FORWARDING_RULES
  usage: 6.0
- limit: 1250.0
  metric: TARGET_POOLS
  usage: 0.0
- limit: 1250.0
  metric: HEALTH_CHECKS
  usage: 10.0
- limit: 2300.0
  metric: IN_USE_ADDRESSES
  usage: 6.0
- limit: 1250.0
  metric: TARGET_INSTANCES
  usage: 0.0
- limit: 250.0
  metric: TARGET_HTTP_PROXIES
  usage: 5.0
- limit: 250.0
  metric: URL_MAPS
  usage: 4.0
- limit: 75.0
  metric: BACKEND_SERVICES
  usage: 10.0
- limit: 2500.0
  metric: INSTANCE_TEMPLATES
  usage: 3.0
- limit: 125.0
  metric: TARGET_VPN_GATEWAYS
  usage: 0.0
- limit: 250.0
  metric: VPN_TUNNELS
  usage: 0.0
- limit: 75.0
  metric: BACKEND_BUCKETS
  usage: 0.0
- limit: 20.0
  metric: ROUTERS
  usage: 0.0
- limit: 250.0
  metric: TARGET_SSL_PROXIES
  usage: 0.0
- limit: 250.0
  metric: TARGET_HTTPS_PROXIES
  usage: 1.0
- limit: 250.0
  metric: SSL_CERTIFICATES
  usage: 3.0
- limit: 275.0
  metric: SUBNETWORKS
  usage: 25.0
- limit: 250.0
  metric: TARGET_TCP_PROXIES
  usage: 0.0
- limit: 10.0
  metric: SECURITY_POLICIES
  usage: 0.0
- limit: 200.0
  metric: SECURITY_POLICY_RULES
  usage: 0.0
- limit: 375.0
  metric: PACKET_MIRRORINGS
  usage: 0.0
- limit: 2500.0
  metric: NETWORK_ENDPOINT_GROUPS
  usage: 0.0
- limit: 6.0
  metric: INTERCONNECTS
  usage: 0.0
- limit: 5000.0
  metric: GLOBAL_INTERNAL_ADDRESSES
  usage: 2.0
- limit: 125.0
  metric: VPN_GATEWAYS
  usage: 0.0
- limit: 10000.0
  metric: MACHINE_IMAGES
  usage: 0.0
- limit: 20.0
  metric: SECURITY_POLICY_CEVAL_RULES
  usage: 0.0
- limit: 125.0
  metric: EXTERNAL_VPN_GATEWAYS
  usage: 0.0
- limit: 1.0
  metric: PUBLIC_ADVERTISED_PREFIXES
  usage: 0.0
- limit: 10.0
  metric: PUBLIC_DELEGATED_PREFIXES
  usage: 0.0
- limit: 1024.0
  metric: STATIC_BYOIP_ADDRESSES
  usage: 0.0
selfLink: https://www.googleapis.com/compute/v1/projects/ttc-team-14
xpnProjectStatus: UNSPECIFIED_XPN_PROJECT_STATUS
```

  
#### Cluster 삭제
```
gcloud container clusters delete cluster-name
```

---  

#### …or create a new repository on the command line
```
echo "# GKE" >> README.md
git init
git add README.md
git commit -m "first commit"
git remote add origin https://github.com/SEOTAEEYOUL/GKE.git
git push -u origin master
```

#### …or push an existing repository from the command line
```
git remote add origin https://github.com/SEOTAEEYOUL/GKE.git
git push -u origin master
```
