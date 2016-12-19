import pandas as pd
import numpy as np
import os

path = '/users/sippiejason/datascience/webscraping/realestate/data/'
#inputFile = 'zillowCleaned' + zipScraped + '-' + suf + '.csv'

filePrefix = "houseObs"
fileExtension = "csv"
outputFile = "allHouseObservations20161213.csv"

allObs = pd.DataFrame()
for file in os.listdir(path):
    if (file.startswith(filePrefix) & file.endswith(fileExtension)):
        aFile = pd.read_csv(path + file,index_col=0)
        allObs = allObs.append(aFile)


# join in address info
uniqueAddr1 = pd.read_csv(path + 'uniqueAddrs28786.csv')
uniqueAddr2 = pd.read_csv(path + 'uniqueAddrs28803.csv')
uniqueAddr = uniqueAddr1.append(uniqueAddr2)
uniqueAddr = uniqueAddr.rename(columns={'addrQuery': 'AddrQuery','countyName':'CountyName'})

uniqueAddr.drop('ZipCode', axis=1, inplace=True)
uniqueAddr.drop('HouseID', axis=1, inplace=True)


mergedData = pd.merge(allObs, uniqueAddr, on='AddrQuery')


mergedData.to_csv(path + outputFile)



