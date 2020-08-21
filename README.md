# GKE

[GKE 빠른 시작](https://cloud.google.com/kubernetes-engine/docs/quickstart)
[GKE Sample](https://github.com/GoogleCloudPlatform/kubernetes-engine-samples)


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
