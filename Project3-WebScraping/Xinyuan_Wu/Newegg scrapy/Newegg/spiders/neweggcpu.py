from scrapy import Spider
from scrapy.http import Request
from scrapy.selector import Selector
from Newegg.items import scrapeCPU

class neweggcpu(Spider):
    name = "neweggcpu"
    allowed_domains = ["newegg.com"]
    start_urls = [
        "http://www.newegg.com/Processors-Desktops/SubCategory/ID-343/Page-%s?PageSize=36&order=BESTSELLING"
        % page for page in xrange(1, 2)
    ]
    rank = 1
    def parse(self, response):
        products = response.xpath('//div[@class = "item-container "]')
        for product in products:
            item = scrapeCPU()
            item['rank'] = self.rank
            item['url'] = product.xpath('div[@class = "item-info"]/a/@href').extract()[0]
            productname = product.xpath('div[@class = "item-info"]/a/text()').extract()[0]
            if 'Refurbished' in productname or 'Open Box' in productname:
                continue
            self.rank += 1
            item['productname'] = productname
            prevprice = product.xpath('div[@class = "item-info"]/div[@class = "item-action"]/ul/li[@class = "price-was"]/span/text()').extract()
            intprice = product.xpath('div[@class = "item-info"]/div[@class = "item-action"]/ul/li[@class = "price-current"]/strong/text()').extract()
            centprice = product.xpath('div[@class = "item-info"]/div[@class = "item-action"]/ul/li[@class = "price-current"]/sup/text()').extract()
            # if price isnt found, skip the item.
            if not intprice:
                item['price'] = prevprice[0]
            else:
                item['price'] = intprice[0] + centprice[0]
            rating = product.xpath('div[@class = "item-info"]/div[@class = "item-branding"]/a/@title').extract()
            if rating == []:
                item['rating'] = 'no rating'
            else:
                item['rating'] = rating[0]
            url = product.xpath('div[@class = "item-info"]/a/@href').extract()[0]
            request = Request(url, callback = self.productpage)
            request.meta['item'] = item
            yield request

    def productpage(self, response):
        specs = response.xpath('//div[@id = "Specs"]/fieldset')
        itemdict = {}
        for i in specs:
            # print '++++++++++++++++++++++++++++++++++++++++++++++++'
            # print specs.extract()
            # print '++++++++++++++++++++++++++++++++++++++++++++++++'
            test = i.xpath('dl')
            for t in test:
                # print '================================================================'
                # print t.xpath('dt/text()').extract()
                # print '================================================================'
                name = t.xpath('dt/text()').extract()
                if name == []:
                    name = t.xpath('dt/a/text()').extract()
                itemdict[name[0]] = t.xpath('dd/text()').extract()[0]
        # print '================================================================'
        # print itemdict
        # print '================================================================'
        item = response.meta['item']
        # rating = response.xpath('//a[@name = "Community"]/i/@title').extract()
        # if rating == []:
        #     item['rating'] = None
        # else:
        #   item['rating'] = rating[0]
        item['brand'] = itemdict.get('Brand', None)
        item['series'] = itemdict.get('Series', None)
        item['name'] = itemdict.get('Name', None)
        item['freq'] = itemdict.get('Operating Frequency', None)
        item['l2cache'] = itemdict.get('L2 Cache', None)
        item['l3cache'] = itemdict.get('L3 Cache', None)
        item['core'] = str(itemdict.get('# of Cores', None)).replace("-Core", "").replace("Dual", "2").replace("Quad", "4")
        item['socket'] = str(itemdict.get('CPU Socket Type', None)).replace("Socket", "").strip()
        item['power'] = itemdict.get('Thermal Design Power', None)
        item['corename'] = itemdict.get('Core Name', None)
        yield item