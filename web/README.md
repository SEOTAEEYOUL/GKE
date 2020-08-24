#WEB

### OS 정보
```
taeeyoul@web01:~$ uname -a
Linux web01 5.3.0-1032-gcp #34~18.04.1-Ubuntu SMP Tue Jul 14 22:07:36 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
taeeyoul@web01:~$ grep . /etc/*release
/etc/lsb-release:DISTRIB_ID=Ubuntu
/etc/lsb-release:DISTRIB_RELEASE=18.04
/etc/lsb-release:DISTRIB_CODENAME=bionic
/etc/lsb-release:DISTRIB_DESCRIPTION="Ubuntu 18.04.5 LTS"
/etc/os-release:NAME="Ubuntu"
/etc/os-release:VERSION="18.04.5 LTS (Bionic Beaver)"
/etc/os-release:ID=ubuntu
/etc/os-release:ID_LIKE=debian
/etc/os-release:PRETTY_NAME="Ubuntu 18.04.5 LTS"
/etc/os-release:VERSION_ID="18.04"
/etc/os-release:HOME_URL="https://www.ubuntu.com/"
/etc/os-release:SUPPORT_URL="https://help.ubuntu.com/"
/etc/os-release:BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
/etc/os-release:PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
/etc/os-release:VERSION_CODENAME=bionic
/etc/os-release:UBUNTU_CODENAME=bionic
```

### 설치 정보
```
sudo -i -u ubuntu #ubuntu 유저로 전환 후 작업

sudo apt update
sudo apt upgrade -y
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

curl $(curl -sL ifconfig.me) -vvv  # check


sudo tee /etc/nginx/sites-available/backend << EOF
server {
  listen 80;
  # server_name _; # change this

  # global gzip on
  gzip on;
  gzip_min_length 10240;
  gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml;
  gzip_disable "MSIE [1-6]\.";

  add_header Cache-Control public;

  location / {
    proxy_pass http://10.178.0.2:80;
    proxy_buffering on;
    proxy_buffers 12 12k;
    proxy_redirect default;
    proxy_redirect default;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$remote_addr;
    proxy_set_header Host \$host;
  }
}
EOF
sudo ln -s /etc/nginx/sites-available/backend /etc/nginx/sites-enabled/backend
sudo rm -f /etc/nginx/sites-enabled/default
sudo systemctl restart nginx
```
