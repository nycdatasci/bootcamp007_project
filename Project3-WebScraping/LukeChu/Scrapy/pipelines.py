# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html


class FlightDealPipeline(object):

    def __init__(self):
        self.filename = 'FlightDeals.txt'

    def open_spider(self, spider):
        self.file = open(self.filename, 'wb')

    def close_spider(self, spider):
    	self.file.close()


    def process_item(self, item, spider):
        
        if item['is_both_ways'] == '1' and item['routing'] != 'Not Found':
            item['routing'] = self.routing_swap(item['routing'])

        line = item['posting_date'] + '|' + item['title'] + '|' + item['airline'] + '|' + item['price'] + '|' + item['is_both_ways'] + '|' + \
        item['travel_dates'] + '|' + item['routing'] + '|' + item['miles'] + '|' + item['travel_info'] + '\n'

        self.file.write(line)
        return item

    def routing_swap(self, routes):
        routes_list = routes.split(' - ')
        # destination will always be the median 
        destination_index = len(routes_list) / 2
        # origin and return will always be start and end point.
        #  swap these
        routes_list[0], routes_list[-1], routes_list[destination_index] = routes_list[destination_index], \
        routes_list[destination_index], routes_list[0]


        return ' - '.join(routes_list) + '/' + routes

