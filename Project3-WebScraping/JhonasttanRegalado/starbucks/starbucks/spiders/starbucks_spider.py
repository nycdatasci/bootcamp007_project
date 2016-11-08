# -*- coding: utf-8 -*-
from scrapy import Spider
from starbucks.items import StarbucksItem
from scrapy.selector import Selector
import re

class StarbucksSpider(Spider):
    name = 'starbucks_spider'
    allowed_urls = ['www.starbucks.com']
    #start_urls = ['https://www.starbucks.com/store-locator?map=40.714189,-74.01046,12z&place=New%20York,%20NY,%20USA']
    start_urls = ['https://www.starbucks.com/store-locator?map=40.714189,-74.01046,12z']    
              
    def parse(self, response):
        bootstrap = response.xpath('//*[@id="bootstrapData"]').extract()
        
        print type(bootstrap), len(bootstrap)
        
        #old schoold regex to the rescue
        rows = re.findall('"id":"(.*?)","name":"(.*?)","phoneNumber":"(.*?)","coordinates":\{(.*?)\}.*?,"addressLines":\[(.*?)\].*?,"features":\[(.*?)\],"slug":"(.*?)"',bootstrap[0], re.IGNORECASE)           

        print len(rows)
        for row in rows:
            #'"latitude":40.712208,"longitude":-74.008192' row[3]
            coordinates = re.findall('"latitude":(.*?),"longitude":(.*)', row[3])
            amenitiesDict = dict(re.findall('"code":"(.*?)","name":"(.*?)"',row[5]))
            starbucksUrl = 'https://www.starbucks.com/store-locator/store/'
            storeUrl = starbucksUrl + row[0] + '/' + row[6]
            print row[3], '\n'
            item = StarbucksItem()
            item['StoreId'] = row[0]           
            item['Name'] = row[1]           
            item['PhoneNumber'] = row[2]            
            item['Latitude'] = coordinates[0][0]   
            item['Longitude'] = coordinates[0][1]
            item['Address'] = row[4]            
            item['Amenities'] = str(amenitiesDict)            
            item['Url'] = storeUrl
            
            '''Known amenities. All others will be counted in Other and will need to be processed manually by adding a new field
            {"code":"CL","name":"Starbucks Reserve-Clover Brewed"},
            {"code":"WA","name":"Oven-warmed Food"},
            {"code":"WF","name":"Wireless Hotspot"},
            {"code":"CD","name":"Mobile Payment"},
            {"code":"DR","name":"Digital Rewards"},
            {"code":"LB","name":"LaBoulange"},
            {"code":"GO","name":"Google Wi-Fi"},
            {"code":"FZ","name":"Fizzio Handcrafted Sodas"},
            {"code":"XO","name":"Mobile Order and Pay"},
            {"code":"LU","name":"Lunch"},
            {"code":"RW","name":"My Starbucks Rewards"},
            {"code":"PS","name":"Playbook Store System"},
            {"code":"CS","name":"tbd - Coffee Scale"}
            '''
            
            if 'CL' in amenitiesDict.keys():
                item['AmeCL'] = 1
                del amenitiesDict['CL']
            else:
                item['AmeCL'] = 0
            
            if 'WA' in amenitiesDict.keys():
                item['AmeWA'] = 1
                del amenitiesDict['WA']
            else:
                item['AmeWA'] = 0

            if 'WF' in amenitiesDict.keys():
                item['AmeWF'] = 1
                del amenitiesDict['WF']
            else:
                item['AmeWF'] = 0
                
            if 'CD' in amenitiesDict.keys():
                item['AmeCD'] = 1
                del amenitiesDict['CD']
            else:
                item['AmeCD'] = 0
            
            if 'DR' in amenitiesDict.keys():
                item['AmeDR'] = 1
                del amenitiesDict['DR']
            else:
                item['AmeDR'] = 0
                
            if 'LB' in amenitiesDict.keys():
                item['AmeLB'] = 1
                del amenitiesDict['LB']
            else:
                item['AmeLB'] = 0
                
            if 'GO' in amenitiesDict.keys():
                item['AmeGO'] = 1
                del amenitiesDict['GO']
            else:
                item['AmeGO'] = 0
                        
            if 'FZ' in amenitiesDict.keys():
                item['AmeFZ'] = 1
                del amenitiesDict['FZ']
            else:
                item['AmeFZ'] = 0
                
            if 'XO' in amenitiesDict.keys():
                item['AmeXO'] = 1
                del amenitiesDict['XO']
            else:
                item['AmeXO'] = 0
                
            if 'LU' in amenitiesDict.keys():
                item['AmeLU'] = 1
                del amenitiesDict['LU']
            else:
                item['AmeLU'] = 0

            if 'RW' in amenitiesDict.keys():
                item['AmeRW'] = 1
                del amenitiesDict['RW']
            else:
                item['AmeRW'] = 0
                
            if 'PS' in amenitiesDict.keys():
                item['AmePS'] = 1
                del amenitiesDict['PS']
            else:
                item['AmePS'] = 0

            if 'CS' in amenitiesDict.keys():
                item['AmeCS'] = 1
                del amenitiesDict['CS']
            else:
                item['AmeCS'] = 0
                
            if 'MX' in amenitiesDict.keys():
                item['AmeMX'] = 1
                del amenitiesDict['MX']
            else:
                item['AmeMX'] = 0
                
            if 'VS' in amenitiesDict.keys():
                item['AmeVS'] = 1
                del amenitiesDict['VS']
            else:
                item['AmeVS'] = 0
                
            if 'NB' in amenitiesDict.keys():
                item['AmeNB'] = 1
                del amenitiesDict['NB']
            else:
                item['AmeNB'] = 0
                
            if 'SQ' in amenitiesDict.keys():
                item['AmeSQ'] = 1
                del amenitiesDict['SQ']
            else:
                item['AmeSQ'] = 0
                
            if 'EM' in amenitiesDict.keys():
                item['AmeEM'] = 1
                del amenitiesDict['EM']
            else:
                item['AmeEM'] = 0

            if 'BA' in amenitiesDict.keys():
                item['AmeBA'] = 1
                del amenitiesDict['BA']
            else:
                item['AmeBA'] = 0            
            
            #capture amenities unaccounted for
            if len(amenitiesDict.keys()) > 0:
                item['AmeOther'] = str(amenitiesDict)
            
            
            yield item
        

