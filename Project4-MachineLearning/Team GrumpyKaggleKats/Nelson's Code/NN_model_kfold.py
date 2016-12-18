## import libraries
import numpy as np

np.random.seed(123)

import pandas as pd
import subprocess
from scipy.sparse import csr_matrix, hstack
from sklearn.metrics import mean_absolute_error
from sklearn.preprocessing import StandardScaler
from sklearn.cross_validation import KFold
from keras.models import Sequential
from keras.layers import Dense, Dropout, Activation
from keras.layers.normalization import BatchNormalization
from keras.callbacks import EarlyStopping, ModelCheckpoint
from keras.layers.advanced_activations import PReLU, ELU
from keras.optimizers import Adam


### functions ###
'''def save_model(model, arch_path, weights_path):
    json_string = model.to_json()
    if not os.path.isdir('cache'):
        os.mkdir('cache')
    open(arch_path, 'w').write(json_string)
    model.save_weights(weights_path, overwrite=True)

def read_model(arch_path, weights_path):
    model = model_from_json(open(arch_path).read())
    model.load_weights(weights_path)
    return model

def merge_several_folds_mean(data, nfolds):
    a = np.array(data[0])
    for i in range(1, nfolds):
        a += np.array(data[i])
    a /= nfolds
    return a.tolist()'''

####

## Batch generators ##################################################################################################################################

def batch_generator(X, y, batch_size, shuffle, y_flag = True):
    # chenglong code for fiting from generator (https://www.kaggle.com/c/talkingdata-mobile-user-demographics/forums/t/22567/neural-network-for-sparse-matrices)
    number_of_batches = np.ceil(X.shape[0] / batch_size)
    counter = 0
    sample_index = np.arange(X.shape[0])
    if shuffle:
        np.random.shuffle(sample_index)

    if (y_flag):
        while True:
            batch_index = sample_index[batch_size * counter:batch_size * (counter + 1)]
            X_batch = X[batch_index, :].toarray()
            y_batch = y[batch_index]
            counter += 1
            yield X_batch, y_batch
            if (counter == number_of_batches):
                if shuffle:
                    np.random.shuffle(sample_index)
                counter = 0
    else:
        while True:
            batch_index = sample_index[batch_size * counter:batch_size * (counter + 1)]
            print batch_index
            X_batch = X[batch_index, :].toarray()
            counter += 1
            yield X_batch
            if (counter == number_of_batches):
                if shuffle:
                    np.random.shuffle(sample_index)
                counter = 0


def batch_generatorp(X, batch_size, shuffle):
    number_of_batches = X.shape[0] / np.ceil(X.shape[0] / batch_size)
    counter = 0
    sample_index = np.arange(X.shape[0])
    while True:
        batch_index = sample_index[batch_size * counter:batch_size * (counter + 1)]
        X_batch = X[batch_index, :].toarray()
        counter += 1
        yield X_batch
        if (counter == number_of_batches):
            counter = 0


########################################################################################################################################################

## read data
train = pd.read_csv('input/trainv3.csv')
test = pd.read_csv('input/testv3.csv')

## CV loss data
cv_loss = pd.DataFrame(columns=["id","loss"])

index = list(train.index)
print index[0:10]
np.random.shuffle(index)
print index[0:10]
train = train.iloc[index]
'train = train.iloc[np.random.permutation(len(train))]'

## set test loss to NaN
test['loss'] = np.nan

## response and IDs
y = np.log(train['loss'].values + 200)
id_train = train['id'].values
print type(id_train)
id_test = test['id'].values

## stack train test
ntrain = train.shape[0]
tr_te = pd.concat((train, test), axis=0)

## Preprocessing and transforming to sparse data
sparse_data = []

f_cat = [f for f in tr_te.columns if 'cat' in f]
for f in f_cat:
    dummy = pd.get_dummies(tr_te[f].astype('category'))
    tmp = csr_matrix(dummy)
    sparse_data.append(tmp)

f_num = [f for f in tr_te.columns if 'cont' in f]
scaler = StandardScaler()
tmp = csr_matrix(scaler.fit_transform(tr_te[f_num]))
sparse_data.append(tmp)

del (tr_te, train, test)

## sparse train and test data
xtr_te = hstack(sparse_data, format='csr')
xtrain = xtr_te[:ntrain, :]
xtest = xtr_te[ntrain:, :]

print('Dim train', xtrain.shape)
print('Dim test', xtest.shape)

del (xtr_te, sparse_data, tmp)


## neural net
def nn_model():
    model = Sequential()

    model.add(Dense(400, input_dim=xtrain.shape[1], init='he_normal'))
    model.add(ELU())
    model.add(BatchNormalization())
    model.add(Dropout(0.5))

    model.add(Dense(200, init='he_normal'))
    model.add(ELU())
    model.add(BatchNormalization())
    model.add(Dropout(0.5))

    model.add(Dense(50, init='he_normal'))
    model.add(ELU())
    model.add(BatchNormalization())
    model.add(Dropout(0.5))

    model.add(Dense(1, init='he_normal'))
    model.compile(Adam(lr=1e-3), loss='mae')
    return (model)


## cv-folds
nfolds = 2
folds = KFold(len(y), n_folds=nfolds, shuffle=True, random_state=111)

## train models
i = 0
nbags = 1
nepochs = 80
pred_oob = np.zeros(xtrain.shape[0])
pred_test = np.zeros(xtest.shape[0])
#pred = []
score = []

for (inTr, inTe) in folds:
    xtr = xtrain[inTr]
    ytr = y[inTr]
    xte = xtrain[inTe]
    yte = y[inTe]

    callbacks = [
        EarlyStopping(monitor='val_loss', patience=2, verbose=0),
    ]

    print xte.shape
    pred = np.zeros(xte.shape[0])
    print '-' * 50
    print(str(i) + ' folds')
    model = nn_model()
    fit = model.fit_generator(generator=batch_generator(xtr, ytr, 128, True),
                              nb_epoch=nepochs,
                              samples_per_epoch=xtr.shape[0],
                              verbose=1, validation_data=(xte.toarray(), yte.toarray()))
                              #callbacks=callbacks)
    #pred = np.exp(
    #    model.predict_generator(generator=batch_generator(xte, 0, 128, False, y_flag = False), val_samples=xte.shape[0])[:, 0]) - 200
    pred = np.exp(
        model.predict(xte.toarray(), batch_size=128, verbose=1)[:,0]) - 200

    #pred_test += np.exp(
    #    model.predict_generator(generator=batch_generator(xtest, 0, 128, False, y_flag = False), val_samples=xtest.shape[0])[:,
    #    0]) - 200

    pred_test += np.exp(
        model.predict(xtest.toarray(), batch_size=128, verbose=1)[:,0]) - 200
    #pred /= nbags
    #pred_oob[inTe] = pred
    cv_loss = pd.concat([cv_loss ,pd.DataFrame({"id" : id_train[inTe], "loss" : pred})])
    score.append(mean_absolute_error(np.exp(yte) - 200, pred))
    i += 1
    print('Fold ', i, '- MAE:', score[i-1])

finalscore = np.mean(score)
print('Total - MAE:', finalscore)

## test predictions
pred_test /= (nfolds * nbags)
df = pd.DataFrame({'id': id_test, 'loss': pred_test})
name_string = 'submission_keras_shift_perm_' + str(nfolds) + '_' + \
              str(nbags) + '_' + str(nepochs) + '_' + str(finalscore) + '.csv'
name_string2 = "keras_CV_" + str(nfolds) + '_' + \
                str(nepochs) + '_' + str(finalscore) + '.csv'
df.to_csv(name_string, index=False)
cv_loss['id'] = cv_loss['id'].astype('int')
cv_loss.to_csv(name_string2, index = False)