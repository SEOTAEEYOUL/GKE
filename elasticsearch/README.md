# ElasticSearch

### 서버 생성
Ubuntu 18.04로 고정된 private ip만 보유 하도록 서버 생성  
- CPU:4core  Memory:8GB Disk:20GB SSD  
- Name : elasticsearch  

### JAVA 11 설치  
```
sudo su - #앞으로 root 권한으로 실행 하므로 주의

apt update && apt upgrade -y #system package update
apt install -y apt-transport-https

apt-cache search openjdk #openjdk-11 이 있는 지 확인 후
apt install -y openjdk-11-jre openjdk-11-jdk #openjdk-11 설치

java -version #설치된 자바 버전 확인

# JAVA_HOME 설정
cat >> /etc/environment << EOF
JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/
EOF
exit # 환경 변수 확인을 위해 SHELL 나간 후 재진입
sudo su - 
echo $JAVA_HOME  # JAVA_HOME 환경 변수 설정 되었는지 확인
```

### Install  
```
# 상기 쉘에 이어서 계속
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch \
    | sudo apt-key add -

cat > /etc/apt/sources.list.d/elastic-7.x.list << EOF
deb https://artifacts.elastic.co/packages/7.x/apt stable main
EOF

apt update && apt install -y elasticsearch

#Elasticsearch 설정

export ES_HOST=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p') && echo $ES_HOST

cat >> /etc/elasticsearch/elasticsearch.yml << EOF
#####################
# add custom config #
cluster.name: ttc-shop-search
node.name: ttc-shop-node-1
network.publish_host: $ES_HOST
discovery.seed_hosts: []
network.host: $ES_HOST
http.port: 9200
cluster.initial_master_nodes: $ES_HOST
EOF

systemctl start elasticsearch # ES 서비스 시작
systemctl enable elasticsearch # ES 서비스 자동 시작 설정
#systemctl status elasticsearch # ES 서비스 상태 확인


curl -XGET "http://$ES_HOST:9200" # ES 이름 및 버전 확인
#curl http://$ES_HOST:9200/_cluster/health?pretty

# ES 쓰기 테스트
curl -XPOST -H 'Content-Type: application/json' \
     "http://$ES_HOST:9200/tutorial/helloworld/1?pretty" \
      -d '{ "message": "Hello World!" }'

# ES 읽기 테스트
curl -X GET -H "Content-Type: application/json" \
     "http://$ES_HOST:9200/tutorial/helloworld/1?pretty"


# Elasticsearch 서버 주소
# ES_HOST=10.178.0.30
# 초기화하기
# curl -XDELETE "http://$ES_HOST:9200/_all"
```
