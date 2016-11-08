import scrapy
import re
from scrapy import Spider
from scrapy.selector import Selector
from happyhour.items import YelpItem

#can throw into MongoDB

class yelpSpider(scrapy.Spider):
    name = "happyhour_spider"
    allowed_domains = ['www.yelp.com']
    start_urls = ["https://www.yelp.com/search?find_desc=Restaurants&find_loc=Boston,+MA&start=0&sortby=rating&attrs=HappyHour"]

    def last_pagenumber_in_search(self, response):
        try:
            last_page_number = int(re.search(r'start=(\d+)',response
                .xpath('//*[@class="available-number pagination-links_anchor"]')
                .extract()[-1])
                .group(1))
            return last_page_number    
        except:
            print "last page not found"
    
    def parse(self, response):
        last_page_number = self.last_pagenumber_in_search(response)
        if last_page_number < 10:
            return
        else:
            page_urls = ["https://www.yelp.com/search?find_desc=Restaurants&find_loc=Boston,+MA&start=" + str(pageNumber)+"&sortby=rating&attrs=HappyHour"
                for pageNumber in range(0, last_page_number+10, 10)]
            for page_url in page_urls:
                yield scrapy.Request(page_url,
                                    callback=self.parse_listing_contents)    



    def parse_listing_contents(self, response):

        from scrapy import Selector
        full_listing = response.xpath('//*[@class="biz-listing-large"]').extract()
        for listing in full_listing:  
            item = YelpItem()
            name = Selector(text=listing).xpath('//a[@class="biz-name js-analytics-click"]//span/text()').extract()
            item['name'] = name
            address = Selector(text=listing).xpath('//address//text()').extract()
            item['address'] = ', '.join(address).strip()
            url = Selector(text=listing).xpath('//a[@class="biz-name js-analytics-click"]/@href').extract()
            item['url'] = 'www.yelp.com'+str(url[0])
            #'www.yelp.com'+str(url[0])
            phone = Selector(text=listing).xpath('//*[@class="biz-phone"]//text()').extract()
            item['phone'] = phone
            # rating = 
            # item['rating'] = rating
            price_rating = Selector(text=listing).xpath('//*[@class="business-attribute price-range"]').extract()
            item['price_rating'] = price_rating

            yield item



