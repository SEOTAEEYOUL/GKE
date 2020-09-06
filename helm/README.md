# Helm

- OSS Package 설치를 위해 Helm3 Client 설치하여 사용함

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

#### bastion 서버 설치 기록  
```
taeeyoul@bastion-1:~$ sudo curl -L https://raw.githubusercontent.com/helm/helm/master/scripts/get
-helm-3 | bash
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  6815  100  6815    0     0  17602      0 --:--:-- --:--:-- --:--:-- 17564
Downloading https://get.helm.sh/helm-v3.3.1-linux-amd64.tar.gz
Preparing to install helm into /usr/local/bin
helm installed into /usr/local/bin/helm
taeeyoul@bastion-1:~$ helm version
version.BuildInfo{Version:"v3.3.0", GitCommit:"8a4aeec08d67a7b84472007529e8097ec3742105", GitTreeState:"dirty", GoVersion:"go1.1
4.7"}
taeeyoul@bastion-1:~$  helm repo add stable https://kubernetes-charts.storage.googleapis.com/
"stable" has been added to your repositories
taeeyoul@bastion-1:~$ helm repo list
NAME    URL                                              
stable  https://kubernetes-charts.storage.googleapis.com/
taeeyoul@bastion-1:~$ helm repo add incubator https://kubernetes-charts-incubator.storage.googlea
pis.com
"incubator" has been added to your repositories
taeeyoul@bastion-1:~$ helm repo add bitnami https://charts.bitnami.com/bitnami
"bitnami" has been added to your repositories
taeeyoul@bastion-1:~$ helm repo add keyporttech     https://keyporttech.github.io/helm-charts/
"keyporttech" has been added to your repositories
taeeyoul@bastion-1:~$ helm repo add argo            https://argoproj.github.io/argo-helm
"argo" has been added to your repositories
taeeyoul@bastion-1:~$ helm repo add codecentric     https://codecentric.github.io/helm-charts
"codecentric" has been added to your repositories
taeeyoul@bastion-1:~$ helm repo add harbor          https://helm.goharbor.io
"harbor" has been added to your repositories
taeeyoul@bastion-1:~$ helm repo list
NAME            URL                                                       
stable          https://kubernetes-charts.storage.googleapis.com/         
incubator       https://kubernetes-charts-incubator.storage.googleapis.com
bitnami         https://charts.bitnami.com/bitnami                        
keyporttech     https://keyporttech.github.io/helm-charts/                
argo            https://argoproj.github.io/argo-helm                      
codecentric     https://codecentric.github.io/helm-charts                 
harbor          https://helm.goharbor.io                                  
taeeyoul@bastion-1:~/workspace/ttc-infra/prometheus$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "harbor" chart repository
...Successfully got an update from the "keyporttech" chart repository
...Successfully got an update from the "argo" chart repository
...Successfully got an update from the "codecentric" chart repository
...Successfully got an update from the "incubator" chart repository
...Successfully got an update from the "stable" chart repository
...Successfully got an update from the "bitnami" chart repository
Update Complete. ⎈ Happy Helming!⎈ 
```
