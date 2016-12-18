import pandas as pd
import numpy as np
from sklearn.cross_validation import KFold
from sklearn.metrics import mean_absolute_error
from sklearn.ensemble import RandomForestRegressor


train = pd.read_csv('./raw/train.csv')
test = pd.read_csv('./raw/test.csv')
test['loss'] = np.nan
joined = pd.concat([train, test])


def evalerror(preds, dtrain):
    labels = dtrain.get_label()
    return 'mae', mean_absolute_error(np.exp(preds), np.exp(labels))

if __name__ == '__main__':
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

    # pd.DataFrame(train).to_csv("train_proc2.csv", index=False)
    # pd.DataFrame(test).to_csv("test_proc2.csv", index=False)

    print train.head()
    print test.head()




    shift = 200
    y = np.log(train['loss'] + shift)
    ids = test['id']
    X = train.drop(['loss', 'id'], 1)
    X_test = test.drop(['loss', 'id'], 1)

    # print X.head()

    # SEED = 0
    #
    # kf = KFold(len(train), n_folds=5, random_state=SEED)
    #
    # ntrees = np.array([400, 500, 600, 700, 800, 900, 1000, 1100, 1200])
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
    #         RF_model = RandomForestRegressor(n_estimators=n, n_jobs=15, random_state=SEED)
    #
    #         RF_model.fit(X_train, Y_train)
    #         res = mean_absolute_error(np.exp(Y_test), np.exp(RF_model.predict(X_test)))
    #         cv_mae.append(res)
    #         print res
    #     n_mae.append(np.mean(cv_mae))
    #     print n_mae

######################################################
    print "model start"
    RF_model = RandomForestRegressor(n_estimators=2000, n_jobs=15, random_state=SEED)
    print "fitting whole train set"
    RF_model.fit(X, y)
    print "calc mae"
    # train_overall_res = mean_absolute_error(y, RF_model.predict(X))
    # print "overall training result: "

    prediction = np.exp(RF_model.predict(X_test)) - shift

    submission = pd.DataFrame()
    submission['id'] = ids
    submission['loss'] = prediction

    submission.to_csv('proc2_RF.csv', index=False)

    #
    # y_real_test = RF_model.predict(X_test)
    # print "y real test: ", y_real_test
    # pd.DataFrame(y_real_test).to_csv("proc_RF_test_y.csv", index=False)


