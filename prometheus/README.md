# Prometheus


#### Helm Install  
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
