# -*- coding: utf-8 -*-
"""
Created on Thu Nov 24 19:04:26 2016

@author: ZIQIAOLIU
"""

# Read raw data from the file

import pandas as pd #provides data structures to quickly analyze data
import numpy as np
import matplotlib.pylab as plt
from sklearn.cross_validation import train_test_split
from sklearn.linear_model import LassoLarsCV

data_train = pd.read_csv("~/Downloads/train.csv")

#drop column id
data_train.drop(['id','cat112','cont1','cont6','cont11'], axis=1, inplace=True)

# drop column cat112
#data_train.drop("cat112",1, inplace=True)

print (data_train.head(5))

#subset categorical data, find index of cat116
index = list(data_train.index)
print index[0:10]

# 114 --- cat 116
data_train.columns.get_loc("cat116")
data_train.columns.get_loc("loss")

#subset 0:114
cat = data_train.iloc[:,:115]
print (cat.head(5))

cont = data_train.iloc[:,115:]
print (cont.head(5))

#x=pandas.get_dummies(cat.iloc[:,0])
#type(x)

cat_dummy=pd.DataFrame([])
for i in range(0,115):
    print i
    tmp=pd.get_dummies(cat.iloc[:,i])
    tmp.columns = cat.columns[i] + tmp.columns
    cat_dummy=pd.concat([cat_dummy.reset_index(drop=True),tmp],axis=1)
    
print (cat_dummy.head(5))
    
x = pd.concat([cat_dummy.reset_index(drop=True),cont],axis=1)
x.drop(["loss"],axis=1, inplace=True)
print (x.head(5))
y = np.log(data_train['loss'].values + 200)

pred_train, pred_test, tar_train, tar_test = train_test_split(x, y, 
                                                              test_size=.2, random_state=123)

del x,y,tmp,index,cat,cat_dummy,data_train
model=LassoLarsCV(cv=5, precompute=False).fit(pred_train,tar_train)

import pickle
model_pkl = open('lasso.pkl', 'w')
pickle.dump(model,model_pkl)
model_pkl.close()

## read model
model_path = open('lasso.pkl','r')
model = pickle.load(model_path)
model_path.close()

print model.alpha
pred_train.
# plot coefficient progression
m_log_alphas = -np.log10(model.alphas_)
ax = plt.gca()
plt.plot(m_log_alphas, model.coef_path_.T)
plt.axvline(-np.log10(model.alpha_), linestyle='--', color='k',
            label='alpha CV')
plt.ylabel('Regression Coefficients')
plt.xlabel('-log(alpha)')
plt.title('Regression Coefficients Progression for Lasso Paths')

# plot mean square error for each fold
m_log_alphascv = -np.log10(model.cv_alphas_)
plt.figure()
plt.plot(m_log_alphascv, model.cv_mse_path_, ':')
plt.plot(m_log_alphascv, model.cv_mse_path_.mean(axis=-1), 'k',
         label='Average across the folds', linewidth=2)
plt.axvline(-np.log10(model.alpha_), linestyle='--', color='k',
            label='alpha CV')
plt.legend()
plt.xlabel('-log(alpha)')
plt.ylabel('Mean squared error')
plt.title('Mean squared error on each fold')


##process test dataset
#Read test dataset
dataset_test = pd.read_csv("~/Downloads/test.csv")
#Save the id's for submission file
ID = dataset_test['id']
#Drop unnecessary columns
dataset_test.drop('id',axis=1,inplace=True)

