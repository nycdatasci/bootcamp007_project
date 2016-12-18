import pandas as pd
import numpy as np
from sklearn.metrics import mean_absolute_error
from sklearn.cross_validation import KFold
from sklearn.ensemble import AdaBoostRegressor

print "Start"

SEED = 0

shift = 200
train = pd.read_csv("./Processed1/train.csv")
X = train.iloc[:, :-1]
y = np.log(train.iloc[:, -1] + shift)
print y

test = pd.read_csv("./Processed1/test.csv")
X_test = test.iloc[:, :-1]

print len(train)
kf = KFold(len(train), n_folds=5, random_state=SEED)

ntrees = np.array([100, 200, 300, 400, 500, 600, 700, 800, 900, 1000])

n_mae = []
for n in ntrees:
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
        RF_model = AdaBoostRegressor(n_estimators=n, random_state=SEED)

        RF_model.fit(X_train, Y_train)
        res = mean_absolute_error(np.exp(Y_test), np.exp(RF_model.predict(X_test)))
        cv_mae.append(res)
        print res
    n_mae.append(np.mean(cv_mae))
    print n_mae
