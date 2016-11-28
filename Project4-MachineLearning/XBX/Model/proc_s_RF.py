import pandas as pd
import numpy as np
from sklearn.cross_validation import KFold
from sklearn.metrics import mean_absolute_error
from sklearn.ensemble import RandomForestRegressor

ntrees = np.array([100, 200, 300, 400, 500, 600, 700, 800, 900, 1000])
SEED = 0

shift = 200
train = pd.read_csv("./Processed1/train.csv")
X = train.iloc[:, :-1]
y = np.log(train.iloc[:, -1] + shift)
print y

test = pd.read_csv("./Processed1/test.csv")
X_test = test.iloc[:, :-1]
y_test = np.log(test.iloc[:, -1] + shift)

# print X, y

# print len(train)
# kf = KFold(len(train), n_folds=5, random_state=SEED)

# n_mae = []
# for n in ntrees:
#     print "num of trees"
#     print n
#     cv_mae = []
#     i = 0
#     for i_train, i_test in kf:
#         i += 1
#         print "cv #: ", i
#         # print i_train, i_test
#         X_train, X_test, Y_train, Y_test = X.iloc[i_train, :], X.iloc[i_test, :], y.iloc[i_train], y.iloc[i_test]
#         # print X_train, X_test, Y_train, Y_test
#         RF_model = RandomForestRegressor(n_estimators=n, n_jobs=12, random_state=SEED)
#
#         RF_model.fit(X_train, Y_train)
#         res = mean_absolute_error(Y_test, RF_model.predict(X_test))
#         cv_mae.append(res)
#         print res
#     n_mae.append(np.mean(cv_mae))
#     print n_mae

print "model build"
RF_model = RandomForestRegressor(n_estimators=1000, n_jobs=12, random_state=SEED)

print "training"
RF_model.fit(X, y)

# def evalerror(preds, train):
#     return 'mae', mean_absolute_error(np.exp(preds), np.exp(train))

y_pred = np.exp(RF_model.predict(X_test)) - shift

subm = pd.DataFrame()
# submission['id'] = ids
subm['loss'] = y_pred

subm.to_csv('proc_s_rf_t.csv', index=False)

##########################################

train_full = pd.read_csv("./Processed1/train_full.csv")
X_full = train_full.iloc[:, :-1]
y_full = np.log(train_full.iloc[:, -1] + shift)
print y

test_sub = pd.read_csv("./Processed1/submit.csv")
X_sub = test_sub

# xgtrain_full = xgb.DMatrix(X_full, label=y_full)
# xgtest_sub = xgb.DMatrix(X_sub)

RF_model_overall = RandomForestRegressor(n_estimators=1000, n_jobs=12, random_state=SEED)

RF_model_overall.fit(X_full, y_full)


print "outputting overall"
submission = pd.DataFrame()
# print np.exp(gbdt.predict(xgtest)) + shift
submission["loss"] = np.exp(RF_model_overall.predict(X_sub)) + shift
print submission
submission.to_csv("proc_s_RF_tAll.csv", index=None)


