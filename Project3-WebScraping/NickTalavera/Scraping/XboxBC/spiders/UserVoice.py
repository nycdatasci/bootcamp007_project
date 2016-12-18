import scrapy
from scrapy.selector import Selector
from XboxBC.items import UserVoiceItem
import re

class UserVoice(scrapy.Spider):
    name = "UserVoice"
    allowed_domains = ["xbox.uservoice.com"]
    start_urls = (
    'https://xbox.uservoice.com/forums/298503-backwards-compatibility?filter=top&page=1',
    'https://xbox.uservoice.com/forums/298503-backwards-compatibility/status/1222799?page=1',
    'https://xbox.uservoice.com/forums/298503-backwards-compatibility/status/1222800?page=1'
    )

    def parse(self, response):
        base_link = 'http://www.xbox.uservoice.com'
        numberOfPages = int(response.xpath("/html/body/div[2]/div/div/div[1]/article/section[3]/div[2]/a/text()")[-2].extract())
        for j in range(1,numberOfPages+1):
            next_page = str(response.request.url)[0:len(response.request.url)-1] + str(j)
            yield scrapy.Request(next_page, callback=self.userVoiceFind)

    def userVoiceFind(self, response):
        rows_in_big_table = response.xpath("/html/body/div[2]/div/div/div[1]/article/section[3]/ol/li")
        for i, onerow in enumerate(rows_in_big_table):
            user_voice_item = UserVoiceItem()
            gameName = onerow.xpath('div[1]/h2/a/text()')
            if len(gameName) != 0:
                gameName = gameName[0].extract()
            votes = onerow.xpath('div[2]/div[1]/strong/text()')
            if len(votes) != 0:
                votes = ''.join(re.findall('\d+',votes[0].extract()))
            comments = onerow.xpath('div[3]/a/text()')
            if len(comments) != 0:
                comments = ''.join(re.findall('\d+',comments[0].extract()))
            in_progress = onerow.xpath('article/div[1]/a/em/text()')
            if len(in_progress) != 0:
                in_progress = in_progress[0].extract()
            user_voice_item['gameName'] = gameName
            user_voice_item['comments'] = comments
            user_voice_item['votes'] = votes
            user_voice_item['in_progress'] = in_progress
            yield user_voice_item
