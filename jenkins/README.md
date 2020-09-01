# Jenkins

Link
[Jenkins Kubernetes Plugin](https://plugins.jenkins.io/kubernetes/)
[Slack Jenkins CI](https://sk-tcl.slack.com/services/B019UNHMDFC?added=1)

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
