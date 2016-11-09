import scrapy
import sys
import re
from scrapy import Spider
from scrapy.selector import Selector
from yelpScrape.items import YelpItem

restaurant = "to-the-world-farm-brooklyn"

class yelpSpider(scrapy.Spider):
    name = "yelpScrape_spider"
    allowed_domains = ['www.yelp.com']
    start_urls = ["https://www.yelp.com/biz/" + restaurant]
    def last_pagenumber_in_search(self, response):
        try:
            last_page_number = int(re.search(r'start=(\d+)', response
                .xpath('//*[@class="available-number pagination-links_anchor"]')
                .extract()[-1])
                .group(1))
            return last_page_number
        except:
            print('Last page not found')

    def parse(self, response):
        last_page_number = self.last_pagenumber_in_search(response)
        if last_page_number < 20:
            return
        else:
            page_urls = [response.url + "?start=" + str(pageNumber)
                     for pageNumber in range(0, last_page_number + 20 , 20)]
            for page_url in page_urls:
                yield scrapy.Request(page_url,
                                    callback=self.parse_listing_results_page)




    def parse_listing_results_page(self, response):
        from scrapy import Selector
        reviews = response.css('.review').extract()
        print "=" * 50
        print len(reviews)
        # for i in map(lambda x: x.extract(), reviews):
        #     print i
        #     print "=" * 50
        for review in reviews[1:]:
            # print re.search('title="(\d).0 star rating', review)
            item = YelpItem()
            item['restaurant'] = re.search('Start your review of <strong>(.+)</strong>', reviews[0]).group(1)
            item['stars'] = re.search('title="(\d).0 star rating', review).group(1)
            item['text'] = re.search('<p lang="en">(.+)<\/p>', review).group(1)
            item['userId'] = re.search('user_id:(.+)"', review).group(1)

            yield item
