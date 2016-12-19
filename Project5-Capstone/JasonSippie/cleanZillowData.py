import json
import re
import numpy as np
import datetime


def startClean(zipScraped, batch):

    inputFile = '/users/sippiejason/datascience/webscraping/realestate/data/zillowOutput' + zipScraped + '-' + str(batch) + '.json'
    outputFile = '/users/sippiejason/datascience/webscraping/realestate/data/zillowCleaned' + zipScraped + '-' + str(batch) + '.json'

    with open(inputFile) as json_data:
        d = json.load(json_data)

    houseRecords = []

    for rec in d:
        # first clean house features
        houseRec = getHouseFeatures(rec, zipScraped)
        # now get price/tax data
        houseRec['PriceHist'] = getPriceHist(rec)
        houseRec['TaxHist'] = getTaxHist(rec)

        houseRecords.append(houseRec)



    with open(outputFile, 'w') as fout:
        json.dump(houseRecords, fout, indent=4, sort_keys=True)


def getHouseFeatures(houseRec, zipScraped):
    houseID = str(houseRec['HouseID']) + '-' + str(zipScraped)

    print("processing " + str(houseID))

    cleanFeatures = {'HouseID': houseID,
                     'AddrQuery': houseRec['AddrQuery'],
                     'ZipCode': houseRec['ZipCode'],
                     'NumBeds': None,
                     'NumBaths': None,
                     'Sqft': None,
                     'LotSize': None,
                     'BuildYear': None,
                     'RemodelYear': None,
                     'CoolingType': None,
                     'HeatingType': None,
                     'SingleMulti': None}

    # ------------------------------------------
    # do houseFact1
    # ------------------------------------------
    hf1 = ""
    try:
        hf1 = houseRec['houseFact1']
        beds = re.search('\d* (?=beds)', hf1)
        numBeds = int(beds.group(0))
        cleanFeatures['NumBeds'] = numBeds
    except:
        print('couldn\'t get beds')

    try:
        baths = re.search('(?<=beds) .*?(?= )', hf1)
        numBaths = float(baths.group(0))
        cleanFeatures['NumBaths'] = numBaths
    except:
        print ('couldn\'t get baths')

    try:
        sqrft = re.search('(?<=baths ).*(?= sqft)', hf1)
        sqft = int(sqrft.group(0).replace(",", ""))
        cleanFeatures['Sqft']= sqft
    except:
        print('couldn\'t get sqft')

    # ------------------------------------------
    # do houseFact2
    # ------------------------------------------

    hf2 = ""

    # Lot:
    try:
        hf2 = '|'.join(houseRec['houseFact2'])
        lot = re.search('(?<=Lot: ).*?(?=\|)', hf2).group(0)

        units = "Acres"
        lotNum = re.search('.*?(?= acres)', lot)

        if lotNum == None:
            lotNum = re.search('.*?(?= sqft)', lot)
            units = "sqft"

        lotNum = float(lotNum.group(0).replace(",", ""))
        if units == "sqft":
            lotNum = lotNum/43560 #convert to acre


        cleanFeatures['LotSize'] = lotNum
    except:
        print("cant\'t get lot size")

    # Build Year
    try:
        buildYear = re.search('(?<=Built in ).*?(?=\|)', hf2).group(0)
        cleanFeatures['BuildYear'] = int(buildYear)
    except:
        print("cant\'t get build year")

    # Cooling/heating
    try:
        cooling = re.search('(?<=Cooling: ).*?(?=\|)', hf2).group(0)
        cleanFeatures['CoolingType'] = cooling
    except:
        print("cant\'t get cooling")

    try:
        heating = re.search('(?<=Heating: ).*?(?=\|)', hf2).group(0)
        cleanFeatures['HeatingType'] = heating
    except:
        print("cant\'t get heating")

    # Single/Multi
    try:
        item = re.search('Single Family', hf2)
        sfmf = item.group(0)
        cleanFeatures['SingleMulti'] = sfmf
    except:  # oops, not sf
        try:
            item = re.search('Multi Family', hf2)
            sfmf = item.group(0)
            cleanFeatures['SingleMulti'] = sfmf
        except:
            print("cant\'t get SFMF")

    # Last remodel year
    try:
        remodelYear = re.search('(?<=Last remodel year: ).*?(?=\|)', hf2).group(0)
        cleanFeatures['RemodelYear'] = remodelYear
    except:
        print("cant\'t get remodel year")

    return cleanFeatures

def getPriceHist(houseRec):
    newPH = []
    try:
        ph = houseRec['priceHist']
        for row in ph:
            r = re.search('Sold', row)
            if r != None:
                sldDate = re.search('.*?(?= Sold)', row).group(0)
                sldDate = str(datetime.datetime.strptime(sldDate, '%m/%d/%y'))
                sldAmt = int(re.search('(?<=Sold \$).*?(?=[\+\- ]|$)', row).group(0).replace(",", ""))
                newPH.append((sldDate, sldAmt))

    except:
        print("cant\'t get price hist")
    return newPH


def getTaxHist(houseRec):
    newTH = []
    try:
        th = houseRec['taxHist']
        for row in th:
            item = re.search('^\d{4}',row) # check for presence of year
            if item != None:
                taxYear = int(item.group(0))
                item = re.search('(?<=\d{4} \$).*?(?= )',row).group(0)
                txAmt = int(item.replace(",", ""))
                newTH.append((taxYear, txAmt))
    except:
        print("cant\'t get tax history")
    return newTH


if __name__ == "__main__":

    zipScraped = "28803"
    batch = [1,2,3,4]

    for b in batch:
        startClean(zipScraped, b)

    # zipScraped = "28786"
    # batch = np.arange(0,9)
    # for b in batch:
    #     startClean(zipScraped, b)


