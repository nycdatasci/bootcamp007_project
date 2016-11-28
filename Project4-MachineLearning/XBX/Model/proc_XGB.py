import pandas as pd
import numpy as np
from sklearn.metrics import mean_absolute_error
from sklearn.cross_validation import KFold
import xgboost as xgb
# from xgboost import XGBRegressor

print "Start"

def xg_eval_mae(yhat, dtrain):
    y = dtrain.get_label()
    return 'mae', mean_absolute_error(y, yhat)

SEED = 0

train = pd.read_csv("./raw/train_proc.csv")
test = pd.read_csv("./raw/test_proc.csv")

print train.head()
print test.head()

X = train.iloc[:, :-1]
y = train.iloc[:, -1]

# train.drop(["loss"], axis=1, inplace=True)
# test.drop(axis=1, inplace=True)

n_train = train.shape[0]
train_test = pd.concat((train, test)).reset_index(drop=True)

print "train_test"
print train_test.head()

# features = train.columns

xgtrain = xgb.DMatrix(X, label=y)
xgtest = xgb.DMatrix(test)

params = {
    'min_child_weight': 1,
    'eta': 0.01,
    'colsample_bytree': 0.5,
    'max_depth': 12,
    'subsample': 0.8,
    'alpha': 1,
    'gamma': 1,
    'silent': 1,
    'verbose_eval': True,
    'seed': SEED
}

res = xgb.cv(params, xgtrain, num_boost_round=1000, nfold=10, seed=SEED, stratified=False,
             early_stopping_rounds=15, verbose_eval=10, show_stdv=True, feval=xg_eval_mae, maximize=False)

print res

best_nrounds = res.shape[0] - 1
print best_nrounds
cv_mean = res.iloc[-1, 0]
cv_std = res.iloc[-1, 1]
print 'cv means: {} {}'.format(cv_mean, cv_std)

gbdt = xgb.train(params, xgtrain, best_nrounds)

print "outputting"
subm = pd.read_csv("sample_submission.csv")
subm.iloc[:, 1] = gbdt.predict(xgtest)
print subm
subm.to_csv("xgb_starter.csv", index=None)


# kf = KFold(len(train), n_folds=5, random_state=SEED)
#
# n_est = np.array([1000, 1500, 2000, 2500, 3000])
# n_mae = []
# for n in n_est:
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
#
    #     model = xgb.train(params, xgtrain)
    #     prediction = model.predict(xgtest)
    #
    #     print prediction
    #
    #     XGB_model = XGBRegressor(max_depth=12, n_estimators=n, gamma=1, silent=1, subsample=0.8, )
    #     XGB_model.fit(X_train,Y_train)
    #
    #
    #
    #     res = mean_absolute_error(Y_test, XGB_model.predict(X_test))
    #     cv_mae.append(res)
    #     print res
    # n_mae.append(np.mean(cv_mae))
    # print n_mae

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
# ax.set_xticks(range(len(n_est)))
# ax.set_xticklabels(n_est,rotation='vertical')
# #Plot the accuracy for all combinations
# plt.savefig("proc_XGB_kaggle_params.png")
#
# # cv res, ntrees