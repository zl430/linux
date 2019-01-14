#!/bin/bash
if [ ! -f allgameserver_MHDL ] ||[ ! -f allgameserver_Proxy ];then
	echo "Check whether there is  allgameserver_MHDL allgameserver_Proxy"
	exit
fi
my_ip=$(ifconfig |grep -A1 eth0 |grep -Po '(?<=addr:).*(?=  Bcas)')
gid=$(cat allgameserver_Proxy|grep $my_ip|awk '{print $3}'|grep -Po "[0-9]{1,2}")
type=$(cat allgameserver_Proxy|grep $my_ip|awk '{print $3}'|awk -F_ '{print $NF}')
echo -e "开始配置$gid组LVS GZ-$type"
yum install nmap rsync mtr iftop -y  
iptables -t mangle -F
iptables -t mangle -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -I FORWARD -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j TCPMSS --set-mss 1300
iptables -t mangle -I FORWARD -p tcp -m tcp --tcp-flags FIN,RST,SYN,ACK SYN,ACK -j TCPMSS --set-mss 1300
iptables -t mangle -I PREROUTING -m ttl --ttl-gt 1 -j TTL --ttl-inc 30
iptables -t mangle -A INPUT -s 10.13.0.0/16 -j TOS --set-tos 0x00/0xff
iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
service iptables save
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
PEER_OUTER_IPADDR=$(eval echo  $`echo hk_${type}_ip`)
PEER_INNER_IPADDR=100.64.1.1
MY_INNER_IPADDR=100.64.1.2
MY_OUTER_IPADDR=$(eval echo  $`echo gz_${type}_ip`)
MTU=1440
EOF
else
cat  > /etc/sysconfig/network-scripts/ifcfg-gre1 <<EOF
DEVICE=gre1
BOOTPROTO=none
ONBOOT=yes
TYPE=GRE
TTL=255
PEER_OUTER_IPADDR=$(eval echo  $`echo hk_${type}_ip`)
PEER_INNER_IPADDR=100.64.1.1
MY_INNER_IPADDR=100.64.1.2
MY_OUTER_IPADDR=$(eval echo  $`echo gz_${type}_ip`)
MTU=1440
EOF
fi

echo "0.0.0.0/0 via 100.64.1.1" > /etc/sysconfig/network-scripts/route-gre1
echo "10.0.0.0/8 via 10.13.0.1" > /etc/sysconfig/network-scripts/route-eth0 
cat allgameserver_MHDL |grep "_$gid"|grep 正式|awk '{print $1"\n"$2}'|sed "s/$/\/32 via 10.13.0.1/g"  >> /etc/sysconfig/network-scripts/route-eth0
sed -i /GATEWAY=/d /etc/sysconfig/network-scripts/ifcfg-eth0  
chkconfig iptables on
echo -e "配置完成"

