import scrapy, re, math, datetime, time
from scrapy.selector import Selector
from XboxBC.items import Xbox360_MS_Site_Item
from XboxBC.pipelines import XboxbcPipeline

class Xbox360_MS_Site(scrapy.Spider):
    name = "Xbox360_MS_Site"
    allowed_domains = ['marketplace.xbox.com']
    start_urls = (
        'http://marketplace.xbox.com/en-US/Games/XboxArcadeGames?SortBy=BestSelling&PageSize=90&Page=1',
        'http://marketplace.xbox.com/en-US/Games/GamesOnDemand?pagesize=90&sortby=BestSelling&Page=1',
        'https://marketplace.xbox.com/en-US/Games/Xbox360Games?pagesize=90&sortby=BestSelling&page=1',
    )

    def parse(self, response):
        numberOfPages = response.xpath('//*[@id="BodyContent"]/div[3]/div[2]/div[1]/text()').extract()[0]
        numberOfPages = re.sub(",","",numberOfPages)
        numberOfPages = re.findall('[0-9.]+',numberOfPages)[-1]
        numberOfPages = int(math.ceil(float(re.findall("[0-9]+", numberOfPages)[-1])/90))
        for j in range(1,numberOfPages+1):
            next_page = str(response.request.url)[0:len(response.request.url)-1] + str(j)
            yield scrapy.Request(next_page, callback=self.xbPageFind)

    def xbPageFind(self, response):
        baseURL = "http://marketplace.xbox.com"
        rows_in_big_table = response.xpath('//*[@id="BodyContent"]/div[3]/ol/li')
        for i, onerow in enumerate(rows_in_big_table):
            xOne_item = Xbox360_MS_Site_Item()
            gameName = onerow.xpath('h2/a/text()').extract()[0].strip()
            gameName = re.sub(r'[^\x00-\x7F]+', '', gameName)
            gameUrl = baseURL + onerow.xpath('h2/a/@href').extract()[0] + '?PageSize=60&Page=1&SortBy=BestSelling'
            dayRecorded = time.strftime("%x")
            xOne_item['gameName'] = gameName
            xOne_item['gamesOnDemandorArcade'] = response.xpath('//*[@id="BodyContent"]/div[1]/h1/text()').extract()[0]
            xOne_item['gameUrl'] = gameUrl
            xOne_item['dayRecorded'] = dayRecorded
            if gameUrl:
                    yield scrapy.Request(url=(gameUrl), callback=self.scrapeIndividualGames, meta={'xOne_item': xOne_item})

    def scrapeIndividualGames(self, response):
        xOne_item = response.meta['xOne_item']
        DLlist = response.xpath('//*[@id="navDownloadType"]/li/a/text()').extract()
        gameCount = ""
        DLdemos = ""
        DLgameVideos = ""
        DLavatarItems = ""
        DLthemes = ""
        DLgamerPictures = ""
        DLgameAddons = ""
        DLsmartglass = ""
        gameNameLong = ""
        for phrase in DLlist:
            if 'Games ' in phrase:
                gameCount = int(re.findall('[0-9.]+',phrase)[0])
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
        if gameCount > 0:
            priceGold = response.xpath('//*[@id="LiveZone"]/div[2]/ol/li/div/div[2]/span/span[1]/text()').extract()
            if len(priceGold) != 0:
                priceGold = priceGold[0].strip().lstrip("$")
            gameNameLong = response.xpath('//*[@id="LiveZone"]/div[2]/ol/li/div/div[1]/h2/text()').extract()
            if len(gameNameLong) != 0:
                gameNameLong = gameNameLong[0].strip()
                gameNameLong = re.sub("Full Game - ","",gameNameLong)
                if len(xOne_item['gameName']) < len(gameNameLong):
                    xOne_item['gameName'] = gameNameLong
            if len(gameNameLong) == 0:
                gameNameLong = response.xpath('//*[@id="LiveZone"]/div[2]/ol/li/div/div/h2/text()').extract()
                gameNameLong = map(str.strip, map(str, gameNameLong))
        if 'E3 2' in xOne_item['gameName'] or 'trial game' in xOne_item['gameName'].lower() or ' pics' in xOne_item['gameName'].lower() or ' theme' in xOne_item['gameName'].lower():
            return
        ProductPublishing = response.xpath('//*[@id="ProductPublishing"]')
        Overview1 = response.xpath('//*[@id="overview1"]')
        Overview2 = response.xpath('//*[@id="overview2"]')
        ProductTitleZone = response.xpath('//*[@id="ProductTitleZone"]')
        ProductPublishingCount = 1
        releaseDate = ProductPublishing.xpath('li[' + str(ProductPublishingCount) + ']/text()').extract()
        if len(releaseDate) != 0:
            releaseDate = releaseDate[0].strip()
            if releaseDate.replace("/", "").isdigit() == False:
                releaseDate = ""
            else:
                ProductPublishingCount = ProductPublishingCount + 1
        developer = ProductPublishing.xpath('li[' + str(ProductPublishingCount) + ']/text()').extract()
        if len(developer) != 0:
            developer = developer[0].strip()
            ProductPublishingCount = ProductPublishingCount + 1
        publisher = ProductPublishing.xpath('li[' + str(ProductPublishingCount) + ']/text()').extract()
        if len(publisher) != 0:
            publisher = publisher[0].strip()
            ProductPublishingCount = ProductPublishingCount + 1
        genre = ProductPublishing.xpath('li[' + str(ProductPublishingCount) + ']/text()').extract()
        if len(genre) != 0:
            genre = genre[0].strip()
        features = Overview2.xpath('div[2]/div/div[1]/ul').extract()
        if len(features) != 0:
            features = features[0]
        onlineFeatures = response.xpath('div[2]/div/div[2]/ul').extract()
        if len(onlineFeatures) != 0:
            onlineFeatures = onlineFeatures[0]
        price = response.xpath('//*[@id="GetProduct"]/a/span/span/text()').extract()
        if len(price) != 0:
            price = price[0].strip().lstrip("$")
            if price == "Free":
                price = 0
        highresboxart = Overview1.xpath('div[1]/img/@src').extract()
        if len(highresboxart) != 0:
            highresboxart = highresboxart[0].strip()
        ESRBRating = response.xpath('//*[@id="ActualRating"]/text()').extract()
        for i in ESRBRating:
            if len(i.strip()) != 0:
                ESRBRating = i.strip()
        xboxRatingStars = ProductTitleZone.xpath('div[2]/div/span/@class').extract()
        xboxRating = 0
        for start in xboxRatingStars:
            xboxRating += float(re.findall('[0-9.]+', start)[0])/4
        numberOfReviews = ProductTitleZone.xpath('div[2]/span/text()')
        if len(numberOfReviews) != 0:
            numberOfReviews = numberOfReviews.extract()[0].strip().strip(',')
        xOne_item['gameCount'] = gameCount
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
        xOne_item['releaseDate'] = releaseDate
        xOne_item['numberOfReviews'] = numberOfReviews
        xOne_item['DLsmartglass'] = DLsmartglass
        xOne_item['DLavatarItems'] = DLavatarItems
        xOne_item['DLdemos'] = DLdemos
        xOne_item['DLgameVideos'] = DLgameVideos
        xOne_item['DLgameAddons'] = DLgameAddons
        xOne_item['DLthemes'] = DLthemes
        xOne_item['DLgamerPictures'] = DLgamerPictures
        yield xOne_item
