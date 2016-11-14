import scrapy
from TvShows.items import TvshowsItem
from scrapy import Selector

# scrapy crawl tvshows_spider -o tvnames.json

class TvSpider(scrapy.Spider):
    name = "tvshows_spider"
    allowed_domains = ["themoviedb.org"]


    def start_requests(self):
        start_url = "https://www.themoviedb.org/tv?page="
        urls = [start_url + str(i) for i in range(1, 1001)]
        for url in urls:
            yield scrapy.Request(url=url, callback=self.parse)


    def parse(self, response):
        for href in response.xpath('//a[@class="title result"]/@href').extract():
            url = response.urljoin(href)
            yield scrapy.Request(url, callback=self.parse_listing_contents)

    def parse_listing_contents(self, response):
        item = TvshowsItem()
        item["show_name"] = \
            response.xpath('//*[@id="main"]/section/div[1]/div/section[1]/section/div[1]/h2/a/text()').extract()[0]
        item["status"] = \
            response.xpath('//*[@id="media_v4"]/section/div[1]/div/section[1]/p[1]/text()').extract()[0].strip()
        item["network"] = \
            response.xpath('//*[@id="media_v4"]/section/div[1]/div/section[1]/p[2]/a/text()').extract()[0]
        item["language"] = \
            response.xpath('//*[@id="media_v4"]/section/div[1]/div/section[1]/p[4]/text()').extract()[0].strip()
        item["tv_db_score"] = \
            response.xpath('//*[@id="main"]/section/div[1]/div/section[1]/section/div[1]/div/div/span[2]/text()').extract()[0].strip()


        genre_panel = response.xpath('//*[@id="media_v4"]/section/div[1]/div/section[2]').extract()
        i = 1
        genres = []
        while Selector(text=genre_panel[0]).xpath('//ul/li[' + str(i) + ']/a/text()').extract() != []:
            if genres == []:
                genres = \
                    Selector(text=genre_panel[0]).xpath('//ul/li[' + str(i) + ']/a/text()').extract()

            else:
                genres.append(Selector(text=genre_panel[0]).xpath('//ul/li[' + str(i) + ']/a/text()').extract()[0])
            i += 1
        item["genre"] = genres


        casts_panel = response.xpath('//*[@id="main"]/section/div[1]/div/section[2]/ol').extract()
        i = 1
        casts = []
        while Selector(text=casts_panel[0]).xpath('//li[' + str(i) + ']/p[1]/a/text()').extract() != []:

            if casts == []:
                casts = \
                    Selector(text=casts_panel[0]).xpath('//li[' + str(i) + ']/p[1]/a/text()').extract()

            else:
                casts.append(Selector(text=casts_panel[0]).xpath('//li[' + str(i) + ']/p[1]/a/text()').extract()[0])
            i += 1
        item["casts"] = casts

        yield item
