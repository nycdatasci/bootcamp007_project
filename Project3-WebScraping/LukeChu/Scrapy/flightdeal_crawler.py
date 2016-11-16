# -*- coding: utf-8 -*-
import scrapy
from scrapy.linkextractors import LinkExtractor
from scrapy.spiders import CrawlSpider, Rule
from scrapy.selector import Selector
from scrapy import Request
from flightdeal.items import FlightDealItem

import re


class FlightDealCrawlerSpider(CrawlSpider):
    name = 'flightdeal_crawler'
    allowed_domains = ["theflightdeal.com"]
    start_urls = ["http://www.theflightdeal.com/category/flight-deals/"]

    # it works! but what's the right regex?
    rules = [
        Rule(LinkExtractor(allow=r'category/flight-deals/page/\d{1,3}\D'), callback='parse_item', follow=True),
    ]



    def parse_start_url(self, response):
        list(self.parse_item(response))

    def parse_item(self, response):

        # for testing one page at a time 
        # block_urls = response.css('.post-title').xpath('a/@href').extract()[0]
        # request = Request(block_urls, callback = self.parse_page2)
        # yield request

        block_urls = response.css('.post-title').xpath('a/@href').extract()

        for  url in block_urls:

            request = Request(url, callback = self.parse_page2)
            
            yield request



    def parse_page2(self, response):

        item = FlightDealItem()

        # a/text() to get text
        # title = response.xpath("//*[@id=\"main\"]/div/div[1]/div[1]/div[2]/h1/a/text()").extract()[0]
        # better to use this beecause the top is dependent on structure preservation
        # below xpaths is only dependent on tag attributes

        # index from examination of HTML strucutre
        # not using text() because of <strong> tags implemented between
        title = response.xpath('//div[@class="entry-content single-entry"]/h1[@class="post-title"]/a/text()').extract()[0]
        posting_date = response.css('.date-container').xpath('strong/text()').extract()[0] + ' ' + \
        response.css('.date-container').xpath('span/text()').extract()[0]
        
        # only Roundtrips. Jet Blue and its one-way sales create too many values.
        if re.search('Roundtrip', self.u2s(title)) is None:
            return


        
        item['posting_date'] = self.u2s(posting_date)
        item['title'] = self.u2s(re.sub(u'\u2013', '-', title))
        item['is_both_ways'] = str(0)
        
        # flag to detect if price is valid for both directions
        if re.search('vice versa', self.u2s(title)) is not None:
            item['is_both_ways'] = str(1)

       

        # extract price from title; number only via lookbehind for '$'    
        item['price'] = re.search('(?<=\$)\d+', self.u2s(title)).group(0)

        # extract airlines, seemingly always written before first price.
        title_part = item['title'].split('$')[0]
        item['airline'] = title_part.split(' - ')[-2]
        # remove [FARE GONE] if it exists
        item['airline'] = re.sub('\[FARE GONE\] ', '', item['airline'])

        body = response.xpath('//div[@class="entry-content single-entry"]/h2/following-sibling::ul/li').extract()

        # format for older pages
        if body == []:
            body = response.xpath('//div[@class="entry-content single-entry"]/p/following-sibling::ul/li').extract()
            
        pos = 0
        found = False
        while pos < len(body) and not found:
            if re.search('(V|v)alid for travel', self.u2s(body[pos])) or re.search('(W|w)e found availability', self.u2s(body[pos])) is not None:
                travel_date_string = self.u2s(re.sub(u'\u2013', '-', body[pos]))
                item['travel_info'] = travel_date_string
                item['travel_dates'] = self.date_extractor(posting_date, travel_date_string)
                found = True
            else:
                item['travel_info'] = 'Not Found'
                pos += 1

        if found == True:
            found = False
        else:
            pos = 0
            item['travel_dates'] = 'Not Found'

        while pos < len(body) and not found:
            if re.match('<li>[A-Z]{3}  [A-Z]{3}', self.u2s(body[pos])) is not None:
                process_route = self.u2s(re.sub(u'\u2013', '-', body[pos]))
                
                # some routing cleanups:

                # need to do this here instead of beautiful soup b/c of vice versa swaps later
                process_route = re.sub('<li>', '', process_route)
                process_route = re.sub('</li>', '', process_route)

                # clear extra info written after in new sentence
                if re.search('\.', process_route) is not None:
                    process_route = process_route.split('.')[0]

                # typo cleanup -  the double dash
                process_route = re.sub('- -', '-', process_route)
                item['routing'] = process_route
                found = True
            else:
                pos += 1

        if found == True:
            found = False
        else:
            pos = 0
            item['routing'] = 'Not Found'

        found = False
        while pos < len(body) and not found:
            if re.search('\d+(,\d+)?(?= miles)', self.u2s(body[pos])) is not None:
                travel_miles_string = self.u2s(body[pos])
                item['miles'] = self.miles_extractor(travel_miles_string)
                found = True
                pos = 0
            else:
                pos += 1

        if found == True:
            found = False
        else:
            pos = 0
            item['miles'] = 'Not Found'


 


        yield item


    # convert unicode to string    
    def u2s(self, uni):
        return uni.encode('ascii', 'ignore')

    def date_extractor(self, post_date, date_string):
        '''Extract month and year from a sentence. These are pretty case specific'''
        # "from Month, Year - Month, Year"
        # split start time, end time by dash
        # split by comma to see year
        # otherwise add year from date

        # from mid/late? Month Day?, Year? - mid/early? Month? Day?, Year?
        # ex. from mid January 30th, 2017 - August 15th, 2017
        # from January 1st - 30th
        # from January - early August
        # from January 1st to August 30th 


        from_to  = re.findall('((mid |late )?(January|February|March|April|May|June|July|August|September|October|November|December)( \d+(th|st|nd|rd))?(, \d{4})? - (early |mid )?(January|February|March|April|May|June|July|August|September|October|November|December)?( \d+(th|st|nd|rd))?(, \d{4})?)', \
        date_string)

        until = re.findall('(?<=until )((early |mid |late )?(January|February|March|April|May|June|July|August|September|October|November|December)( \d+(th|st|nd|rd))?(, \d{4})?)', \
        date_string)

        in_start = re.findall('(?<=in )((early |mid |late )?(January|February|March|April|May|June|July|August|September|October|November|December)( \d+(th|st|nd|rd))?(, \d{4})?)', \
        date_string)








        # swap month and day to mm/dd/year
        post_date_split = self.u2s(post_date).split(' ')
        post_date_split[0], post_date_split[1] = post_date_split[1], post_date_split[0]


        parsed_dates = ''


        if until != []:
            parsed_dates += '/' + ' '.join(post_date_split) + ' - ' + '/'.join([g[0] for g in until])

        if in_start != []:
            parsed_dates += '/' + '/'.join([g[0] for g in in_start])

        if from_to != []:
            parsed_dates += '/' + '/'.join([g[0] for g in from_to])


        if parsed_dates == '':
            or_without_to = re.findall('(?<=or )((mid |late )?(January|February|March|April|May|June|July|August|September|October|November|December)( \d+(th|st|nd|rd))?(, \d{4})?', \
            date_string)

            if or_without_to != []:
                parsed_dates += '/' + '/'.join([g[0] for g in or_without_to])
            else:
                parsed_dates = 'Not Found'

        return parsed_dates

    def miles_extractor(self, miles_string):

        miles = re.search('\d+(,\d+)?(?= miles)', miles_string).group(0)
        miles = re.sub(',', '', miles)

        return miles


       
        








