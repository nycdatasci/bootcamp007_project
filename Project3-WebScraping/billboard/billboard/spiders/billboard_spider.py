from scrapy import Spider
from scrapy.selector import Selector
from billboard.items import BillboardItem

class BillboardSpider(Spider):
    name = "billboard_spider"
    allowed_urls = ['http://www.billboard.com/']
    start_urls = ['http://www.billboard.com/charts/hot-100']

    def parse(self, response):
        rows = response.xpath('//*[@id="main"]/div[4]/div/div[1]/article | //*[@id="main"]/div[4]/div/div[2]/article').extract()
        #rows_2 = response.xpath('//*[@id="main"]/div[4]/div/div[2]/article').extract()

        for i in range(0, len(rows)):
            current_week = Selector(text=rows[i]).xpath('//div[1]/div[2]/div[1]/span[1]/text() | //div[1]/div[3]/div[1]/span[1]/text() | //div[1]/div[4]/div[1]/span[1]/text() | //div[1]/div[5]/div[1]/span[1]/text()').extract()
            song = Selector(text=rows[i]).xpath('//div[1]/div[2]/div[3]/div/h2/text() | //div[1]/div[3]/div[3]/div/h2/text() | //div[1]/div[4]/div[3]/div/h2/text() | //div[1]/div[5]/div[3]/div/h2/text()').extract()
            artist = Selector(text=rows[i]).xpath('//div[1]/div[2]/div[3]/div/a/text() | //div[1]/div[3]/div[3]/div/a/text() | //div[1]/div[4]/div[3]/div/a/text() | //div[1]/div[5]/div[3]/div/a/text()').extract()
            last_week = Selector(text=rows[i]).xpath('//div/div[1]/span[2]/text()').extract()
            peak_position = Selector(text=rows[i]).xpath('//div/div[2]/span[2]/text()').extract()
            wks_on_chart = Selector(text=rows[i]).xpath('//div/div[3]/span[2]/text()').extract()


            item = BillboardItem()
            item['current_week'] = current_week
            item['song'] = song
            item['artist'] = artist
            item['last_week'] = last_week
            item['peak_position'] = peak_position
            item['wks_on_chart'] = wks_on_chart

            yield item
















