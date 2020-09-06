# Prometheus

* Cluster 내의 Pod 를 모니터링 하기 위해 설치
* Helm Chart stable/prometheus 사용
* Local 에 받아서 설치하는 형태를 취함


### 정보 보기
```
taeeyoul@bastion-1:~/workspace/ttc-infra/prometheus$ helm show chart stable/prometheus --version 11.12.0
apiVersion: v1
appVersion: 2.20.1
dependencies:
- condition: kubeStateMetrics.enabled
  name: kube-state-metrics
  repository: https://kubernetes-charts.storage.googleapis.com/
  version: 2.8.*
deprecated: true
description: DEPRECATED Prometheus is a monitoring system and time series database.
home: https://prometheus.io/
icon: https://raw.githubusercontent.com/prometheus/prometheus.github.io/master/assets/prometheus_logo-cb55bb5c346.png
name: prometheus
sources:
- https://github.com/prometheus/alertmanager
- https://github.com/prometheus/prometheus
- https://github.com/prometheus/pushgateway
- https://github.com/prometheus/node_exporter
- https://github.com/kubernetes/kube-state-metrics
version: 11.12.1

```

    
## stable/prometheus 설치

### values.yaml 의 설정값 변경 
- Persistent Volume 사용 설정  
  - default StorageClass 사용 설정
  ```
  persistentVolume:
    ## If true, Prometheus server will create/use a Persistent Volume Claim
    ## If false, use emptyDir
    ##
    enabled: true
    ## Prometheus server data Persistent Volume access modes
    ## Must match those of existing PV or dynamic provisioner
    ## Ref: http://kubernetes.io/docs/user-guide/persistent-volumes/
    ##
    accessModes:
      # - ReadWriteOnce
      - ReadWriteMany

    ## Prometheus server data Persistent Volume mount root path
    ##
    mountPath: /data
    ## Prometheus server data Persistent Volume size
    ##
    size: 8Gi

    ## Prometheus server data Persistent Volume Storage Class
    ## If defined, storageClassName: <storageClass>
    ## If set to "-", storageClassName: "", which disables dynamic provisioning
    ## If undefined (the default) or set to null, no storageClassName spec is
    ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
    ##   GKE, AWS & OpenStack)
    ##
    # storageClass: "-"
  ```
   
- Container Memory 설정 (guaranteed mode)  
  ```
  ## Prometheus server resource requests and limits
  ## Ref: http://kubernetes.io/docs/user-guide/compute-resources/
  ##
  resources:
    limits:
      cpu: 100m
      memory: 2048Mi
    requests:
      cpu: 100m
      memory: 2048Mi
  ```
   
- Ingress 사용을 위해 ServiceType 설정(NodePort)  
  ```
  service:
    annotations: {}
    labels: {}
    clusterIP: ""
    ## List of IP addresses at which the Prometheus server service is available
    ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
    ##
    externalIPs: []
    loadBalancerIP: ""
    loadBalancerSourceRanges: []
    servicePort: 80
    sessionAffinity: None
    # type: ClusterIP
    type: NodePort
  ```
    
- 보관 주기 (15d)  
  ```
  ## Prometheus data retention period (default if not specified is 15 days)
  ##
  retention: "15d"
  ```
   
### Install  
```
taeeyoul@cloudshell:~/workspace/ttc-infra/prometheus/prometheus$ helm install prometheus . -n ttc-infra -f values.yaml
NAME: prometheus
LAST DEPLOYED: Tue Sep  1 08:18:50 2020
NAMESPACE: ttc-infra
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
prometheus-server.ttc-infra.svc.cluster.local
From outside the cluster, the server URL(s) are:
http://prometheus.team14.sk-ttc.com
http://team14.sk-ttc.com/prometheus
The Prometheus alertmanager can be accessed via port 80 on the following DNS name from within your cluster:
prometheus-alertmanager.ttc-infra.svc.cluster.local
From outside the cluster, the alertmanager URL(s) are:
http://alertmanager.team14.sk-ttc.com
http://team14.sk-ttc.com/alertmanager
#################################################################################
######   WARNING: Pod Security Policy has been moved to a global property.  #####
######            use .Values.podSecurityPolicy.enabled with pod-based      #####
######            annotations                                               #####
######            (e.g. .Values.nodeExporter.podSecurityPolicy.annotations) #####
#################################################################################
The Prometheus PushGateway can be accessed via port 9091 on the following DNS name from within your cluster:
prometheus-pushgateway.ttc-infra.svc.cluster.local
Get the PushGateway URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace ttc-infra -l "app=prometheus,component=pushgateway" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace ttc-infra port-forward $POD_NAME 9091
For more information on running Prometheus, visit:
https://prometheus.io/
```

### 설치 후 작업  
#### Prometheus Alerting Rules 설정  
- "prometheus-server" ConfigMap 내의 alerting_rules.yml 에 Alerting Rules 설정  
   ```
    - name: application.rules
      rules:
      - alert: api_high_median_response_time
        expr: histogram_quantile(0.5, sum(rate(http_request_duration_ms_buket[1m])) by (le, app, route, method)) > 100
        for: 60s
        labels:
          severity: warning
        annotations:
          summary: "High median response time on {{ $labels.app }} and {{ $labels.method }} {{ $labels.route }}"
      - alert: chk_pod_cpu_high_utilization
        expr: round(100 * label_join(label_join(sum(rate(container_cpu_usage_seconds_total{container_name != "POD", image !=""}[1m
])) by (pod_name, container_name, namespace) , "pod", "", "pod_name"), "container", "", "container_name") / ignoring(container_nam
e, pod_name) avg(kube_pod_container_resource_limits_cpu_cores) by (pod, container, namespace)) > 95
        for: 1m
        labels:
          severity: info
        annotations:
          summary: 'CPU 사용량이 높은 POD {{$labels.pod}} on{{$labels.container}}'
          description: 'pod[{{$labels.namespace}}/{{$labels.pod}}] 의 container[{{$labels.container}}] CPU 사용량 [{{$value}} %]  
높습니다'
.
.
.
    - name: redis.rules
      rules:
      - alert: redis_slave_abnormal
        expr: count(redis_instance_info{role="slave"}) by (app) != 2
        for: 10m
        labels:
          severity: critical
        annotations:
          summary: 'Redis "{{ $labels.app }}" slave is abnormal'
          description: 'Redis "{{  $labels.app  }}" 가 비정상 상태임. 슬레이브 수({{ $value }})가 2가 아님'
      - alert: redis_master_link_down
        expr: redis_master_link_up != 1
        for: 10m
        labels:
          severity: critical
        annotations:
          summary: 'Redis "{{ $labels.release }}" is between Master and Slave data unsynchronized'
          description: 'Redis "{{ $labels.release }}" 마스터 연결 다운: Redis "{{ $labels.release }}" 가 마스터-슬레이브 싱크가 안
됨'
.
.
.

   ```


#### AlertManager 설정
- "prometheus-alertmanager" ConfigMap 의 **alertmanager.yaml** 내의  정보 수정
  - Slack webhook 등록
    ```
    global:
      resolve_timeout: 5m
      slack_api_url: https://hooks.slack.com/services/TM5CQKE5U/BMSEKU648/------------------------

    ```
  - "route" 내의 "receiver" 설정
     route:
      group_by: ['job']
      group_interval: 5m
      group_wait: 30s
      receiver: slack-notifications
      repeat_interval: 12h
     
    ```
  - "receivers" 내에 Slack Alert Format 설정  
    ```
    receivers:
    - name: 'slack-notifications'
      slack_configs:
      - channel: '#ttc'
        username: 'SK-TTC2020'
        send_resolved: true
        icon_emoji: ':crocodile:'
        icon_url: '{{ template "slack.default.iconurl" . }}'
        title: '[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] 모니터링 이벤트 알림'
        text: "{{ range .Alerts }} *경고:* _{{ .Labels.alertname }}_\n*심각도:* `{{ .Labels.severity }}`\n*환경:* *TTC.team14*\n*: * {{ .Annotations.summary }}\n*내용:* {{ .Annotations.description }}\n{{ end }}"
    ```   
