#!/usr/bin/env python
# -*- coding: UTF-8 -*-
#广东:cn-south-02
#香港:hk-01

import get_info
import os

#chenhao
PublicKey = ''
PrivateKey = ''
Servergroup = ["17","18","19"]
zone="GZ"

if zone == "GZ":
  data_center = "cn-south-02"
  zone_id = "15"
  zone_name = "GZ"
elif zone == "HK":
  data_center = "hk-01"
  zone_id = "16"
  zone_name = "HKU"

a =get_info.Ucloud(PublicKey,PrivateKey)

#创建Vserver
ulbid = ""
ulbinfo = a.get_DescribeULB(data_center,ulbid)
hport = ["8080","8081","8082","8083","8084","8085","8086","8087","8090","8091","8092","8093","8094","8095","8096","8097","8100","8101","8102","8103","8104","8105","8106","8107","8110","8111","8112","8113","8114","8115","8116","8117"]
tport = ["8088","8089","8098","8099","8108","8109","8118","8119"]
for groupid in Servergroup:
  print "++++++++++第",groupid,"组开始创建VServer++++++++++"
  ulbname = "MHDL_Proxy_New_" + groupid + "_" + zone
  for ulblist in ulbinfo['DataSet']:
    if ulbname in  ulblist['Name']:
      ulbid = ulblist['ULBId']
      for port in hport:
        name = 'http' + port
        a.create_VServer(data_center,name,port,'HTTP',ulbid)
      for port in tport:
        name = 'tcp' + port
        a.create_VServer(data_center,name,port,'TCP',ulbid)
  print "++++++++++第",groupid,"组VServer创建完成++++++++++"

#添加Vserver后端服务器
uhostinfo = a.get_host(data_center)
ulbid = ""
ulbinfo = a.get_DescribeULB(data_center,ulbid)
for groupid in Servergroup:
  uhostname = "MHDL_Proxy_" + groupid + "_" + zone_name
  ulbname = "MHDL_Proxy_New_" + groupid + "_" + zone
  print "++++++++++第",groupid,"组VServer开始添加后端服务器++++++++++"
  for uhostlist in uhostinfo:
     if uhostname in uhostlist['Name']:
       uhostid = uhostlist['UHostId']
       for ulblist in ulbinfo['DataSet']:
         if ulbname in  ulblist['Name']:
           ulbid = ulblist['ULBId']
           for vserverlist in ulblist['VServerSet']:
             vvid = vserverlist['VServerId']
             vport =  str(vserverlist['FrontendPort'])
             a.create_Backend(data_center,vvid,vport,uhostid,ulbid)
  print "++++++++++第",groupid,"组VServer后端服务器添加完成++++++++++"

#获取ULB IP,并生成域名信息
f=open('mhdl_domain.txt','w')
for groupid in Servergroup:
  ulbname = "MHDL_Proxy_New_" + groupid + "_" + zone
  for ulblist in ulbinfo['DataSet']:
    if ulbname in  ulblist['Name']:
      ulbip = ulblist['IPSet'][0]['EIP']
      domain = "z" + groupid + "."+ zone_id + ".game.zhanchenggame.com"
      #res = ulbip+"\t"+domain+"\t"+ulbname
      res = "%-20s\t%s\t%s"%(domain,ulbname,ulbip)
      f.write(res+os.linesep)
f.close()
print "mhdl_domain.txt生成完成,请查看..."
"""
#删除Vserver
ulbid = ""
ulbinfo = a.get_DescribeULB(data_center,ulbid)
for groupid in Servergroup:
  print "++++++++++第",groupid,"组开始删除VServer++++++++++"
  ulbname = "MHDL_Proxy_New_" + groupid + "_" + zone
  for ulblist in ulbinfo['DataSet']:
    if ulbname in  ulblist['Name']:
      ulbid = ulblist['ULBId']
      for vserverlist in ulblist['VServerSet']:
        vvid = vserverlist['VServerId']
        print a.del_Vserver(data_center,ulbid,vvid)
  print "++++++++++第",groupid,"组VServer删除完成++++++++++"
"""
