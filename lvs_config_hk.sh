#!/bin/bash
if [ ! -f add-realserver-zc.sh ] || [ ! -f allgameserver_MHDL ] ||[ ! -f allgameserver_Proxy ];then
	echo "Check whether there is add-realserver.sh allgameserver_MHDL allgameserver_Proxy"
	exit
fi
my_ip=$(ifconfig |grep -A1 eth0 |grep -Po '(?<=addr:).*(?=  Bcas)')
gid=$(cat allgameserver_Proxy|grep $my_ip|awk '{print $3}'|grep -Po "[0-9]{1,2}")
type=$(cat allgameserver_Proxy|grep $my_ip|awk '{print $3}'|awk -F_ '{print $NF}')
yum install -y keepalived ipvsadm 
echo -e "开始配置$gid组LVS HK-$type"
iptables -t mangle -F
iptables -t mangle -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -A FORWARD -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j TCPMSS --set-mss 1300
iptables -t mangle -A FORWARD -p tcp -m tcp --tcp-flags FIN,RST,SYN,ACK SYN,ACK -j TCPMSS --set-mss 1300
service iptables save
chkconfig keepalived on
chkconfig iptables on
sed -i '7s/net.ipv4.ip_forward\ =\ 0/net.ipv4.ip_forward\ =\ 1/' /etc/sysctl.conf
sysctl -p

hk_a_ip=$(cat allgameserver_Proxy|grep "HK_${gid}_$type"|awk '{print $1}')
hk_b_ip=$(cat allgameserver_Proxy|grep "HK_${gid}_$type"|awk '{print $1}')
gz_a_ip=$(cat allgameserver_Proxy|grep "GZ_${gid}_$type"|awk '{print $1}')
gz_b_ip=$(cat allgameserver_Proxy|grep "GZ_${gid}_$type"|awk '{print $1}')

if [ ! -f /etc/sysconfig/network-scripts/ifcfg-gre1 ];then
touch /etc/sysconfig/network-scripts/ifcfg-gre1
cat  > /etc/sysconfig/network-scripts/ifcfg-gre1 <<EOF
DEVICE=gre1
BOOTPROTO=none
ONBOOT=yes
TYPE=GRE
TTL=255
PEER_OUTER_IPADDR=$(eval echo  $`echo gz_${type}_ip`)
PEER_INNER_IPADDR=100.64.1.2
MY_INNER_IPADDR=100.64.1.1
MY_OUTER_IPADDR=$(eval echo  $`echo hk_${type}_ip`)
MTU=1440
EOF
else
cat  > /etc/sysconfig/network-scripts/ifcfg-gre1 <<EOF
DEVICE=gre1
BOOTPROTO=none
ONBOOT=yes
TYPE=GRE
TTL=255
PEER_OUTER_IPADDR=$(eval echo  $`echo gz_${type}_ip`)
PEER_INNER_IPADDR=100.64.1.2
MY_INNER_IPADDR=100.64.1.1
MY_OUTER_IPADDR=$(eval echo  $`echo hk_${type}_ip`)
MTU=1440
EOF
fi
cat allgameserver_MHDL |grep "_$gid"|grep 正式|awk '{print $1}' > route-inside.txt
cat allgameserver_MHDL |grep "_$gid"|grep 正式|awk '{print $2}' > route-outside.txt
seq 8080 8119 > port-tcp.txt
cat allgameserver_MHDL |grep "_$gid"|grep 正式|awk '{print $1"\n"$2}'|sed "s/$/\/32 via 100.64.1.2/g" > /etc/sysconfig/network-scripts/route-gre1
sh   add-realserver-zc.sh
echo -e "配置完成"
