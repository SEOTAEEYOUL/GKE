# CronJob

- HPA 를 특정주기에 맞춰 수행 Pod 개수를 늘릴 때 사용함  

#### 파일 예시
- startingDeadlineSeconds 가 200 이면, 컨트롤러는 최근 200초 내 몇 개의 잡이 누락되었는지 카운팅
- concurrencyPolicy 가 Forbid 로 설정되었고, 크론잡이 이전 일정이 스케줄되어 여전히 시도하고 있을 때, 그 때 누락되었다고 판단
```
taeeyoul@cloudshell:~/workspace/ttc-infra/cronjob (ttc-team-14)$ cat cj.yaml
#cronjob.yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"
  startingDeadlineSeconds: 200
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            args:
            - /bin/sh
            - -c
            - date; echo "Hello from the Kubernetes cluster"
          restartPolicy: OnFailure
```

### 필드 형식

```
taeeyoul@cloudshell:~/workspace/ttc-infra/cronjob (ttc-team-14)$ ka get cj
NAME                                  SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
elasticsearch-elasticsearch-curator   0 1 * * *     False     1        102m            4d1h
hello                                 */1 * * * *   False     0        <none>          14s
```
