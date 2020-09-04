# Ingress  

* Google Cloud VPC 네트워크와 긴밀하게 통합되는 엔터프라이즈급 부하 분산 기능을 제공 
* FrontendConfig 및 BackendConfig 커스텀 리소스 정의(CRD)를 사용하면 부하 분산기를 추가로 맞춤설정할 수 있음 
  * FrontendConfig : 인그레스 객체에서 참조  
  * BackendConfig는 서비스 객체에서 참조  
* FrontendConfig CRD와 BackendConfig CRD는 해당하는 인그레스 및 서비스 리소스와 동일한 수명 주기를 공유하며 종종 함께 배포됨

### Link
> [인그레스 기능](https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-features?hl=ko)  
> [외부 HTTP(S) 부하 분산용 인그레스 ](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress-xlb?hl=ko)  
> [내부 부하 분산용 인그레스 구성](https://cloud.google.com/kubernetes-engine/docs/how-to/internal-load-balance-ingress?hl=ko)  
> [HTTP(S) 부하 분산용 GKE 인그레스](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress?hl=kO)  
  
![Ingress BackendConfig 및 FrontendConfig 개요](https://cloud.google.com/kubernetes-engine/images/ingress-configs.svg?hl=ko)  
  
### 내부 인그레스 주석 요약  
#### 인그레스 주석  
|주석|설명| 
|---|:---|
|kubernetes.io/ingress.class | 내부 인그레스에 대해 'gce-internal'로 지정됩니다. </br>클래스가 지정되지 않았으면 기본적으로 인그레스 리소스가 외부 인그레스로 해석됩니다. |  
|kubernetes.io/ingress.allow-http | 클라이언트와 HTTP(S) 부하 분산기 간에 HTTP 트래픽을 허용할지 여부를 지정합니다. </br> 가능한 값은 'true', 'false'입니다. </br> 기본값은 'true'이지만, 내부 부하 분산을 위해 HTTPS를 사용하는 경우 'false'로 설정해야 합니다. </br> HTTP 중지를 참조하세요. |  
|ingress.gcp.kubernetes.io/pre-shared-cert | Google Cloud 프로젝트에 인증서와 키를 업로드할 수 있습니다. </br> 이 주석을 사용하여 인증서와 키를 참조합니다. </br> HTTP(S) 부하 분산에서 여러 SSL 인증서 사용을 참조하세요. |  

#### 인그레스와 관련된 서비스 주석  
|주석|설명| 
|---|:---|
|beta.cloud.google.com/backend-config | 이 주석을 사용하여 servicePort와 연결된 백엔드 서비스를 구성합니다. </br> 자세한 내용은 인그레스 기능을 참조하세요. |  
|cloud.google.com/neg | 이 주석을 사용하여 부하 분산기에서 네트워크 엔드포인트 그룹을 사용하도록 지정합니다. </br> 컨테이너 기반 부하 분산 사용을 참조하세요. |  


#### 정상일때   
  > 조회시 등록한 Host Backend 정보의 IP, Port No 가 표시됨  
  > Annotations 에 "HEALTHY" 가 표시됨
  > GCP 콘솔의 "부하분산" 를 조회시 정상으로 표기됨  
   
* kubectl 로  보기
```
taeeyoul@cloudshell:~/workspace/ttc-infra/ingress (ttc-team-14)$ ki describe ing ttc-infra
Name:             ttc-infra
Namespace:        ttc-infra
Address:          34.107.213.157
Default backend:  default-http-backend:80 (192.168.2.31:8080)
Rules:
  Host                            Path  Backends
  ----                            ----  --------
  prometheus.team14.sk-ttc.com
                                  /*   prometheus-server:80 (192.168.2.21:9090)
  alertmanager.team14.sk-ttc.com
                                  /*   prometheus-alertmanager:80 (192.168.2.30:9093)
  grafana.team14.sk-ttc.com
                                  /*   grafana:80 (192.168.2.20:3000)
  argocd.team14.sk-ttc.com
                                  /*   argocd-server:80 (192.168.2.23:8080)
  gitea.team14.sk-ttc.com
                                  /*   gitea-gitea-http:3000 (192.168.2.27:3000)
  jenkins.team14.sk-ttc.com
                                  /*   jenkins:8080 (192.168.2.28:8080)
Annotations:                      ingress.kubernetes.io/backends:
                                    {"k8s-be-30210--011a2b9a78e503d3":"HEALTHY","k8s-be-30421--011a2b9a78e503d3":"HEALTHY","k8s-be-31271--011a2b9a78e503d3":"HEALTHY","k8s-be-...
                                  ingress.kubernetes.io/forwarding-rule: k8s2-fr-crjzahb8-ttc-infra-ttc-infra-lb01do1z
                                  ingress.kubernetes.io/target-proxy: k8s2-tp-crjzahb8-ttc-infra-ttc-infra-lb01do1z
                                  ingress.kubernetes.io/url-map: k8s2-um-crjzahb8-ttc-infra-ttc-infra-lb01do1z
                                  meta.helm.sh/release-name: ttc
                                  meta.helm.sh/release-namespace: ttc-infra
Events:                           <none>
```


#### Ingress 오류 조회  
```
taeeyoul@cloudshell:~ (ttc-team-14)$ kubectl get events --all-namespaces --field-selector involvedObject.kind=Ingress
NAMESPACE   LAST SEEN   TYPE      REASON      OBJECT                                            MESSAGE
default     17m         Normal    ADD         ingress/frontend-ingress                          default/frontend-ingress
default     13m         Warning   Sync        ingress/frontend-ingress                          Error during sync: error running backend syncing routine: googleapi: Error 404: The resource 'projects/ttc-tea
m-14/zones/asia-northeast3-a/networkEndpointGroups/k8s1-011a2b9a-default-frontend-80-a7c8bff4' was not found, notFound
default     10m         Warning   Sync        ingress/frontend-ingress                          Error during sync: error running load balancer syncing routine: loadbalancer crjzahb8-default-frontend-ingress
-jmhb548p does not exist: googleapi: Error 400: Invalid value for field 'resource.target': 'https://www.googleapis.com/compute/beta/projects/ttc-team-14/regions/asia-northeast3/targetHttpProxies/k8s2-tp-crj
zahb8-default-frontend-ingress-jmhb548p'. A reserved and active subnetwork is required in the same region and VPC as the forwarding rule., invalid
default     8m12s       Normal    ADD         ingress/frontend-ingress                          default/frontend-ingress
default     109s        Warning   Sync        ingress/frontend-ingress                          Error during sync: error running load balancer syncing routine: loadbalancer crjzahb8-default-frontend-ingress
-jmhb548p does not exist: googleapi: Error 400: Invalid value for field 'resource.target': 'https://www.googleapis.com/compute/beta/projects/ttc-team-14/regions/asia-northeast3/targetHttpProxies/k8s2-tp-crj
zahb8-default-frontend-ingress-jmhb548p'. A reserved and active subnetwork is required in the same region and VPC as the forwarding rule., invalid
default     18m         Warning   Sync        ingress/hello-ingress                             Error during sync: error running backend syncing routine: googleapi: Error 404: The resource 'projects/ttc-tea
m-14/zones/asia-northeast3-a/networkEndpointGroups/k8s1-011a2b9a-default-frontend-80-a7c8bff4' was not found, notFound
default     8m10s       Warning   Sync        ingress/hello-ingress                             Error during sync: error running load balancer syncing routine: loadbalancer crjzahb8-default-hello-ingress-v0
qyyrt7 does not exist: googleapi: Error 400: Invalid value for field 'resource.target': 'https://www.googleapis.com/compute/beta/projects/ttc-team-14/regions/asia-northeast3/targetHttpProxies/k8s2-tp-crjzah
b8-default-hello-ingress-v0qyyrt7'. A reserved and active subnetwork is required in the same region and VPC as the forwarding rule., invalid
default     12m         Warning   Sync        ingress/hello-ingress                             Error during sync: error running backend syncing routine: googleapi: Error 404: The resource 'projects/ttc-tea
m-14/zones/asia-northeast3-c/networkEndpointGroups/k8s1-011a2b9a-default-frontend-80-a7c8bff4' was not found, notFound
ttc-infra   33m         Normal    ADD         ingress/prometheus-prometheus-oper-alertmanager   ttc-infra/prometheus-prometheus-oper-alertmanager
ttc-infra   30s         Warning   Translate   ingress/prometheus-prometheus-oper-alertmanager   error while evaluating the ingress spec: service "ttc-infra/prometheus-prometheus-oper-alertmanager" is type "
ClusterIP", expected "NodePort" or "LoadBalancer"
ttc-infra   33m         Normal    ADD         ingress/prometheus-prometheus-oper-prometheus     ttc-infra/prometheus-prometheus-oper-prometheus
ttc-infra   30s         Warning   Translate   ingress/prometheus-prometheus-oper-prometheus     error while evaluating the ingress spec: service "ttc-infra/prometheus-prometheus-oper-prometheus" is type "Cl
usterIP", expected "NodePort" or "LoadBalancer"
```

---


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

