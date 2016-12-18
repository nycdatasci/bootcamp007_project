
import numpy as np
import pandas as pd
import urllib2
import urllib
import json

path = "/Users/sippiejason/datascience/webscraping/realestate/data/"

def getNeededGeo():
    houseObs = pd.read_csv(path + 'allHouseObservations20161213.csv')
    #unique list of addresses that need geos
    addrs = houseObs.loc[:, ['AddrQuery', 'ZipCode', 'CityName', 'CountyName', 'StreetAddr' ]].drop_duplicates()

    # all the addrs whose geocoder data we've already loaded from the census
    allAddrGeos = pd.read_csv(path + "addrGeo.csv", index_col=0)
    # all the addrs whose geocoder data we've unsuccessfully tried to load from the census
    allMissedGeos = pd.read_csv(path + "addrGeoMissed.csv", index_col=0)

    print "starting with " + str(len(addrs)) + " addresses"
    # only look up addresses that we haven't dealt with before
    neededAddrs = addrs[~addrs.AddrQuery.isin(allAddrGeos.AddrQuery)]
    neededAddrs = neededAddrs[~neededAddrs.AddrQuery.isin(allMissedGeos.AddrQuery)]

    # get geocoder data for addresses
    geos = getGeos(neededAddrs)

    # add new geos to the full list and save to csv
    allAddrGeos = allAddrGeos.append(geos)
    allAddrGeos.to_csv(path + "addrGeo.csv")



def getGeos(neededAddrs):

    allLocs = pd.DataFrame()
    missedLocs = pd.DataFrame()

    print "Getting " + str(len(neededAddrs)) + " geo tracts"

    for i in neededAddrs.index:

        qsDict = {'street': neededAddrs.loc[i, "StreetAddr"],
                  'city': neededAddrs.loc[i, "CityName"],
                  'state': 'NC'}

        prefix = "https://geocoding.geo.census.gov/geocoder/geographies/address?"
        suffix = "&benchmark=Public_AR_Census2010&vintage=Census2010_Census2010&layers=14&format=json"
        key = key = '&key=49bdc2de261c9822e82e5e1c8c1b288ed173bd90'
        qs = urllib.urlencode(qsDict)
        j = ""
        try:
            response = urllib2.urlopen(prefix + qs + suffix + key)
            html = response.read()
            j = json.loads(html)
        except:
            print "error contacting server"

        try:
            #if i % 50 == 0:
            print "Trying row " + str(i)
            blocks = j['result']['addressMatches'][0]['geographies']['Census Blocks'][0]
            blocks["AddrQuery"] = neededAddrs.loc[i, "AddrQuery"]
            allLocs = allLocs.append(pd.DataFrame(blocks, index=[blocks["OBJECTID"]]))
        except:
            print "Couldn\'t get " + neededAddrs.loc[i, "AddrQuery"]
            missedLocs = missedLocs.append(neededAddrs.loc[i, :])

    allMissedLocs = pd.read_csv(path+"addrGeoMissed.csv", index_col=0)
    allMissedLocs = allMissedLocs.append(missedLocs)
    allMissedLocs.to_csv(path+"addrGeoMissed.csv", )

    return allLocs


def getNeededDemoData(year):

    allAddrGeos = pd.read_csv(path + "addrGeo.csv", index_col=0)
    geos = allAddrGeos.loc[:, ['OBJECTID', 'COUNTY', 'STATE', 'BLKGRP', 'TRACT']].drop_duplicates()

    allDemog = pd.DataFrame()
    neededGeos = geos

    try:
        allDemog = pd.read_csv(path + "demogData" + str(year) + ".csv", index_col=False)
        neededGeos = geos[~geos.OBJECTID.isin(allDemog.GeoID)]
    except: # no file available
        pass

    print "Getting " + str(len(neededGeos)) + " demographic records"

    newDemog = getDemoData(neededGeos, year)

    allDemog = allDemog.append(newDemog)

    allDemog.to_csv(path + "demogData" + str(year) + ".csv")


def getDemoData(neededDemog, year):
    demoDict = {'Race': {'File': 'B02001',
                         'Total': '_001E',
                         'White': '_002E'},
                'HHwChild': {'File': 'B11005',
                             'Total': '_001E',
                             'Und18': '_002E'},
                'HHwSeniors': {'File': 'B11007',
                               'Total': '_001E',
                               'Over65': '_002E'},
                'EduAttain': {'File': 'B15003',
                              'Total': '_001E',
                              'HS': '_017E',
                              'Bachelors': '_022E'},
                'HHIncome': {'File': 'B19013',
                             'MedIncome': '_001E'},
                'RetIncome': {'File': 'B19059',
                              'Total': '_001E',
                              'RetIncCnt': '_002E'},
                'MortStat': {'File': 'B25081',
                             'Total': '_001E',
                             'NumWithMort': '_002E',
                             'NumWithMoreOr': '_003E',
                             'NumWithMoreAnd': '_006E'},
                'MedValue': {'File': 'B25077',
                             'MedValue': '_001E'}
                }


    allDemog = pd.DataFrame()

    for i in neededDemog.index:
        print "working on " + str(i)

        countyCode = str(neededDemog.loc[i, "COUNTY"])
        stateCode = str(neededDemog.loc[i, "STATE"])
        blockGroup = str(neededDemog.loc[i, "BLKGRP"])
        tract = str(neededDemog.loc[i, "TRACT"])
        geoID = str(neededDemog.loc[i, "OBJECTID"])

        url = ""
        fileNm = ""
        metric = ""
        prefix = ""
        colLabel = ""
        key = '&key=49bdc2de261c9822e82e5e1c8c1b288ed173bd90'

# api.census.gov/data/2015/acs5?get=NAME,B01001_001E&for=state:*&key=...
# api.census.gov/data/2010/acs5?key=YOUR KEY GOES HERE&get=B02001_001E,NAME&for=state:06,36


        d = {'GeoID': geoID}
        for k in demoDict.keys():
            fileNm = demoDict[k]["File"]
            for item in demoDict[k].keys():
                if item != "File":
                    metric = demoDict[k][item]
                    colLabel = k + item
                    try:
                        if year == 2015:
                            prefix = "http://api.census.gov/data/2015/acs5?get=NAME,"
                            url = prefix + fileNm + metric + '&for=block+group:' + blockGroup + \
                                  '&in=state:' + stateCode + '+county:0' + countyCode + \
                                  '+tract:' + tract + key
                        else:
                            prefix = "http://api.census.gov/data/" + str(year) + "/acs5?" + key
                            url = prefix + "&get=" + fileNm + metric + ",NAME" + '&for=block+group:' + blockGroup + \
                                  '&in=state:' + stateCode + '+county:0' + countyCode + \
                                  '+tract:' + tract

                        response = urllib2.urlopen(url)
                        html = response.read()

                        j = json.loads(html)

                        retItem = j[1][1] if year == 2015 else j[1][0]

                        if retItem == None:
                            print "No data for: " + colLabel
                            d[colLabel] = None
                        else:
                            d[colLabel] = int(retItem)
                    except:
                        d[colLabel] = None
                        print "failed for " + url

        i += 1
        allDemog = allDemog.append(d, ignore_index=True)


    return allDemog

if __name__ == "__main__":
    year = 2015
    getNeededGeo()
    getNeededDemoData(year)

