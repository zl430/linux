#!/usr/bin/python
#coding=utf-8
import sys
import http.client
import json

params='login_email=1906869123@qq.com&login_password=zuolei@221315&format=json'
headers = {"Content-type": "application/x-www-form-urlencoded", "Accept": "text/json"}
conn = http.client.HTTPSConnection("dnsapi.cn")

if len(sys.argv) !=4:
  print('参数：dnsid name value')
  conn.request("POST","/Domain.List",params,headers)
  Response=conn.getresponse().read()
  res = json.loads(Response)
  domains=res['domains']
  for d in domains:
    print(d['id'],d['status'],d['name'])
  exit(1)


domainid=sys.argv[1]
name=sys.argv[2]
value=sys.argv[3]
print('domainid,name,value')

conn.request("POST","/Record.Create",params+'&domain_id='+domainid+'&sub_domain='+name+'&record_type=A&record_line=%E9%BB%98%E8%AE%A4&value='+value,headers)
Response=conn.getresponse().read()
print('Response')
