import pandas as pd
import numpy as np
from sklearn.metrics import mean_absolute_error
from sklearn.cross_validation import KFold
from xgboost import XGBRegressor

print "Start"

SEED = 0

train = pd.read_csv("train_proc.csv")
X = train.iloc[:, :-1]
y = train.iloc[:, -1]

kf = KFold(len(train), n_folds=5, random_state=SEED)

n_est = np.array([100,500,1000])

n_mae = []
for n in n_est:
    print "num of trees"
    print n
    cv_mae = []
    i = 0
    for i_train, i_test in kf:
        i += 1
        print "cv #: ", i
        # print i_train, i_test
        X_train, X_test, Y_train, Y_test = X.iloc[i_train, :], X.iloc[i_test, :], y.iloc[i_train], y.iloc[i_test]
        # print X_train, X_test, Y_train, Y_test


        XGB_model = XGBRegressor(n_estimators=n,seed=SEED)
        XGB_model.fit(X_train,Y_train)


        res = mean_absolute_error(Y_test, XGB_model.predict(X_test))
        cv_mae.append(res)
        print res
    n_mae.append(np.mean(cv_mae))
    print n_mae

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

#Set figure size
plt.rc("figure", figsize=(25, 10))

#Plot the MAE of all combinations
fig, ax = plt.subplots()
plt.plot(n_mae)
#Set the tick names to names of combinations
ax.set_xticks(range(len(n_est)))
ax.set_xticklabels(n_est,rotation='vertical')
#Plot the accuracy for all combinations
plt.savefig("proc_XGB.png")

# cv res, ntrees