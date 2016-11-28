###### XGBoost With feature combing ######
##### Kaggler script #####

import numpy as np
import pandas as pd
import xgboost as xgb

from datetime import datetime
from sklearn.metrics import mean_absolute_error
from sklearn.cross_validation import KFold
from scipy.stats import skew, boxcox
from sklearn.preprocessing import StandardScaler
import itertools

shift = 200
COMB_FEATURE = 'cat80,cat87,cat57,cat12,cat79,cat10,cat7,cat89,cat2,cat72,' \
               'cat81,cat11,cat1,cat13,cat9,cat3,cat16,cat90,cat23,cat36,' \
               'cat73,cat103,cat40,cat28,cat111,cat6,cat76,cat50,cat5,' \
               'cat4,cat14,cat38,cat24,cat82,cat25'.split(',')

def encode(charcode):
    r = 0
    ln = len(str(charcode))
    for i in range(ln):
        r += (ord(str(charcode)[i]) - ord('A') + 1) * 26 ** (ln - i - 1)
    return r

fair_constant = 2
def fair_obj(preds, dtrain):
    labels = dtrain.get_label()
    x = (preds - labels)
    den = abs(x) + fair_constant
    grad = fair_constant * x / (den)
    hess = fair_constant * fair_constant / (den * den)
    return grad, hess

def xg_eval_mae(yhat, dtrain):
    y = dtrain.get_label()
    return 'mae', mean_absolute_error(np.exp(y)-shift,
                                      np.exp(yhat)-shift)
def mungeskewed(train, test, numeric_feats):
    ntrain = train.shape[0]
    test['loss'] = 0
    train_test = pd.concat((train, test)).reset_index(drop=True)
    skewed_feats = train[numeric_feats].apply(lambda x: skew(x.dropna()))
    skewed_feats = skewed_feats[skewed_feats > 0.25]
    skewed_feats = skewed_feats.index

    for feats in skewed_feats:
        train_test[feats] = train_test[feats] + 1
        train_test[feats], lam = boxcox(train_test[feats])
    return train_test, ntrain

if __name__ == "__main__":

    print('\nStarted')
    directory = 'input/'
    train = pd.read_csv(directory + 'train.csv')
    test = pd.read_csv(directory + 'test.csv')

    numeric_feats = [x for x in train.columns[1:-1] if 'cont' in x]
    categorical_feats = [x for x in train.columns[1:-1] if 'cat' in x]
    train_test, ntrain = mungeskewed(train, test, numeric_feats)

    print('')
    for comb in itertools.combinations(COMB_FEATURE, 2):
        feat = comb[0] + "_" + comb[1]
        train_test[feat] = train_test[comb[0]] + train_test[comb[1]]
        train_test[feat] = train_test[feat].apply(encode)
        print('Analyzing Columns:', feat)

    print('')
    for col in categorical_feats:
        print('Analyzing Column:', col)
        train_test[col] = train_test[col].apply(encode)

    print(train_test[categorical_feats])

    ss = StandardScaler()
    train_test[numeric_feats] = \
        ss.fit_transform(train_test[numeric_feats].values)

    train = train_test.iloc[:ntrain, :].copy()
    test = train_test.iloc[ntrain:, :].copy()

    print('\nMedian Loss:', train.loss.median())
    print('Mean Loss:', train.loss.mean())

    ids = pd.read_csv('input/test.csv')['id']
    ids_train = train['id']
    train_y = np.log(train['loss'] + shift)
    train_x = train.drop(['loss','id'], axis=1)
    test_x = test.drop(['loss','id'], axis=1)

    n_folds = 10
    cv_sum = 0
    early_stopping = 100
    fpred = []
    xgb_rounds = []

    d_train_full = xgb.DMatrix(train_x, label=train_y)
    d_test = xgb.DMatrix(test_x)

    ## CV loss data
    cv_loss = pd.DataFrame(columns=["id", "loss"])

    kf = KFold(train.shape[0], n_folds=n_folds)
    for i, (train_index, test_index) in enumerate(kf):
        print('\n Fold %d' % (i+1))
        X_train, X_val = train_x.iloc[train_index], train_x.iloc[test_index]
        y_train, y_val = train_y.iloc[train_index], train_y.iloc[test_index]

        rand_state = 2016

        params = {
            'seed': 0,
            'colsample_bytree': 0.7,
            'silent': 1,
            'subsample': 0.7,
            'learning_rate': 0.03,
            'objective': 'reg:linear',
            'max_depth': 12,
            'min_child_weight': 100,
            'verbose' : True,
            'booster': 'gbtree'}

        d_train = xgb.DMatrix(X_train, label=y_train)
        d_valid = xgb.DMatrix(X_val, label=y_val)
        watchlist = [(d_train, 'train'), (d_valid, 'eval')]

        clf = xgb.train(params,
                        d_train,
                        100000,
                        watchlist,
                        early_stopping_rounds=50,
                        obj=fair_obj,
                        feval=xg_eval_mae)

        xgb_rounds.append(clf.best_iteration)
        scores_val = clf.predict(d_valid, ntree_limit=clf.best_ntree_limit)
        cv_score = mean_absolute_error(np.exp(y_val), np.exp(scores_val))
        print('eval-MAE: %.6f' % cv_score)
        y_pred = np.exp(clf.predict(d_test, ntree_limit=clf.best_ntree_limit)) - shift

        cv_loss = pd.concat([cv_loss, pd.DataFrame({"id": ids_train[test_index], "loss": scores_val})])

        if i > 0:
            fpred = pred + y_pred
        else:
            fpred = y_pred
        pred = fpred
        cv_sum = cv_sum + cv_score

    mpred = pred / n_folds
    score = cv_sum / n_folds
    print('Average eval-MAE: %.6f' % score)
    n_rounds = int(np.mean(xgb_rounds))

    print("Writing results")
    result = pd.DataFrame(mpred, columns=['loss'])
    result["id"] = ids
    result = result.set_index("id")
    print("%d-fold average prediction:" % n_folds)

    now = datetime.now()
    score = str(round((cv_sum / n_folds), 6))
    sub_file = 'submission_' + str(n_folds) + 'fold-average-xgb_fairobj_' + str(score) + '_' + str(
        now.strftime("%Y-%m-%d-%H-%M")) + '.csv'
    print("Writing submission: %s" % sub_file)
    result.to_csv(sub_file, index=True, index_label='id')

    name_string2 = "xgboost_CV_featurecomb_" + str(n_folds) + \
                   '_' + str(score) + '.csv'
    cv_loss['id'] = cv_loss['id'].astype('int')
    cv_loss.to_csv(name_string2, index=False)