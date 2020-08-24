# WAS

### OS 정보 
```
Welcome to Ubuntu 18.04.4 LTS (GNU/Linux 5.3.0-1032-gcp x86_64)
 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

 * Are you ready for Kubernetes 1.19? It's nearly here! Try RC3 with
   sudo snap install microk8s --channel=1.19/candidate --classic
   https://microk8s.io/ has docs and details.
This system has been minimized by removing packages and content that are
not required on a system that users do not log into.
To restore this content, you can run the 'unminimize' command.
8 packages can be updated.
0 updates are security updates.
*** System restart required ***
The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.
Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.
taeeyoul@was01:~$ uname -a
Linux was01 5.3.0-1032-gcp #34~18.04.1-Ubuntu SMP Tue Jul 14 22:07:36 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
taeeyoul@was01:~$ grep . /etc/*releases
grep: /etc/*releases: No such file or directory
taeeyoul@was01:~$ grep . /etc/*release
/etc/lsb-release:DISTRIB_ID=Ubuntu
/etc/lsb-release:DISTRIB_RELEASE=18.04
/etc/lsb-release:DISTRIB_CODENAME=bionic
/etc/lsb-release:DISTRIB_DESCRIPTION="Ubuntu 18.04.4 LTS"
/etc/os-release:NAME="Ubuntu"
/etc/os-release:VERSION="18.04.4 LTS (Bionic Beaver)"
/etc/os-release:ID=ubuntu
/etc/os-release:ID_LIKE=debian
/etc/os-release:PRETTY_NAME="Ubuntu 18.04.4 LTS"
/etc/os-release:VERSION_ID="18.04"
/etc/os-release:HOME_URL="https://www.ubuntu.com/"
/etc/os-release:SUPPORT_URL="https://help.ubuntu.com/"
/etc/os-release:BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
/etc/os-release:PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
/etc/os-release:VERSION_CODENAME=bionic
/etc/os-release:UBUNTU_CODENAME=bionic
```


### 설치정보  
#### 서버생성   
Ubuntu 18.04 minimum 로 고정된 public ip도 보유 하도록 서버 생성  
- CPU: 2core
- Memory:4GB
- Disk:20GB SSD
- Name : app-01

#### WordPress 설치  
```
sudo -i -u ubuntu #ubuntu 유저로 전환 후 작업

## 환경 변수 설정
INSTALL_DIR="/var/www/wordpress"

# DB 정보
DB_HOST=10.23.64.3   #Cloud SQL 구성 후 얻은 주소
DB_USER=ttc          #Cloud SQL 구성 할 때 생성한 User ID
DB_NAME=wordpress    #생성할 database 이름
DB_PASS=TTC@2020sk     #Cloud SQL 구성 할 때 생성한 User ID
ES_HOST=10.178.0.49  #ElasticSearch 주소

# SITE 기본 정보
_TITLE_="TTC+SHOP"
_NAME_="ttc"
_PASS_="TTC@2020sk"
_EMAIL_="ttc@sk-ttc.com"

sudo apt update
sudo apt install -y unzip apt-transport-https sendmail


# Apache2 설치
sudo apt install -y apache2
sudo a2enmod rewrite
sudo systemctl start apache2 
sudo systemctl enable apache2

sudo usermod -a -G www-data $USER


# PHP 7.4 설치
sudo apt install -y software-properties-common language-pack-en-base
sudo LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php #진행중 엔터 필요

sudo timedatectl set-timezone 'Asia/Seoul'
# ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

sudo apt install -y php7.4 php7.4-{common,mysql,xml,xmlrpc,curl,gd,cli,opcache} \
     php7.4-{zip,soap,mbstring,bz2,intl,gmp,bcmath} \
     libapache2-mod-php7.4 php-imagick 

# DATABASE 설정
sudo apt install -y mariadb-client

# Databse 생성 : 아래 실행 후 Cloud SQL 구성 할 때 생성한 비밀번호 입력
echo "CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci" | mysql -h$DB_HOST -u$DB_USER -p$DB_PASS

# nfs mount
sudo apt install -y nfs-common
sudo mkdir -p /mnt/ttc_nfs
sudo mount -t nfs 10.212.235.218:/ttc_nfs /mnt/ttc_nfs/
sudo ln -s /mnt/ttc_nfs/wordpress /var/www/wordpress
sudo cat >> /etc/fstab << EOF
10.212.235.218:/ttc_nfs    /mnt/ttc_nfs    nfs    defaults    0    0
EOF


# Wordpress 설치
curl -fsSL http://wordpress.org/latest.tar.gz | tar zxv

sudo mv wordpress $INSTALL_DIR
sudo chown -R $USER:www-data $INSTALL_DIR
sudo chmod 2775 $INSTALL_DIR

sudo find $INSTALL_DIR -type d -exec chmod g+ws {} +
sudo find $INSTALL_DIR -type f -exec chmod g+w {} +

sudo chown -R www-data:www-data $INSTALL_DIR

sudo tee /etc/apache2/sites-available/000-default.conf << EOF
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot ${INSTALL_DIR}
        <Directory "${INSTALL_DIR}">
            AllowOverride All
            Options +Indexes +FollowSymLinks +ExecCGI
            AllowOverride All
            Order deny,allow
            Allow from all
            Require all granted
        </Directory>
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

sudo systemctl restart apache2

MYIP=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

curl http://$MYIP/wp-admin/setup-config.php?step=2 --data \ "dbname=$DB_NAME&uname=$DB_USER&pwd=$DB_PASS&dbhost=$DB_HOST&prefix=wp_&submit=Submit&language=ko_KR"

curl http://$MYIP/wp-admin/install.php?step=2 --data \ 
"weblog_title=$_TITLE_&user_name=$_NAME_&admin_password=$_PASS_&admin_password2=$_PASS_&admin_email=$_EMAIL_&blog_public=1&Submit=Install+WordPress&language=ko_KR"


#보안상 히스토리 삭제
cat /dev/null > ~/.bash_history && history -c && exit
cat /dev/null > ~/.bash_history && history -c && exit 

#이후 WooCommerce 플러그인 설치 및 데이터 Import/Migration는 매뉴얼 수행
```

#### SITE URL(도메인)  DB 접속해서 직접 바꾸기  
```
mysql -h$DB_HOST -u$DB_USER -p$DB_PASS

USE wordpress;
 
#아래 커맨드로 확인
SELECT option_value from wp_options where option_name = 'siteurl' or option_name = 'home';

#아래 커맨드로 수정
UPDATE wp_options set option_value = 'http://legacy.sk-ttc.com' where option_name = 'siteurl' or option_name = 'home'; 

FLUSH PRIVILEGES;
EXIT
```

