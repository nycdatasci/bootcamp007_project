# -*- coding: utf-8 -*-
"""
Script for parsing datafiles into mongo database

Created on Tue Nov 29 20:52:18 2016

@author: nathan
"""
import unicodecsv as csv 
import re
import blockcode
import pymongo
import sys

# define file locations
blockcode_file = '../raw_data/nycb2010.csv'
trees_2015_file = '../raw_data/Tree_Census_2015.csv'
trees_2005_file = '../raw_data/Tree_Census_2005R.csv'
trees_2015_basename = '../raw_data/trees_2015'
trees_2005_basename = '../raw_data/trees_2005'

# add this to a dictionary to make lookup great
boroCodes = {}
boroCodes['Bronx'] = {}
boroCodes['Queens'] = {}
boroCodes['Manhattan'] = {}
boroCodes['Staten Island'] = {}
boroCodes['Brooklyn'] = {}

# debug break used when testing to only load subset of data
debug_break = 10000000
get_blockcode = False
save_to_mongodb = False
save_train = False

# set the number of observations for each boro to collect for train data
train_max = 10000000

trainCount = {}
trainCount['Bronx'] = 0
trainCount['Queens'] = 0
trainCount['Manhattan'] = 0
trainCount['Staten Island'] = 0
trainCount['Brooklyn'] = 0

# stores approximate percent of total trees found in dataset
# se we can produce balanced train sets
boroPercent = {} 
boroPercent['Bronx'] = 0.10
boroPercent['Queens'] = 0.41
boroPercent['Manhattan'] = 0.09
boroPercent['Staten Island'] = 0.14
boroPercent['Brooklyn'] = 0.26

trainRecords = []

# function to store record in mongo database
MONGODB_SERVER = 'localhost'
MONGODB_PORT = 27017
MONGODB_DB = "trees"
MONGODB_COLLECTION = "census"

# save observations to CSV files
def saveRecordsToCSV(filename, records):
    try:    
        fieldnames = ['tree_id', 'year', 'tree_dbh', 'health', 'spc_latin',\
        'spc_common', 'root_stone', 'root_grate', 'root_other',\
        'trunk_wire', 'address', 'zipcode', 'boro_name', 'longitude',\
        'latitude', 'block_code', 'sidewalk']
    
        with open(filename + ".csv", 'wb') as out_file:
            csvwriter = csv.DictWriter(out_file, delimiter=',', fieldnames=fieldnames)
            csvwriter.writeheader()   
    
            for row in records:
                csvwriter.writerow(row)
        
            out_file.close()
    except:
        e = sys.exc_info()[0]
        print 'file %s, %s' % (filename, e)

# save observations to mongo database
def saveRecordsToMongoDB(records):
    if save_to_mongodb:
        connection = pymongo.MongoClient(MONGODB_SERVER, MONGODB_PORT)
        db = connection[MONGODB_DB]
        collection = db[MONGODB_COLLECTION]
    
        for obs in records:
            collection.insert(obs)
               
def storeTrainRecord(filename, boroName, obs):
    global trainRecords, trainCount, boroPercent, train_max
    
    # check to see if to save train data otherwise return
    if not save_train:
        return False
    
    # check to see if to save this observation
    count = trainCount[boroName]
    percent = boroPercent[boroName]
    
    if count <= train_max*percent:
        trainRecords.append(obs)
        trainCount[boroName] = count + 1
    
    # check if to see if to save the record and return true to stop the main
    # loop
    if len(trainRecords) == train_max:
        saveRecordsToCSV(filename, trainRecords);
        
        # reset everything to 0        
        trainRecords = []
        for key in trainCount:
            trainCount[key] = 0
            
        return True
    else:
        return False
    
# get poly
def getPolygons(geoms):
    polygons = []
    start = geoms.find('(((') + 1
    end = geoms.find(')))') + 2
    text = geoms[start:end]
    slist = re.findall('\(\((.+?)\)\)', text)
    
    for data in slist:
        if data.find('), (') > 1:
            sa = data.split('), (')
            for subdata in sa:
                polygons.append(subdata)
        else:
            polygons.append(data)        
    
    return polygons
    
# this read the code blocks
def readBlockCodes():
    global boroCodes
    
    print('Reading NYC block code information ...\n')

    with open(blockcode_file, 'rb') as mycsvfile:
        dictofdata = csv.DictReader(mycsvfile)
        
        for row in dictofdata:
            boroName = row['BoroName']
            
            bcInfo = blockcode.BlockCodeInfo(getPolygons(row['the_geom']))
            blockCodes = boroCodes[boroName]            
            blockCodes[row['BCTCB2010']] = bcInfo

def readTreeCensus2015():
    global debug_break, trees_2015_basename, trainRecords
    
    print('Reading 2015 tree census data ...\n')

    with open(trees_2015_file, 'rb') as mycsvfile:
        dictofdata = csv.DictReader(mycsvfile)
        
        line = 1
        ucount = 0
        ecount = 0
        mcount = 0 # missing sidewalk value
        records = []
        dead_records = [] # store dead trees
        
        for row in dictofdata:
            line += 1 # increment the line count
            
            if line > debug_break:
                break
            
            try:
                boroName = row['boroname']
                blockCodes = boroCodes[boroName]            
            
                # set the block code
                lng = float(row['longitude'])
                lat = float(row['latitude'])
                
                blockCode = "TEST-" + row['zipcode']
                if get_blockcode:
                    blockCode = blockcode.getBlockCode(blockCodes, lng, lat)
                
                obs = {} # store information for saving
                
                obs['tree_id'] = row['tree_id']      
                obs['year'] = 2015
                
                # there are clearly some outliers in the tree dbh data
                # so just devide by them by ten for now
                tree_dbh = float(row['tree_dbh'])
                if tree_dbh > 70:
                    tree_dbh = tree_dbh/10
                    
                obs['tree_dbh'] = tree_dbh 
                
                if row['status'] == 'Dead':
                    obs['health'] = 'Dead'
                elif len(row['health']) == 4:
                    obs['health'] = row['health']
                else:
                    obs['health'] = 'Unknown'
                
                # clean up the latin names
                spc_latin = str(row['spc_latin']).upper()
                obs['spc_latin'] = spc_latin.replace('VAR. INERMIS', '')
                
                obs['spc_common'] = str(row['spc_common']).upper()
                
                if not spc_latin:
                    obs['spc_latin'] = 'UNKNOWN'
                    obs['spc_common'] = 'UNKNOWN'
                
                obs['root_stone'] = row['root_stone']
                obs['root_grate'] = row['root_grate']
                obs['root_other'] = row['root_other']
                obs['trunk_wire'] = row['trunk_wire']
                
                obs['address'] = row['address'] + ", " + row['zip_city']
                obs['zipcode'] = row['zipcode']
                obs['boro_name'] = boroName
                obs['longitude'] = lng
                obs['latitude'] = lat
                obs['block_code'] = blockCode
                
                # check to make sure we have a value for sidewalk damage
                # otherwise skip. These entries are typically dead 
                # trees or stumps
                sidewalk  = row['sidewalk']
                
                if(obs['health'] == 'Dead'):
                   dead_records.append(obs)
                   mcount += 1 
                elif sidewalk == 'Damage' or sidewalk == 'NoDamage':               
                    obs['sidewalk'] = sidewalk
                    records.append(obs)
                    
                    # store this as a train record if needed
                    # store training data and if we have enough then stop
                    stop = storeTrainRecord(trees_2015_basename + "_train", boroName, obs)                
                    if(stop):
                        break
                else:
                    obs['sidewalk'] = "Unknown";
                    obs['health'] = 'Dead'                    
                    dead_records.append(obs)
                    mcount += 1
                
                # increment the count
                if blockCode == 'Unknown':
                    ucount += 1
                    print "Unknown Block code > ", line, row['tree_id'], lng, lat 
                    
                if line%1000 == 0:
                    print "Report line# %i, train count: %i, unknown bcs: %i, missing: %i, error: %i" % (line, len(trainRecords), ucount, mcount, ecount)
            except ValueError:
                print "Error processing record ..." + row['tree_id']
            except KeyError:
                print "Incorrect boroname for " + row['tree_id']
                ecount += 1
        
        # report out the number of records processed
        print "Report line# %i, train count: %i, unknown bcs: %i, missing: %i, error: %i" % (line, len(trainRecords), ucount, mcount, ecount)        
        
        # save records to csv
        saveRecordsToCSV(trees_2015_basename, records)
        saveRecordsToCSV(trees_2015_basename + "_dead", dead_records)
        saveRecordsToMongoDB(records)

# split address into its parts
def splitLocationData(text):
    location = []
    
    slist = text.split('\n')
    location.append(slist[0] + ", " + slist[1])
    
    lnglat = slist[2]
    lnglat = lnglat[1:-1].split(', ')
    location.append(lnglat[1])
    location.append(lnglat[0])

    return location    
    
# read in the tree census data for 2005
def readTreeCensus2005():
    global debug_break, trees_2005_basename

    print('\nReading 2005 tree census data ...\n')

    with open(trees_2005_file, 'rb') as mycsvfile:
        dictofdata = csv.DictReader(mycsvfile)
        
        line = 0
        ucount = 0;
        ecount = 0;
        records = []
        
        for row in dictofdata:
            line += 1 # increment the line count
            
            if line > debug_break:
                break
            
            try:
                boroName = row['boroname']
                if boroName == '5':
                    boroName = 'Staten Island'
                
                blockCodes = boroCodes[boroName]            
            
                # set the block code
                location = splitLocationData(row['Location 1'])
                lng = float(location[1])
                lat = float(location[2])
                
                # skip anything which doesn't have correct longitude, latitude
                if lng == 0:
                    line += 1
                    continue                
                
                # get the block code
                blockCode = "TEST-" + row['zipcode']
                if get_blockcode:
                    blockCode = blockcode.getBlockCode(blockCodes, lng, lat)                
                               
                obs = {} # store information for saving
                obs['tree_id'] = row['OBJECTID'] + '_2005'      
                obs['year'] = 2005
                obs['tree_dbh'] = row['tree_dbh']                
                obs['health'] = row['status']
                obs['spc_latin'] = row['spc_latin']
                obs['spc_common'] = row['spc_common']                
                
                if row['sidw_crack'] == 'Yes' or row['sidw_raise'] == 'Yes':
                    obs['sidewalk'] = 'Damage'
                else:
                    obs['sidewalk'] = 'NoDamage'
                    
                obs['root_stone'] = row['horz_blck']
                obs['root_grate'] = row['horz_grate']
                obs['root_other'] = row['horz_other']
                obs['trunk_wire'] = row['inf_wires']
                
                obs['address'] = location[0]
                obs['zipcode'] = row['zipcode']
                obs['boro_name'] = boroName
                obs['longitude'] = lng
                obs['latitude'] = lat
                obs['block_code'] = blockCode
                
                records.append(obs)
                
                # store training data and if we have enough then stop
                stop = storeTrainRecord(trees_2005_basename + "_train", boroName, obs)                
                if(stop):
                    break
                
                if blockCode == 'Unknown':
                    ucount += 1
                    print "Unknown Block code > ", boroName, row['zipcode'], line, row['OBJECTID'], lng, lat 
                
                if line%1000 == 0:
                    print "Report line# %i, train count: %i, unknown bcs: %i, error: %i" % (line, len(trainRecords), ucount, ecount)
            except ValueError:
                print "Error processing record ..." + row['OBJECTID']
            except KeyError:
                print "Incorrect boroname for " + row['OBJECTID'] + ": " + row['boroname']
                ecount += 1
        
        # report out the number of records processed
        print "Report line# %i, train count: %i, unknown bcs: %i, error: %i" % (line, len(trainRecords), ucount, ecount)
        
        # save records to csv
        saveRecordsToCSV(trees_2005_basename, records)
        saveRecordsToMongoDB(records)
        
# first read the block code data
readBlockCodes()
#import data_processor_test
#data_processor_test.testBlockCodes(boroCodes)

# next read in the 2015 sensor data
readTreeCensus2015()
#readTreeCensus2005()