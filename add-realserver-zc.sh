#!/bin/bash
        echo "global_defs {
        router_id LVS_DEVEL
        }" >/etc/keepalived/keepalived.conf

        ip=`ifconfig eth0 | sed -n '/inet /{s/.*addr://;s/ .*//;p}'`

        while read line
        do
        port=$line
        echo "virtual_server $ip $port {
              delay_loop 60
              lb_algo wrr
              lb_kind NAT
              protocol TCP" >>/etc/keepalived/keepalived.conf
        while read line
        do 
        ipadd=$line
        echo "    real_server $line $port {
                  weight 65534
                  TCP_CHECK {
                  connect_timeout 10
                  nb_get_retry 5
                  delay_before_retry 5
                  connect_port $port
                  }
          }" >>/etc/keepalived/keepalived.conf
        done < /root/route-inside.txt

        while read line
        do
        ipadd=$line
        echo "    real_server $line $port {
                  weight 1
                  TCP_CHECK {
                  connect_timeout 10
                  nb_get_retry 5
                  delay_before_retry 5
                  connect_port $port
                  }
          }" >>/etc/keepalived/keepalived.conf
        done < /root/route-outside.txt

        echo "}" >>/etc/keepalived/keepalived.conf
        done < /root/port-tcp.txt



