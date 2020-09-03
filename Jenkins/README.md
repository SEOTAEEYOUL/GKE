# Jenkins

#### Link  
[Jenkins Kubernetes Plugin](https://plugins.jenkins.io/kubernetes/)  
    
[Slack Jenkins CI - Slack 용 App](https://sk-tcl.slack.com/services/B019UNHMDFC?added=1)  
[Slack Notification - Jenkinsfile 에서 slack 연동 Plugin](https://plugins.jenkins.io/slack/)  
    
[Gitea - 자동 빌드용 Plugin](https://plugins.jenkins.io/gitea/)  
    
[Jenkins를 사용하여 Google Kubernetes Engine에 지속적으로 배포](https://cloud.google.com/solutions/continuous-delivery-jenkins-kubernetes-engine?hl=ko)  
[How to Push Docker Image to Google Container Registry (GCR) through Jenkins Job](https://medium.com/google-cloud/how-to-push-docker-image-to-google-container-registry-gcr-through-jenkins-job-52b9d5ce9f7f)  
[* Container Registry 인증 방식 *](https://cloud.google.com/container-registry/docs/advanced-authentication)  
[* GCR 배포를 위한 권한 *](https://cloud.google.com/container-registry/docs/access-control#permissions_and_roles)  

![Jenkins Pipeline](https://cloud.google.com/solutions/images/jenkins-cd-container-engine.svg?hl=ko)

### Install  
#### Search  
```
taeeyoul@cloudshell:~/workspace/ttc-infra/jenkins (ttc-team-14)$ helm search repo stable/jenkins
NAME            CHART VERSION   APP VERSION     DESCRIPTION
stable/jenkins  2.5.2           lts             Open source continuous integration server. It s...
taeeyoul@cloudshell:~/workspace/ttc-infra/jenkins (ttc-team-14)$ helm fetch stable/jenkins
taeeyoul@cloudshell:~/workspace/ttc-infra/jenkins (ttc-team-14)$ ls -lt
total 52
-rw-r--r-- 1 taeeyoul taeeyoul 53215 Sep  1 01:37 jenkins-2.5.2.tgz
taeeyoul@cloudshell:~/workspace/ttc-infra/jenkins (ttc-team-14)$ tar -xzvf jenkins-2.5.2.tgz
jenkins/Chart.yaml
jenkins/values.yaml
jenkins/templates/NOTES.txt
jenkins/templates/_helpers.tpl
jenkins/templates/config.yaml
jenkins/templates/deprecation.yaml
jenkins/templates/home-pvc.yaml
jenkins/templates/jcasc-config.yaml
jenkins/templates/jenkins-agent-svc.yaml
jenkins/templates/jenkins-backup-cronjob.yaml
jenkins/templates/jenkins-backup-rbac.yaml
jenkins/templates/jenkins-master-alerting-rules.yaml
jenkins/templates/jenkins-master-backendconfig.yaml
jenkins/templates/jenkins-master-deployment.yaml
jenkins/templates/jenkins-master-ingress.yaml
jenkins/templates/jenkins-master-networkpolicy.yaml
jenkins/templates/jenkins-master-route.yaml
jenkins/templates/jenkins-master-servicemonitor.yaml
jenkins/templates/jenkins-master-svc.yaml
jenkins/templates/jobs.yaml
jenkins/templates/rbac.yaml
jenkins/templates/secret-https-jks.yaml
jenkins/templates/secret.yaml
jenkins/templates/service-account-agent.yaml
jenkins/templates/service-account.yaml
jenkins/templates/tests/jenkins-test.yaml
jenkins/templates/tests/test-config.yaml
jenkins/.helmignore
jenkins/CHANGELOG.md
jenkins/OWNERS
jenkins/README.md
```

### 설정값 (values.yaml)
- 영구볼륨클레임, 서비스타입, 네임스페이스
```
  # List of plugins to be install during Jenkins master start
  installPlugins:
    - kubernetes:1.25.7
    - workflow-job:2.39
    - workflow-aggregator:2.6
    - credentials-binding:1.23
    - git:4.2.2
    - configuration-as-code:1.41
```

### 추가설치 Plugin
[Slack Notification](https://plugins.jenkins.io/slack/)  
[Google Authenticated Source](https://plugins.jenkins.io/google-source-plugin/)  
[Gitea](https://plugins.jenkins.io/gitea/)

  

### Helm 배포
```
taeeyoul@cloudshell:~/workspace/ttc-infra/jenkins/jenkins (ttc-team-14)$ helm install jenkins . -n ttc-infra -f values.yaml
NAME: jenkins
LAST DEPLOYED: Wed Sep  2 03:03:21 2020
NAMESPACE: ttc-infra
STATUS: deployed
REVISION: 1
NOTES:
1. Get your 'admin' user password by running:
  printf $(kubectl get secret --namespace ttc-infra jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
2. Get the Jenkins URL to visit by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace ttc-infra -l "app.kubernetes.io/component=jenkins-master" -l "app.kubernetes.io/instance=jenkins" -o jsonpath="{.items[0].metadata.name}")
  echo http://127.0.0.1:8080
  kubectl --namespace ttc-infra port-forward $POD_NAME 8080:8080
3. Login with the password from step 1 and the username: admin
4. Use Jenkins Configuration as Code by specifying configScripts in your values.yaml file, see documentation: http:///configuration-as-code and examples: https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos
For more information on running Jenkins on Kubernetes, visit:
https://cloud.google.com/solutions/jenkins-on-container-engine
For more information about Jenkins Configuration as Code, visit:
https://jenkins.io/projects/jcasc/
taeeyoul@cloudshell:~/workspace/ttc-infra/jenkins/jenkins (ttc-team-14)$
```

---


#### GCR 배포를 위한 Jenkinsfile 에서 docker login 추가하는 절차  
- 현재 access token 방식은 1 시간 유효 이므로, 매 배포시 만들어 넣어 주어야 함  
   
1) 서비스 계정 추가 및 권한 추가
- 부여할 권한
> 스토리자 관리자
> 스토리지 객체 뷰어

2) 서비스 계정의 Key 를 Json 형태로 받음  

- Cloud SDK 서비스 계정 Login 하기  
> gcloud auth activate-service-account ACCOUNT --key-file=KEY-FILE
   
```
taeeyoul@bastion-1:~/workspace/ttc-infra/Jenkins$ gcloud auth activate-service-account tyseo-565@ttc-team-14.iam.gserviceaccount.com  --key-file=tyseo-565.json
Activated service account credentials for: [tyseo-565@ttc-team-14.iam.gserviceaccount.com]
```

- Access Token 을 가지고 Login   
> Access Token 은 일시적으로 Container Registry와 연결하는 데 사용하기 한 시간 전에 요청합니다.  
```
taeeyoul@bastion-1:~/workspace/ttc-infra/Jenkins$ gcloud auth print-access-token | docker login -u oauth2accesstoken --password-
stdin https://asia.gcr.io
WARNING! Your password will be stored unencrypted in /home/taeeyoul/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store
Login Succeeded
taeeyoul@bastion-1:~/workspace/ttc-infra/Jenkins$ gcloud auth print-access-token | docker login -u oauth2accesstoken --password-
stdin https://gcr.io
WARNING! Your password will be stored unencrypted in /home/taeeyoul/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store
Login Succeeded
```


3) Add Jenkinsfile 에 Docker login 추가
> gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://[HOSTNAME]
> [HOSTNAME] gcr.io, us.gcr.io, eu.gcr.io 또는 asia.gcr.io


- 오류 Case
```
+ docker login -u oauth2accesstoken -p "ya29.c.Kp ... I-_uOiH" https//asia.gcr.io
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
```

- 성공 Case
```
echo -n "ya29.c.Kp ... I-_uOiH"| docker login -u oauth2accesstoken --password-stdin https://asia.gcr.io
```
