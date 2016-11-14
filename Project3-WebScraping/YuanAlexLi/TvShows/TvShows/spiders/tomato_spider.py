import scrapy
import json
import urllib2
from scrapy import Selector
from TvShows.items import TomatoItem

# scrapy crawl tvshows_spider -o tvnames.json

class TvUrlGenerator():
    def __init__(self):
        pass

    def extract_show_names(self):
        with open("tvnamesFF.json", "r") as js:
            shows = json.load(js)

        urls = []
        for s in shows:
            title = s["show_name"].strip().replace(" ", "_").replace("'", "_")
            title_utf = urllib2.quote(title.encode('utf-8'))
            tomato_search_address = "https://www.rottentomatoes.com/tv/" + title_utf
            urls.append(tomato_search_address)

        return urls


class TomatoSpider(scrapy.Spider):
    name = "tomato_spider"
    allowed_domains = ["www.rottentomatoes.com"]

    def start_requests(self):
        start_url = TvUrlGenerator().extract_show_names()
        for url in start_url:
            yield scrapy.Request(url=url, callback=self.parse)

    def parse_season_page(self, response):
        item = TomatoItem()

        try:
            tomatometer = response.xpath('//*[@id="tomato_meter_link"]/span[2]/span/text()').extract()[0]
        except:
            tomatometer = None
        item['tomatometer'] = tomatometer

        try:
            aud_score = response.xpath('//div[@class="meter-value"]/span/text()').extract()[0]
        except:
            aud_score = None
        item['aud_score'] = aud_score

        try:
            name_season = response.xpath('//*[@id="movie-title"]/text()').extract()[0]
        except:
            name_season = None
        item["name_season"] = name_season

        yield item

    def parse(self, response):

        season_list = response.xpath('//*[@id="seasonList"]').extract()

        season_hrefs = \
            Selector(text=season_list[0]).xpath('//*[@itemprop="season"]/div[@class="media-body"]/div/strong/a/@href').extract()

        for i in range(len(season_hrefs)):
            # item["num_episode"] = epi_list[i]
            request = scrapy.Request(url="https://www.rottentomatoes.com" + season_hrefs[i], callback=self.parse_season_page)
            # request.meta['item'] = item
            yield request

