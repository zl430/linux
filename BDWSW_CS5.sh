#!/bin/bash
#BDWSW Combined Service
#Version 5
#Create By ChenHao
#Date 2015-12-27
#Modify By ChenHao 
#修改了数据库的导出导入方式，不再导入到SQL文件，而是在导出的时候直接进行导入操作
#2016-7-5
#添加了数据库备份，和已经合服的服再次合服的处理

cdate=$(echo $(date +"%F %T")|awk '{print $1}'|sed "s/-//g")
Home_Dir="/data/BDWSW_hefu"
Log_Dir="/data/weblogs"
Log_File="/data/weblogs/BDWSW_CS_$cdate.log"
Notice_Log="/data/weblogs/BDWSW_error_$cdate.log"
Config_Bak_Dir="/data/backup"
Mysqldump="/usr/bin/mysqldump -u admin -pFJRUDKEISLWO -h"
Mysql="/usr/bin/mysql -u admin -pFJRUDKEISLWO -h"
Nginx_dir="/usr/local/nginx/conf/vhost"
Uc_db_ip="10.6.24.22"
Cs_db_ip="10.10.26.175"
Game_type="bdwsw"
Tab_Head="zc_${Game_type}_s"
Station_suffix="game.bdwsw.zhanchenggame.com"
Game_list="/root/leesh_new/allgameserver_BDWSW"
csgroup="cs4"
#csgroup='1' 第一组要合服的站点，如果是第二组修改为csgroup='2',test为测试环境测试，debug为线上合服测试

#获取合服信息
Data_list=$($Mysql $Cs_db_ip -e "SELECT server_id FROM zc_${Game_type}_uc.zc_${Game_type}_cs WHERE csgroup='$csgroup';"|grep -v "server_id"|sort -n)
Export_list=$($Mysql $Cs_db_ip -e "SELECT exportid FROM zc_${Game_type}_uc.zc_${Game_type}_cs WHERE csgroup='$csgroup';"|grep -v "exportid"|sort -u)
Import_list=$($Mysql $Cs_db_ip -e "SELECT import FROM zc_${Game_type}_uc.zc_${Game_type}_cs WHERE csgroup='$csgroup';"|grep -v "import"|sort -u)


Init_start(){
#Check Directory 
#检查需要的目录是否存在，如不存在则创建
if [ ! -f /usr/bin/mysql ];then yum  -y install mysql ;fi
if [ ! -d  $Home_Dir/ ];then echo "$Home_Dir Not Found .exit..." && exit 0;fi
cd $Home_Dir/

if [ ! -f /etc/hosts.bak ];then
  cat /etc/hosts > /etc/hosts.bak
else
   md5m=$(md5sum /etc/hosts|awk '{print $1}')
   md5s=$(md5sum /etc/hosts.bak|awk '{print $1}')
   if [ $md5m != $md5s ];then
     cat /etc/hosts > /etc/hosts.bak
   fi
fi

cat /root/leesh_new/BDWSW_host >> /etc/hosts
if [ $? != 0 ];then exit 1;fi

if [ -d $Log_Dir/ ] && [ -d $Config_Bak_Dir/config/ ];then
	echo "[$(date +"%F %T")] $Log_Dir/ 和 $Config_Bak_Dir/config/ 目录存在" >> $Log_File
else
	echo "[$(date +"%F %T")] $Log_Dir/ 或 $Config_Bak_Dir/config/ 目录不存在" >> $Log_File
	mkdir -p $Log_Dir/ $Config_Bak_Dir/config/ &&  echo "[$(date +"%F %T")] mkdir -p $Log_Dir/ $Config_Bak_Dir/config/" >> $Log_File
fi
}

Init_stop(){
echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts
echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
echo "127.0.0.1 10-10-63-12" >> /etc/hosts
echo "10.10.63.12 10-10-63-12" >> /etc/hosts
echo "[$(date +"%F %T")] $Game_type CS off"  >> $Log_File
}

Exp_Imp_Db(){
#Export and Import Game Server Database
#导出库中指定表，而非整个库
#后台执行导出操作，导出同时直接导入.
exp_tab=$(cat /data/shell/merge_table_data.txt)
cd $Home_Dir/
$Mysqldump $Uc_db_ip zc_${Game_type}_uc zc_${Game_type}_uc_server > zc_${Game_type}_uc_server.sql
for i in $Data_list 
do
	exp_data=$($Mysql $Cs_db_ip -e "SELECT export FROM zc_${Game_type}_uc.zc_${Game_type}_cs WHERE server_id='$i' AND csgroup='$csgroup';"|grep -v "[a-z]")
	exp_host=$($Mysql $Cs_db_ip -e "SELECT export_db_ip FROM zc_${Game_type}_uc.zc_${Game_type}_cs WHERE server_id='$i' AND csgroup='$csgroup';"|grep -v "[a-z]")
	exp_id=$($Mysql $Cs_db_ip -e "SELECT exportid FROM zc_${Game_type}_uc.zc_${Game_type}_cs WHERE server_id='$i' AND csgroup='$csgroup';"|grep -v "[a-z]")
	imp_host=$($Mysql $Cs_db_ip -e "SELECT import_db_ip FROM zc_${Game_type}_uc.zc_${Game_type}_cs WHERE server_id='$i' AND csgroup='$csgroup';"|grep -v "[a-z]")
	imp_data=$($Mysql $Cs_db_ip -e "SELECT import FROM zc_${Game_type}_uc.zc_${Game_type}_cs WHERE server_id='$i' AND csgroup='$csgroup';"|grep -v "[a-z]")
	redis_ip=$($Mysql $Cs_db_ip -e "SELECT master_redis_ip FROM zc_${Game_type}_uc.zc_${Game_type}_cs WHERE server_id='$i' AND csgroup='$csgroup';"|grep -v "[a-z]")
	if [ "$exp_data" = "N" ];then
		echo "[$(date +"%F %T")] $Tab_Head$exp_id is N,Skip $Tab_Head$exp_id" >> $Log_File
		$Mysql $Uc_db_ip -e "UPDATE zc_${Game_type}_uc.zc_${Game_type}_uc_server SET newserver='$imp_data' WHERE id='$i';" && echo "[$(date +"%F %T")] UPDATE s$i newserver is $imp_data" >> $Log_File
    $Mysql $Uc_db_ip -e "UPDATE zc_${Game_type}_uc.zc_${Game_type}_uc_server SET import='$imp_host' WHERE id='$i';" && echo "[$(date +"%F %T")] UPDATE s$i import is $imp_host" >> $Log_File
    $Mysql $Uc_db_ip -e "UPDATE zc_${Game_type}_uc.zc_${Game_type}_uc_server SET redis_ip='$redis_ip' WHERE id='$i';" && echo "[$(date +"%F %T")] UPDATE s$i redis_ip is $redis_ip" >> $Log_File
	elif [ "$exp_data" = "B" ];then
		echo "[$(date +"%F %T")] $Tab_Head$exp_id is B,Backup $Tab_Head$exp_id"  >> $Log_File
    $Mysql $Uc_db_ip -e "UPDATE zc_${Game_type}_uc.zc_${Game_type}_uc_server SET newserver='0' WHERE id='$i';" && echo "[$(date +"%F %T")] UPDATE s$i newserver is 0" >> $Log_File
	elif [ "$exp_data" = "Y" ];then
		#清空token_online表(踢人)
		#$Mysql $exp_host -e "truncate $Tab_Head$exp_id.zc_${Game_type}_token_online;" &&  echo "[$(date +"%F %T")] truncate $Tab_Head$exp_id.zc_${Game_type}_token_online Success" >> $Log_File
		#修改uc库中的newserver,import,redis_ip
		$Mysql $Uc_db_ip -e "UPDATE zc_${Game_type}_uc.zc_${Game_type}_uc_server SET newserver='$imp_data' WHERE id='$i';" && echo "[$(date +"%F %T")] UPDATE s$i newserver is $imp_data" >> $Log_File
		$Mysql $Uc_db_ip -e "UPDATE zc_${Game_type}_uc.zc_${Game_type}_uc_server SET import='$imp_host' WHERE id='$i';" && echo "[$(date +"%F %T")] UPDATE s$i import is $imp_host" >> $Log_File
		$Mysql $Uc_db_ip -e "UPDATE zc_${Game_type}_uc.zc_${Game_type}_uc_server SET redis_ip='$redis_ip' WHERE id='$i';" && echo "[$(date +"%F %T")] UPDATE s$i redis_ip is $redis_ip" >> $Log_File
		echo "[$(date +"%F %T")] $exp_host: $Tab_Head$exp_id --> $imp_host: $Tab_Head$imp_data" >> $Log_File
		echo "[$(date +"%F %T")] $Tab_Head$exp_id is Y,Start Export Import " >> $Log_File
		echo "[$(date +"%F %T")] Start Export $Tab_Head$exp_id & Import $Tab_Head$imp_data " >> $Log_File 
		starttime=$(date +"%s") && \
		for tab in $exp_tab
		do
			$Mysqldump $exp_host --skip-add-drop-table -t $Tab_Head$exp_id $tab 2>> $Notice_Log | $Mysql $imp_host $Tab_Head$imp_data 2>> $Notice_Log 
			if [ $? = 0 ];then
				echo "[$(date +"%F %T")] $Tab_Head$exp_id.$tab Import Done..." >> $Log_File
			else
				echo "[$(date +"%F %T")] $Tab_Head$exp_id.$tab Import Fail..." >> $Log_File
				echo "[$(date +"%F %T")] $Tab_Head$exp_id.$tab" >> $Notice_Log
				continue
			fi
		done && \
		stoptime=$(date +"%s") && \
		timecost=$(echo "scale=1;($stoptime-$starttime)/60"|bc|awk '{printf "%.1f",$0}') && \
		echo "[$(date +"%F %T")] CS info: Start Time:$(date  +"%F %T" -d @$starttime) Stop Time:$(date  +"%F %T" -d @$stoptime) Time Cost:${timecost}M  $Tab_Head$exp_id " >> $Log_File
	fi
done
#修复UC表
#$Mysql $Uc_db_ip -e "UPDATE zc_${Game_type}_uc.zc_${Game_type}_uc_server SET newserver='0' WHERE \`id\`=\`newserver\`;" && echo "[$(date +"%F %T")] UPDATE UC Table id=newserver is 0" >> $Log_File
}

Mod_Db_Redis(){
#Modify Database ConfigFile and Modify Redis Config
#修改站点数据库配置和Redis配置
#备份要修改的站点配置文件
for i in $Data_list
do
	ssh 10.10.21.218 "
	cd /data/www/
	tar zcf $Config_Bak_Dir/config/ss$i.$Station_suffix.tgz ss$i.$Station_suffix/application/config/database.php  ss$i.$Station_suffix/application/config/config.php
	" && echo "[$(date +"%F %T")] Backup ss$i.$Station_suffix of config.php database.php" >> $Log_File
done
#Master:合服的站点 Slave:被合服的站点
#将Master站点配置文件复制到Slave站点
for i in $Data_list 
do
	import=$($Mysql $Cs_db_ip -e "SELECT import FROM zc_${Game_type}_uc.zc_${Game_type}_cs WHERE server_id='$i' AND csgroup='$csgroup';"|grep -v "[a-z]")
	import_db_ip=$($Mysql $Cs_db_ip -e "SELECT import_db_ip FROM zc_${Game_type}_uc.zc_${Game_type}_cs WHERE server_id='$i' AND csgroup='$csgroup';"|grep -v "[a-z]")
	master_redis_ip=$($Mysql $Cs_db_ip -e "SELECT master_redis_ip FROM zc_${Game_type}_uc.zc_${Game_type}_cs WHERE server_id='$i' AND csgroup='$csgroup';"|grep -v "[a-z]")
	#master_socket_server=$(ssh s$import.$Station_suffix "grep socket_server_url /data/www/s$import.$Station_suffix/application/config/config.php|grep -Po '(?<=http://).*(?=;)'|sed \"s/'//g\"")
	ssh 10.10.21.218 "
	sed -i \"/redis_host/ s/=.*/= '$master_redis_ip';/\" /data/www/ss$i.$Station_suffix/application/config/config.php
	sed -i \"/server_merge_id/ s/=.*/= $import;/\" /data/www/ss$i.$Station_suffix/application/config/config.php 
	sed -i \"/database/ s/=>.*/=> '$Tab_Head$import',/\" /data/www/ss$i.$Station_suffix/application/config/database.php  
	sed -i \"/hostname/ s/=>.*/=> '$import_db_ip',/\" /data/www/ss$i.$Station_suffix/application/config/database.php
	" && \
  echo "[$(date +"%F %T")] 修改ss$i.$Station_suffix的redis_host为$master_redis_ip" >> $Log_File && \
  echo "[$(date +"%F %T")] 修改ss$i.$Station_suffix的server_merge_id为$import"  >> $Log_File && \
  echo "[$(date +"%F %T")] 修改ss$i.$Station_suffix的database为$Tab_Head$import" >> $Log_File && \
  echo "[$(date +"%F %T")] 修改ss$i.$Station_suffix的hostname为$import_db_ip" >> $Log_File 
done
}

Mod_Cron(){
#修改计划任务
#1.备份原有计划任务
#2.将Slave站点计划任务删除
for i in $(cat $Game_list |grep NFSa|egrep "GF|HK"|awk '{print $1}');do ssh $i "crontab -l > cron_$cdate";done
wait
for i in $($Mysql $Cs_db_ip -e "SELECT server_id FROM zc_${Game_type}_uc.zc_${Game_type}_cs WHERE crontab='Y' AND csgroup='$csgroup';"|grep -v "[a-z]")
do
	ssh s$i.$Station_suffix "
	/usr/bin/crontab -l | sed "/$i/d"  > /root/cron_$cdate.1
	/usr/bin/crontab /root/cron_$cdate.1
	" && echo "[$(date +"%F %T")] s$i Crontab Delete Done..." >> $Log_File
done
}

CS_backup_DB(){
Back_dir=/data/backup_cs/
a=1
for i in $(echo -e "$Export_list\n$Import_list" | sort -u)
do 
	exp_host=$($Mysql $Cs_db_ip -e "SELECT distinct(export_db_ip)  FROM zc_${Game_type}_uc.zc_${Game_type}_cs WHERE exportid='$i' AND csgroup='$csgroup';"|grep -v "[a-z]")
	a=`expr $a + 1`
	if [ $a -gt 6 ];then a=1;fi
	ip=$(cat /root/leesh_new/allgameserver_BDWSW |grep cross|awk '{print $1}'|sed -n "${a}p")
	ssh $ip "
	if [ ! -d $Back_dir ];then
	   mkdir -p $Back_dir
    fi
    echo \"[\$(date +\"%F %T\")] $ip $Tab_Head$i Start Backup\"
    $Mysqldump $exp_host $Tab_Head$i > $Back_dir$Tab_Head$i.sql && echo \"[\$(date +\"%F %T\")] $ip $Tab_Head$i Backup Done\"
  " >> $Log_File  &
done
while true
do
	mnum=$(ps -ef |grep -c mysqldum[p])
	if [ $mnum -eq 0 ];then echo "[$(date +"%F %T")] Backup ALL Done" >> $Log_File;break;fi
sleep 1
done
}
Mod_backup_DB(){
Back_dir=/data/backup_mod/
a=1
for i in $Export_list
do 
	exp_host=$($Mysql $Cs_db_ip -e "SELECT export_db_ip FROM zc_${Game_type}_uc.zc_${Game_type}_cs WHERE server_id='$i' AND csgroup='$csgroup';"|grep -v "[a-z]")
	exp_id=$($Mysql $Cs_db_ip -e "SELECT exportid FROM zc_${Game_type}_uc.zc_${Game_type}_cs WHERE server_id='$i' AND csgroup='$csgroup';"|grep -v "[a-z]")
	a=`expr $a + 1`
	if [ $a -gt 6 ];then a=1;fi
	ip=$(cat /root/leesh_new/allgameserver_BDWSW |grep cross|awk '{print $1}'|sed -n "${a}p")
	ssh $ip "
	if [ ! -d $Back_dir ];then
	   mkdir -p $Back_dir
    fi
    echo \"[\$(date +\"%F %T\")] $ip $Tab_Head$exp_id Start Backup\"
    $Mysqldump $exp_host $Tab_Head$exp_id > $Back_dir$Tab_Head$i.sql && echo \"[\$(date +\"%F %T\")] $ip $Tab_Head$exp_id Backup Done\"
    " >> $Log_File  &
done
while true
do
	mnum=$(ps -ef |grep -c mysqldum[p])
	if [ $mnum -eq 0 ];then echo "[$(date +"%F %T")] Backup ALL Done" >> $Log_File;break;fi
sleep 1
done
}
Mod_Servcer_DB(){
cd $Home_Dir/
for i in $Export_list
do
	exp_host=$($Mysql $Cs_db_ip -e "SELECT export_db_ip FROM zc_${Game_type}_uc.zc_${Game_type}_cs WHERE server_id='$i' AND csgroup='$csgroup';"|grep -v "[a-z]")
	exp_id=$($Mysql $Cs_db_ip -e "SELECT exportid FROM zc_${Game_type}_uc.zc_${Game_type}_cs WHERE server_id='$i' AND csgroup='$csgroup';"|grep -v "[a-z]")
	echo "[$(date +"%F %T")] $Tab_Head$exp_id SQL File Generate Start" >> $Log_File && \
	curl -s "http://10.10.59.253/server.merge.com/index.php?c=merge&m=get_query&serverid=${exp_id}" 2>&1 > /dev/null&& \
	echo "[$(date +"%F %T")] $Tab_Head$exp_id SQL File Generate successful" >> $Log_File
	scp -q 10.10.59.253:/data/www/server.merge.com/hefu_before_${exp_id}.sql $Home_Dir/
	starttime=$(date +"%s") && \
	echo "[$(date +"%F %T")] $Tab_Head$exp_id Start Modify" >> $Log_File && \
	$Mysql $exp_host $Tab_Head$exp_id  -e "source $Home_Dir/hefu_before_${exp_id}.sql;" 2>&1|sed "s/^/[$(date +"%F %T")] /g" >> $Notice_Log && \
	echo "[$(date +"%F %T")] $Tab_Head$exp_id Done Modify" >> $Log_File && \
	stoptime=$(date +"%s") && timecost=$(echo "scale=1;($stoptime-$starttime)/60"|bc|awk '{printf "%.1f",$0}') \
	&& echo "[$(date +"%F %T")] Mod info: Start Time:$(date  +"%F %T" -d @$starttime) Stop Time:$(date  +"%F %T" -d @$stoptime) Time Cost:${timecost}M  $Tab_Head$exp_id" >> $Log_File &
done
while true
do
	mnum=$(ps -ef |grep mysq[l]|grep -c befor[e])
	if [ $mnum -eq 0 ];then echo "[$(date +"%F %T")] ALL Done Modify" >> $Log_File;break;fi
sleep 1
done
}
CS_Servcer_DB(){
cd $Home_Dir/
for i in $(echo -e "$Export_list\n$Import_list" | sort -u)
do
  exp_host=$($Mysql $Cs_db_ip -e "SELECT export_db_ip FROM zc_${Game_type}_uc.zc_${Game_type}_cs WHERE server_id='$i' AND csgroup='$csgroup';"|grep -v "[a-z]")
  exp_id=$($Mysql $Cs_db_ip -e "SELECT exportid FROM zc_${Game_type}_uc.zc_${Game_type}_cs WHERE server_id='$i' AND csgroup='$csgroup';"|grep -v "[a-z]")
  echo "[$(date +"%F %T")] $Tab_Head$exp_id SQL File Generate Start" >> $Log_File && \
  curl -s "http://10.10.59.253/server.merge.com/index.php?c=merge&m=get_query&type=1&serverid=${exp_id}" 2>&1 > /dev/null&& \
  echo "[$(date +"%F %T")] $Tab_Head$exp_id SQL File Generate successful" >> $Log_File
  scp -q 10.10.59.253:/data/www/server.merge.com/hefu_before_${exp_id}_2.sql $Home_Dir/
  starttime=$(date +"%s") && \
  echo "[$(date +"%F %T")] $Tab_Head$exp_id Start Modify" >> $Log_File && \
  $Mysql $exp_host $Tab_Head$exp_id  -e "source $Home_Dir/hefu_before_${exp_id}_2.sql;" 2>&1|sed "s/^/[$(date +"%F %T")] /g" >> $Notice_Log && \
  echo "[$(date +"%F %T")] $Tab_Head$exp_id Done Modify" >> $Log_File && \
  stoptime=$(date +"%s") && timecost=$(echo "scale=1;($stoptime-$starttime)/60"|bc|awk '{printf "%.1f",$0}') \
  && echo "[$(date +"%F %T")] Mod info: Start Time:$(date  +"%F %T" -d @$starttime) Stop Time:$(date  +"%F %T" -d @$stoptime) Time Cost:${timecost}M  $Tab_Head$exp_id" >> $Log_File &
done
while true
do
  mnum=$(ps -ef |grep mysq[l]|grep -c befor[e])
  if [ $mnum -eq 0 ];then echo "[$(date +"%F %T")] ALL Done Modify" >> $Log_File;break;fi
sleep 1
done
}
Mod_Server_Conf(){
for i in $Data_list
do
	ssh 10.10.21.218  "
	if [ ! -d /data/backup/ ];then
	   mkdir -p /data/backup/
	fi
	mergec=\$(grep -w 'server_merge' /data/www/ss$i.$Station_suffix/application/config/config.php  |awk '{print \$NF}'|sed 's/;//g')
	mergen=\$(grep -w 'server_prefix' /data/www/ss$i.$Station_suffix/application/config/config.php  |awk '{print \$NF}'|sed 's/;//g')
	if [ \"\$mergec\" = \"false\" ]||[ \"\$mergec\" = \"FALSE\" ];then
		\cp -f /data/www/ss$i.$Station_suffix/application/config/config.php /data/backup/${i}_config.php
		sed -i \"/server_merge/ s/false/TRUE/\" /data/www/ss$i.$Station_suffix/application/config/config.php
		sed -i \"/server_merge_id/ s/=.*/= $i;/\" /data/www/ss$i.$Station_suffix/application/config/config.php
		echo \"[\$(date +\"%F %T\")] 修改ss$i.$Station_suffix的server_merge为TRUE\"
		echo \"[\$(date +\"%F %T\")] 修改ss$i.$Station_suffix的server_merge_id为$i\"
  fi
	if [ \"\$mergen\" != \"100000000000\" ];then
		sed -i \"/server_prefix/ s/=.*/= 100000000000;/\" /data/www/ss$i.$Station_suffix/application/config/config.php
		echo \"[\$(date +\"%F %T\")] 修改ss$i.$Station_suffix的server_prefix为100000000000\"
  fi
	if [ \"\$mergec\" = \"\" ]||[ \"\$mergen\" = \"\" ];then
		echo \"[\$(date +\"%F %T\")] ERROR merge Not found\"
	fi
	" >> $Log_File
done
}
Init_start

#维护
#1.备份要维护的数据库
#Mod_backup_DB
#2.执行SQL修改表数据
#Mod_Servcer_DB
#3.修改单服配置文件
#Mod_Server_Conf

#合服
#1.备份要合并的数据库
#CS_backup_DB
#2.合服前维护
#CS_Servcer_DB
#3.合并数据库
#Exp_Imp_Db
#4.修改单服配置文件
#Mod_Db_Redis
#5.修改计划任务
Mod_Cron

Init_stop
