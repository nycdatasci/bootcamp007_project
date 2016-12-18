import pandas as pd
import numpy as np
from sklearn.cross_validation import KFold
from sklearn.metrics import mean_absolute_error
from sklearn.ensemble import RandomForestRegressor

ntrees = np.array([100, 200, 300, 400, 500, 600, 700, 800, 900, 1000])
SEED = 0

train = pd.read_csv("train_proc.csv")
X = train.iloc[:, :-1]
y = train.iloc[:, -1]
# # print X, y
#
# # print len(train)
# kf = KFold(len(train), n_folds=5, random_state=SEED)
#
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
#
# import matplotlib
# matplotlib.use('Agg')
# import matplotlib.pyplot as plt
#
# #Set figure size
# plt.rc("figure", figsize=(25, 10))
#
# #Plot the MAE of all combinations
# fig, ax = plt.subplots()
# plt.plot(n_mae)
# #Set the tick names to names of combinations
# ax.set_xticks(range(len(ntrees)))
# ax.set_xticklabels(ntrees,rotation='vertical')
# #Plot the accuracy for all combinations
# plt.savefig("proc_RF.png")

# cv res, ntrees
# [1289.7063130699314, 1286.1679206808615, 1284.9638172860064, 1284.3827534924014, 1283.9948829942284,
#  1283.8443826938887, 1283.6201162968075, 1283.5208713226923, 1283.3989149896133, 1283.3679800960149]

print "start"
test = pd.read_csv("test_proc.csv")
X_real_test = test

print "model start"
RF_model = RandomForestRegressor(n_estimators=1000, n_jobs=12, random_state=SEED)
print "fitting whole train set"
RF_model.fit(X, y)
print "calc mae"
# train_overall_res = mean_absolute_error(y, RF_model.predict(X))
# print "overall training result: "

y_real_test = RF_model.predict(X_real_test)
print "y real test: ", y_real_test
pd.DataFrame(y_real_test).to_csv("proc_RF_test_y.csv", index=False)
