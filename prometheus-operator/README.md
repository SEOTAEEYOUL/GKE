# Prometheus-operator

### Link
* [prometheus-operator](https://coreos.com/blog/the-prometheus-operator.html)  
* [prometheus-operator - getting-started](https://coreos.com/operators/prometheus/docs/latest/user-guides/getting-started.html)  
* [prometheus-operator - rbac](https://coreos.com/operators/prometheus/docs/latest/rbac.html)  
* [Simple Management of Prometheus Monitoring Pipeline with the Prometheus Operator](https://medium.com/kubernetes-tutorials/simple-management-of-prometheus-monitoring-pipeline-with-the-prometheus-operator-b445da0e0d1a)    

![prometheus-operator](https://coreos.com/sites/default/files/inline-images/p1.png)

### stable/prometheus-operator 설치  
```
taeeyoul@cloudshell:~/workspace/ttc-infra/prometheus-operator (ttc-team-14)$ helm install prometheus . -n ttc-infra -f values.yaml
NAME: prometheus
LAST DEPLOYED: Wed Aug 26 09:34:03 2020
NAMESPACE: ttc-infra
STATUS: deployed
REVISION: 1
NOTES:
The Prometheus Operator has been installed. Check its status by running:
  kubectl --namespace ttc-infra get pods -l "release=prometheus"
Visit https://github.com/coreos/prometheus-operator for instructions on how
to create & configure Alertmanager and Prometheus instances using the Operator.
```

### Persistent Volume 생성  
####   
```
taeeyoul@cloudshell:~/workspace (ttc-team-14)$ gcloud services enable container.googleapis.com sqladmin.googleapis.com
Operation "operations/acf.108b1ba2-7b7d-4b55-8270-7df501efab65" finished successfully.
```

```
taeeyoul@cloudshell:~/workspace/ttc-infra/prometheus-operator (ttc-team-14)$ helm install prometheus . -n ttc-infra -f values.yaml
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
NAME: prometheus
LAST DEPLOYED: Wed Aug 26 03:42:46 2020
NAMESPACE: ttc-infra
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
** Please be patient while the chart is being deployed **
Watch the Prometheus Operator Deployment status using the command:
m
    kubectl get deploy -w --namespace ttc-infra -l app.kubernetes.io/name=prometheus-operator-operator,app.kubernetes.io/instance=prometheus
Watch the Prometheus StatefulSet status using the command:
    kubectl get sts -w --namespace ttc-infra -l app.kubernetes.io/name=prometheus-operator-prometheus,app.kubernetes.io/instance=prometheus
Prometheus can be accessed via port "9090" on the following DNS name from within your cluster:
    prometheus-prometheus-oper-prometheus.ttc-infra.svc.cluster.local
To access Prometheus from outside the cluster execute the following commands:
  You should be able to access your new Prometheus installation through
  http://prometheus.local
Watch the Alertmanager StatefulSet status using the command:
    kubectl get sts -w --namespace ttc-infra -l app.kubernetes.io/name=prometheus-operator-alertmanager,app.kubernetes.io/instance=prometheus
Alertmanager can be accessed via port "9093" on the following DNS name from within your cluster:
    prometheus-prometheus-oper-alertmanager.ttc-infra.svc.cluster.local
To access Alertmanager from outside the cluster execute the following commands:
  You should be able to access your new Prometheus installation through
  http://alertmanager.local
taeeyoul@cloudshell:~/workspace/ttc-infra/prometheus-operator (ttc-team-14)$
```
