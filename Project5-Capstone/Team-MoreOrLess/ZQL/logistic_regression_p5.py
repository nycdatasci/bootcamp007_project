# -*- coding: utf-8 -*-
"""
Created on Mon Dec 19 11:16:17 2016

@author: ZIQIAOLIU
"""

import numpy as np
import pandas as pd
import statsmodels.api as sm
import matplotlib.pyplot as plt
from patsy import dmatrices
from sklearn.linear_model import LogisticRegression
from sklearn.cross_validation import train_test_split
from sklearn import metrics


numer_data = pd.read_csv("~/Downloads/numerai_datasets1214/numerai_training_data.csv")
numer_data_test=pd.read_csv("~/Downloads/numerai_datasets1214/numerai_tournament_data.csv")


x = numer_data.iloc[:,:21]
#x.describe()

y = numer_data.iloc[:,-1]

 
model = LogisticRegression()
model = model.fit(x, y)

predict = model.predict(x)

predict_test = model.predict(numer_data_test)
print predict

# generate class probabilities
probs_test = model.predict_proba(numer_data_test)
print probs_test

# generate evaluation metrics
print metrics.accuracy_score(y, predict)
print metrics.roc_auc_score(y, probs_test[:, 1])

t_id=numer_data_test['t_id']
t_id=np.array(t_id, dtype=int)

result= pd.DataFrame(columns=["t_id","probability"])

#del result
result = pd.concat([result, pd.DataFrame({"t_id": t_id, "probability": probs_test[:, 1]})])
# rearrange columns
result = result[['t_id', 'probability']]
result.t_id = result.t_id.astype(int)
result.to_csv("~/Downloads/numerai_datasets1214/result.csv", index = False)

#logloss = log_loss(y,predict)
#accuracy = accuracy_score(labels_test, prob_predictions_class_test, normalize=True,sample_weight=None)
#print 'accuracy', accuracy
#print 'logloss', logloss

