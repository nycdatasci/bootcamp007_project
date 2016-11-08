import scrapy
from scrapy import Spider
from scrapy.selector import Selector
from happyhour.items import YelpItem

class yelpSpider(scrapy.Spider):
    name = "happyhour_spider"
    allowed_domains = ['https://www.yelp.com']
    start_urls = ["https://www.yelp.com/search?find_desc=Restaurants&find_loc=Boston,+MA&start=0&sortby=rating&attrs=HappyHour"]

    def parse(self, response):

        from scrapy import Selector
        
        full_listing = response.xpath('//*[@class="biz-listing-large"]').extract()
        

        for listing in full_listing:  
            item = YelpItem()
            name = Selector(text=listing).xpath('//a[@class="biz-name js-analytics-click"]//span/text()').extract()
            item['name'] = name
            address = ' '.join(Selector(text=listing).xpath('//address//text()').extract()).strip()
            item['address'] = address
            url = Selector(text=listing).xpath('//a[@class="biz-name js-analytics-click"]/@href').extract()
            item['url'] = url
            phone = Selector(text=listing).xpath('//*[@class="biz-phone"]//text()').extract()
            item['phone'] = phone
            # rating = 
            # item['rating'] = rating
            price_rating = Selector(text=listing).xpath('//*[@class="business-attribute price-range"]').extract()
            item['price_rating'] = price_rating

            yield item

        # for url in urls:
        #     item = YelpItem()
        #     item['url'] = url
        #     yield item

        # for name in names:
        #     item = YelpItem()
        #     item['name'] = name
        #     yield item
