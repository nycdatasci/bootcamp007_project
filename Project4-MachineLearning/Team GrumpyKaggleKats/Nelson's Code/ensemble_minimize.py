# Libraries
import pandas as pd
import numpy as np
from scipy.optimize import minimize
from sklearn.metrics import mean_absolute_error

#Read in data
train = pd.read_csv('input/trainv3.csv')
cv_0 = train[['id','loss']]
cv_1 = pd.read_csv('keras_CV_10_60_1163.6405263.csv').sort(columns = 'id')
cv_2 = pd.read_csv('keras_CV_10_60_1164.82209107.csv').sort(columns = 'id')
cv_3 = pd.read_csv('keras_CV_10_60_1176.67957987.csv').sort(columns = 'id')
cv_4 = pd.read_csv('keras_CV_10_60_1177.70232953.csv').sort(columns = 'id')
cv_5 = pd.read_csv('keras_CV_10_60_1198.86896814.csv').sort(columns = 'id')
cv_6 = pd.read_csv('xgboost_CV_10__1132.7827513.csv').sort(columns = 'id')
cv_7 = pd.read_csv('xgboost_CV_10__1133.00639747.csv').sort(columns = 'id')
cv_8 = pd.read_csv('xgboost_CV_10__1133.42906567.csv').sort(columns = 'id')
cv_9 = pd.read_csv('xgboost_CV_10__1138.0532475.csv').sort(columns = 'id')
cv_10 = pd.read_csv('keras_CV_10_80_1167.07515103.csv').sort(columns = 'id')
cv_11 = pd.read_csv('xgboost_CV_featurecomb_10_1130.662975.csv').sort(columns = 'id')
cv_12 = pd.read_csv('Keras_bag_CV_10_1134.10793839.csv').sort(columns = 'id')
cv_13 = pd.read_csv('10Fold_50Forest_CV_losses.csv').sort(columns = 'id')
cv_14 = pd.read_csv('Keras_bag_CV_5_1139.87281409.csv').sort(columns = 'id')
cv_11['loss'] = np.exp(cv_11['loss']) - 200

# rename columns
cv_1.rename(columns = {'loss':'loss_1'}, inplace=True)
cv_2.rename(columns = {'loss':'loss_2'}, inplace=True)
cv_3.rename(columns = {'loss':'loss_3'}, inplace=True)
cv_4.rename(columns = {'loss':'loss_4'}, inplace=True)
cv_5.rename(columns = {'loss':'loss_5'}, inplace=True)
cv_6.rename(columns = {'loss':'loss_6'}, inplace=True)
cv_7.rename(columns = {'loss':'loss_7'}, inplace=True)
cv_8.rename(columns = {'loss':'loss_8'}, inplace=True)
cv_9.rename(columns = {'loss':'loss_9'}, inplace=True)
cv_10.rename(columns = {'loss':'loss_10'}, inplace=True)
cv_11.rename(columns = {'loss':'loss_11'}, inplace=True)
cv_12.rename(columns = {'loss':'loss_12'}, inplace=True)
cv_13.rename(columns = {'loss':'loss_13'}, inplace=True)
cv_14.rename(columns = {'loss':'loss_14'}, inplace=True)

# Combine to form complete dataframe
cv_list = [cv_0,cv_1,cv_4,cv_5,cv_6,cv_7,
           cv_11,cv_12,cv_13,cv_14]
cv_final = reduce(lambda left,right: \
                  pd.merge(left,right,on='id'), cv_list)

#Variables to use in optimization
train = cv_final.drop(['id','loss'],1)
response = cv_final['loss']

# Function to calculate MAE by passing in weights
def MAE_func(weights):
    """
    scipy minimize will pass the weights as a numpy array
    """
    final_prediction = 0
    for weight, prediction in zip(weights, predictions):
            final_prediction += weight*prediction

    return mean_absolute_error(response, final_prediction)

# Collect predictions
predictions = []
for col in train.columns:
    predictions.append(train[col])

# Start with random weights
starting_values = np.random.uniform(size=len(predictions))

# adding constraints and a different solver as suggested by user 16universe
cons = ({'type': 'eq', 'fun': lambda w: 1-sum(w)})

# our weights are bound between 0 and 1
bounds = [(0, 1)] * len(predictions)

# Minimize our MAE function
res = minimize(MAE_func,
               starting_values,
               method='SLSQP',
               bounds=bounds,
               constraints=cons,
               options={'maxiter': 100000})

# Print results
print('Ensemble Score: {best_score}'.format(best_score=res['fun']))
print('Best Weights: {weights}'.format(weights=res['x']))