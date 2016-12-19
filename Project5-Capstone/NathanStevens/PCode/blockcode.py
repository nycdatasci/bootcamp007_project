# -*- coding: utf-8 -*-
"""
Created on Wed Nov 30 15:01:26 2016
The help fuinction for get the block given a long and latitude
@author: nathan


https://en.wikipedia.org/wiki/Decimal_degrees
"""
import numpy as np

# get the block code given and longitude and latitude. This is using
# brute force calculation to do this
def getBlockCode(blockCodes, lng, lat):
    for key in blockCodes:
        bcInfo = blockCodes[key]
              
        if(bcInfo.is_inside(lng, lat)):
            return key
            
    # just return None
    return 'Unknown'
        

# define class for storing block code information
class BlockCodeInfo(object):
    
    # default constructor
    def __init__(self, polygon_list):
        self.precision = 0.002        
        self.polygons = {}
        
        xy_means = []        
        for i in range(len(polygon_list)):
            ps = polygon_list[i]
            polygon = [[float(i) for i in xy.split(' ')] for xy in ps.split(', ')]
            
            self.polygons[i] = polygon
            
            # calculate            
            npa = np.array(polygon)
            xy_means.append(npa.mean(axis=0))

        # now geth the means tp lng and lat to speed on checking
        if len(xy_means) == 1:
            self.lng_mean = xy_means[0][0]
            self.lat_mean = xy_means[0][1]
        else:
            npa = np.array(xy_means)
            xy_means = npa.mean(axis=0)
            self.lng_mean = xy_means[0]
            self.lat_mean = xy_means[1]
                
    # method to check if point is insite polygon
    def is_inside(self, lng, lat):
        # first check we are even is within 3 blocks        
        lat_mean_diff = np.abs(self.lng_mean - lng)
        lng_mean_diff = np.abs(self.lat_mean - lat)        
        
        # 0.003 is about 3 city blocks
        if lng_mean_diff > 0.004 and lat_mean_diff > 0.004:
            return False
        
        # now actually find the correct block code
        for key in self.polygons:
            polygon = self.polygons[key]            
            
            if self.point_in_poly(lng, lat, polygon):
                return True
            '''
            for xy in polygon:            
                #print xy[0], xy[1], lng, lat
                lng_diff = np.abs(xy[0] - lng)
                lat_diff = np.abs(xy[1] - lat)
        
                if lng_diff <= self.precision and lat_diff <=  self.precision:                
                    return True
            '''
        # we got here so we are not in the point
        return False
        
    # code to check if point is inside polygon. code taken from link
    # below:
    # http://geospatialpython.com/2011/01/point-in-polygon.html
    # x is the longitude and y = latitude    
    def point_in_poly(self, x, y, poly):

        n = len(poly)
        inside = False
    
        p1x, p1y = poly[0]
        
        for i in range(n+1):
            p2x, p2y = poly[i % n]
            if y > min(p1y,p2y):
                if y <= max(p1y,p2y):
                    if x <= max(p1x,p2x):
                        if p1y != p2y:
                            xints = (y-p1y)*(p2x-p1x)/(p2y-p1y)+p1x
                        if p1x == p2x or x <= xints:
                            inside = not inside
            p1x,p1y = p2x,p2y
    
        return inside
    
    # return the length of the polygon
    def get_size(self):
        return len(self.polygons)
    
    