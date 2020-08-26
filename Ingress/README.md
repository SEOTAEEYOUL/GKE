# Ingress

### Link
[인그레스 기능](https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-features?hl=ko)
[외부 HTTP(S) 부하 분산용 인그레스 ](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress-xlb?hl=ko)  
[내부 부하 분산용 인그레스 구성](https://cloud.google.com/kubernetes-engine/docs/how-to/internal-load-balance-ingress?hl=ko)  

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
