# Helm

### Install

```
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
taeeyoul@cloudshell:~ (ttc-team-14)$ ./get_helm.sh
Helm v3.3.0 is available. Changing from version v3.2.1.
Downloading https://get.helm.sh/helm-v3.3.0-linux-amd64.tar.gz
Preparing to install helm into /usr/local/bin
helm installed into /usr/local/bin/helm
taeeyoul@cloudshell:~ (ttc-team-14)$ which helm
/usr/local/bin/helm
taeeyoul@cloudshell:~ (ttc-team-14)$ helm version
version.BuildInfo{Version:"v3.3.0", GitCommit:"8a4aeec08d67a7b84472007529e8097ec3742105", GitTreeState:"dirty", GoVersion:"go1.14.7"}
```

### Helm 초기화

### Helm Repo 추가  
```
taeeyoul@cloudshell:~ (ttc-team-14)$ helm repo add stable https://kubernetes-charts.storage.googleapis.com/
"stable" has been added to your repositories
taeeyoul@cloudshell:~ (ttc-team-14)$ helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com
"incubator" has been added to your repositories
taeeyoul@cloudshell:~ (ttc-team-14)$ helm repo add bitnami https://charts.bitnami.com/bitnami
"bitnami" has been added to your repositories
taeeyoul@cloudshell:~ (ttc-team-14)$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Unable to get an update from the "bitnami" chart repository (https://charts.bitnami.com/bitnami):
        Get "https://charts.bitnami.com/bitnami/index.yaml": dial tcp: lookup charts.bitnami.com on 169.254.169.254:53: no such host
...Successfully got an update from the "incubator" chart repository
h...Successfully got an update from the "stable" chart repository
Update Complete. ⎈ Happy Helming!⎈
taeeyoul@cloudshell:~ (ttc-team-14)$ helm repo list
NAME            URL
stable          https://kubernetes-charts.storage.googleapis.com/
bitnami         https://charts.bitnami.com/bitnami
incubator       https://kubernetes-charts-incubator.storage.googleapis.com
keyporttech     https://keyporttech.github.io/helm-charts/
argo            https://argoproj.github.io/argo-helm
codecentric     https://codecentric.github.io/helm-charts
harbor          https://helm.goharbor.io
```
