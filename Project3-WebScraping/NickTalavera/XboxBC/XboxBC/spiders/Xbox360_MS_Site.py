# This package will contain the spiders of your Scrapy project
#
# Please refer to the documentation for information on how to create and manage
# your spiders.
#class Major_Nelson_Blog_BC_List_Spider(scrapy.Spider):
import scrapy
from scrapy.selector import Selector
# from scrapy.http import Request
from XboxBC.items import Xbox360_MS_Site_Item
from XboxBC.pipelines import XboxbcPipeline
import re
import math
import datetime
import time

class Xbox360_MS_Site(scrapy.Spider):
    name = "Xbox360_MS_Site"
    allowed_domains = ['marketplace.xbox.com']

    start_urls = (
        'http://marketplace.xbox.com/en-US/Games/GamesOnDemand?pagesize=90&sortby=BestSelling&Page=1',
    )

    def parse(self, response):
        print "=" * 50
        numberOfPages = response.xpath('//*[@id="BodyContent"]/div[3]/div[2]/div[1]/text()').extract()[0]
        numberOfPages = re.findall('[0-9.]+',numberOfPages)[-1]
        numberOfPages = int(math.ceil(float(re.findall("[0-9]+", numberOfPages)[-1])/90))
        # for j in range(1,numberOfPages+1):
        for j in range(1,2):
            next_page = 'http://marketplace.xbox.com/en-US/Games/GamesOnDemand?pagesize=90&sortby=BestSelling&Page=' + str(j)
            print("Page" + str(j))
            print(next_page)
            yield scrapy.Request(next_page, callback=self.xbPageFind)


    def xbPageFind(self, response):
        baseURL = "http://marketplace.xbox.com"
        rows_in_big_table = response.xpath('//*[@id="BodyContent"]/div[3]/ol/li')
        # print(rows_in_big_table.extract())
        #
        for i, onerow in enumerate(rows_in_big_table):
            xOne_item = Xbox360_MS_Site_Item()
            gameName = onerow.xpath('h2/a/text()').extract()[0]
            gameName = re.sub(r'[^\x00-\x7F]+', '', gameName)
            gameUrl = baseURL + onerow.xpath('h2/a/@href').extract()[0]
            dayRecorded = time.strftime("%x")
            xOne_item['gameName'] = gameName
            xOne_item['gamesOnDemandorArcade'] = response.xpath('//*[@id="BodyContent"]/div[1]/h1/text()').extract()[0]
            xOne_item['gameUrl'] = gameUrl
            xOne_item['dayRecorded'] = dayRecorded
            if gameUrl:
                    yield scrapy.Request(url=gameUrl, callback=self.scrapeIndividualGames, meta={'xOne_item': xOne_item})


    def scrapeIndividualGames(self, response):
        xOne_item = response.meta['xOne_item']
        developer = response.xpath('//*[@id="ProductPublishing"]/li[3]/text()').extract()[0].strip()
        publisher = response.xpath('//*[@id="ProductPublishing"]/li[2]/text()').extract()[0].strip()
        genre = response.xpath('//*[@id="ProductPublishing"]/li[4]/text()').extract()[0].strip()
        features = response.xpath('//*[@id="overview2"]/div[2]/div/div[1]/ul').extract()[0]
        onlineFeatures = response.xpath('//*[@id="overview2"]/div[2]/div/div[2]/ul').extract()
        if len(onlineFeatures) != 0:
            onlineFeatures = onlineFeatures[0]
        price = response.xpath('//*[@id="GetProduct"]/a[2]/span/span/text()').extract()
        if len(price) != 0:
            price = price[0]
        releaseDate = response.xpath('//*[@id="ProductPublishing"]/li[1]/text()').extract()[0].strip()
        priceGold = ""
        highresboxart = response.xpath('//*[@id="overview1"]/div[1]/img/@src').extract()[0]
        ESRBRating = response.xpath('//*[@id="ActualRating"]/text()').extract()[1].strip()
        xboxRatingStars = response.xpath('//*[@id="ProductTitleZone"]/div[2]/div/span/@class').extract()
        xboxRating = 0
        for start in xboxRatingStars:
            xboxRating += float(re.findall('[0-9.]+', start)[0])/4
        numberOfReviews = response.xpath('//*[@id="ProductTitleZone"]/div[2]/span/text()').extract()[0].strip()

        DLlist = response.xpath('//*[@id="navDownloadType"]/li/a/text()').extract()
        DLdemos = ""
        DLgameVideos = ""
        DLavatarItems = ""
        DLthemes = ""
        DLgamerPictures = ""
        DLgameAddons = ""
        DLsmartglass = ""
        for phrase in DLlist:
            if 'Game Demos' in phrase:
                DLdemos = re.findall('[0-9.]+',phrase)[0]
            elif 'Game Videos' in phrase:
                DLgameVideos = re.findall('[0-9.]+',phrase)[0]
            elif 'Game Add-ons' in phrase:
                DLgameAddons = re.findall('[0-9.]+',phrase)[0]
            elif 'Themes' in phrase:
                DLthemes = re.findall('[0-9.]+',phrase)[0]
            elif 'Gamer Pictures' in phrase:
                DLgamerPictures = re.findall('[0-9.]+',phrase)[0]
            elif 'Avatar Items' in phrase:
                DLavatarItems = re.findall('[0-9.]+',phrase)[0]
            elif 'Xbox SmartGlass' in phrase:
                DLsmartglass = re.findall('[0-9.]+',phrase)[0]

        xOne_item['developer'] = developer
        xOne_item['publisher'] = publisher
        xOne_item['genre'] = genre
        xOne_item['features'] = features
        xOne_item['onlineFeatures'] = onlineFeatures
        xOne_item['price'] = price
        xOne_item['priceGold'] = priceGold
        xOne_item['highresboxart'] = highresboxart
        xOne_item['ESRBRating'] = ESRBRating
        xOne_item['xbox360Rating'] = xboxRating
        xOne_item['numberOfReviews'] = numberOfReviews
        xOne_item['DLsmartglass'] = DLsmartglass
        xOne_item['DLavatarItems'] = DLavatarItems
        xOne_item['DLdemos'] = DLdemos
        xOne_item['DLgameVideos'] = DLgameVideos
        xOne_item['DLgameAddons'] = DLgameAddons
        xOne_item['DLthemes'] = DLthemes
        xOne_item['DLgamerPictures'] = DLgamerPictures
        yield xOne_item
