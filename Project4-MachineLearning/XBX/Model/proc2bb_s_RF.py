import pandas as pd
import numpy as np
from sklearn.cross_validation import KFold
from sklearn.metrics import mean_absolute_error
from sklearn.ensemble import RandomForestRegressor

# ntrees = np.array([100, 200, 300, 400, 500, 600, 700, 800, 900, 1000])
SEED = 0

shift = 200
train = pd.read_csv("./Processed2v2/train_encode2_v2.csv")
X = train.iloc[:, 1:-1]
# X.iloc[:, 0:116] = X.iloc[:, 0:116] - 1
y = np.log(train.iloc[:, -1] + shift)
print X.head()

test = pd.read_csv("./Processed2v2/test_encode2_v2.csv")
X_test = test.iloc[:, 1:-1]
# X_test.iloc[:, 0:116] = X_test.iloc[:, 0:116] - 1
y_test = np.log(test.iloc[:, -1] + shift)
print X_test.head()


print "model build"
RF_model = RandomForestRegressor(n_estimators=2000, n_jobs=8, random_state=SEED)

print "training"
RF_model.fit(X, y)

# def evalerror(preds, train):
#     return 'mae', mean_absolute_error(np.exp(preds), np.exp(train))

y_pred = np.exp(RF_model.predict(X_test)) - shift

subm = pd.DataFrame()
# submission['id'] = ids
subm['loss'] = y_pred

subm.to_csv('proc2bb_s_RF_t.csv', index=False)

##########################################

train_full = pd.read_csv("./Processed2v2/train_full_encode2_v2.csv")
X_full = train_full.iloc[:, 1:-1]
# X_full.iloc[:, 0:116] = X_full.iloc[:, 0:116] - 1
y_full = np.log(train_full.iloc[:, -1] + shift)
print X_full

test_sub = pd.read_csv("./Processed2v2/submit_encode2_v2.csv")
X_sub = test_sub.iloc[:, 1:]
# X_sub.iloc[:, 0:116] = X_sub.iloc[:, 0:116] - 1
print X_sub.iloc[:, 110:120].head()


RF_model_overall = RandomForestRegressor(n_estimators=2000, n_jobs=12, random_state=SEED)

RF_model_overall.fit(X_full, y_full)


print "outputting overall"
submission = pd.DataFrame()
# print np.exp(gbdt.predict(xgtest)) + shift
submission["loss"] = np.exp(RF_model_overall.predict(X_sub)) + shift
print submission
submission.to_csv("proc2bb_s_RF_tAll.csv", index=None)


