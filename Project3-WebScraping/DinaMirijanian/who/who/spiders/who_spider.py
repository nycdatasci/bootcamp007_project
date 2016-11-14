import scrapy
#import json
from who.items import whoItem
from scrapy.selector import Selector

class whospider(scrapy.Spider):
    name = "whospider"
    allowed_domains = ["who.int"]
    start_urls = (
        'http://www.who.int/countries/en/',
    )
    def parse(self, response):      
        largerbox = response.xpath('//div[@class="col_1-1-1_1"]/div[@class="largebox"]').extract()
        for a in range(len(largerbox)):
            cntry=Selector(text = largerbox[a]).xpath('//ul/li').extract()
            for b in range(len(cntry)): 
                page_url = Selector(text = cntry[b]).xpath('//a/@href').extract()[0]
#		print "=" * 50
#		print page_url 
                yield scrapy.Request("http://www.who.int/" + page_url,callback=self.parse_listing_results_page)

        largerbox = response.xpath('//div[@class="col_1-1-1_2"]/div[@class="largebox"]').extract()
        for a in range(len(largerbox)):
            cntry=Selector(text = largerbox[a]).xpath('//ul/li').extract()
            for b in range(len(cntry)):
                page_url = Selector(text = cntry[b]).xpath('//a/@href').extract()[0]
#               print "=" * 50
#               print page_url 
                yield scrapy.Request("http://www.who.int/" + page_url,callback=self.parse_listing_results_page)

        largerbox = response.xpath('//div[@class="col_1-1-1_3"]/div[@class="largebox"]').extract()
        for a in range(len(largerbox)):
            cntry=Selector(text = largerbox[a]).xpath('//ul/li').extract()
            for b in range(len(cntry)):
                page_url = Selector(text = cntry[b]).xpath('//a/@href').extract()[0]
#               print "=" * 50
#               print page_url 
                yield scrapy.Request("http://www.who.int/" + page_url,callback=self.parse_listing_results_page)




    def parse_listing_results_page(self, response):
        print "Succees"
        country = response.xpath('//*[@id="content"]/h1/text()').extract()
 	table = response.xpath('//div[@class="box"]/table[@class="tableData"]/tbody').extract()[0]
	if len(Selector(text=table).xpath('//tr[1]/td/text()').extract())> 0:
		total_population = Selector(text=table).xpath('//tr[1]/td/text()').extract()[0]
	else:
		total_population = Selector(text=table).xpath('//tr[1]/td/strong/text()').extract()[0]

	if len(Selector(text=table).xpath('//tr[2]/td/text()').extract())> 0:
                gnipc = Selector(text=table).xpath('//tr[2]/td/text()').extract()[0]
        else:
                gnipc = Selector(text=table).xpath('//tr[2]/td/strong/text()').extract()[0]

        if len(Selector(text=table).xpath('//tr[3]/td/text()').extract())> 0:
                life_ex_birth_mf = Selector(text=table).xpath('//tr[3]/td/text()').extract()[0]
        else:
                life_ex_birth_mf = Selector(text=table).xpath('//tr[3]/td/strong/text()').extract()[0]

	if len(Selector(text=table).xpath('//tr[4]/td/text()').extract())> 0:
                p_dying_five = Selector(text=table).xpath('//tr[4]/td/text()').extract()[0]
	else:
                p_dying_five = Selector(text=table).xpath('//tr[4]/td/strong/text()').extract()[0]

 	if len(Selector(text=table).xpath('//tr[5]/td/text()').extract())> 0:
                p_15_60_mf = Selector(text=table).xpath('//tr[5]/td/text()').extract()[0]
        else:
                p_15_60_mf = Selector(text=table).xpath('//tr[5]/td/strong/text()').extract()[0]

        if len(Selector(text=table).xpath('//tr[6]/td/text()').extract())> 0:
                health_per_capita = Selector(text=table).xpath('//tr[6]/td/text()').extract()[0]
        else:
                health_per_capita = Selector(text=table).xpath('//tr[6]/td/strong/text()').extract()[0]

        if len(Selector(text=table).xpath('//tr[7]/td/text()').extract())> 0:
                expend_health_GDP = Selector(text=table).xpath('//tr[7]/td/text()').extract()[0]
        else:
                expend_health_GDP = Selector(text=table).xpath('//tr[7]/td/strong/text()').extract()[0]


	item = whoItem()
	item['country'] = country
	item['total_population'] = total_population
	item['gnipc'] = gnipc
        item['life_ex_birth_mf'] = life_ex_birth_mf
        item['p_dying_five'] = p_dying_five
        item['p_15_60_mf'] = p_15_60_mf
        item['health_per_capita'] = health_per_capita
        item['expend_health_GDP'] = expend_health_GDP

#	with open('log.txt', 'a') as f:
#		f.write(format(item['total_population'] ,  item['gnipc']))

	yield item
