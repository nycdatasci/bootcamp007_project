# -*- coding: utf-8 -*-
import csv
import logging
from scrapy import Spider, Request
from scrapy.selector import Selector
from wiki.items import WikiItem

pantheon_file = "../data/pantheon.tsv"


class WikiSpider(Spider):
    """
    A spider to scrape info about a historical figure on wikipedia
    """

    start_urls = ["https://en.wikipedia.org/?curid=11015252"]

    def start_requests(self):
        """Pull wiki pages from the pantheon data set"""

        # Iterate over curid"
        with open(pantheon_file, 'r') as f:
            reader = csv.reader(f, delimiter='\t')
            next(reader, None)  # skip the header
            for row in reader:
                curid = row[0]
                url = 'https://en.wikipedia.org/?curid={}'.format(curid)
                yield Request(url, self.parse, meta={'curid': curid})

    name = 'wiki_spider'
    allowed_urls = ['https://en.wikipedia.org/']

    def parse(self, response):
        """Parse the wikipedia page of a historical figure"""

        # Extract the figure's image, birth and death date
        info_box = Selector(text=response.css('.infobox').extract_first())
        image_url = info_box.xpath('//a[@class="image"]//@src').extract_first()
        image_url = "https:" + image_url
        death_date = info_box.xpath('//*[@class="dday deathdate"]//text()').extract_first()
        death_date_raw = info_box.select("//th[contains(text(), 'Died')]/following-sibling::td/text()").extract_first()
        birth_date = info_box.xpath('//*[@class="bday"]//text()').extract_first()
        birth_date_raw = info_box.select("//th[contains(text(), 'Born')]/following-sibling::td/text()").extract_first()

        # Create the wiki item
        wiki_item = WikiItem()
        wiki_item["image_url"] = image_url
        wiki_item["death_date"] = death_date
        wiki_item["death_date_raw"] = death_date_raw
        wiki_item["birth_date"] = birth_date
        wiki_item["birth_date_raw"] = birth_date_raw
        wiki_item["curid"] = response.meta['curid']

        yield wiki_item
