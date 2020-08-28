# Gitea

### Install  
```
taeeyoul@cloudshell:~/workspace/ttc-infra/gitea/gitea (ttc-team-14)$ helm install gitea . -n ttc-infra -f values.yaml
NAME: gitea
LAST DEPLOYED: Fri Aug 28 02:27:25 2020
NAMESPACE: ttc-infra
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Connect to your Gitea web URL by running:
  Ingress is enabled for this chart deployment.  Please access the web UI at gitea.team14.sk-ttc.com
2. Connect to your Gitea ssh port:
  export POD_NAME=$(kubectl get pods --namespace ttc-infra -l "app=gitea-gitea" -o jsonpath="{.items[0].metadata.name}")
  kubectl port-forward $POD_NAME 8022:22
  echo http://127.0.0.1:8080/
  kubectl port-forward $POD_NAME 8022:22
```

#### 설치 확인  
```
taeeyoul@cloudshell:~/workspace/ttc-infra/gitea/gitea$ ki get pod,svc,ep -lrelease=git
NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/git-gitea-http   ClusterIP   172.16.22.238   <none>        3000/TCP   93s
service/git-gitea-ssh    ClusterIP   172.16.253.22   <none>        22/TCP     93s
NAME                       ENDPOINTS   AGE
endpoints/git-gitea-http   <none>      93s
endpoints/git-gitea-ssh    <none>      93s
taeeyoul@cloudshell:~/workspace/ttc-infra/gitea/gitea$ ki get pod,svc,ep,ing -lrelease=git
NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/git-gitea-http   ClusterIP   172.16.22.238   <none>        3000/TCP   98s
service/git-gitea-ssh    ClusterIP   172.16.253.22   <none>        22/TCP     98s
NAME                       ENDPOINTS   AGE
endpoints/git-gitea-http   <none>      98s
endpoints/git-gitea-ssh    <none>      98s
NAME                                  HOSTS                   ADDRESS   PORTS   AGE
ingress.extensions/git-giteaingress   git.team14.sk-ttc.com             80      98s
```
