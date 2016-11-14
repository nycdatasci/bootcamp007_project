# -*- coding: utf-8 -*-
import scrapy
import json
from scrapy.selector import Selector
from Wayback.items import WaybackItem

SITE = 'www.reddit.com'

item = WaybackItem()
class WaybackSpider(scrapy.Spider):
    name = "waybackspider"
    #allowed_domains = ["https://web.archive.org/web/*/www.reddit.com"]
    start_urls = (
        'https://web.archive.org/web/*/'+SITE,
    )

    
    def parseData(self, response):

        top25_text = response.xpath('//*[@id="siteTable"]/div/div[@class="entry unvoted"]/p[@class="title"]/a[contains(@class, "title")]/text()').extract()
        top25_url = response.xpath('//*[@id="siteTable"]/div/div[@class="entry unvoted"]/p[@class="title"]/a/@href').extract()
        top25snapshots = map(lambda x:str(x.split('/')[2]), response.xpath('//*[@id="siteTable"]/div/div[@class="entry unvoted"]/p[@class="title"]/a/@href').extract())
        snapdate = map(lambda x:x[0:8], top25snapshots)
        snaptimes = map(lambda x:x[8:15], top25snapshots)
        top25_upvotes = response.xpath('//*[@id="siteTable"]/div/div/div[@class="score unvoted"]/text()').extract()
        top25_subreddits1 = map(lambda x: x.split("/")[-2], response.xpath('//*[@id="siteTable"]/div/div[@class="entry unvoted"]/p[@class="tagline"]/a[@class="subreddit hover may-blank"]/@href').extract())
        top25_subreddits2 = map(lambda x: x.split("/")[-2], response.xpath('//*[@id="siteTable"]/div/div[@class="entry unvoted"]/p[@class="tagline "]/a[@class="subreddit hover may-blank"]/@href').extract())
        top25_time1 = response.xpath('//*[@id="siteTable"]/div/div[@class="entry unvoted"]/p[@class="tagline"]/time/@datetime').extract();
        top25_time2 = response.xpath('//*[@id="siteTable"]/div/div[@class="entry unvoted"]/p[@class="tagline "]/time/@datetime').extract();
        top25_submitter1 = response.xpath('//*[@id="siteTable"]/div/div[@class="entry unvoted"]/p[@class="tagline"]/a[contains(@class, "author may-blank")]/text()').extract()
        top25_submitter2 = response.xpath('//*[@id="siteTable"]/div/div[@class="entry unvoted"]/p[@class="tagline "]/a[contains(@class, "author may-blank")]/text()').extract()
        top25_comment_counts = response.xpath('//*[@id="siteTable"]/div/div[@class="entry unvoted"]/ul/li[@class="first"]/a/text()').extract()

        ## Extract the top 10 items
        for i in range (0,10):
            item['titles'] = top25_text[i]
            item['rank'] = i + 1
            item['url'] = top25_url[i]
            item['upvotes'] = top25_upvotes[i]
            if(len(top25_submitter1) == 0):
                item['submitter'] = top25_submitter2[i]
            else:
                item['submitter'] = top25_submitter1[i]
            item['comments'] = top25_comment_counts[i]
            if(len(top25_subreddits1) == 0):
                item['subreddit'] = top25_subreddits2[i]
            else:
                item['subreddit'] = top25_subreddits1[i]
            if(len(top25_time1) == 0):
                item['submit_datetime'] = top25_time2[i]
            else:
                item['submit_datetime'] = top25_time1[i]
            item['snapshot_datetime'] = top25snapshots[i]
            item['snapshot_time'] = snaptimes[i]
            item['snapshot_date'] = snapdate[i]
            yield item
        


    def parse(self, response):
        print 'PARSING DATA VIA WAYBACK.PY.PARSE.()..'

        # Look at all the months  in the website
        months  = response.xpath('//div[@id="calOver"]/div[@class="month"]').extract()
        
        ## For each month, get the list of URLs and extract the href
        url_list = []
        for month in months:
          url_list.extend(Selector(text = month).xpath('//div[@class="pop"]/ul/li/a/@href').extract())

        hours = map(lambda x:x.split('/')[2][0:10], url_list)

        # zipped = zip(url_list, hours)

        # final = []
        # added= []

        # for i in range (1,len(hours)):
        #     if (zipped[i][1] in added):
        #         continue
        #     else:
        #         final.append(zipped[i][0])
        #         added.append(zipped[i][1])



        url_list = map(lambda x: 'https://web.archive.org' + x, url_list)


        print "=" * 50
        print  len(months)
        # print final[0]
        # print len(final)

        # for i in range (0, len(url_list)):
        #     item = WaybackItem()
        #     item['urls'] = url_list[i]
        #     yield item

        for url in url_list:
            yield scrapy.Request(url=url, callback=self.parseData)


        # for i in range (0, 25):
        #     item = WaybackItem()
        #     yield scrapy.Request(url_list[i], callback=self.parse_listing_contents)
        #     top25_text = response.xpath('//*[@id="siteTable"]/div/div[@class="entry unvoted"]/p[@class="title"]/a/text()').extract()
        #     top25_url = response.xpath('//*[@id="siteTable"]/div/div[@class="entry unvoted"]/p[@class="title"]/a/@href').extract()

        #     item['urls'] = top25_text
        #     yield item
            #print url_list[i]
            #yield scrapy.Request(url_list[i], callback=self.parse_listing_contents)


        # json_array = response.xpath('//meta[@id="_bootstrap-room_options"]/@content').extract()
        # if json_array:
        #     airbnb_json_all = json.loads(json_array[0])
        #     airbnb_json = airbnb_json_all['airEventData']
        #     item['rev_count'] = airbnb_json['visible_review_count']
        #     item['amenities'] = airbnb_json['amenities']
        #     item['host_id'] = airbnb_json_all['hostId']
        #     item['hosting_id'] = airbnb_json['hosting_id']
        #     item['room_type'] = airbnb_json['room_type']
        #     item['price'] = airbnb_json['price']
        #     item['bed_type'] = airbnb_json['bed_type']
        #     item['person_capacity'] = airbnb_json['person_capacity']
        #     item['cancel_policy'] = airbnb_json['cancel_policy']
        #     item['rating_communication'] = airbnb_json['communication_rating']
        #     item['rating_cleanliness'] = airbnb_json['cleanliness_rating']
        #     item['rating_checkin'] = airbnb_json['checkin_rating']
        #     item['satisfaction_guest'] = airbnb_json['guest_satisfaction_overall']
        #     item['instant_book'] = airbnb_json['instant_book_possible']
        #     item['accuracy_rating'] = airbnb_json['accuracy_rating']
        #     item['response_time'] = airbnb_json['response_time_shown'] 
        #     item['nightly_price'] = airbnb_json_all['nightly_price']
        # item['url'] = response.url
        # yield item

        # For each item in the URL list, dump it into a CSV as an item.
        # for i in range (1, len(url_list)):
        #     item = WaybackItem()
        #     item['urls'] = url_list[i]
        #     yield item
        
        # print response.xpath('//*[@id="2016-0"]/table/tbody/tr[2]')
        # print len(response.xpath('//*[@id="2016-0"]/table/tbody'))
        # num_snapshots = response.xpath('//*[@id="2016-0"]/table/tbody/tr[1]/td[6]/div/div[1]/p').extract()[0]
        # extract_num_snaps =  int(num_snapshots.split(' ')[0].split('<p>')[1])

        # for i in range (1,extract_num_snaps):
        #     current_url = response.xpath('//*[@id="2016-0"]/table/tbody/tr[1]/td[6]/div/div[1]/ul/li[' + str(i)+ ']/a/@href').extract()[0]
        #     print 'https://web.archive.org/web/' + current_url
        #     #URL = Selector(text=calendar[1]).xpath('//td[0]/div/div[1]/ul/li/a').extract()
        #     #print URL
        #     item = WaybackItem()
        #     item['urls'] = 'https://web.archive.org/web/' + current_url
        #     yield item

        



    # def parse_listing_results_page(self, response):
    #     for href in response.xpath('//a[@class="media-photo media-cover"]/@href').extract():
    #         url = response.urljoin(href)
    #         yield scrapy.Request(url, callback=self.parse_listing_contents)

