# Jenkins

#### Link  
[Jenkins Kubernetes Plugin](https://plugins.jenkins.io/kubernetes/)  
[Slack Jenkins CI](https://sk-tcl.slack.com/services/B019UNHMDFC?added=1)  
[Slack Notification](https://plugins.jenkins.io/slack/)  
[Jenkins를 사용하여 Google Kubernetes Engine에 지속적으로 배포](https://cloud.google.com/solutions/continuous-delivery-jenkins-kubernetes-engine?hl=ko)  
[How to Push Docker Image to Google Container Registry (GCR) through Jenkins Job](https://medium.com/google-cloud/how-to-push-docker-image-to-google-container-registry-gcr-through-jenkins-job-52b9d5ce9f7f)  
[Container Registry 인증 방식](https://cloud.google.com/container-registry/docs/advanced-authentication)

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


#### GCR 배포를 위한 Jenkins Plugin  
1) Install required Jenkins Plugins  
```
Google OAuth Credentials Plugin
Docker Pipeline Plugin
Google Container Registry Auth Plugin
```

2) Create a service account.  
```
taeeyoul@bastion-1:~/workspace/ttc-infra/Jenkins$ gcloud auth activate-service-account tyseo-565@ttc-team-14.iam.gserviceaccount.com  --key-file=tyseo-565.json
Activated service account credentials for: [tyseo-565@ttc-team-14.iam.gserviceaccount.com]
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


3) Add Global Credential 
Jenkins -> Credentials -> Global Credentials -> Add Credentials
