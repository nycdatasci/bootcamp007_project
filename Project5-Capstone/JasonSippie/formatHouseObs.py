import pandas as pd
import numpy as np
import json


def loadHouses(zipScraped, batch):
    suf = str(batch)

    inputFile = '/users/sippiejason/datascience/webscraping/realestate/data/zillowCleaned' + zipScraped + '-' + suf + '.json'
    outputFile = '/users/sippiejason/datascience/webscraping/realestate/data/houseObs' + zipScraped + '-' + suf + '.csv'

    # total number of years to observe
    # may vary depending on the features of the property
    yearFirstLast = [2000, 2016]

    #open source file
    with open(inputFile) as json_data:
        d = json.load(json_data)

    # filter properties with at least one sale recorded
    # and add to filterZ
    filterZ = []
    for rec in d:
        if len(rec['PriceHist']) >= 1:
            filterZ.append(rec)


    houseObs = pd.DataFrame() # all the house observations we'll write to file
    i = 1
    iMax = len(filterZ)
    # loop through the house records and generate a set of observations
    for houseRec in filterZ:
        print "Doing item " + str(i) + " of " + str(iMax)
        houseObs = houseObs.append(buildHouseObs(houseRec, yearFirstLast))
        i = i + 1

    # write to file
    houseObs.to_csv(outputFile)


# Given a set of house records and a suggested date range
# create house observation entries.
# These are rudimentary and will have additional columns merged
# onto them in separate steps.

def buildHouseObs(houseRec, yearFirstLast):

    oneHouseObs = pd.DataFrame()

    # extract a list of unique years from the sales and tax history
    yrs = set()
    for priceRec in houseRec['PriceHist']:
        soldYear = int(priceRec[0][0:4])
        yrs.add(soldYear)

    if len(houseRec['TaxHist']) > 0:
        for taxRec in houseRec['TaxHist']:
            taxYear = int(taxRec[0])
            yrs.add(taxYear)

    # figure out what first year to use
    yearStart = yearFirstLast[0]
    if houseRec['BuildYear'] != None:
        bYear = int(houseRec['BuildYear'])
        yearStart = max(bYear, yearFirstLast[0]) # don't make observation years that predate the house


    yearStart = min(min(yrs), yearStart) # use either the oldest transaction record or the whatever came out of the above routine

    yearRange = np.arange(yearStart, yearFirstLast[1]+1) # our list of years to observe for this house



    houseID = str(houseRec['HouseID'])

    # generate observations
    for yr in yearRange:
        indx = houseID + str(yr)

        if houseRec['RemodelYear'] == None:
            yrsSinceRemodel = None
        else:
            yrsSinceRemodel = yr - int(houseRec['RemodelYear'])


        if houseRec['BuildYear'] == None:
            yrsOld = None
        else:
            yrsOld = yr - int(houseRec['BuildYear'])

        oneObs = pd.DataFrame({
            'ObsYear': yr,
            'SaleFlg': 0,
            'SalePrice': None,
            'Tax':None,
            'YrsSinceSold': None,
            'YrsSinceRemodel': yrsSinceRemodel,
            'YrsOld': yrsOld,
            'HouseID': houseID,
            'BuildYear': houseRec['BuildYear'],
            'CoolingType': houseRec['CoolingType'],
            'HeatingType': houseRec['HeatingType'],
            'LotSize': houseRec['LotSize'],
            'RemodelYear':houseRec['RemodelYear'],
            'SingleMulti': houseRec['SingleMulti'],
            'NumBaths': houseRec['NumBaths'],
            'NumBeds': houseRec['NumBeds'],
            'Sqft': houseRec['Sqft'],
            'ZipCode': houseRec['ZipCode'],
            'AddrQuery': houseRec['AddrQuery']
        }, index=[indx])

        oneHouseObs = oneHouseObs.append(oneObs)

    oneHouseObs = oneHouseObs.sort_index(axis=0, ascending=False)


    # Update sales price
    for priceRec in houseRec['PriceHist']:
        soldYear = int(priceRec[0][0:4])
        soldAmt = priceRec[1]
        oneHouseObs.loc[houseID + str(soldYear), 'SaleFlg']= 1
        oneHouseObs.loc[houseID + str(soldYear), 'SalePrice'] = soldAmt


    if len(houseRec['TaxHist']) > 0:
        for taxRec in houseRec['TaxHist']:
            taxYear = int(taxRec[0])
            taxAmt = taxRec[1]
            oneHouseObs.loc[houseID + str(taxYear), 'Tax'] = taxAmt

    return oneHouseObs

if __name__ == "__main__":
    zipScraped = "28803"
    batch = [1,2,3,4]

    for b in batch:
        loadHouses(zipScraped, b)

    # zipScraped = "28786"
    # batch = np.arange(0,9)
    # for b in batch:
    #     loadHouses(zipScraped, b)




