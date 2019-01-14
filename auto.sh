#!/bin/bash
#生成蛮荒nginx代理点配置文件
for groupid in $(seq -f "%02g" 17  19)
do
cat ../allgameserver_Proxy |grep "_${groupid}_" > .auto.tmp
speedy_proxy(){
#迅达云走外网
cat .auto.tmp | grep "UCLOUD香港"|awk '{print $2}' > host_ip.txt
for i in $(cat .auto.tmp|grep "Proxy"|egrep "speedy"|awk '{print $2}')
do
  echo "+++++++++++$i+++++++++++"
  server_zone=$(grep "$i" .auto.tmp|awk '{print $5"-"$6}'|grep -Po "[A-Z]{1,5}-[a-z]{1,20}")
  flag=1
  while [[ $flag != 0 ]];do
  ssh $i "echo -e \"nameserver 8.8.8.8\nnameserver 114.114.114.114\" > /etc/resolv.conf && service iptables stop && chkconfig iptables off && rm -rf  /usr/local/src/* /etc/yum.repos.d/* && yum clean all && if [ ! -d /data/shell/ ];then mkdir -p /data/shell/;fi" && \
  scp -q yum/* $i:/etc/yum.repos.d/ && \
  scp -q /data/shell/nginx_log_cut_2.sh $i:/data/shell/ && \
  scp -q ../allgameserver_Proxy ../shell/ng_tcp_module.sh host_ip.txt ../shell/add_nginx_proxy.sh $i:/usr/local/src/ && \
  echo "server zone: ${server_zone}" && \
  echo "group id: $groupid" && \
  ssh $i "
cd /usr/local/src/
sh ng_tcp_module.sh $groupid ${server_zone}
\\cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
npid=\$(ps -ef |grep -c \"ngin[x]\")
if [ \$npid -gt 1 ];then
/usr/local/nginx/sbin/nginx -s reload
else
/usr/local/nginx/sbin/nginx
fi
zpid=\$(ps -ef |grep -c \"zabbi[x]\")
if [ \$zpid -gt 2 ];then
killall zabbix_agentd && /usr/local/zabbix-2.4.2/sbin/zabbix_agentd
else
/usr/local/zabbix-2.4.2/sbin/zabbix_agentd
fi
" && \
  flag=0
  done
done
}
softlayer_proxy(){
cat ../allgameserver_Proxy |grep "_${groupid}_" > .auto.tmp
#softlayer走内网
cat .auto.tmp |grep  "softlayer香港" |awk '{print $1}' > host_ip.txt
for i in $(cat .auto.tmp|grep "Proxy"|egrep "softlayer"|egrep -v "softlayer香港"|awk '{print $2}')
do
  echo "+++++++++++$i++++++++++++"
  server_zone=$(grep "$i" .auto.tmp|awk '{print $5"-"$6}'|grep -Po "[A-Z]{1,5}-[a-z]{1,20}")
  flag=1
#  while [[ $flag != 0 ]];do
  ssh $i "echo -e \"nameserver 8.8.8.8\nnameserver 114.114.114.114\" > /etc/resolv.conf && service iptables stop && chkconfig iptables off && rm -rf  /usr/local/src/*  /etc/yum.repos.d/* && yum clean all && if [ ! -d /data/shell/ ];then mkdir -p /data/shell/;fi" && \
  scp -q yum/* $i:/etc/yum.repos.d/ && \
  scp -q /data/shell/nginx_log_cut_2.sh $i:/data/shell/ && \
  scp -q ../allgameserver_Proxy ../shell/ng_tcp_module.sh host_ip.txt ../shell/add_nginx_proxy.sh $i:/usr/local/src/ && \
  echo "server zone: ${server_zone}" && \
  echo "group id: $groupid" && \
  ssh $i "
cd /usr/local/src/
sh ng_tcp_module.sh $groupid ${server_zone}
\\cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
npid=\$(ps -ef |grep -c \"ngin[x]\")
if [ \$npid -gt 1 ];then
/usr/local/nginx/sbin/nginx -s reload
else
/usr/local/nginx/sbin/nginx
fi
" && \
  flag=0
#  done
done
}
#speedy_proxy
softlayer_proxy
done
