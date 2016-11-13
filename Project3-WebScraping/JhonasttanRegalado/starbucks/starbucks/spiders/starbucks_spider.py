# -*- coding: utf-8 -*-
from scrapy import Spider
from starbucks.items import StarbucksItem
from scrapy.selector import Selector
import re

class StarbucksSpider(Spider):
    name = 'starbucks_spider'
    allowed_urls = ['www.starbucks.com']
    #start_urls = ['https://www.starbucks.com/store-locator?map=40.714189,-74.01046,12z&place=New%20York,%20NY,%20USA']
    start_urls = ['https://www.starbucks.com/store-locator?map=40.714189,-74.01046,12z', \
    'https://www.starbucks.com/store-locator?map=40.731492,-74.003937,13z', \
    'https://www.starbucks.com/store-locator?map=40.758283,-73.966,13z', \
    'https://www.starbucks.com/store-locator?map=40.768815,-74.004967,13z', \
    'https://www.starbucks.com/store-locator?map=40.787663,-73.980591,13z', \
    'https://www.starbucks.com/store-locator?map=40.819369,-73.945744,13z', \
    'https://www.starbucks.com/store-locator?map=40.848332,-73.920509,13z']    
              
    def parse(self, response):
        bootstrap = response.xpath('//*[@id="bootstrapData"]').extract()
        
        print type(bootstrap), len(bootstrap)
        
        #old schoold regex to the rescue
        rows = re.findall('"id":"(.*?)","name":"(.*?)","phoneNumber":"(.*?)","coordinates":\{(.*?)\}.*?,"addressLines":\[(.*?)\].*?,"features":\[(.*?)\],"slug":"(.*?)"',bootstrap[0], re.IGNORECASE)           

        #print len(rows)
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
            item['AmenitiesCarto'] = '<ul>' + '<li>'.join(amenitiesDict.values()) + '</ul>'            
            item['Url'] = storeUrl
            item['StoreNameUrl'] = '<a href="' + storeUrl + '">' + row[1]  + '</a>'

            
            
            if 'CL' in amenitiesDict.keys():
                item['CL'] = 1
                del amenitiesDict['CL']
            else:
                item['CL'] = 0
            
            if 'WA' in amenitiesDict.keys():
                item['WA'] = 1
                del amenitiesDict['WA']
            else:
                item['WA'] = 0

            if 'WF' in amenitiesDict.keys():
                item['WF'] = 1
                del amenitiesDict['WF']
            else:
                item['WF'] = 0
                
            if 'CD' in amenitiesDict.keys():
                item['CD'] = 1
                del amenitiesDict['CD']
            else:
                item['CD'] = 0
            
            if 'DR' in amenitiesDict.keys():
                item['DR'] = 1
                del amenitiesDict['DR']
            else:
                item['DR'] = 0
                
            if 'LB' in amenitiesDict.keys():
                item['LB'] = 1
                del amenitiesDict['LB']
            else:
                item['LB'] = 0
                
            if 'GO' in amenitiesDict.keys():
                item['GO'] = 1
                del amenitiesDict['GO']
            else:
                item['GO'] = 0
                        
            if 'FZ' in amenitiesDict.keys():
                item['FZ'] = 1
                del amenitiesDict['FZ']
            else:
                item['FZ'] = 0
                
            if 'XO' in amenitiesDict.keys():
                item['XO'] = 1
                del amenitiesDict['XO']
            else:
                item['XO'] = 0
                
            if 'LU' in amenitiesDict.keys():
                item['LU'] = 1
                del amenitiesDict['LU']
            else:
                item['LU'] = 0

            if 'RW' in amenitiesDict.keys():
                item['RW'] = 1
                del amenitiesDict['RW']
            else:
                item['RW'] = 0
                
            if 'PS' in amenitiesDict.keys():
                item['PS'] = 1
                del amenitiesDict['PS']
            else:
                item['PS'] = 0

            if 'CS' in amenitiesDict.keys():
                item['CS'] = 1
                del amenitiesDict['CS']
            else:
                item['CS'] = 0
                
            if 'MX' in amenitiesDict.keys():
                item['MX'] = 1
                del amenitiesDict['MX']
            else:
                item['MX'] = 0
                
            if 'VS' in amenitiesDict.keys():
                item['VS'] = 1
                del amenitiesDict['VS']
            else:
                item['VS'] = 0
                
            if 'NB' in amenitiesDict.keys():
                item['NB'] = 1
                del amenitiesDict['NB']
            else:
                item['NB'] = 0
                
            if 'SQ' in amenitiesDict.keys():
                item['SQ'] = 1
                del amenitiesDict['SQ']
            else:
                item['SQ'] = 0
                
            if 'EM' in amenitiesDict.keys():
                item['EM'] = 1
                del amenitiesDict['EM']
            else:
                item['EM'] = 0

            if 'BA' in amenitiesDict.keys():
                item['BA'] = 1
                del amenitiesDict['BA']
            else:
                item['BA'] = 0  

            if 'WT' in amenitiesDict.keys():
                item['WT'] = 1
                del amenitiesDict['WT']
            else:
                item['WT'] = 0  
                
            if 'hrs24' in amenitiesDict.keys():
                item['hrs24'] = 1
                del amenitiesDict['hrs24']
            else:
                item['hrs24'] = 0  
                
            if 'DT' in amenitiesDict.keys():
                item['DT'] = 1
                del amenitiesDict['DT']
            else:
                item['DT'] = 0  
                
                
                
                
            
            #capture amenities unaccounted for
            if len(amenitiesDict.keys()) > 0:
                item['AmeOther'] = str(amenitiesDict)
            
            
            yield item
        

