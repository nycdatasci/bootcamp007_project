# -*- coding: utf-8 -*-
"""
Created on Wed Nov 30 19:58:56 2016
A class for testing functions in the main class
@author: nathan
"""
import blockcode

# function for testing block codes
def testBlockCodes(boroCodes):    
    print('BoroCodes Code:', len(boroCodes['Brooklyn']))
    
    blockCodes = boroCodes['Brooklyn']

    for key in blockCodes:
        bcInfo = blockCodes[key]
        
        if bcInfo.get_size() > 1:
            #-73.81447097519414 40.839612253681175 Bronx Test
            #-73.82701324463507 40.65085989912992 Queens Test        
            #-73.9048175268759 40.62547796344267  Brookyln       
            print bcInfo.get_size()

    bc = blockcode.getBlockCode(blockCodes, -73.9048, 40.6255)
    print "Found Block Code " + bc
