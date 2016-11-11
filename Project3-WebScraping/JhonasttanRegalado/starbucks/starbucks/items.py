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
    CL = Field(serializer=int)
    WA = Field(serializer=int)
    WF = Field(serializer=int)
    CD = Field(serializer=int)
    DR = Field(serializer=int)
    LB = Field(serializer=int)
    GO = Field(serializer=int)
    FZ = Field(serializer=int)
    XO = Field(serializer=int)
    LU = Field(serializer=int)
    RW = Field(serializer=int)
    PS = Field(serializer=int)
    CS = Field(serializer=int)
    MX = Field(serializer=int)
    VS = Field(serializer=int)
    NB = Field(serializer=int)
    SQ = Field(serializer=int)
    EM = Field(serializer=int)
    BA = Field(serializer=int)
    WT = Field(serializer=int)
    hrs24 = Field(serializer=int)
    DT = Field(serializer=int)
    
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
