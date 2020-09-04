
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

