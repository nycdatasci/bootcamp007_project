import scrapy
from scrapy import Selector
from Instagram.items import InstagramItem
from scrapy.contrib.spiders import Rule
from scrapy.linkextractors import LinkExtractor
import time

username = 'eatmenyc'
numCode = '1529120365'

class instagramSpider(scrapy.Spider):
    name = 'instagram_spider'
    allowed_domains = ['www.imgrum.net']
    start_urls = ["http://www.imgrum.net/user/instagram/25025320/759169594685720489_25025320"]
    global page_num
    page_num = 1

    # Rules = (
    # Rule(LinkExtractor(allow=(), restrict_xpaths=('//ul[@class="pagerblock type_columns1"]/li/a')), callback="parse", follow=True),)

    def parse(self, response):
        global page_num
        page_tries = 1
        time.sleep(5)
        all_posts = response.xpath('//div[@class="blogpost_preview_fw"]').extract()

        for post in all_posts:
            url = (Selector(text=post)).xpath('//div[@class="pf_output_container image"]/a/img/@src').extract()
            nLikes = Selector(text=post).xpath('//div[@class="gallery_likes gallery_likes_add "]//span/text()'
                                               ).extract()
            place = Selector(text=post).xpath('//div[@class="post-views"]//span/text()').extract()
            numCom = Selector(text=post).xpath('//div[@class="post-views"]//span/text()').extract()
            #cap = Selector(text = post).xpath('//div[@class="pf_output_container image"]/a/img/@alt').extract()[0]

            if url:
                item = InstagramItem()
                item['image_urls'] = url[0]
                item['numLikes'] = nLikes[0]
                if len(place) == 2:
                    item['location'] = place[0]
                    item['numComments'] = numCom[1]
                else:
                    item['location'] = "NA"
                    item['numComments'] = numCom[0]
                #item['caption'] = cap
                yield item

        # follow next page links
        while(page_tries < 4):
            next_page = response.xpath('//ul[@class="pagerblock type_columns1"]/li/a/@href').extract()
            if next_page:
                print "=" * 50
                print "Go to next page"
                page_tries = 5
                next_href = next_page[0]
                request = scrapy.Request(url=next_href, callback=self.parse)
                page_num = page_num + 1
                print page_num
                yield request
            else:
                page_tries = page_tries + 1
                print("on next page try:" + str(page_tries))
                if(page_tries == 4):
                    print("No next page \n")


