# AutoScaler

### 부하 대응 방안
* 예측된 부하(토요일 10시)에 대해서는 토요일 10 시 전(9시 30분 경)에 스케줄에 의해 미리 복제갯수를 변경하는 방식으로 부하에 대음
* 비 예측 대응은 HPA를 통해서 부하를 서비스 대응을 함

![AutoScaler](https://d33wubrfki0l68.cloudfront.net/4fe1ef7265a93f5f564bd3fbb0269ebd10b73b4e/1775d/images/docs/horizontal-pod-autoscaler.svg)


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
