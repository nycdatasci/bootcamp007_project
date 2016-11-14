import scrapy
import urllib2
import pandas as pd
import re
from scrapy import Selector
from TvShows.items import Tmt2Item

class TvUrlGenerator():
    def __init__(self):
        pass

    def extract_show_names(self):
        with open("showname_reduced.csv", "r") as f:
            shownames = pd.read_csv(f)

        urls = []
        for row in shownames.iterrows():
            title = row[1][0].strip().replace(" ", "_").replace("'", "_")
            title_utf = urllib2.quote(title.encode('utf-8'))
            tomato_search_address = "https://www.rottentomatoes.com/tv/" + title_utf
            urls.append(tomato_search_address)

        return urls

class Tmt2Spider(scrapy.Spider):
    name = "tmt2_spider"
    allowed_domains = ["www.rottentomatoes.com"]

    def start_requests(self):
        start_url = TvUrlGenerator().extract_show_names()
        for url in start_url:
            yield scrapy.Request(url=url, callback=self.parse)

    def parse(self, response):
        item = Tmt2Item()

        season_list = response.xpath('//*[@id="seasonList"]').extract()

        try:
            show_name = \
                re.search(r"(.*):", Selector(text=season_list[0]).xpath('//*[@itemprop="season"]/div[@class="media-body"]'
                                                                        '/div/strong/a/text()').extract()[0]).groups()[0]
        except:
            show_name = None
        item['show_name'] = show_name

        try:
            avg_aud_score = \
                response.xpath('//*[@id="scorePanel"]/div/div[2]/div/div/div[2]/div[1]/span/text()').extract()[0].rstrip("%")
        except:
            avg_aud_score = None
        item['avg_aud_score'] = avg_aud_score

        yield item
