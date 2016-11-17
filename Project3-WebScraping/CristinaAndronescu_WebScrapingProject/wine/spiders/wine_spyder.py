# -*- coding: utf-8 -*-
"""
Created on Thu Nov 10 14:22:54 2016

@author: cristina1
"""
import scrapy
from scrapy import Spider
from wine.items import WineItem
from scrapy import Selector

class WineSpider(Spider):
    
    name = 'wine_spider'
    base_url = 'http://www.wine.com'
    start_urls = ["http://www.wine.com/v6/wineshop/default.aspx"]
    
    def parse(self, response):
        
        ## scrape the page
        product_urls = response.xpath('//*[@class="listProductName"]/@href').extract()
        for product_url in product_urls:
            yield scrapy.Request(url = self.base_url + product_url,
                                 callback = self.parse_product)

        try:
            next_url = response.xpath('//*[@id="ctl00_BodyContent_ctrProducts_ctrPagingBottom_lnkNext"]/@href').extract()
#            print '***********************************'    
#            print 'http://www.wine.com' + next_url[0]          
#            print '***********************************' 
            yield scrapy.Request(url = self.base_url + next_url[0], 
                                 callback = self.parse)
        except ValueError:
            print "Reached the last page"
            return
            
    def parse_product(self, response):
        item = WineItem()
        item['name_year'] = response.xpath('/html/body/main/section[2]/h1/text()').extract()
        item['name_location'] = response.xpath('/html/body/main/section[2]/h2/text()').extract()
        item['alch_s'] = response.xpath('/html/body/main/section[2]/ul[1]/li[2]/text()').extract() 
        item['alch'] = response.xpath('/html/body/main/section[2]/ul[1]/li[3]/text()').extract() 
        item['wtype'] = response.xpath('/html/body/main/section[2]/ul/li[1]/text()').extract()
        item['price'] = response.xpath('/html/body/main/section[2]/div[1]/div[1]/div/span/text()').extract()
        item['winemaker_notes'] = response.xpath('/html/body/main/section[3]/ul[2]/li[1]/section[1]/p/text()').extract()
        item['wcritical_acclaim1'] = response.xpath('/html/body/main/section[3]/ul[2]/li[1]/section[2]/ul/li[1]/article/span[2]/text()').extract()
        item['wcritical_acclaim2'] = response.xpath(' /html/body/main/section[3]/ul[2]/li[1]/section[2]/ul/li[2]/article/span[2]/text()').extract()
        item['wcritical_acclaim3'] = response.xpath(' /html/body/main/section[3]/ul[2]/li[1]/section[2]/ul/li[3]/article/span[2]/text()').extract()
        item['wcritical_acclaim4'] = response.xpath(' /html/body/main/section[3]/ul[2]/li[1]/section[2]/ul/li[4]/article/span[2]/text()').extract()
        item['wcritical_acclaim5'] = response.xpath(' /html/body/main/section[3]/ul[2]/li[1]/section[2]/ul/li[5]/article/span[2]/text()').extract()
        lis = response.xpath('//div[@class="currentVintageProfessinalReviews"]/ul[@class="wineRatings"]/li').extract()
        item['rating_name'] = list()
        item['rating_score'] = list()
        for li in lis:
            name, score = Selector(text = li).xpath('.//span/span/text()').extract()
            item['rating_name'].append(name)
            item['rating_score'].append(score)

        return item
        
        
#         item['all_comb'] = response.xpath('/html/body/main/section[2]/ul[1]/text()').extract() 
#        filter(lambda x: len(x) > 0, map(lambda x: x.strip(), response.xpath('/html/body/main/section[3]/ul[2]/li[1]//text()').extract()))
#        item['all_text'] = filter(lambda x: len(x) > 0, map(lambda x: x.strip(), response.xpath('/html/body/main/section[3]/ul[2]/li[1]//text()').extract()))
        
#        /html/body/main/section[2]/ul[1]/li[2]
#         /html/body/main/section[2]/ul[1]/li[3]
#         /html/body/main/section[2]/ul/li[2]
#         /html/body/main/section[2]/div[1]/div[1]/div/span
#         /html/body/main/section[2]/div[1]/div[1]/div/span
#         /html/body/main/section[2]/div[1]/div/div/span
         
#         critical_acclaim = response.xpath('/html/body/main/section[3]/ul[2]/li[1]/section[2]/text()').extract()
#         print '*************************************'
#         print winemaker_notes
#         print critical_acclaim
#         print '*************************************'
#      response.xpath('/html/body/main/section[3]/ul[2]/li[1]/section[1]/h3/text()').extract()
#      response.xpath('/html/body/main/section[3]/ul[2]/li[1]/section[1]/p/text()').extract() # text wine maker
#      response.xpath('/html/body/main/section[3]/ul[2]/li[1]/section[1]').extract()
#      response.xpath('/html/body/main/section[3]/ul[2]/li[1]/section[2]/ul/li[1]/article ').extract()
#      response.xpath('/html/body/main/section[3]/ul[2]/li[1]').extract() # whole frame but not just the text
#      response.xpath('/html/body/main/section[3]/ul[2]/text()').extract()
#      response.xpath('/html/body/main/section[3]/text()').extract()
         
         
       
#    
#      rev = response.xpath('//section[@class="cristicalAcclaim"]/ul[@class="wineRatings"]/li').extract()
#      
#      
#      item['review_text'] = list()
#      for rev in revs:
#          revtext = Selector(text=li).xpath(')
      
      
      
      
#            base_url + "?Nao=100"
#            urls = [ ]
#            for i in range(0, 87):
#                #urls.append(base_url + "?Nao=100" + str(i*100) )
#                urls.append(base_url + "?Nao=100" + str(i+100))
#                print urls
#            for url in urls.find(class= listProductName):
#                yield scrapy.Request(url=url, callback=self.parse)
#                
#                print url
#    