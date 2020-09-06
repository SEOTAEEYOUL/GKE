# ArgoCD

## ArgoCD

### ArgoCD 정보 보기
```
taeeyoul@bastion-1:~/workspace/ttc-infra/argocd$ helm show chart argo/argo-cd --version 2.6.0
apiVersion: v1
appVersion: 1.6.2
dependencies:
- condition: redis-ha.enabled
  name: redis-ha
  repository: https://kubernetes-charts.storage.googleapis.com
  version: 4.4.2
description: A Helm chart for ArgoCD, a declarative, GitOps continuous delivery tool
  for Kubernetes.
home: https://github.com/argoproj/argo-helm
icon: https://raw.githubusercontent.com/argoproj/argo/master/docs/assets/argo.png
keywords:
- argoproj
- argocd
- gitops
maintainers:
- name: alexec
- name: alexmt
- name: jessesuen
- name: seanson
name: argo-cd
version: 2.6.0
```

### values.yaml 설정
- Container Memory 설정 (guaranteed mode)  
  ```
  resources:
    limits:
      cpu: 100m
      memory: 128Mi
    requests:
      cpu: 100m
      memory: 128Mi
  ```

- Ingress 사용을 위한 service type 설정 (ClusterIP -> NodePort)
  ```
  ## Server service configuration
  service:
    annotations: {}
    labels: {}
    type: NodePort
    servicePortHttp: 80
    servicePortHttps: 443
    servicePortHttpName: http
    servicePortHttpsName: https
    loadBalancerIP: ""
    loadBalancerSourceRanges: []
  ```

  
- Admin Password 설정
  ```
    # Argo expects the password in the secret to be bcrypt hashed. You can create this hash with
    # `htpasswd -nbBC 10 "" $ARGO_PWD | tr -d ':\n' | sed 's/$2y/$2a/'`
    # argocdServerAdminPassword:
    # Password modification time defaults to current time if not set
    # argocdServerAdminPasswordMtime: "2006-01-02T15:04:05Z"
    argocdServerAdminPassword: "$2a$10$GtIFgNLN5aczCqSHb/BN8e647QaInweoZoTG5WDZy.jr2.yW8jCzy"
  ```
   

### Helm 설치
```
taeeyoul@cloudshell:~/workspace/ttc-infra/argocd/argo-cd (ttc-team-14)$ helm install argocd . -n ttc-infra -f values.yaml
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
NAME: argocd
LAST DEPLOYED: Thu Sep  3 08:48:29 2020
NAMESPACE: ttc-infra
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
In order to access the server UI you have the following options:
1. kubectl port-forward service/argocd-server -n ttc-infra 8080:443
    and then open the browser on http://localhost:8080 and accept the certificate
2. enable ingress in the values file `service.ingress.enabled` and either
taeeyoul@cloudshell:~/workspace/ttc-infra/argocd/argo-cd (ttc-team-14)$ helm install argocd . -n ttc-infra -f values.yaml
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
manifest_sorter.go:192: info: skipping unknown hook: "crd-install"
NAME: argocd
LAST DEPLOYED: Fri Aug 28 01:55:25 2020
NAMESPACE: ttc-infra
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
In order to access the server UI you have the following options:
1. kubectl port-forward service/argocd-server -n ttc-infra 8080:443
    and then open the browser on http://localhost:8080 and accept the certificate
2. enable ingress in the values file `service.ingress.enabled` and either
      - Add the annotation for ssl passthrough: https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/ingress.md#option-1-ssl-passthrough
      - Add the `--insecure` flag to `server.extraArgs` in the values file and terminate SSL at your ingress: https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/ingress.md#option-2-multiple-ingress-objects-and-hosts
After reaching the UI the first time you can login with username: admin and the password will be the
name of the server pod. You can get the pod name by running:
kubectl get pods -n ttc-infra -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
```

---  
   
## Argocd Notification  


### 정보 보기
```
taeeyoul@bastion-1:~/workspace/ttc-infra/argocd$ helm show chart argo/argocd-notifications --version 1.0.11
apiVersion: v2
appVersion: 0.7.0
description: A Helm chart for ArgoCD notifications, an add-on to ArgoCD.
home: https://github.com/argoproj/argo-helm
icon: https://raw.githubusercontent.com/argoproj/argo/master/docs/assets/argo.png
keywords:
- argoproj
- argocd
- argocd-notifications
maintainers:
- name: alexmt
- name: andyfeller
name: argocd-notifications
version: 1.0.11
```

### 설치
#### Values.yaml 의 Slack 정보 등록
- Slack OAuth Access Token 설정
  ```
  secret:
    # Whether helm chart creates controller secret
    create: true
    notifiers:
      # For more information: https://argoproj-labs.github.io/argocd-notifications/services/overview/
      slack:
        # For more information: https://argoproj-labs.github.io/argocd-notifications/services/slack/
        # Specifies whether Slack notifier should be configured
        enabled: true
        # OAuth Access Token
        token: xoxb-719432660198-1074835145332-OBBUqd2VQFdctC2Y4HzvRdsv
        # Optional override username
        username:
        # Optional override icon
        icon: TTC2020-Team14
        # Optional override signingSecret: https://argoproj-labs.github.io/argocd-notifications/recipients/slack-bot/
        signingSecret:
  ```
  
- Container Memory 설정 (guaranteed mode)  
  ```
  resources:
    limits:
      cpu: 100m
      memory: 128Mi
    requests:
      cpu: 100m
      memory: 128Mi
  ```

- Notification 설정
  ```
  triggers:
    # The condition when the notification should be sent. The definition includes name, condition and notification template referenc e.
    #
    # Enable built-in triggers:
    #
    # Application has degraded
    - name: on-health-degraded
      enabled: true
    # Application syncing has failed
    - name: on-sync-failed
      enabled: true
    # Application is being synced
    - name: on-sync-running
      enabled: true
    # Application status is 'Unknown'
    - name: on-sync-status-unknown
      enabled: true
    # Application syncing has succeeded
    - name: on-sync-succeeded
      enabled: true
    # Or define your custom triggers:
    #
    - name: my-custom-trigger
      condition: app.status.sync.status == 'Unknown'
      template: my-custom-template
    # For more information: https://argoproj-labs.github.io/argocd-notifications/triggers_and_templates/
  ```

#### Helm Install
```
taeeyoul@cloudshell:~/workspace/ttc-infra/argocd/argocd-notifications (ttc-team-14)$ helm install argocd-notification . -n ttc-infra -f values.yaml
NAME: argocd-notification
LAST DEPLOYED: Fri Aug 28 01:47:42 2020
NAMESPACE: ttc-infra
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

### 설치 후 Slack Notification 설정하기
- App 조회
  ```
  taeeyoul@bastion-1:~/workspace/ttc-infra/argocd/argocd-notifications$ ki get app
  NAME         AGE
  nodejs-bot   2d17h
  wordpress    2d17h
  ```

- Slack 알림이 가도록 설정
  ```
  taeeyoul@bastion-1:~/workspace/ttc-infra/argocd/argocd-notifications$ kubectl patch app nodejs-bot -n ttc-infra -p '{"metadata":{"annotations":{"recipients.argocd-notifications.argoproj.io":"slack:ttc"}}}' --type merge
  application.argoproj.io/nodejs-bot patched
  taeeyoul@bastion-1:~/workspace/ttc-infra/argocd/argocd-notifications$ kubectl patch app wordpress -n ttc-infra -p '{"metadata":{"annotations":{"recipients.argocd-notifications.argoproj.io":"slack:ttc"}}}' --type merge
  application.argoproj.io/wordpress patched
  ```
