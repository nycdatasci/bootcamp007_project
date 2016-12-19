# -*- coding: utf-8 -*-
"""
Created on Fri Dec 16 20:02:10 2016

@author: ZIQIAOLIU
"""

"""
Tune the Number and Size of Decision Trees with XGBoost in Python
http://machinelearningmastery.com/tune-number-size-decision-trees-xgboost-python/
1.How to evaluate the effect of adding more decision trees to your XGBoost model.
2.How to evaluate the effect of creating larger decision trees to your XGBoost model.
3.How to investigate the relationship between the number and depth of trees on your problem.

"""
# XGBoost on Otto dataset, Tune n_estimators
import pandas as pd
import numpy as np
from xgboost import XGBClassifier
from sklearn.grid_search import GridSearchCV
from sklearn.cross_validation import StratifiedKFold
from sklearn.preprocessing import LabelEncoder
import matplotlib
matplotlib.use('Agg')
from matplotlib import pyplot

# load data
numer_data = pd.read_csv("~/Downloads/numerai_datasets1214/numerai_training_data.csv")

# split data into X and y
x = numer_data.iloc[:,:21]
y = numer_data.iloc[:,-1]


# grid search
model5= XGBClassifier()
n_estimators = [50, 100, 150, 200]
max_depth = [2, 4, 6, 8]
learning_rate=[0.001, 0.01, 0.1, 0.2, 0.3]
subsample =[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 1.0]
#colsample_bytree =[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 1.0]
#colsample_bylevel =[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 1.0]
min_child_weight=[1,3,5,7]
print(max_depth)
param_grid = dict(max_depth=max_depth, n_estimators=n_estimators,
                  learning_rate=learning_rate,
                  subsample=subsample,
                  #colsample_bylevel=colsample_bylevel,
                  colsample_bytree=0.6,
                  min_child_weight=min_child_weight
                  )
param_grid=param_grid.items()
kfold = StratifiedKFold(y, n_folds=10, shuffle=True, random_state=7)
grid_search = GridSearchCV(model5, param_grid, scoring="log_loss", n_jobs=-1, cv=kfold)
result = grid_search.fit(x, y)

param = {
 'n_estimators':[50,100,150],
 'max_depth':[2,3],
 'min_child_weight':[1,3],
 'colsample_bytree':[0.6,0.8],
 'colsample_bylevel':[0.2,0.3],
'subsample':[0.5,0.8],
'learning_rate':[0.01, 0.1]
}


# https://github.com/dmlc/xgboost/blob/master/doc/parameter.md

gsearch1 = GridSearchCV(estimator = XGBClassifier( 
        objective= 'binary:logistic', 
        seed=1), 
    param_grid = param, 
    scoring='log_loss',
    cv=10,
    verbose = 1)
results1=gsearch1.fit(x, y)

# summarize results
print("Best: %f using %s" % (results1.best_score_, results1.best_params_))
means, stdevs = [], []
for params, mean_score, scores in result.grid_scores_:
	stdev = scores.std()
	means.append(mean_score)
	stdevs.append(stdev)
	print("%f (%f) with: %r" % (mean_score, stdev, params))
# plot
pyplot.errorbar(n_estimators, means, yerr=stdevs)
pyplot.title("XGBoost n_estimators vs Log Loss")
pyplot.xlabel('n_estimators')
pyplot.ylabel('Log Loss')
#pyplot.savefig('n_estimators.png')

# plot results
scores = [x[1] for x in result.grid_scores_]
scores = np.array(scores).reshape(len(max_depth), len(n_estimators))
for i, value in enumerate(max_depth):
    pyplot.plot(n_estimators, scores[i], label='depth: ' + str(value))
pyplot.legend()
pyplot.xlabel('n_estimators')
pyplot.ylabel('Log Loss')
pyplot.savefig('n_estimators_vs_max_depth.png')