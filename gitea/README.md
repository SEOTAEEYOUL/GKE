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
taeeyoul@cloudshell:~/workspace/ttc-infra/gitea/gitea (ttc-team-14)$ ki get pod | grep gitea
gitea-gitea-b4867f648-s6tgm                           3/3     Running   0          2m4s

taeeyoul@cloudshell:~/workspace/ttc-infra/gitea/gitea (ttc-team-14)$ ki get pod,svc,ep,ing,pvc -lrelease=gitea
NAME                       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/gitea-gitea-http   NodePort    172.16.53.218   <none>        3000:32502/TCP   113s
service/gitea-gitea-ssh    ClusterIP   172.16.95.144   <none>        22/TCP           112s

NAME                         ENDPOINTS           AGE
endpoints/gitea-gitea-http   192.168.2.83:3000   113s
endpoints/gitea-gitea-ssh    192.168.2.83:22     112s
NAME                                    HOSTS                     ADDRESS         PORTS   AGE

ingress.extensions/gitea-giteaingress   gitea.team14.sk-ttc.com   34.107.206.65   80      112s
NAME                                   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/gitea-gitea      Bound    pvc-4edcc7e5-cf00-42c6-8521-4e49f0bd959f   1Gi        RWO            nfs-client     113s
persistentvolumeclaim/gitea-postgres   Bound    pvc-ba8f32a4-008b-4ddd-bc73-10b6a545b9e9   1Gi        RWO            nfs-client     113s
```

#### Storage Class 가 standard 일 경우 발생하는 오류  
- pvc 는 생성되나 pod 가 아래와 같은 오류가 발생하여 Pending 상태로 지속됨
  - 해결책 : Storage Class 를 nfs-client 로 변경함
  
```
NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
gitea-gitea      Bound    pvc-e8e630fa-f9f5-498e-8869-d0bcc5acce55   1Gi        RWO            standard       2m39s
gitea-postgres   Bound    pvc-114654f4-15cd-45c5-98c6-215c7f7e892a   1Gi        RWO            standard       2m39s
```
  
```	
gitea-gitea-b4867f648-m75jz                           0/3     Pending   0          3m4s
```

```
Events:
  Type     Reason             Age                  From                Message
  ----     ------             ----                 ----                -------
  Normal   NotTriggerScaleUp  106s                 cluster-autoscaler  pod didn't trigger scale-up (it wouldn't fit if a new node is added):
  Warning  FailedScheduling   105s (x3 over 109s)  default-scheduler   pod has unbound immediate PersistentVolumeClaims (repeated 3 times)
  Warning  FailedScheduling   15s (x3 over 103s)   default-scheduler   0/3 nodes are available: 3 node(s) had volume node affinity conflict.
```


