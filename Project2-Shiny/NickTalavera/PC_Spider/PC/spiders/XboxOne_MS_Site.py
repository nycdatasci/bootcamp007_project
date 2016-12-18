# This package will contain the spiders of your Scrapy project
#
# Please refer to the documentation for information on how to create and manage
# your spiders.
#class Major_Nelson_Blog_BC_List_Spider(scrapy.Spider):
import scrapy
from scrapy.selector import Selector
# from scrapy.http import Request
from XboxBC.items import XboxOne_MS_Site_Item
import re
import math
import datetime
import time

class XboxOne_MS_Site(scrapy.Spider):
    name = "XboxOne_MS_Site"
    allowed_domains = ['microsoft.com']

    start_urls = (
        'https://www.microsoft.com/en-us/store/top-paid/games/xbox?s=store&skipitems=0',
    )

    def parse(self, response):
        print "=" * 50
        numberOfPages = response.xpath('//*[@id="productPlacementList"]/div/p[1]/small/text()').extract()[0]
        numberOfPages = int(math.floor(float(re.findall("[0-9]+", numberOfPages)[-1])/90))
        
        print "=" * 50
        for j in range(0,numberOfPages+1):
        # for j in range(0,1):
            next_page = 'https://www.microsoft.com/en-us/store/top-paid/games/xbox?s=store&skipitems=' + str(j*90)
            print(next_page)
            print("Page" + str(j))
            yield scrapy.Request(next_page, callback=self.xbPageFind)


    def xbPageFind(self, response):
        baseURL = "https://www.microsoft.com"
        rows_in_big_table = response.xpath('//*[@id="productPlacementList"]/div/div/section/a')
        # //*[@id="productPlacementList"]/div/div/section[5]/a/div[2]/h3
        for i, onerow in enumerate(rows_in_big_table):
            # if i % 2 == 0:
            #     continue
            xOne_item = XboxOne_MS_Site_Item()

            gameName = onerow.xpath('div/h3/text()').extract()[0]
            #     gamesOnDemandorArcade = onerow.xpath('').extract()[0]
            gameUrl = onerow.xpath('@href')
            if len(gameUrl) != 0:
                gameUrl = gameUrl[0].extract().strip()
                gameUrl = baseURL + gameUrl
            price = onerow.xpath('div[2]/div[2]/span/text()')
            if len(price) == 0:
                price = onerow.xpath('div[2]/div[2]/span[1]/s/text()')
            if len(price) != 0:
                price = price[0].extract().strip()
            priceGold = onerow.xpath('div[2]/div[2]/span[1]/span[2]/text()').extract()#div[2]/div[2]/span[1]/span[2]
            if len(priceGold) > 0:
                priceGold = priceGold[0]
            today = datetime.date.today()
            dayRecorded = time.strftime("%x")
            #     releaseDate = onerow.xpath('').extract()[0]
            #     ESRBRating = onerow.xpath('').extract()[0]
            xboxRating = onerow.xpath('div[2]/div[1]/p/span[1]/text()').extract()[0]
            #     # Number of Reviews
            #     smartglass = onerow.xpath('').extract()[0]
            #     # Avatar Items
            #     demos = onerow.xpath('').extract()[0]
            #     # Game Videos
            #     # Game Addons
            #     themes = onerow.xpath('').extract()[0]
            #     # Gamer Pictures
            #     # Content Links
            #
            print(gameName)
            #     print(gamesOnDemandorArcade)

            print(gameUrl)
            #     print(developer)
            #     print(publisher)
            #     print(genre)
            #     print(highresboxart)
            #     print(features)
            #     print(onlineFeatures)
            print(price)
            print(priceGold)
            print(dayRecorded)
            #     print(releaseDate)
            #     print(ESRBRating)
            print(xboxRating)
            #     # print(Number of Reviews)
            #     print(smartglass)
            #     # print(Avatar Items)
            #     print(demos)
            #     # print(Game Videos)
            #     # print(Game Addons)
            #     print(themes)
            #     # print(Gamer Pictures)
            #     # print(Content Links)
            #
            #
            #
            xOne_item['gameName'] = gameName
            #     xOne_item['gamesOnDemandorArcade'] = gamesOnDemandorArcade
            xOne_item['gameUrl'] = gameUrl
            #     xOne_item['developer'] = developer
            #     xOne_item['publisher'] = publisher
            #     xOne_item['genre'] = genre
            #     xOne_item['highresboxart'] = highresboxart
            #     xOne_item['features'] = features
            #     xOne_item['onlineFeatures'] = onlineFeatures
            xOne_item['price'] = price
            xOne_item['priceGold'] = priceGold
            xOne_item['dayRecorded'] = dayRecorded
            #     xOne_item['releaseDate'] = releaseDate
            #     xOne_item['ESRBRating'] = ESRBRating
            xOne_item['xboxRating'] = xboxRating
            #     # xOne_item['Number of Reviews'] =
            #     xOne_item['smartglass'] = smartglass
            #     # xOne_item['Avatar Items'] =
            #     xOne_item['demos'] = demos
            #     # xOne_item['Game Videos'] =
            #     # xOne_item['Game Addons'] =
            #     xOne_item['themes'] = themes
            #     # xOne_item['Gamer Pictures'] =
            #     # xOne_item['Content Links'] =
            yield xOne_item
            print "=" * 50
