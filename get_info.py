#!/usr/bin/env python
# _*_coding:utf8 _*_
import urllib2
import urlparse
import hashlib
import urllib
import httplib
import sys
import json
import glob
reload(sys)
sys.setdefaultencoding('utf8')





class Ucloud:
    def __init__(self,public_key,private_key):
        """
        initialized variables to public_key  private_key
        
        """
        self.data_center = {'北京BGP-A':'cn-north-01','北京BGP-C':'cn-north-03','亚太':'hk-01','北美':'us-west-01'}
        self.public_key = public_key
        self.private_key = private_key
    def _verfy_ac(self, private_key, params):
        items = params.items()
        items.sort()
        params_data = "";
        for key,value in items:
            params_data = params_data + str(key) + str(value)
        params_data = params_data + private_key
        sign = hashlib.sha1()
        sign.update(params_data)
        signature = sign.hexdigest()
        return signature
    def http_post(self,params):
        """

        :rtype : request ucloud api and  pass parameter,params is dict
        """
        conn = httplib.HTTPConnection("api.ucloud.cn")
        URL="/?"
        for key in sorted(params.keys()):
            value=params[key]
            if str(value).find('+') > 0:
               new_value = value.replace('+','%2B')
               #print new_value
               URL=URL+key+"="+str(new_value)+"&"
               #print URL
            else:
                URL=URL+key+"="+str(value)+"&"
           # print URL
        ll=len(URL)
        URL=URL[0:(ll-1)]
        #print URL
        conn.request("GET",URL)

        Response=conn.getresponse().read()
        res={}
        try:
            res=json.loads(Response)
            #print res
        except:
            print "failed: "+URL
        return res
    def get_business(self,data_center,prid):
        params = {}
        params['Action'] = 'DescribeUHostTags'
        params['Region'] = data_center
        params['ProjectId'] = prid
        params['PublicKey'] = self.public_key
        Signature = self._verfy_ac(self.private_key, params)
        params['Signature'] = Signature
        res = self.http_post(params)
        if res['RetCode'] == 0:
            return res['TagSet']
        else:
            print 'error'
    def get_host(self,data_center):
        params = {}
        params['Action'] = 'DescribeUHostInstance'
        params['Region'] = data_center
        params['UHostIds.n'] = ''
        params['Offset'] = 0
        params['Limit'] = 1000
        params['PublicKey'] = self.public_key
        Signature = self._verfy_ac(self.private_key, params)
        params['Signature'] = Signature
        res = self.http_post(params)
        if res['RetCode'] == 0:
            return res['UHostSet']
        else:
            print 'error'
    def get_udb(self,data_center,prid):
        params = {}
        params['Action'] ='DescribeUDBInstance'
        params['Region'] = data_center
        params['ProjectId'] = 'org-718'
        params['ClassType'] = 'SQL'
        params['Offset'] ='0'
        params['Limit'] ='1000'
        params['PublicKey'] = self.public_key
        Signature = self._verfy_ac(self.private_key, params)
        params['Signature'] = Signature
        res = self.http_post(params)
        if res['RetCode'] == 0:
            return res
           # return res['DataSet']
        else:
            print 'error'
    def get_group(self,data_center):
        params = {}
        params['Action'] ='DescribeUHostTags'
        params['Region'] = data_center
        params['PublicKey'] = self.public_key
        Signature = self._verfy_ac(self.private_key, params)
        params['Signature'] = Signature
        res = self.http_post(params)
    def get_image(self,data_center):
        params = {}
        params['Action'] = 'DescribeImage'
        params['Region'] = data_center
        params['ImageType'] = 'Custom'
        params['PublicKey'] = self.public_key
        Signature = self._verfy_ac(self.private_key, params)
        params['Signature'] = Signature
        res = self.http_post(params)
        if res['RetCode'] == 0:
            return res
           # return res['DataSet']
        else:
            print 'error'
    def get_DescribeSecurityGroup(self,data_center):
        params = {}
        params['Action'] = 'DescribeSecurityGroup'
        params['Region'] = data_center
        params['PublicKey'] = self.public_key
        Signature = self._verfy_ac(self.private_key, params)
        params['Signature'] = Signature
        res = self.http_post(params)
        if res['RetCode'] == 0:
            return res
           # return res['DataSet']
        else:
            print 'error'
    def create_VServer(self,data_center,vname,vport,vprot,ulbid):
        params = {}
        params['Action'] = 'CreateVServer'
        params['Region'] = data_center 
        params['ULBId'] = ulbid
        params['Protocol'] = vprot
        params['VServerName'] = vname
        params['FrontendPort'] = vport
        params['PublicKey'] = self.public_key
        Signature = self._verfy_ac(self.private_key, params)
        params['Signature'] = Signature
        res = self.http_post(params)
        if res['RetCode'] == 0:
            return res
        else:
            print 'error'
            print URL

    def get_DescribeULB(self,data_center,ulbid):
        params = {}
        params['Action'] = 'DescribeULB'
        params['Region'] = data_center
        params['ULBId'] = ulbid
        params['PublicKey'] = self.public_key
        Signature = self._verfy_ac(self.private_key, params)
        params['Signature'] = Signature
        res = self.http_post(params)
        if res['RetCode'] == 0:
            return res
        else:
            print 'error'
    def create_Backend(self,data_center,vserverid,sport,vhostid,ulbid):
        params = {}
        params['Action'] = 'AllocateBackend'
        params['Region'] = data_center
        params['ULBId'] = ulbid
        params['VServerId'] = vserverid
        params['ResourceType'] = 'UHost'
        params['ResourceId'] = vhostid
        params['Port'] = sport
        params['PublicKey'] = self.public_key
        Signature = self._verfy_ac(self.private_key, params)
        params['Signature'] = Signature
        res = self.http_post(params)
        if res['RetCode'] == 0:
            return res
        else:
            print 'error'
    def del_Vserver(self,data_center,ulbid,vserverid):
        params = {}
        params['Action'] = 'DeleteVServer'
        params['Region'] = data_center
        params['ULBId'] = ulbid
        params['VServerId'] = vserverid
        params['PublicKey'] = self.public_key
        Signature = self._verfy_ac(self.private_key, params)
        params['Signature'] = Signature
        res = self.http_post(params)
        if res['RetCode'] == 0:
            return res
        else:
            print 'error'
    def update_Vserver(self,data_center,ulbid,vserverid,Modifycharacter):
        params = {}
        params['Action'] = 'UpdateVServerAttribute'
        params['Region'] = data_center
        params['ULBId'] = ulbid
        params['VServerId'] = vserverid
        params['PersistenceType'] = Modifycharacter
        params['PublicKey'] = self.public_key
        Signature = self._verfy_ac(self.private_key, params)
        params['Signature'] = Signature
        res = self.http_post(params)
        if res['RetCode'] == 0:
            return res
        else:
            print 'error'
    def get_eip_info(self,data_center):
        params = {}
        params['Action'] = 'DescribeEIP'
        params['Region'] = data_center
        params['Offset'] = '0'
        params['Limit'] = '10000'
        params['PublicKey'] = self.public_key
        Signature = self._verfy_ac(self.private_key, params)
        params['Signature'] = Signature
        res = self.http_post(params)
        if res['RetCode'] == 0:
            return res
        else:
            print 'error'
    def get_share_info(self,data_center):
        params = {}
        params['Action'] = 'DescribeShareBandwidth'
        params['Region'] = data_center
        params['PublicKey'] = self.public_key
        Signature = self._verfy_ac(self.private_key, params)
        params['Signature'] = Signature
        res = self.http_post(params)
        if res['RetCode'] == 0:
            return res
        else:
            print 'error'
    def add_eip_share(self,data_center,eipid,shareid):
        params = {}
        params['Action'] = 'AssociateEIPWithShareBandwidth'
        params['Region'] = data_center
        params['EIPIds.0'] = eipid
        params['ShareBandwidthId'] = shareid
        params['PublicKey'] = self.public_key
        Signature = self._verfy_ac(self.private_key, params)
        params['Signature'] = Signature
        res = self.http_post(params)
        if res['RetCode'] == 0:
            return res
        else:
            print 'error'

if __name__ == '__main__':
    #PublicKey = 'ucloudxuwei@zhanchengkeji.com14405529820002144838582'
    #PrivateKey = 'd7203dcf81d0a19b78c62cf3716bf0fec6b7c633'
    PublicKey = '8eHTecPRCUzHQl+kps7o5iI9eQfr4o0/BXIF9jUgCGw='
    PrivateKey = 'c007d71204fe333e8b20e8731423f5e7da65113f'
    a = Ucloud(PublicKey,PrivateKey)
    a.get_host('cn-north-01','org-718')

