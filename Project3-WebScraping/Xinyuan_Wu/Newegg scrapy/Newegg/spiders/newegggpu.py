from scrapy import Spider
from scrapy.http import Request
from scrapy.selector import Selector
from Newegg.items import scrapeGPU

class newegggpu(Spider):
    name = "newegggpu"
    allowed_domains = ["newegg.com"]
    rank = 1

    def start_requests(self):
        start_urls = [
            "http://www.newegg.com/Desktop-Graphics-Cards/SubCategory/ID-48/Page-%s?Tid=7709&PageSize=36&order=BESTSELLING"
            % page for page in xrange(1, 16)
        ]
        for url in start_urls:
            yield Request(url = url, callback = self.parse)

    def parse(self, response):
        products = response.xpath('//div[@class = "item-container "]')
        for product in products:
            item = scrapeGPU()
            item['rank'] = self.rank
            item['url'] = product.xpath('div[@class = "item-info"]/a/@href').extract()[0]
            productname = product.xpath('div[@class = "item-info"]/a/text()').extract()[0]
            if 'Refurbished' in productname or 'Open Box' in productname:
                continue
            item['productname'] = productname
            try:
                prevprice = product.xpath('div[@class = "item-info"]/div[@class = "item-action"]/ul/li[@class = "price-was"]/span/text()').extract()[0]
            except Exception as e:
                prevprice = None
            intprice = product.xpath('div[@class = "item-info"]/div[@class = "item-action"]/ul/li[@class = "price-current"]/strong/text()').extract()
            centprice = product.xpath('div[@class = "item-info"]/div[@class = "item-action"]/ul/li[@class = "price-current"]/sup/text()').extract()

            if not intprice:
                item['price'] = prevprice
            else:
                item['price'] = intprice[0] + centprice[0]
            rating = product.xpath('//div[@class = "item-info"]/div[@class = "item-branding"]/a/@title').extract()
            if rating == []:
                item['rating'] = 'no rating'
            else:
                item['rating'] = rating[0]
            url = product.xpath('div[@class = "item-info"]/a/@href').extract()[0]
            request = Request(url, callback = self.productpage)
            request.meta['item'] = item
            self.rank += 1
            yield request

    def productpage(self, response):
        try:
            specs = response.xpath('//div[@id = "Specs"]/fieldset')
        except Exception as e:
            yield None
        itemdict = {}
        for i in specs:
            test = i.xpath('dl')
            for t in test:
                name = t.xpath('dt/text()').extract()
                if name == []:
                    name = t.xpath('dt/a/text()').extract()
                itemdict[name[0]] = t.xpath('dd/text()').extract()[0]
        item = response.meta['item']
        item['brand'] = itemdict.get('Brand', None)
        item['model'] = itemdict.get('Model', None)
        item['chipmake'] = itemdict.get('Chipset Manufacturer', None)
        item['gpu'] = itemdict.get('GPU', None)
        item['coreclock'] = itemdict.get('Core Clock', None)
        item['boostclock'] = itemdict.get('Boost Clock', None)
        item['memoryclock'] = itemdict.get('Effective Memory Clock', None)
        item['memorysize'] = itemdict.get('Memory Size', None)
        item['memoryinterface'] = itemdict.get('Memory Interface', None)
        item['memorytype'] = itemdict.get('Memory Type', None)
        yield item