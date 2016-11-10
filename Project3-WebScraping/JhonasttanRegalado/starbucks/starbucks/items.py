# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

#import scrapy
from scrapy import Item, Field

class StarbucksItem(Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    StoreId = Field(serializer=str)
    Name = Field(serializer=str)
    PhoneNumber = Field(serializer=str)
    Longitude = Field()
    Latitude = Field()
    Address = Field(serializer=str)
    Amenities = Field(serializer=str)
    AmenitiesCarto = Field(serializer=str)
    StoreNameUrl = Field(serializer=str)
    Url = Field(serializer=str)
    AmeCL = Field(serializer=int)
    AmeWA = Field(serializer=int)
    AmeWF = Field(serializer=int)
    AmeCD = Field(serializer=int)
    AmeDR = Field(serializer=int)
    AmeLB = Field(serializer=int)
    AmeGO = Field(serializer=int)
    AmeFZ = Field(serializer=int)
    AmeXO = Field(serializer=int)
    AmeLU = Field(serializer=int)
    AmeRW = Field(serializer=int)
    AmePS = Field(serializer=int)
    AmeCS = Field(serializer=int)
    AmeMX = Field(serializer=int)
    AmeVS = Field(serializer=int)
    AmeNB = Field(serializer=int)
    AmeSQ = Field(serializer=int)
    AmeEM = Field(serializer=int)
    AmeBA = Field(serializer=int)
    AmeWT = Field(serializer=int)
    Amehrs24 = Field(serializer=int)
    AmeDT = Field(serializer=int)
    
    AmeOther = Field(serializer=str)
    
    '''
    {"code":"CL","name":"Starbucks Reserve-Clover Brewed"},
    {"code":"WA","name":"Oven-warmed Food"},
    {"code":"WF","name":"Wireless Hotspot"},
    {"code":"CD","name":"Mobile Payment"},
    {"code":"DR","name":"Digital Rewards"},
    {"code":"LB","name":"LaBoulange"},
    {"code":"GO","name":"Google Wi-Fi"},
    {"code":"FZ","name":"Fizzio Handcrafted Sodas"},
    {"code":"XO","name":"Mobile Order and Pay"},
    {"code":"LU","name":"Lunch"},
    {"code":"RW","name":"My Starbucks Rewards"},
    {"code":"PS","name":"Playbook Store System"},
    {"code":"CS","name":"tbd - Coffee Scale"}
    {"code":"MX","name":"Music Experience"}
    {u'VS': u'Verismo'}
    {u'NB': u'Nitro Cold Brew'}
    {u'SQ': u'tbd'}
    {u'EM': u'Starbucks Evenings'}
    {u'BA': u'Bakery'}
    {u'WT': u'tbd - Walk-T'}
    {u'hrs24': u'Open 24 hours per day'}
    {u'DT': u'Drive-Through'}
    '''
