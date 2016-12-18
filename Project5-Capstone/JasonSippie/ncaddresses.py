#from scrapy import Spider
#from scrapy.selector import Selector
import scrapy
from realestate.items import RealEstateItem
import time


class GSSpider(scrapy.Spider):
    name = 'ncaddr_spider'
    allowed_urls = ['northcarolinaresidentdb.com']
    rowID = 0

    baseURL ='https://northcarolinaresidentdb.com'
    start_urls = [baseURL + "/find/address"]

    def parse(self, response):
        try:
			zipTable = response.xpath('//*[@id="zip-table"]/tbody/tr') # table with links to zip codes

			for row in zipTable[1:]: # skip the 00000 zipcode
				zipCode = row.xpath('.//a[contains(@href,"address")]/text()').extract_first()

				if zipCode != "28786":
					continue
					
				zipCodeLink = row.xpath('.//a[contains(@href,"address")]/@href').extract_first()
				cityName = row.xpath('.//td')[2].xpath('.//text()').extract_first()
				countyName = row.xpath('.//td')[3].xpath('.//text()').extract_first()
				#countyPop = zipTable[rows].xpath('.//td')[4].xpath('.//text()').extract_first()

				# error handling in here

				# make a new item
				item = RealEstateItem()
				item['zipCode'] = zipCode
				item['cityName'] = cityName
				item['countyName'] = countyName

				# package up a url and drill to next level
				tgtURL = self.baseURL + zipCodeLink
				yield scrapy.Request(tgtURL, callback=self.parseZip, meta={'item': item})
        except:
			logging.log(logging.DEBUG, 'Parse error on: ' + response.url)



    def parseZip(self, response): # parse street names in a zipcode
		# copy info from parent item
		parItem  = response.meta['item']
		streetTable = response.xpath('//*[@id="zip-table"]/tbody/tr') # table with links to street names

		for row in streetTable:
			streetName = row.xpath('.//a[contains(@href,"address")]/text()').extract_first()
			streetNameLink = row.xpath('.//a[contains(@href,"address")]/@href').extract_first()
			
			# real estate item

			item = RealEstateItem()

			item['streetName'] = streetName
			item['zipCode'] = parItem['zipCode']
			item['cityName'] = parItem['cityName']
			item['countyName'] = parItem['countyName']


			# package up a url and drill to next level
			tgtURL = self.baseURL + streetNameLink


			yield scrapy.Request(tgtURL, callback=self.parseStreet, meta={'item': item})

    def parseStreet(self, response): # parse street addresses on a street
		# copy info from parent item
		parItem  = response.meta['item']
		time.sleep(1)

		addrTable = response.xpath('//*[@id="search-table"]/tbody/tr') # table with links to street addresses

		for row in addrTable:
			residentName = row.xpath('.//a/text()').extract_first()
			residentLink = row.xpath('.//a/@href').extract_first()
			streetAddr = row.xpath('.//td')[2].xpath('.//text()').extract_first()
			residentAge = row.xpath('.//td')[4].xpath('.//text()').extract_first()

			residentName = residentName.strip()
			
			# real estate item

			item = RealEstateItem()
			item['residentName'] = residentName
			item['residentAge'] = residentAge
			item['streetAddr'] = streetAddr
			item['streetName'] = parItem['streetName']
			item['zipCode'] = parItem['zipCode']
			item['cityName'] = parItem['cityName']
			item['countyName'] = parItem['countyName']



			# package up a url and drill to next level
			tgtURL = self.baseURL + residentLink

			yield scrapy.Request(tgtURL, callback=self.parseRes, meta={'item': item})


    def parseRes(self, response):
		# copy info from parent item
		parItem = response.meta['item']

		gender = response.xpath('//html/body/div[2]/main/div[1]/div[1]/div[2]/div[5]/div[1]/div/text()').extract()
		race = response.xpath('//html/body/div[2]/main/div[1]/div[1]/div[2]/div[5]/div[2]/div/text()').extract()


		gender = ''.join(gender).strip()
		race = ''.join(race).strip()


		item = RealEstateItem()
		item['rowID'] = self.rowID
		item['residentName'] = parItem['residentName']
		item['residentAge'] = parItem['residentAge']
		item['streetAddr'] = parItem['streetAddr']
		item['streetName'] = parItem['streetName']
		item['zipCode'] = parItem['zipCode']
		item['cityName'] = parItem['cityName']
		item['countyName'] = parItem['countyName']
		item['residentGender'] = gender
		item['residentRace'] = race

		addrQuery = item['streetAddr'] + ' ' + item['cityName'] + ' NC ' + item['zipCode']
		item['addrQuery'] = addrQuery


		self.rowID = self.rowID + 1

		print item

		yield item










