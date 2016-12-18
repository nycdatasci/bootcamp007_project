# This package will contain the spiders of your Scrapy project
#
# Please refer to the documentation for information on how to create and manage
# your spiders.
#class Major_Nelson_Blog_BC_List_Spider(scrapy.Spider):
import scrapy
from scrapy.selector import Selector
# from scrapy.http import Request
from XboxBC.items import RemastersItem
import re

class Remasters(scrapy.Spider):
    name = "Remasters"
    allowed_domains = ["gameinformer.com"]

    start_urls = (
        'http://www.gameinformer.com/themes/blogs/generic/post.aspx?WeblogApp=features&y=2016&m=05&d=16&WeblogPostName=definitive-evolving-list-new-gen-remaster-hd-remake-&PostPageIndex=1',
    )
    def parse(self, response):
        base_link = 'http://www.gameinformer.com'
        print "=" * 50

        # numberOfPages = response.xpath('//*[@id="next"]')
        numberOfPages = int(response.xpath('//*[@id="divRenderBody"]/div/@rel').extract()[0])
        print "=" * 50
        for j in range(1,numberOfPages+1):
            next_page = 'http://www.gameinformer.com/themes/blogs/generic/post.aspx?WeblogApp=features&y=2016&m=05&d=16&WeblogPostName=definitive-evolving-list-new-gen-remaster-hd-remake-&PostPageIndex=' + str(j)
            print("Page" + str(j))
            yield scrapy.Request(next_page, callback=self.remasterFind)

    def remasterFind(self, response):
            gameNames = response.xpath('//*[@id="divRenderBody"]/div[1]/div/p/strong/text()').extract()
            print(range(0,len(gameNames)))
            for i in range(0,len(gameNames)):
                remasterItem = RemastersItem()
                gameName = gameNames[i]
            # # #     votes = ''.join(re.findall('\d+',onerow.xpath('div[2]/div[1]/strong/text()').extract()[0]))
            # # #     comments = ''.join(re.findall('\d+',onerow.xpath('div[3]/a/text()').extract()[0]))
            # # #     in_progress = onerow.xpath('article/div[1]/a/em/text()').extract()
            # # #     # /html/body/div[2]/div/div/div[1]/article/section[3]/ol/li[6]/article/div[1]/a/em
                print(gameName)
            # # #     print(votes)
            # # #     print(comments)
            # # #     print(in_progress)
            # # #
                remasterItem['gameName'] = gameName
            # # #     user_voice_item['comments'] = comments
            # # #     user_voice_item['votes'] = votes
            # # #     user_voice_item['in_progress'] = in_progress
                print "=" * 50
                yield remasterItem
