#!/usr/bin/env python
# -*- coding: UTF-8 -*-
#广东:cn-south-02
#香港:hk-01

import get_info
import os

#chenhao
PublicKey = ''
PrivateKey = ''
a =get_info.Ucloud(PublicKey,PrivateKey)


zone="HK"

if zone == "GZ":
  data_center = "cn-south-02"
elif zone == "HK":
  data_center = "hk-01"
elif zone == "BJA":
  data_center = "cn-north-01"
elif zone == "BJC":
	data_center = "cn-north-03"
eip_info = a.get_eip_info(data_center)
Eipid = []
for i in  eip_info['EIPSet']:
  if i['PayMode'] != 'ShareBandwidth':
     Eipid.append(i['EIPId'])

share_info =  a.get_share_info(data_center)
shareid = share_info['DataSet'][0]['ShareBandwidthId']
for i in Eipid:
  print a.add_eip_share(data_center,i,shareid)
