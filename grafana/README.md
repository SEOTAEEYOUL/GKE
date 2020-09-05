# Grafana 

* Kubernetes Helm Chart Stable 의 것을 사용함
* Helm Chart 를 받은 후 Local 에 풀어서 설치하는 형태를 사용함
* 기본 values.yaml 를 수정하여 설치하는 방식을 사용 (-f 사용은 kubeapps 에서 설정이 보이게 하기 위함
* Ingress 부분을 설치 후 삭제함 -> 정상 테스트 용도로 사용하고 ttc-infra Ingress 에 rule 을 추가함


#### Search & Fetch
```
taeeyoul@cloudshell:~/workspace/ttc-infra/grafana$ helm search repo grafana
NAME                    CHART VERSION   APP VERSION     DESCRIPTION
bitnami/grafana         3.4.1           7.1.4           Grafana is an open source, feature rich metrics...
incubator/grafana       0.1.4           0.0.1           DEPRECATED - incubator/grafana
stable/grafana          5.5.5           7.1.1           The leading tool for querying and visualizing t...
taeeyoul@cloudshell:~/workspace/ttc-infra/grafana$ helm fetch stable/grafana
taeeyoul@cloudshell:~/workspace/ttc-infra/grafana$ ls -lt
total 28
-rw-r--r-- 1 taeeyoul taeeyoul 21051 Sep  1 10:25 grafana-5.5.5.tgz
taeeyoul@cloudshell:~/workspace/ttc-infra/grafana$ tar -xzvf grafana-5.5.5.tgz
grafana/Chart.yaml
grafana/values.yaml
grafana/templates/NOTES.txt
grafana/templates/_helpers.tpl
grafana/templates/_pod.tpl
grafana/templates/clusterrole.yaml
grafana/templates/clusterrolebinding.yaml
grafana/templates/configmap-dashboard-provider.yaml
grafana/templates/configmap.yaml
grafana/templates/dashboards-json-configmap.yaml
grafana/templates/deployment.yaml
grafana/templates/headless-service.yaml
grafana/templates/ingress.yaml
grafana/templates/poddisruptionbudget.yaml
grafana/templates/podsecuritypolicy.yaml
grafana/templates/pvc.yaml
grafana/templates/role.yaml
grafana/templates/rolebinding.yaml
grafana/templates/secret-env.yaml
grafana/templates/secret.yaml
grafana/templates/service.yaml
grafana/templates/serviceaccount.yaml
grafana/templates/statefulset.yaml
grafana/templates/tests/test-configmap.yaml
grafana/templates/tests/test-podsecuritypolicy.yaml
grafana/templates/tests/test-role.yaml
grafana/templates/tests/test-rolebinding.yaml
grafana/templates/tests/test-serviceaccount.yaml
grafana/templates/tests/test.yaml
grafana/.helmignore
grafana/README.md
grafana/ci/default-values.yaml
grafana/ci/with-dashboard-json-values.yaml
grafana/ci/with-dashboard-values.yaml
grafana/dashboards/custom-dashboard.json
taeeyoul@cloudshell:~/workspace/ttc-infra/grafana$
```


#### Vaulue.yaml 설정 변경 부분  
- Ingress 사용을 위한 Service Type 변경 (ClusterIP -> NodePort)  
```
service:
  type: NodePort
  port: 80
  targetPort: 3000
    # targetPort: 4181 To be used with a proxy extraContainer
  annotations: {}
  labels: {}
  portName: service
```

- Admin Password 설정 (team14 공용 Password 적용)  
```
# Administrator credentials when not using an existing secret (see below)
adminUser: admin
adminPassword: ********
```
   
   
- Resources 절을 활성화 (Guaranteed 모드 설정)  
```
resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi
.
.
.
```
   
- Persistent Volume 적용(현재 default 는 nfs-sc 임)  
```
persistence:
  type: pvc
  enabled: true
  # storageClassName: default
  accessModes:
    # - ReadWriteOnce
    - ReadWriteMany
  size: 10Gi
  # annotations: {}
  finalizers:
    - kubernetes.io/pvc-protection
  # subPath: ""
  # existingClaim:
```
   
- DataSource 절에 Prometheus 정보 입력  
```
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-server.ttc-infra.svc.cluster.local
      access: proxy
      isDefault: true
```
   
- 기본 Dashboard ConfigMap 활성화  
```
dashboardsConfigMaps:
  default: "grafana-dashboard"
```
   
#### Install  
```
taeeyoul@cloudshell:~/workspace/ttc-infra/grafana/grafana$ helm install grafana . -n ttc-infra -f values.yaml
NAME: grafana
LAST DEPLOYED: Tue Sep  1 11:08:07 2020
NAMESPACE: ttc-infra
STATUS: deployed
REVISION: 1
NOTES:
1. Get your 'admin' user password by running:
   kubectl get secret --namespace ttc-infra grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
2. The Grafana server can be accessed via port 80 on the following DNS name from within your cluster:
   grafana.ttc-infra.svc.cluster.local
   If you bind grafana to 80, please update values in values.yaml and reinstall:
   ...
   securityContext:
     runAsUser: 0
     runAsGroup: 0
     fsGroup: 0
   command:
   - "setcap"
   - "'cap_net_bind_service=+ep'"
   - "/usr/sbin/grafana-server &&"
   - "sh"
   - "/run.sh"
   ...
   Details refer to https://grafana.com/docs/installation/configuration/#http-port.
   Or grafana would always crash.
   From outside the cluster, the server URL(s) are:
     http://grafana.team14.sk-ttc.com
3. Login with the password from step 1 and the username: admin
```
   
#### 기본 Dashboard 작성 및 추가   
- Dashboard 를 jsong 형태로 저장  
```
apiVersion: v1
kind: ConfigMap
metadata:
  annotations:
    meta.helm.sh/release-name: grafana
    meta.helm.sh/release-namespace: ttc-infra
  labels:
    app.kubernetes.io/instance: grafana
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: grafana
    app.kubernetes.io/version: 7.1.1
    helm.sh/chart: grafana-5.5.5
  name: grafana-dashboard
  namespace: ttc-infra
data:
  microservice-dashbaord.json: |-
    {
      "annotations": {
.
.
.
     "timezone": "",
      "title": "Micro Service Pods Core Usage",
      "uid": "kube-system-app-status-dashboard",
      "version": 5
    }
  apache-dashbaord.json: |-
    { 
      "annotations": {
        "list": [
          {
            "builtIn": 1,
            "datasource": "-- Grafana --",
.
.
.
      },
      "timezone": "",
      "title": "Apache",
      "uid": "Z9pbY-HWk",
      "version": 2
    }
  reids-dashbaord.json: |-
    {
      "annotations": {
        "list": [
          {
            "builtIn": 1,
            "datasource": "-- Grafana --",
            "enable": true,
            "hide": true,
            "iconColor": "rgba(0, 211, 255, 1)",
            "name": "Annotations & Alerts",
            "type": "dashboard"
          }
        ]
.
.
.
          }
        ]
      },
      "time": {
        "from": "now-24h",
        "to": "now"
      },
      "timepicker": {
        "refresh_intervals": [
          "5s",
          "10s",
          "30s",
          "1m",
          "5m",
          "15m",
          "30m",
          "1h",
          "2h",
          "1d"
        ],
        "time_options": [
          "5m",
          "15m",
          "1h",
          "6h",
          "12h",
          "24h",
          "2d",
          "7d",
          "30d"
        ]
      },
      "timezone": "browser",
      "title": "Redis Status",
      "uid": "LKSa_7Liz",
      "version": 29
    }
```
