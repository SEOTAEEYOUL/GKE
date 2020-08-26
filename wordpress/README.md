# WordPress

### Persistent Volume 생성  
#### GKE 및 Cloud SQL Admin API를 사용 설정    
```
taeeyoul@cloudshell:~/workspace (ttc-team-14)$ gcloud services enable container.googleapis.com sqladmin.googleapis.com
Operation "operations/acf.108b1ba2-7b7d-4b55-8270-7df501efab65" finished successfully.
```

#### Zone 설정  
```
taeeyoul@cloudshell:~/workspace/app (ttc-team-14)$ gcloud config set compute/zone asia-northeast3
Updated property [compute/zone].
taeeyoul@cloudshell:~/workspace/app (ttc-team-14)$ gcloud config list
[component_manager]
disable_update_check = True
[compute]
gce_metadata_read_timeout_sec = 5
zone = asia-northeast3
[core]
account = taeeyoul@gmail.com
disable_usage_reporting = True
project = ttc-team-14
[metrics]
environment = devshell
Your active configuration is: [cloudshell-3579]
```
