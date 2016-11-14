# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html
from scrapy.conf import settings
from scrapy import log
from items import AwardItem
from keywords import get_keywords
import xml.etree.ElementTree as ET
import pymongo
import re
import zipfile
import os

class ReSnagPipeline(object):
    
    # process each item    
    def process_item(self, item, spider):
        path = self.get_path(item['url'])
        
        # write out the file
        with open(path, "wb") as f:
            f.write(item['body'])
            
        # remove body and add path as reference
        del item['body']
        
        # unzip the file
        unzip_directory = self.unzip_awards(path)        
        
        # now process all file in the directory        
        award_items = self.process_awards(unzip_directory, spider)
        
        item['awards'] = award_items
        item['path'] = path
        item['fileCount'] = len(award_items)
        
        # let item be processed by other pipelines. ie. db store
        return item
    
    # save the downloaded file to zip file
    def get_path(self, url):
        match = re.search(r'\d{4}', url)
        year = match.group(0)
        return settings['DOWNLOAD_DIR'] + 'awards-' + year + '.zip'

    # unzip the downloaded zip file
    def unzip_awards(self, path):
        unzip_directory = settings['DOWNLOAD_DIR'] + 'awards'
        
        zip_ref = zipfile.ZipFile(path, 'r')
        zip_ref.extractall(unzip_directory)
        zip_ref.close()
        
        return unzip_directory
                
    # for all the files in the unzip directory process earch of them
    def process_awards(self, folder, spider):
        award_items = []
        
        for the_file in os.listdir(folder):
            file_path = os.path.join(folder, the_file)
            
            try:
                if os.path.isfile(file_path):
                    award_item = self.get_award(file_path)
                    award_items.append(award_item)
            except Exception as e:
                print(e)
                msg = "Unable to process file " + file_path
                log.msg(msg, level=log.DEBUG, spider=spider)
            finally:
                # now delete the file since we done processing it
                os.unlink(file_path)
    
        # return the number of files which where processed
        return award_items
        
    # save the xml to mongo database. since it looks each xml
    # contains only ne record the we don't need to worry about
    # iterating through more than one record?    
    def get_award(self, file_path):
        print "Converting xml file: " + file_path
        
        tree = ET.parse(file_path)
        root = tree.getroot()
        award = root.find('Award')
        
        # create a new AwardItem object from the xml data 
        awardItem = AwardItem()
                
        awardItem['Title'] = award.find('AwardTitle').text
        awardItem['Date'] = award.find('AwardEffectiveDate').text
        
        amount = award.find('AwardAmount')        
        if amount is not None:
            awardItem['Amount'] = amount.text
        
        # add institution
        institution = award.find('Institution')
        if institution is not None:        
            awardItem['Institution'] = institution.find('Name').text
        
        # add the authors
        division = award.find('Division')
        if division is not None:
            awardItem['Division'] = division.find('LongName').text
        
        investigator = award.find('Investigator')
        if investigator is not None:        
            awardItem['Investigator'] = investigator.find('FirstName').text + " " + investigator.find('LastName').text + " | " + investigator.find('EmailAddress').text
        
        abstract = award.find('AbstractNarration')
        if abstract is not None and abstract.text is not None:
            awardItem['Abstract'] = abstract.text
            awardItem['Keywords'] = get_keywords(abstract.text)      
        
        return awardItem            

# class to save the record to the mongo DB
class MongoDBPipeline(object):

    def __init__(self):
        connection = pymongo.MongoClient(
            settings['MONGODB_SERVER'],
            settings['MONGODB_PORT']
        )
        db = connection[settings['MONGODB_DB']]
        self.collection = db[settings['MONGODB_COLLECTION']]

    def process_item(self, item, spider):
        for award in item['awards']:
            self.collection.insert(dict(award))
            log.msg("Added to MongoDB database!",
                    level=log.DEBUG, spider=spider)
        
        # delete the awards records before return this item 
        # to save memory
        del item['awards']
        return item
            
# this pipe line is for testing purposes
class WriteItemPipeline(object):

	def __init__(self):
		self.filename = 'ReSnagUrls.txt'

	def open_spider(self, spider):
		self.file = open(self.filename, 'wb')
		
	def close_spider(self, spider):
		self.file.close()

	def process_item(self, item, spider):
		line = str(item['url']) + " " + str(item['fileCount']) + '\n'
		self.file.write(line)
		return item
