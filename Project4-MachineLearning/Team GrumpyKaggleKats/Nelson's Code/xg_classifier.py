import pandas as pd
import xgboost as xgb
from sklearn.cross_validation import KFold
import numpy as np
from sklearn.metrics import mean_squared_error

train = pd.read_csv('input/train_enn1.csv')
test = pd.read_csv('input/testv4.csv')
train_original = pd.read_csv('input/trainv3.csv').drop(['loss'],1)
#test['cat118'] = np.nan
#joined = pd.concat([train, test])

print ("Factorizing categorical variables...")
features = train.columns
cats = [feat for feat in features if 'cat' in feat]
print cats
for feat in cats:
    train[feat] = pd.factorize(train[feat], sort=True)[0]
    test[feat] = pd.factorize(test[feat], sort=True)[0]
    if feat != 'cat118':
        train_original[feat] = pd.factorize(train_original[feat], sort=True)[0]

'''for column in list(train.select_dtypes(include=['object']).columns):
    if train[column].nunique() != test[column].nunique():
        set_train = set(train[column].unique())
        set_test = set(test[column].unique())
        remove_train = set_train - set_test
        remove_test = set_test - set_train

        remove = remove_train.union(remove_test)


        def filter_cat(x):
            if x in remove:
                return np.nan
            return x


        joined[column] = joined[column].apply(lambda x: filter_cat(x), 1)

    joined[column] = pd.factorize(joined[column].values, sort=True)[0]

train = joined[joined['cat118'].notnull()]
test = joined[joined['cat118'].isnull()]'''

y = train['cat118']
ids_train = train_original['id']
ids = test['id']
X = train.drop(['loss', 'cat118'], 1)
X_test = test.drop(['id','cat118'], 1)
train_original = train_original.drop(['id'],1)

sample = np.arange(X.shape[0])
np.random.shuffle(sample)
X = X.iloc[sample,:]
y = y[sample]

RANDOM_STATE = 2016
params = {
    'min_child_weight': 1,
    'eta': 0.01,
    'eta_decay': 0.9995,
    'colsample_bytree': 0.5,
    'max_depth': 12,
    'subsample': 0.8,
    'alpha': 1,
    'gamma': 1,
    'silent': 1,
    'verbose_eval': True,
    'seed': RANDOM_STATE,
    'objective':'binary:logistic',
    'eval_metric': 'auc'
}

#xgtrain = xgb.DMatrix(X, label=y)
xgtest = xgb.DMatrix(X_test)
xgtrain_org = xgb.DMatrix(train_original)

n_folds = 5
kf = KFold(X.shape[0], n_folds=n_folds, shuffle = True)
pred_test = 0
temp_cv_score = []

## CV loss data
cv_loss = pd.DataFrame(columns=["id","cat118"])

train_pred = np.zeros(train_original.shape[0])

for i, (train_index, test_index) in enumerate(kf):
    print "-" * 80
    print('\n Fold %d' % (i + 1))

    X_train, X_val = X.iloc[train_index], X.iloc[test_index]
    y_train, y_val = y.iloc[train_index], y.iloc[test_index]

    xgtrain = xgb.DMatrix(X_train, label=y_train)
    xgtrain_2 = xgb.DMatrix(X_val, label=y_val)

    watchlist = [(xgtrain, 'train'), (xgtrain_2, 'eval')]

    model = xgb.train(params, xgtrain, 5000, watchlist, verbose_eval=True, early_stopping_rounds= 100)

    pred_cv = model.predict(xgtrain_2, ntree_limit=model.best_ntree_limit)
    pred_test += model.predict(xgtest, ntree_limit=model.best_ntree_limit)
    train_pred += model.predict(xgtrain_org, ntree_limit=model.best_ntree_limit)

cv_loss = pd.DataFrame({"id": ids_train, "cat118": train_pred})

    #print ('\n Fold %d' % (i + 1) + ' score: ' + str(temp_cv_score[i]))

submission = pd.DataFrame()
submission['cat118'] = pred_test/n_folds
submission['id'] = ids
name_string = 'outlier_classification_xg.csv'
submission.to_csv(name_string, index=False)

name_string2 = 'cv_prob_outlier_classification.csv'
cv_loss['id'] = cv_loss['id'].astype('int')
cv_loss.to_csv(name_string2, index = False)