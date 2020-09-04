# AutoScaler

!(AutoScaler)[https://d33wubrfki0l68.cloudfront.net/4fe1ef7265a93f5f564bd3fbb0269ebd10b73b4e/1775d/images/docs/horizontal-pod-autoscaler.svg]


### HPA 구성  
```
taeeyoul@cloudshell:~/workspace/ttc-infra/cronjob (ttc-team-14)$ ka get hpa
NAME                 REFERENCE                       TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
proxy                Deployment/proxy                0%/30%          3         9         3          40h
wordpress            Deployment/wordpress            9%/30%          3         30        5          3d19h
wordpress-20200903   Deployment/wordpress-20200903   <unknown>/30%   3         30        3          17h
```


### Scale Out/In 시키기  
```
taeeyoul@cloudshell:~/workspace/ttc-infra/cronjob (ttc-team-14)$ ka scale --replicas=4 deploy wordpress
deployment.apps/wordpress scaled
taeeyoul@cloudshell:~/workspace/ttc-infra/cronjob (ttc-team-14)$ ka get hpa
NAME                 REFERENCE                       TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
proxy                Deployment/proxy                0%/30%          3         9         3          40h
wordpress            Deployment/wordpress            9%/30%          3         30        4          3d19h
wordpress-20200903   Deployment/wordpress-20200903   <unknown>/30%   3         30        3          17h
taeeyoul@cloudshell:~/workspace/ttc-infra/cronjob (ttc-team-14)$ ka scale --replicas=3 deploy wordpress
deployment.apps/wordpress scaled
taeeyoul@cloudshell:~/workspace/ttc-infra/cronjob (ttc-team-14)$ ka get hpa
NAME                 REFERENCE                       TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
proxy                Deployment/proxy                1%/30%          3         9         3          40h
wordpress            Deployment/wordpress            19%/30%         3         30        3          3d19h
wordpress-20200903   Deployment/wordpress-20200903   <unknown>/30%   3         30        3          17h
```
