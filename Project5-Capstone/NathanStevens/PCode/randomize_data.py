# -*- coding: utf-8 -*-
"""
Created on Fri Dec 02 12:14:16 2016

@author: nathan
"""
import random
import unicodecsv as csv

trees_2005_file = '../raw_data/Tree_Census_2005.csv'
rtrees_2005_file = '../raw_data/RTree_Census_2005.csv'

lines = []

with open(trees_2005_file) as f:
    reader = csv.reader(f)
    lines = list(reader)
    
    print "Done reading %i lines of text ..." % len(lines)
    
    # remove the header
    header = lines[0]

    lines.pop(0)
    random.shuffle(lines)

    # add back header
    lines.insert(0, header)
    
print "Writng out %i lines of text ..." % len(lines)
outFile = open(rtrees_2005_file, 'wb')
wr = csv.writer(outFile, dialect='excel')
wr.writerows(lines)
outFile.close()
print "Done ..."
