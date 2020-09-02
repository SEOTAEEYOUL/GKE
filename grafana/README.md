# Grafana 


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
   ```
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
   ```
   Details refer to https://grafana.com/docs/installation/configuration/#http-port.
   Or grafana would always crash.
   From outside the cluster, the server URL(s) are:
     http://grafana.team14.sk-ttc.com
3. Login with the password from step 1 and the username: admin
```
