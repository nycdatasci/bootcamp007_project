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
        
        for i, onerow in full_listing:
            #name = Selector(text=full_listing[i]).xpath('//a[@class="biz-name js-analytics-click"]//span/text()').extract()
            #address = ' '.join(Selector(text=full_listing[i]).xpath('//address//text()').extract()).strip()
            url = Selector(text=full_listing[i]).xpath('//a[@class="biz-name js-analytics-click"]/@href').extract()
            phone = Selector(text=full_listing[i]).xpath('//*[@class="biz-phone"]//text()').extract()
            # rating = 
            # price_rating = Selector(text=full_listing[i]).xpath('//*[@class="business-attribute price-range"]').extract()

        yield item

        # for url in urls:
        #     item = YelpItem()
        #     item['url'] = url
        #     yield item

        # for name in names:
        #     item = YelpItem()
        #     item['name'] = name
        #     yield item
