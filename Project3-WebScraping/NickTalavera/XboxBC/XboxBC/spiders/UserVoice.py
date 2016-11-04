# This package will contain the spiders of your Scrapy project
#
# Please refer to the documentation for information on how to create and manage
# your spiders.
#class Major_Nelson_Blog_BC_List_Spider(scrapy.Spider):
import scrapy
from scrapy.selector import Selector
# from scrapy.http import Request
from XboxBC.items import UserVoiceItem
import re

class UserVoice(scrapy.Spider):
    name = "UserVoice"
    allowed_domains = ["xbox.uservoice.com"]

    start_urls = (
        'https://xbox.uservoice.com/forums/298503-backwards-compatibility?filter=top&page=1',
    )
    def parse(self, response):
        base_link = 'http://www.xbox.uservoice.com'
        print "=" * 50
        numberOfPages = int(response.xpath("/html/body/div[2]/div/div/div[1]/article/section[3]/div[2]/a/text()")[-2].extract())
        print(numberOfPages)
        print "=" * 50
        for j in range(1,numberOfPages+1):
            next_page = 'https://xbox.uservoice.com/forums/298503-backwards-compatibility?filter=top&page=' + str(j)
            print("Page" + str(j))
            yield scrapy.Request(next_page, callback=self.userVoiceFind)

    def userVoiceFind(self, response):
            rows_in_big_table = response.xpath("/html/body/div[2]/div/div/div[1]/article/section[3]/ol/li")
            for i, onerow in enumerate(rows_in_big_table):
                user_voice_item = UserVoiceItem()

                gameName = onerow.xpath('div[1]/h2/a/text()').extract()[0]
                votes = ''.join(re.findall('\d+',onerow.xpath('div[2]/div[1]/strong/text()').extract()[0]))
                comments = ''.join(re.findall('\d+',onerow.xpath('div[3]/a/text()').extract()[0]))
                in_progress = onerow.xpath('article/div[1]/a/em/text()').extract()
                # /html/body/div[2]/div/div/div[1]/article/section[3]/ol/li[6]/article/div[1]/a/em
                print(gameName)
                print(votes)
                print(comments)
                print(in_progress)

                user_voice_item['gameName'] = gameName
                user_voice_item['comments'] = comments
                user_voice_item['votes'] = votes
                user_voice_item['in_progress'] = in_progress
                print "=" * 50
                yield user_voice_item
