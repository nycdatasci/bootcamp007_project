# -*- coding: utf-8 -*-
"""
Created on Sat Nov 26 00:21:37 2016

@author: ZIQIAOLIU
"""

## multiple linear regression 


##ridge regression
import pandas as pd

## define function
def dummy_data(data):
    #import pandas as pd
    if data.dtype.name!="category":
        print ('no dummy')
    else:       
        data_dummy=pd.DataFrame([])
        for i in range(0, len(data.columns)):
            print i
            tmp=pd.get_dummies(data.iloc[:,i])
            tmp.columns = data.columns[i] + tmp.columns
            data_dummy=pd.concat([data_dummy.reset_index(drop=True),tmp],axis=1)
            print (data_dummy.head(5))
    
    
data_train = pd.read_csv("~/Downloads/train.csv")

#drop column id
data_train.drop(['id','cat112','cont1','cont6','cont11'], axis=1, inplace=True)
cat = data_train.iloc[:,:115]
print (cat.head(5))

dummy_data(cat)