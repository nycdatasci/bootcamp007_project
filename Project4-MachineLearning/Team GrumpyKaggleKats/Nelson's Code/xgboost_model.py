# Packages
import pandas as pd
import numpy as np
import xgboost as xgb
from sklearn.metrics import mean_absolute_error
from sklearn.cross_validation import KFold

# Read in data
train = pd.read_csv('input/trainv3.csv')
test = pd.read_csv('input/testv3.csv')

#train_original = pd.read_csv('input/trainv3.csv').drop(['id','loss'],1)
test['loss'] = np.nan
joined = pd.concat([train, test])

# Custom evaluation function
def evalerror(preds, dtrain):
    labels = dtrain.get_label()
    return 'mae', mean_absolute_error(np.exp(preds), np.exp(labels))

# Convert to factors and add classes in categories present in test but not train
for column in list(train.select_dtypes(include=['object']).columns):
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

train = joined[joined['loss'].notnull()]
test = joined[joined['loss'].isnull()]

# Separate training set and response variables
shift = 200
y = np.log(train['loss'] + shift)
ids = test['id']
ids_train = train['id']
X = train.drop(['id','loss'], 1)
X_test = test.drop(['id','loss'], 1)

# Shuffle data
sample = np.arange(X.shape[0])
np.random.shuffle(sample)
print ids_train[sample[0:5]]
ids_train = ids_train[sample].reset_index(drop=True)
print '\n'
print ids_train[0:5]
X = X.iloc[sample,:].reset_index(drop=True)
y = y[sample].reset_index(drop=True)

# XGBoost parameters
RANDOM_STATE = 2016
params = {
    'min_child_weight': 1,
    'eta': 0.01,
    'eta_decay' : 0.9996,
    'colsample_bytree': 0.5,
    'max_depth': 12,
    'subsample': 0.8,
    'alpha': 1,
    'gamma': 1,
    'silent': 1,
    'verbose_eval': True,
    'seed': RANDOM_STATE
}

xgtest = xgb.DMatrix(X_test)

# Number of KFolds
n_folds = 5
kf = KFold(X.shape[0], n_folds=n_folds, shuffle = True)
pred_test = 0
temp_cv_score = []

## CV loss data
cv_loss = pd.DataFrame(columns=["id","loss"])

for i, (train_index, test_index) in enumerate(kf):
    print "-" * 80
    print('\n Fold %d' % (i + 1))

    # Split train and validation sets
    X_train, X_val = X.iloc[train_index], X.iloc[test_index]
    y_train, y_val = y.iloc[train_index], y.iloc[test_index]

    # Convert to special xgboost data structure
    xgtrain = xgb.DMatrix(X_train, label=y_train)
    xgtrain_2 = xgb.DMatrix(X_val, label=y_val)

    # Used to print evaluations
    watchlist = [(xgtrain, 'train'), (xgtrain_2, 'eval')]

    # Train and predict validation and test scores
    model = xgb.train(params, xgtrain, 10000, watchlist, feval=evalerror, verbose_eval=True, early_stopping_rounds= 300)
    pred_cv = np.exp(model.predict(xgtrain_2, ntree_limit=model.best_ntree_limit)) - shift
    pred_test += np.exp(model.predict(xgtest, ntree_limit=model.best_ntree_limit)) - shift

    temp_cv_score.append(mean_absolute_error(pred_cv, np.exp(y_val) - shift))
    #train_pred = np.exp(model.predict(xgtrain_org, ntree_limit = model.best_ntree_limit)) - shift
    #train_score = mean_absolute_error(train_pred, np.exp(y_val) - shift)
    cv_loss = pd.concat([cv_loss, pd.DataFrame({"id": ids_train[test_index], "loss": pred_cv})])

    print ids_train[test_index]

    print ('\n Fold %d' % (i + 1) + ' score: ' + str(temp_cv_score[i]))
    #print ('\n Fold %d' % (i + 1) + ' score: ' + str(train_score))

finalscore = np.mean(temp_cv_score)
print('\n Final Score: ' + str(finalscore))

# Validation and test predictions to csv files
submission = pd.DataFrame()
submission['loss'] = pred_test/n_folds
submission['id'] = ids
name_string = 'submission_xgboost_' + str(n_folds) + '_' + \
               str(finalscore) + '.csv'
submission.to_csv(name_string, index=False)

name_string2 = "xgboost_CV_" + str(n_folds) + '_' + \
                '_' + str(finalscore) + '.csv'
cv_loss['id'] = cv_loss['id'].astype('int')
cv_loss.to_csv(name_string2, index = False)

print('\n cv scores: ')
print(temp_cv_score)