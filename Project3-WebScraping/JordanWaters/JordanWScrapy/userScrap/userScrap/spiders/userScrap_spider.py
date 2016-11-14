import scrapy
import sys
import re
from scrapy import Spider
from scrapy.selector import Selector
from userScrap.items import YelpItem

yourID = 'Ja9gBg4CYOne-MXqHUrcYA'
#restaurant = "a-and-a-bake-and-doubles-shop-brooklyn"
# item = YelpItem()
# item['userId'] = yourID
# page_url = "https://www.yelp.com/user_details_reviews_self?rec_pagestart=0&userid=" + yourID
# yield scrapy.Request(page_url,callback=self.parse_user, meta={'item':item})


class yelpSpider(scrapy.Spider):

    name = "userScrap_spider"
    allowed_domains = ['www.yelp.com']
    # start_urls = ["https://www.yelp.com/biz/" + restaurant]

    def __init__(self,yourID=None, *args, **kwargs):
        super(yelpSpider, self).__init__(*args, **kwargs)
        #self.restaurant = restaurant
        self.start_urls = ['https://www.yelp.com/user_details_reviews_self?rec_pagestart=0&userid=%s' %yourID]

    def last_pagenumber_in_search(self, response):
        try:
            last_page_number = int(re.search(r'start=(\d+)', response.xpath('//*[@class="available-number pagination-links_anchor"]').extract()[-1]).group(1))
            return last_page_number
        except:
            last_page_number = 0
            return last_page_number

    # def parse(self, response):
    #     last_page_number = self.last_pagenumber_in_search(response)
    #     if last_page_number < 20:
    #         return
    #     if response.url == 'https://www.yelp.com/user_details_reviews_self?rec_pagestart=0&userid=%s' %yourID:
    #         item = YelpItem()
    #         item['userId'] = yourID
    #         page_url = "https://www.yelp.com/user_details_reviews_self?rec_pagestart=0&userid=" + userID
    #         yield scrapy.Request(page_url,callback=self.parse_user, meta={'item':item})
    #     else:
    #         page_urls = ['https://www.yelp.com/biz/'+ restaurant + "?start=" + str(pageNumber) for pageNumber in range(0, last_page_number + 20 , 20)]
    #         for page_url in page_urls:
    #             yield scrapy.Request(page_url, callback=self.parse_listing_results_page)
    #
    #
    # def parse_listing_results_page(self, response):
    #     reviews = response.css('.review').extract()
    #     for review in reviews[1:]:
    #         if re.search('user_id:(.+)"', review).group(1):
    #             userID = re.search('user_id:(.+)"', review).group(1)
    #             item = YelpItem()
    #             item['userId'] = userID
    #             page_url = "https://www.yelp.com/user_details_reviews_self?rec_pagestart=0&userid=" + userID
    #             yield scrapy.Request(page_url,callback=self.parse_user, meta={'item':item})


    def parse(self, response):
        item = YelpItem()
        item['userId'] = yourID
        last_page_number2 = self.last_pagenumber_in_search(response)
        if last_page_number2 < 10:
            return
        else:
            page_urls = ["https://www.yelp.com/user_details_reviews_self?rec_pagestart=" + str(pageNumber) + '&userid=' + item['userId'] for pageNumber in range(0, last_page_number2 + 10 , 10)]
            for page_url in page_urls:
                yield scrapy.Request(page_url, callback=self.parse_listing_results_page_user, meta={'item':item})


    def parse_listing_results_page_user(self, response):
    # from scrapy import Selector
        item = response.meta['item']
        reviews = response.css('.review').extract()
    # for i in map(lambda x: x.extract(), reviews):
    #     print i
    #     print "=" * 50
        for review in reviews:
            if Selector(text =review).xpath('//a[@class="biz-name js-analytics-click"]//span//text()').extract():
                # print re.search('title="(\d).0 star rating', review)
                item['restaurant'] = Selector(text =review).xpath('//a[@class="biz-name js-analytics-click"]//span//text()').extract()
                print(item['restaurant'])
                # item = YelpItem()
                # item['restaurant'] = re.search('Start your review of <strong>(.+)</strong>', reviews[0]).group(1)
                item['stars'] = re.search('title="(\d).0 star rating', review).group(1)
                item['text'] = re.search('<p lang="en">(.+)<\/p>', review).group(1)
                # userID = re.search('user_id:(.+)"', review).group(1)
                # item['userId'] = userID
                yield item
