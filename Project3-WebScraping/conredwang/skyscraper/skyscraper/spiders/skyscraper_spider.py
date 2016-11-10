 # -*- coding: utf-8 -*-
 
# author : Conred Wang
# title : Wed scraping using Scrapy.  Code 2 of 3.  skyscraper_spider.py

from scrapy import Spider
from scrapy.selector import Selector
from skyscraper.items import SkyscraperItem
import scrapy

class SkyscraperSpider(Spider):
	name = 'skyscraper_spider'
	allowed_urls = ['skyscrapercenter.com']
	start_urls = ['https://skyscrapercenter.com/buildings']

#...parse
#...Scrape data from main page and use "parse_building_page" to scrape additional data from secondary page for each individual building.
#...Main page 'https://skyscrapercenter.com/buildings' data arrangement is consistent and positional.  Thus, data can be scraped with hard-coded index. 

	def parse(self, response):
		rows = response.xpath('//*[@id="table-buildings"]/tbody/tr').extract()
		for row in rows: 
			blgName = Selector(text=row).xpath('//td[4]/a/text()').extract()[0].strip()
			blgCity = Selector(text=row).xpath('//td[5]/a/text()').extract()[0]
			blgCountry = Selector(text=row).xpath('//td[5]/a/text()').extract()[1]
			blgFloor = Selector(text=row).xpath('//td[8]/text()').extract()[0]
			blgPurpose = Selector(text=row).xpath('//td[11]/text()').extract()[0].strip()
			blgUrl = "https://skyscrapercenter.com/" + Selector(text=row).xpath('//td[4]/a/@href').extract()[0].strip()            
			hgtRank = Selector(text=row).xpath('//td[1]/text()').extract()[0]
			hgtFeet = Selector(text=row).xpath('//td[7]/text()').extract()[0].replace(",","")
			isMultiPurpose = "Y" if blgPurpose.find("/") != -1 else "N"
			forOffice = "Y" if blgPurpose.find("office") != -1 else "N"
			forResidential = "Y" if blgPurpose.find("residential") != -1 else "N"
			forHotel = "Y" if blgPurpose.find("hotel") != -1 else "N"
			forRetail = "Y" if blgPurpose.find("retail") != -1 else "N"    
			yrComplete = Selector(text=row).xpath('//td[9]/text()').extract()[0]
			item = SkyscraperItem()
			item['blgName']= blgName
			item['blgCity'] = blgCity
			item['blgCountry'] = blgCountry
			item['blgFloor'] = blgFloor
			item['blgPurpose'] = blgPurpose
			item['blgUrl'] =blgUrl          
			item['hgtRank'] = hgtRank    
			item['hgtFeet'] = hgtFeet
			item['isMultiPurpose'] = isMultiPurpose
			item['forOffice'] = forOffice
			item['forResidential'] = forResidential
			item['forHotel'] = forHotel
			item['forRetail'] = forRetail    
			item['yrComplete'] = yrComplete
			request = scrapy.Request(blgUrl, callback=self.parse_building_page)
			request.meta['item'] = item # use 'request.meta' to pass the partial filled 'item' to parse_building_page
			yield request

#...parse_building_page
#...Scrape data from individual building page by navigating to the URL specified in main page.
#...Secondary page data basically arranged as key-value pairs.
#...However, some key may be missing for some buildings.  For example, there is no Proposed Year for Willis Tower.
#...And following conditions make the scraping even more challenging:
#...1) Sometimes key embedded within a link.  But sometimes just a text.
#...2) Some keys and some values contain unicode.
#...3) Data arrangement is inconsistent and unpredictable.  Thus, we traverse available key-value pairs.  As soon as we
#......get both Proposed Year and Start Year, we stop the traverse.  But, if Proposed Year is mssing, we will traverse 
#......all key-value pairs.

	def parse_building_page(self, response):
		yrPropose = "NA"
		yrStart =  "NA"   
		tmProposeStart = "NA"
		tmProposeComplete = "NA"
		tmStartComplete = "NA"        
		blgrows = response.xpath('//table[@class="table table-condensed table-building-data"]/tbody/tr').extract()
		for blgrow in blgrows:
			tdKey = Selector(text=blgrow).xpath('//td[1]/a/text()').extract() 
			tdValue = Selector(text=blgrow).xpath('//td[2]/text()').extract()  
			if len(tdKey) > 0 and len(tdValue) > 0:
				tdKey = tdKey[0].encode('ascii','ignore')
				tdValue = tdValue[0].encode('ascii','ignore')
				if 'Proposed' in tdKey :
					yrPropose = tdValue 
				if 'Construction Start' in tdKey :
					yrStart = tdValue 
			if len(yrPropose) > 2 and len(yrStart) > 2 :
				break
		item = response.meta['item']                
		if yrPropose != 'NA' and yrStart != 'NA':
			tmProposeStart = int(yrStart) - int(yrPropose)
		if yrPropose != 'NA' :
			tmProposeComplete = int(item['yrComplete']) - int(yrPropose)
		if yrStart != 'NA' :
			tmStartComplete = int(item['yrComplete']) - int(yrStart)
		item['yrPropose'] = yrPropose
		item['yrStart'] = yrStart    
		item['tmProposeStart'] = tmProposeStart
		item['tmProposeComplete'] = tmProposeComplete
		item['tmStartComplete'] = tmStartComplete
		yield item