# This package will contain the spiders of your Scrapy project
#
# Please refer to the documentation for information on how to create and manage
# your spiders.
#class Major_Nelson_Blog_BC_List_Spider(scrapy.Spider):
import scrapy
from scrapy.selector import Selector
# from scrapy.http import Request
from XboxBC.items import Xbox360_MS_Site_Item
import re

class Xbox360_MS_Site(scrapy.Spider):
    name = "Xbox360_MS_Site"
    allowed_domains = ["marketplace.xbox.com"]

    start_urls = (
        'http://marketplace.xbox.com/en-US/Games/GamesOnDemand?SortBy=BestSelling&PageSize=90&Page=1',
    )
    def parse(self, response):
        base_link = 'http://marketplace.xbox.com'
        rows_in_big_table = response.xpath('//*[@id="BodyContent"]/div[3]/ol/li[1]/h2/a')
        for i, onerow in enumerate(rows_in_big_table):
            x360_item = Xbox360_MS_Site_Item()

            gameName = onerow.xpath('').extract()[0]
            gamesOnDemandorArcade = onerow.xpath('').extract()[0]
            gameUrl = onerow.xpath('').extract()[0]
            developer = onerow.xpath('').extract()[0]
            publisher = onerow.xpath('').extract()[0]
            genre = onerow.xpath('').extract()[0]
            highresboxart = onerow.xpath('').extract()[0]
            features = onerow.xpath('').extract()[0]
            onlineFeatures = onerow.xpath('').extract()[0]
            price = onerow.xpath('').extract()[0]
            dayRecorded = onerow.xpath('').extract()[0]
            releaseDate = onerow.xpath('').extract()[0]
            ESRBRating = onerow.xpath('').extract()[0]
            xboxRating = onerow.xpath('').extract()[0]
            # Number of Reviews
            smartglass = onerow.xpath('').extract()[0]
            # Avatar Items
            demos = onerow.xpath('').extract()[0]
            # Game Videos
            # Game Addons
            themes = onerow.xpath('').extract()[0]
            # Gamer Pictures
            # Content Links

            print "=" * 50
            print(gameName)
            print(gamesOnDemandorArcade)
            print(gameUrl)
            print(developer)
            print(publisher)
            print(genre)
            print(highresboxart)
            print(features)
            print(onlineFeatures)
            print(price)
            print(dayRecorded)
            print(releaseDate)
            print(ESRBRating)
            print(xboxRating)
            # print(Number of Reviews)
            print(smartglass)
            # print(Avatar Items)
            print(demos)
            # print(Game Videos)
            # print(Game Addons)
            print(themes)
            # print(Gamer Pictures)
            # print(Content Links)



            x360_item['gameName'] = gameName
            x360_item['gamesOnDemandorArcade'] = gamesOnDemandorArcade
            x360_item['gameUrl'] = gameUrl
            x360_item['developer'] = developer
            x360_item['publisher'] = publisher
            x360_item['genre'] = genre
            x360_item['highresboxart'] = highresboxart
            x360_item['features'] = features
            x360_item['onlineFeatures'] = onlineFeatures
            x360_item['price'] = price
            x360_item['dayRecorded'] = dayRecorded
            x360_item['releaseDate'] = releaseDate
            x360_item['ESRBRating'] = ESRBRating
            x360_item['xboxRating'] = xboxRating
            # x360_item['Number of Reviews'] =
            x360_item['smartglass'] = smartglass
            # x360_item['Avatar Items'] =
            x360_item['demos'] = demos
            # x360_item['Game Videos'] =
            # x360_item['Game Addons'] =
            x360_item['themes'] = themes
            # x360_item['Gamer Pictures'] =
            # x360_item['Content Links'] =
            yield x360_item
            print "=" * 50
