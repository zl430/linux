#!/bin/bash
#name:zuolei
#date:181012
#自动安装jdk、rabbitmq、mongodb、nginx、tomcat、redis、MySQL、PHP、elk
install_log="/root/install_log"
hidden="/root/hidden_file"
package="/data/package"
localhost_ip=`curl icanhazip.com`
group=`cat /etc/group | grep  "^www"`
if [ -z "$group" ];then
	 groupadd www  2>/dev/null  >> $hidden && useradd -s /sbin/nologin -s www www 2>/dev/null  >> $hidden
else
   user=`cat   /etc/passwd | grep "^www"`
   if [ -z "$user" ];then
   		useradd -g www www
   	fi
fi
yum_repair(){
if [ -n "$linux7" ];then
	rpm -aq|grep yum|xargs rpm -e --nodeps 2>/dev/null  >> $hidden
	wget http://mirrors.163.com/centos/7/os/x86_64/Packages/python-urlgrabber-3.10-8.el7.noarch.rpm 2>/dev/null  >> $hidden
	wget http://mirrors.163.com/centos/7/os/x86_64/Packages/yum-3.4.3-158.el7.centos.noarch.rpm 2>/dev/null  >> $hidden
	wget http://mirrors.163.com/centos/7/os/x86_64/Packages/yum-cron-3.4.3-158.el7.centos.noarch.rpm 2>/dev/null  >> $hidden
	wget http://mirrors.163.com/centos/7/os/x86_64/Packages/yum-metadata-parser-1.1.4-10.el7.x86_64.rpm 2>/dev/null  >> $hidden
	wget http://mirrors.163.com/centos/7/os/x86_64/Packages/yum-plugin-fastestmirror-1.1.31-45.el7.noarch.rpm 2>/dev/null  >> $hidden
	rpm -ivh --force --nodeps python-urlgrabber-3.10-8.el7.noarch.rpm 2>/dev/null  >> $hidden
	rpm -ivh --force --nodeps yum-metadata-parser-1.1.4-10.el7.x86_64.rpm 2>/dev/null  >> $hidden
	rpm -ivh --force --nodeps yum-3.4.3-158.el7.centos.noarch.rpm yum-plugin-fastestmirror-1.1.31-45.el7.noarch.rpm 2>/dev/null  >> $hidden
	wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo 2>/dev/null  >> $hidden
	yum makecache 2>/dev/null  >> $hidden
	sed -i 's/\$releasever/7/' CentOS-Base.repo 2>/dev/null  >> $hidden
	yum clean all 2>/dev/null  >> $hidden
	yum makecache 2>/dev/null  >> $hidden
elif [ -n "$linux6" ];then
	wget http://mirrors.163.com/centos/6/os/x86_64/Packages/python-urlgrabber-3.9.1-11.el6.noarch.rpm 2>/dev/null  >> $hidden
	wget http://mirrors.163.com/centos/6/os/x86_64/Packages/yum-3.2.29-81.el6.centos.noarch.rpm 2>/dev/null  >> $hidden
	wget http://mirrors.163.com/centos/6/os/x86_64/Packages/yum-cron-3.2.29-81.el6.centos.noarch.rpm 2>/dev/null  >> $hidden
	wget http://mirrors.163.com/centos/6/os/x86_64/Packages/yum-metadata-parser-1.1.2-16.el6.x86_64.rpm 2>/dev/null  >> $hidden
	wget http://mirrors.163.com/centos/6/os/x86_64/Packages/yum-plugin-fastestmirror-1.1.30-41.el6.noarch.rpm 2>/dev/null  >> $hidden
	rpm -ivh --force --nodeps python-urlgrabber-3.9.1-11.el6.noarch.rpm 2>/dev/null  >> $hidden 
	rpm -ivh --force --nodeps yum-metadata-parser-1.1.2-16.el6.x86_64.rpm 2>/dev/null  >> $hidden
	rpm -ivh --force --nodeps yum-3.2.29-81.el6.centos.noarch.rpm yum-plugin-fastestmirror-1.1.30-41.el6.noarch.rpm 2>/dev/null  >> $hidden
	wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo   2>/dev/null  >> $hidden
	yum makecache 2>/dev/null  >> $hidden
	sed -i 's/\$releasever/6/' CentOS-Base.repo 2>/dev/null  >> $hidden
	yum clean all 2>/dev/null  >> $hidden
	yum makecache 2>/dev/null  >> $hidden
else
	exit 1
fi
}

yum_env(){
linux=`cat   /etc/redhat-release`
linux7=`echo $linux | grep -Po  "7.\d+"`
linux6=`echo $linux | grep -Po  "6.\d+"`
yum  repolist  2>/dev/null > /root/yum_log
yum_chk=`cat /root/yum_log | grep  "repolist:" | awk -F: '{print $2}'| sed -e 's/,//g' -e 's/^ //g'`
if [[ ${yum_chk} =~ [0-9]{4,5} ]];then
   yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel  ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5* krb5-devel libidn libidn-devel openssl openssl-devel libtool  libtool-libs libevent-devel libevent openldap openldap-devel nss_* openldap-clients openldap-servers libtool-ltdl libtool-ltdl-devel bison wget lrzsz 2>/dev/null  >> $hidden
else
   w=1
   if [ -n "$linux7" ];then
      rpm -ivh http://mirrors.ustc.edu.cn/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm 2>/dev/null  >> $hidden
	  	if [[ ${yum_chk} =~ [0-9]{4,5} ]];then
		 			yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel  ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5* krb5-devel libidn libidn-devel openssl openssl-devel libtool  libtool-libs libevent-devel libevent openldap openldap-devel nss_* openldap-clients openldap-servers libtool-ltdl libtool-ltdl-devel bison wget lrzsz 2>/dev/null  >> $hidden
		 			echo "yum list ok" >> $install_log
	  	else
		 			echo "yum list no" >> $install_log
		 			exit 1
	  	fi
   elif [ -n "$linux6" ];then
        rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm 2>/dev/null  >> $hidden
	  		if [[ ${yum_chk} =~ [0-9]{4,5} ]];then
		 				echo "yum list ok" >> $install_log
		 				yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel  ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5* krb5-devel libidn libidn-devel openssl openssl-devel libtool  libtool-libs libevent-devel libevent openldap openldap-devel nss_* openldap-clients openldap-servers libtool-ltdl libtool-ltdl-devel bison wget lrzsz 2>/dev/null  >> $hidden
	  		else
		 				echo "yum list no" >> $install_log
		 				exit 1
	  		fi
   fi
fi
rm  -rf  /root/yum_log
}

yum_env1(){
if [ -n "$linux6" ];then
	 wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo 2>/dev/null  >> $hidden
elif [ -n "$linux7" ];then
	 wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo 2>/dev/null  >> $hidden
fi
yum clean all 2>/dev/null  >> $hidden
yum makecache 2>/dev/null  >> $hidden
yum search lldb 2>/dev/null  >> $hidden 
yum -y install epel-release 2>/dev/null  >> $hidden
}
yum remove  java -y 2>/dev/null  >> $hidden && source /etc/profile
java_chack(){
package="/data/package"
java -version  2>/dev/null  >> $hidden
if [ $? -eq 0 ];then
#   java -version > /root/java_version  2>/dev/null  >> $hidden
#   java=`cat  /root/java_version | grep "java version" | awk -F\" {print $2}` 2>/dev/null  >> $hidden
#  rm -rf /root/java_version
#else
	 jdk_pack=`ls $package | grep "^jdk.*.gz"`
   tar xzf $package/$jdk_pack -C /usr/local/
   jdk_dir=`ls /usr/local/ | grep "^jdk1*"`
   echo "
   
# jdk evn
export JAVA_HOME=/usr/local/${jdk_dir}
export CLASSPATH=.:/usr/local/${jdk_dir}/lib/dt.jar:/usr/local/${jdk_dir}/lib/tools.jar
export PATH=/usr/local/${jdk_dir}/bin:$PATH
" >> /etc/profile &&  source /etc/profile
java -version  2>/dev/null  >> $hidden
if [ $? -eq 0 ];then 
	echo "java install ok" >> $install_log
else 
	echo "java install no" >> $install_log
fi
fi
}
source /etc/profile
rabbitmq_install(){
if [ ! -d /etc/rabbitmq ];then
   mkdir -p /etc/rabbitmq
fi
cd $package
yum -y install make gcc gcc-c++ kernel-devel m4 ncurses ncurses-devel openssl-devel perl 2>/dev/null  >> $hidden
tar -zxf otp_src_18.2.1.tar.gz && cd otp_src_18.2.1 && ./configure --prefix=/usr/local/erlang 2>/dev/null  >> $hidden&& make 2>/dev/null  >> $hidden&& make install 2>/dev/null  >> $hidden&& cd ..
echo "
#set erlang environment
export PATH=$PATH:/usr/local/erlang/bin
" >> /etc/profile
if [ $? -ne 0 ];then
	 echo "export PATH=$PATH:/usr/local/erlang/bin" >> /etc/profile
fi	 
source /etc/profile
yum -y  install xmlto zip unzip 2>/dev/null  >> $hidden
tar -zxf rabbitmq-server-3.5.7.tar.gz && cd $package/rabbitmq-server-3.5.7
make TARGET_DIR=/usr/local/rabbitmq SBIN_DIR=/usr/local/rabbitmq/sbin MAN_DIR=/usr/local/rabbitmq/man DOC_INSTALL_DIR=/usr/local/rabbitmq/doc 2>/dev/null  >> $hidden
if [ $? -eq 0 ];then
	make TARGET_DIR=/usr/local/rabbitmq SBIN_DIR=/usr/local/rabbitmq/sbin MAN_DIR=/usr/local/rabbitmq/man DOC_INSTALL_DIR=/usr/local/rabbitmq/doc install 2>/dev/null  >> $hidden
fi
cd ..
echo "

export PATH=$PATH:/usr/local/erlang/bin:/usr/local/rabbitmq/sbin
" >> /etc/profile
source /etc/profile
/usr/local/rabbitmq/sbin/rabbitmq-plugins enable rabbitmq_management 2>/dev/null  >> $hidden
source /etc/profile
. /etc/profile
/usr/local/rabbitmq/sbin/rabbitmq-server  -detached & 2>/dev/null  >> $hidden
rabbitmq_start=`netstat -anptul | grep -Po ':5672|:15672' | uniq | wc -l`
#if [ ${rabbitmq_start} -eq 2 ];then
#	echo "rabbitmq install ok" >> $install_log
#else
#	echo "rabbitmq install no" >> $install_log
#fi
echo "rabbitmq install ok" >> $install_log
/usr/local/rabbitmq/sbin/rabbitmqctl add_user  root wdGBwqLWZZZj 2>/dev/null  >> $hidden
/usr/local/rabbitmq/sbin/rabbitmqctl set_user_tags root administrator  2>/dev/null  >> $hidden
echo "rabbitmq 初始用户root，密码为:wdGBwqLWZZZj" >> $install_log
echo "web界面使用root登陆不成功，手动执行/usr/local/rabbitmq/sbin/rabbitmqctl set_user_tags root administrator" >> $install_log
}

redis_install(){
cd $package
echo "redis安装包下载中。。。" >> $install_log
wget http://download.redis.io/releases/redis-2.8.19.tar.gz  2>/dev/null  >> $hidden
tar -xzf redis-2.8.19.tar.gz &&  cd redis-2.8.19
make   2>/dev/null  >> $hidden && make install 2>/dev/null  >> $hidden
cp redis.conf /etc/
sed -i 's/daemonize no/daemonize yes/g' /etc/redis.conf
/data/package/redis-2.8.19/src/redis-server  /etc/redis.conf
redis_start=`netstat -anptul | grep "6379"`
if [ -n "$redis_start" ];then
	 echo "redis start ok" >> $install_log
fi
}

tomcat_install(){
cd $package
tar -xzf apache-tomcat-7.0.91.tar.gz -C  /usr/local
cd /usr/local
mv apache-tomcat-7.0.91 tomcat7
echo "
#tomcat evn
 CATALINA_HOME=/usr/local/tomcat7 export CATALINA_HOME
" >> /etc/profile
source /etc/profile
cd /usr/local/tomcat7/bin
jdk_dir=`ls /usr/local/ | grep "^jdk1*"`
tomcat1=`grep -n  "# OS specific support" catalina.sh | awk  -F: '{print $1}'`
sed ''$tomcat1' aJAVA_HOME=/usr/local/'${jdk_dir}'' -i catalina.sh
sed ''$tomcat1' aCATALINA_HOME=/usr/local/tomcat7' -i catalina.sh
cp   catalina.sh    /etc/init.d/tomcat
service  tomcat start 2>/dev/null  >> $hidden
tomcat_start=`netstat  -anptul | grep "8080"`
if [ -n "$tomcat_start" ];then
	 echo "tomcat start ok" 	>> $install_log
fi
}

mongo_install(){
cd $package
tar xzf mongodb-linux-x86_64-rhel70-3.2.21.tgz
mv mongodb-linux-x86_64-rhel70-3.2.21 /data/mongodb
mkdir -p /data/{db,log} 
touch /data/log/mongodb.log
echo "
dbpath = /data/db
logpath = /data/log/mongodb.log
port = 27017
fork = true
logappend = true
auth = true
" > /data/mongodb/bin/mongodb.conf
echo "mongo install ok" >> $install_log
/data/mongodb/bin/mongod --config  /data/mongodb/bin/mongodb.conf 2>/dev/null  >> $hidden
mongo_start=`cat $hidden|tail -5 | grep -i "successfully"`
if [ -n "$mongo_start" ];then
	echo "mongo start ok" >> $install_log
fi
}

nginx_install(){
if [ ! -d /data/www ];then
	mkdir -p /data/www
	if [ ! -d /data/weblogs/nginx ];then
		mkdir -p /data/weblogs/nginx
		chmod +w /data/weblogs/nginx
		chown -R www:www /data/weblogs/nginx
	fi
fi
cd $package
tar  zxf pcre-8.39.tar.gz && cd pcre-8.39
./configure 2>/dev/null  >> $hidden
if [ $? -eq 0 ];then
	make 2>/dev/null  >> $hidden &&  make install 2>/dev/null  >> $hidden
	if [ $? -eq 0 ];then
		echo "pcre install ok" >> $install_log
	fi
fi
cd ..
ln -sf /usr/local/lib/libpcre.a /usr/lib64/libpcre.a
if [ $? -eq 0 ];then
	ln -sf /usr/local/lib/libpcre.la /usr/lib64/libpcre.la
	if [ $? -eq 0 ];then
		ln -sf /usr/local/lib/libpcre.so /usr/lib64/libpcre.so
		if [ $? -eq 0 ];then
			ln -sf /usr/local/lib/libpcre.so.1 /usr/lib64/libpcre.so.1
			if [ $? -eq 0 ];then
				ln -sf /usr/local/lib/libpcre.so.1.0.0 /usr/lib64/libpcre.so.1.0.0
			fi
		fi
	fi
fi
tar  zxf tengine-2.0.3.tar.gz && cd tengine-2.0.3
./configure --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-pcre=../pcre-8.39 2>/dev/null  >> $hidden
if [ $? -eq 0 ];then
	make 2>/dev/null  >> $hidden &&  make install 2>/dev/null  >> $hidden
	if [ $? -eq 0 ];then
		echo "nginx install ok" >> $install_log
	fi
fi
cd ..
mkdir /usr/local/nginx/conf/vhost/
nginx_l=`cat /usr/local/nginx/conf/nginx.conf | wc -l`
sed -i ''${nginx_l}'i include vhost/*.conf;' /usr/local/nginx/conf/nginx.conf
sed -i 's/#error_log  logs\/error.log;/error_log  \/data\/weblogs\/nginx_error.log;/g' /usr/local/nginx/conf/nginx.conf
log1=`grep -n "log_format"  /usr/local/nginx/conf/nginx.conf | awk -F: '{print $1}'`
log2=`expr $log1 + 2`
for i in `seq $log1 $log2`;do
sed -i ''${i}'s/#//g' /usr/local/nginx/conf/nginx.conf
done
}

mysql_install(){
tar  -zxf cmake-2.8.8.tar.gz &&  cd cmake-2.8.8
./configure 2>/dev/null  >> $hidden &&  gmake 2>/dev/null  >> $hidden && gmake  install 2>/dev/null  >> $hidden
groupadd mysql 2>/dev/null  >> $hidden &&  useradd  -s /sbin/nologin  -g mysql mysql 2>/dev/null  >> $hidden
cd $package
tar  -zxf mysql-5.5.25a.tar.gz && cd mysql-5.5.25a
cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql/ -DMYSQL_DATADIR=/data/mysql -DMYSQL_UNIX_ADDR=/data/mysql/mysqld.sock -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DENABLED_LOCAL_INFILE=1 -DMYSQL_TCP_PORT=3306 -DWITH_EXTRA_CHARSETS:STRING=utf8,gbk -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DMYSQL_UNIX_ADDR=/data/mysql/mysql.sock -DWITH_DEBUG=0 -DWITH_READLINE=1 -DWITH_SSL=yes -DSYSCONFDIR=/data/mysql 2>/dev/null  >> $hidden
make  2>/dev/null  >> $hidden && make install 2>/dev/null  >> $hidden
chmod +w /usr/local/mysql &&  chown -R mysql:mysql /usr/local/mysql
mkdir -p /data/mysql/data/
mkdir -p /data/mysql/binlog/
mkdir -p /data/mysql/relaylog/
chown -R mysql:mysql /data/mysql/
/usr/local/mysql/scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/data/mysql/data  --user=mysql 2>/dev/null  >> $hidden
m_y=`tail -100 $hidden | grep "OK" | wc -l`
if [ "$m_y" -eq 2 ];then
	 echo "mysql install ok" >> $install_log
   cd support-files/ && cp mysql.server /etc/init.d/mysqld && chmod +x /etc/init.d/mysqld
	 cp my-large.cnf /data/mysql/my.cnf
	 mysql1="
	 skip-name-resolve
	 innodb-file-per-table=1\n
	 basedir \= \/usr\/local\/mysql\n
	 datadir \= \/data\/mysql\/data\n
	 log-error \= \/data\/mysql\/mysql_error.log\n
	 pid-file \= \/data\/mysql\/mysql.pid\n
	 relay-log-index \= \/data\/mysql\/relaylog\/relaylog\n
	 relay-log-info-file \= \/data\/mysql\/relaylog\/relaylog\n
	 relay-log \= \/data\/mysql\/relaylog\/relaylog\n
	 log-slow-queries \= \/data\/mysql\/slow.log\n
	 "
	 echo -en $mysql1 | sed 's/^ //g' | while   read  line ;do mysql2=`grep -n "\[mysqldump\]" /data/mysql/my.cnf | awk -F: '{print $1}'` ;sed -i ''$mysql2' i'"$line"''  /data/mysql/my.cnf   ; done
	 mv  /etc/my.cnf /etc/my.cnf.bak
	 chown -R mysql:mysql /data/mysql/
	 /etc/init.d/mysqld  start 2>/dev/null  >> $hidden
	 mysql=`netstat -anptul |  grep  "3306"`
	 if [ -n "$mysql" ];then
	 	 echo "mysql start ok" >> $install_log
	 else
	 	 echo "mysql start no" >> $install_log
	 fi
else
   echo "mysql install no" >> $install_log
fi
/usr/local/mysql/bin/mysqladmin   -uroot  password '3yrfpSnfMuxz9HKW'
if [ $? -eq 0 ];then
	 echo "mysql root用户初始密码为:3yrfpSnfMuxz9HKW" >>  $install_log
	 /usr/local/mysql/bin/mysql -uroot -p3yrfpSnfMuxz9HKW -e "create user 'admin'@'%' identified by 'wdGBwqLWZZZj';"
	 if [ $? -eq 0 ];then
		  /usr/local/mysql/bin/mysql -uroot -p3yrfpSnfMuxz9HKW -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, PROCESS, REFERENCES, INDEX, ALTER, SHOW DATABASES, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, REPLICATION SLAVE, REPLICATION CLIENT, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER ON *.* TO 'admin'@'%'"
			echo "创建admin用户密码为:wdGBwqLWZZZj"  >> $install_log
	 fi
fi
}

mysql7_install(){
cd $package
tar -xzf  cmake-2.8.12.tar.gz && cd cmake-2.8.12
./configure  2>/dev/null  >> $hidden &&  make 2>/dev/null  >> $hidden &&  make install 2>/dev/null  >> $hidden
cd ..
echo "正在下载boot安装包。。。" >> $install_log
wget http://downloads.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.tar.gz 2>/dev/null  >> $hidden
echo "正在下载mysql5.7安装包。。。" >> $install_log
wget https://cdn.mysql.com/archives/mysql-5.7/mysql-5.7.9.tar.gz 2>/dev/null  >> $hidden
sed -i 's/^mysql//g' /etc/group  &&   sed -i 's/^mysql//g' /etc/passwd
groupadd mysql  2>/dev/null  >> $hidden &&  useradd –g mysql mysql 2>/dev/null  >> $hidden
tar -xzf boost_1_59_0.tar.gz
tar -xzf mysql-5.7.9.tar.gz
mkdir -p /data/mysql
cd mysql-5.7.9
cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql  -DMYSQL_DATADIR=/data/mysql  -DDOWNLOAD_BOOST=1 -DWITH_BOOST=../boost_1_59_0 -DSYSCONFDIR=/etc  -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DENABLED_LOCAL_INFILE=1 -DENABLE_DTRACE=0  -DDEFAULT_CHARSET=utf8mb4  -DDEFAULT_COLLATION=utf8mb4_general_ci  -DWITH_EMBEDDED_SERVER=1 2>/dev/null  >> $hidden
make 2>/dev/null  >> $hidden &&  make install 2>/dev/null  >> $hidden
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld 2>/dev/null  >> $hidden
chmod +x /etc/init.d/mysqld 2>/dev/null  >> $hidden
chkconfig --add  mysqld 2>/dev/null  >> $hidden
chkconfig mysqld on 2>/dev/null  >> $hidden
mv  /etc/my.cnf  /etc/my.cnf.bak
echo "
[client]
port = 3306
socket = /tmp/mysql.sock
default-character-set = utf8mb4

[mysqld]
port = 3306
socket = /tmp/mysql.sock

basedir = /usr/local/mysql
datadir = /data/mysql
pid-file = /data/mysql/mysql.pid
user = mysql
bind-address = 0.0.0.0
server-id = 1

init-connect = 'SET NAMES utf8mb4'
character-set-server = utf8mb4

back_log = 300

max_connections = 1000
max_connect_errors = 6000
open_files_limit = 65535
table_open_cache = 128
max_allowed_packet = 4M
binlog_cache_size = 1M
max_heap_table_size = 8M
tmp_table_size = 16M

read_buffer_size = 2M
read_rnd_buffer_size = 8M
sort_buffer_size = 8M
join_buffer_size = 8M
key_buffer_size = 4M

thread_cache_size = 8

query_cache_type = 1
query_cache_size = 8M
query_cache_limit = 2M

ft_min_word_len = 4

log_bin = mysql-bin
binlog_format = mixed
expire_logs_days = 30

log_error = /data/mysql/mysql-error.log
slow_query_log = 1
long_query_time = 1
slow_query_log_file = /data/mysql/mysql-slow.log

performance_schema = 0
explicit_defaults_for_timestamp

skip-external-locking

default_storage_engine = InnoDB
innodb_file_per_table = 1
innodb_open_files = 500
innodb_buffer_pool_size = 64M
innodb_write_io_threads = 4
innodb_read_io_threads = 4
innodb_thread_concurrency = 0
innodb_purge_threads = 1
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 2M
innodb_log_file_size = 32M
innodb_log_files_in_group = 3
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120

bulk_insert_buffer_size = 8M
myisam_sort_buffer_size = 8M
myisam_max_sort_file_size = 10G
myisam_repair_threads = 1

interactive_timeout = 28800
wait_timeout = 28800

[mysqldump]
quick
max_allowed_packet = 16M

[myisamchk]
key_buffer_size = 8M
sort_buffer_size = 8M
read_buffer = 4M
write_buffer = 4M
EOF
" > /etc/my.cnf
/usr/local/mysql/bin/mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/data/mysql 2>/dev/null >> $hidden
if [ $? -eq 0 ];then
	 echo "mysql 初始化成功" >> $install_log
fi
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql
service mysql start 2>/dev/null  >> $hidden
chkconfig mysql on 2>/dev/null  >> $hidden
mysql_start=`netstat   -anptul | grep "3306"`
if [ -n "$mysql_start" ];then
	 echo "mysql start ok" >> $install_log
fi
}

php_install(){
ln -s /usr/local/mysql/lib/libmysqlclient.so.18 /usr/lib64/libmysqlclient.so.18
cd $package
tar -xzf libiconv-1.14.tar.gz && cd libiconv-1.14
./configure --prefix=/usr/local 2>/dev/null  >> $hidden && make 2>/dev/null  >> $hidden && make install 2>/dev/null  >> $hidden && cd ..
ln -sf /usr/local/lib/libiconv.so.2 /usr/lib64/libiconv.so.2
ldconfig
cd $package
tar -zxf libmcrypt-2.5.8.tar.gz && cd libmcrypt-2.5.8
./configure 2>/dev/null  >> $hidden &&  make 2>/dev/null  >> $hidden && make install 2>/dev/null  >> $hidden
ldconfig
cd libltdl/ &&  ./configure -enable-ltdl-install 2>/dev/null  >> $hidden &&  make 2>/dev/null  >> $hidden && make install 2>/dev/null  >> $hidden && cd ../../
ln -sf /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config
if [ $? -eq 0 ];then
	 ln -sf /usr/local/lib/libmcrypt.la /usr/lib64/libmcrypt.la
	 if [ $? -eq 0 ];then
			ln -sf /usr/local/lib/libmcrypt.so /usr/lib64/libmcrypt.so
			if [ $? -eq 0 ];then
				 ln -sf /usr/local/lib/libmcrypt.so.4 /usr/lib64/libmcrypt.so.4
				 if [ $? -eq 0 ];then
						ln -sf /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib64/libmcrypt.so.4.4.8
						ldconfig
				 fi
			fi
	 fi
fi
cd $package
tar -zxf mhash-0.9.9.9.tar.gz  && cd mhash-0.9.9.9
 ./configure 2>/dev/null  >> $hidden &&  make 2>/dev/null  >> $hidden && make install 2>/dev/null  >> $hidden && cd ..
ln -sf /usr/local/lib/libmhash.a /usr/lib64/libmhash.a
if [ $? -eq 0 ];then
	 ln -sf /usr/local/lib/libmhash.la /usr/lib64/libmhash.la
	 if [ $? -eq 0 ];then
			ln -sf /usr/local/lib/libmhash.so /usr/lib64/libmhash.so
			if [ $? -eq 0 ];then
				 ln -sf /usr/local/lib/libmhash.so.2 /usr/lib64/libmhash.so.2
				 if [ $? -eq 0 ];then
						ln -sf /usr/local/lib/libmhash.so.2.0.1 /usr/lib64/libmhash.so.2.0.1
						ldconfig
				 fi
			fi
	 fi
fi
cd $package
tar -zxf mcrypt-2.6.8.tar.gz && cd mcrypt-2.6.8
 ./configure 2>/dev/null  >> $hidden &&  make 2>/dev/null  >> $hidden && make install 2>/dev/null  >> $hidden && cd ..
if [ $? -eq 0 ];then
	 ln -s /usr/lib64/libjpeg.so /usr/lib/libjpeg.so
	 if [ $? -eq 0 ];then
		  ln -s /usr/lib64/libldap.so /usr/lib/libldap.so
		  if [ $? -eq 0 ];then
				 ln -s /usr/lib64/libpng.so /usr/lib/libpng.so
 				 ldconfig
 			fi
 	 fi
fi
cd $package
tar -zxf php-5.4.5.tar.gz &&  cd php-5.4.5
./configure \
--prefix=/usr/local/php \
--with-config-file-path=/usr/local/php/etc \
--with-mysql=/usr/local/mysql \
--with-mysqli=/usr/local/mysql/bin/mysql_config \
--with-iconv=/usr/local \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--with-libxml-dir=/usr \
--enable-xml \
--disable-rpath \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--with-curl \
--with-curlwrappers \
--enable-mbregex \
--enable-fpm \
--enable-mbstring \
--with-mcrypt \
--with-gd \
--enable-gd-native-ttf \
--with-openssl \
--with-mhash \
--enable-pcntl \
--enable-sockets \
--with-ldap \
--with-ldap-sasl \
--with-xmlrpc \
--enable-zip \
--enable-soap \
--without-pear \
--enable-maintainer-zts 2>/dev/null  >> $hidden 
make ZEND_EXTRA_LIBS='-liconv'  2>/dev/null  >> $hidden && make install 2>/dev/null  >> $hidden
mkdir -p /usr/local/php/etc/
cp -f php.ini-production /usr/local/php/etc/php.ini && cd ..
mkdir -p /data/weblogs
echo "
[global]
pid = /usr/local/php/php-fpm.pid
error_log = /data/weblogs/php-fpm-error.log
log_level = notice
emergency_restart_threshold = 10
emergency_restart_interval = 1m
process_control_timeout = 5s
daemonize = yes
[www]
listen = 127.0.0.1:9000
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
user = www
group = www
listen.mode=0666
pm = dynamic
pm.max_children = 64
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 15
pm.max_requests = 1024
request_terminate_timeout = 0s
request_slowlog_timeout = 0s
slowlog = /data/weblogs/php-fpm-slow.log
rlimit_files = 65535
rlimit_core = 0
chroot =
chdir =
catch_workers_output = yes
env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
php_flag[display_errors] = off
" > /usr/local/php/etc/php-fpm.conf
/usr/local/php/sbin/php-fpm -t 2>/dev/null  >> $hidden 
php_start=`cat $hidden|tail -5 | grep -i "successfully"`
if [ -n "$php_start" ];then
	 echo "php install ok" >> $install_log
fi
}
source /etc/profile
elk_install(){
cd $package
echo "elasticsearch安装包下载中。。。" >> $install_log
sudo wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.2.tar.gz 2>/dev/null  >> $hidden
sudo wget https://github.com/elasticsearch/elasticsearch-servicewrapper/archive/master.tar.gz 2>/dev/null  >> $hidden
tar -zxf elasticsearch-1.4.2.tar.gz -C $package
ln -s $package/elasticsearch-1.4.2 $package/elasticsearch
tar -zxf master.tar.gz -C $package
mv $package/elasticsearch-servicewrapper-master/service $package/elasticsearch/bin/
source /etc/profile
$package/elasticsearch/bin/service/elasticsearch start 2>/dev/null  >> $hidden
es_start=`cat $hidden | grep -Pi "(Starting Elasticsearch|Waiting for Elasticsearch|running: PID:)"|wc -l`
if [ "$es_start" -eq 3 ];then echo "es start ok" >> $install_log;fi
cd $package
echo "logstash安装包下载中。。。" >> $install_log
sudo wget https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz 2>/dev/null >> $hidden
tar -zxf logstash-1.4.2.tar.gz -C $package
ln -s $package/logstash-1.4.2 $package/logstash
mkdir -p $package/logstash/conf
echo "
input {  
  stdin {  
    type => \"human\" 
  }  
}  

output {  
  stdout {  
    codec => rubydebug  
  }  

  elasticsearch {  
    host => \"${localhost_ip}\"
    port => 9300  
  }  
}
" > $package/logstash/conf/test.conf
#$package/logstash/bin/logstash -f $package/logstash/conf/test.conf &
if [ $? -eq 0 ];then echo "logstash start ok ">> $install_log;fi
cd $package 
echo "kibana安装包下载中。。。" >> $install_log
sudo wget https://download.elasticsearch.org/kibana/kibana/kibana-3.1.2.tar.gz 2>/dev/null >> $hidden
tar -zxf kibana-3.1.2.tar.gz -C $package
mv kibana-3.1.2 /data/www/kibana
yum  -y install httpd-tools 2>/dev/null >> $hidden
echo "
server {
        listen       81;
        server_name  localhost;

        #charset koi8-r;

        access_log  /data/weblogs/elk_access.log  main;
			 	auth_basic "hello";
        auth_basic_user_file /data/nginx_passwd;
        location / {
            root   /data/www/kibana/;
            index  index.html index.htm;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }
" > /usr/local/nginx/conf/vhost/elk.conf
htpasswd -bc  /data/nginx_passwd elk 123456
sed -i '/elasticsearch:/ s/\"+window.location.hostname+\"/'${localhost_ip}'/' /data/www/kibana/config.js   
#elasticsearch: "http://"+window.location.hostname+":9200",
echo "http.cors.enabled: true" >> $package/elasticsearch/config/elasticsearch.yml
/usr/local/nginx/sbin/nginx -t  2>/dev/null  >> $hidden
nginx_t=`cat $hidden |  tail -2 |  grep "successful"`
if [ -n "$nginx_t" ];then
	 n1=`netstat -anptul |  grep "80"`
	 if [ -n "$n1" ];then
	 		/usr/local/nginx/sbin/nginx -s  reload
	 		n1_n1=`netstat -anptul |  grep "80"`
	 		if [ -n "$n1_n1" ];then
	 			 echo "nginx restart ok" >> $install_log
	 		else
	 		   echo "nginx restart no" >> $install_log
	 		fi
	 else
	    /usr/local/nginx/sbin/nginx
	 		n2_n2=`netstat -anptul |  grep "80"`
	 		if [ -n "$n2_n2" ];then
	 			 echo "nginx restart ok" >> $install_log
	 		else
	 		   echo "nginx restart no" >> $install_log
	 		fi
	 fi
else
   /usr/local/nginx/sbin/nginx
   if [ $? -eq 0 ];then
   		echo "nginx restart ok" >> $install_log
	 else
	 		   echo "nginx restart no" >> $install_log
	 fi
fi
$package/elasticsearch/bin/service/elasticsearch restart 2>/dev/null  >> $hidden
if [ $? -eq 0 ];then echo "elasticsearch启动成功，初始用户:elk,密码:123456 ">> $install_log;fi
echo "
input {
    file{
        type => \"nginx\"
        path => \"/data/weblogs/nginx_error.log\"
    }
}
output {
  stdout {
    codec => rubydebug
  }

  elasticsearch {
    host => \"${localhost_ip}\"
    port => 9300
  }
}
" > $package/logstash/conf/nginx.conf
nohup  $package/logstash/bin/logstash -f $package/logstash/conf/nginx.conf &
#jobs -l
}
# &> /dev/null
# nohup java -jar cat-game.jar >game.log &
#show global variables   like 'port';
#change master to master_host='192.168.140.128',master_user='test',master_port=3306,master_password='123456',master_log_file='mysql-bin.000009',master_log_pos=3000;
#sed 's/\xc2\xa0/ /g' -i
#./configure --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-pcre=../pcre-8.39 --with-stream 
#db.grantRolesToUser('rwuser',[{role:"dbOwner",db:"my_mongodb"}]); 授予rwuser用户dbOwner权限
yum_env
java_chack
rabbitmq_install
redis_install
tomcat_install
mongo_install
nginx_install
mysql_install
mysql7_install
#php_install
elk_install