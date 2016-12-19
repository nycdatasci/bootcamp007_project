#-*- coding: utf-8 -*-

import numpy as np
np.random.seed(2016)

import os
import glob
import cv2
import math
import pickle
import datetime
import pandas as pd
import time
from shutil import copy2
import warnings
import random
warnings.filterwarnings("ignore")  # this is weird

from sklearn.cross_validation import train_test_split
from sklearn.cross_validation import KFold
from keras.models import Sequential
from keras.layers.core import Dense, Dropout, Activation, Flatten
from keras.layers.convolutional import Convolution2D, MaxPooling2D, ZeroPadding2D
from keras.layers.normalization import BatchNormalization
from keras.optimizers import SGD
from keras.optimizers import Adam
from keras.callbacks import EarlyStopping, ModelCheckpoint
from keras.utils import np_utils
from keras.models import model_from_json
from sklearn.metrics import log_loss
from scipy.misc import imread, imresize, imshow

use_cache = 1
num_classes = 4


def show_image(im, name='image'):
    cv2.imshow(name, im)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

# color_type = 1 - gray
# color_type = 3 - RGB
def get_im_cv2(path, img_rows, img_cols, color_type=1):
    # Load as grayscale
    if color_type == 1:
        img = cv2.imread(path, 0)
    elif color_type == 3:
        img = cv2.imread(path)
    # Reduce size
    resized = cv2.resize(img, (img_cols, img_rows), interpolation = cv2.INTER_LINEAR)
    return resized


def get_im_cv2_mod(path, img_rows, img_cols, color_type=1):
    # Load as grayscale
    if color_type == 1:
        img = cv2.imread(path, 0)
    else:
        img = cv2.imread(path)
    # Reduce size
    rotate = random.uniform(-10, 10)
    M = cv2.getRotationMatrix2D((img.shape[1]/2, img.shape[0]/2), rotate, 1)
    img = cv2.warpAffine(img, M, (img.shape[1], img.shape[0]))
    resized = cv2.resize(img, (img_cols, img_rows), interpolation = cv2.INTER_LINEAR)
    return resized

def load_train(img_rows, img_cols, color_type=1):
    X_train = []
    X_train_id = []
    y_train = []
    start_time = time.time()

    print('Read train images')
    for j in range(num_classes):
        print('Load folder {}'.format(j))
        path = os.path.join('..', 'input', 'train_o', str(j), '*.png')
        files = glob.glob(path)
        for fl in files:
            flbase = os.path.basename(fl)
            img = get_im_cv2_mod(fl, img_rows, img_cols, color_type)
            X_train.append(img)
            X_train_id.append(flbase)
            y_train.append(j)

    print('Read train data time: {} seconds'.format(round(time.time() - start_time, 2)))
    return X_train, y_train, X_train_id

def load_test(img_rows, img_cols, color_type=1):
    print('Read test images')
    path = os.path.join('..', 'input', 'test_o', '*.png')
    files = glob.glob(path)
    X_test = []
    X_test_id = []
    total = 0
    start_time = time.time()
    thr = math.floor(len(files)/10)
    for fl in files:
        flbase = os.path.basename(fl)
        # img = get_im_cv2(fl, img_rows, img_cols, color_type)
        img = get_im_cv2_mod(fl, img_rows, img_cols, color_type)
        X_test.append(img)
        X_test_id.append(flbase)
        total += 1
        if total%thr == 0:
            print('Read {} images from {}'.format(total, len(files)))

    print('Read test data time: {} seconds'.format(round(time.time() - start_time, 2)))
    return X_test, X_test_id


def cache_data(data, path):
    if os.path.isdir(os.path.dirname(path)):
        file = open(path, 'wb')
        pickle.dump(data, file)
        file.close()
    else:
        print('Directory doesnt exists')


def restore_data(path):
    data = dict()
    if os.path.isfile(path):
        file = open(path, 'rb')
        data = pickle.load(file)
    return data


def save_model(model, arch_path, weights_path):
    json_string = model.to_json()
    if not os.path.isdir('cache'):
        os.mkdir('cache')
    open(arch_path, 'w').write(json_string)
    model.save_weights(weights_path, overwrite=True)


def read_model(arch_path, weights_path):
    model = model_from_json(open(arch_path).read())
    model.load_weights(weights_path)
    return model


def split_validation_set(train, target, test_size):
    random_state = 51
    X_train, X_test, y_train, y_test = train_test_split(train, target, test_size=test_size, random_state=random_state)
    return X_train, X_test, y_train, y_test

def create_submission(predictions, test_id, info):
    result1 = pd.DataFrame(predictions, columns=['adidas', 'jordan', 'newbalance', 'nike'])
    result1.loc[:, 'img'] = pd.Series(test_id, index=result1.index)
    now = datetime.datetime.now()
    if not os.path.isdir('subm'):
        os.mkdir('subm')
    suffix = info + '_' + str(now.strftime("%Y-%m-%d-%H-%M"))
    sub_file = os.path.join('subm', 'submission_' + suffix + '.csv')
    result1.to_csv(sub_file, index=False)


def save_useful_data(predictions_valid, valid_ids, model, info):
    result1 = pd.DataFrame(predictions_valid, columns=['adidas', 'jordan', 'newbalance', 'nike'])
    result1.loc[:, 'img'] = pd.Series(valid_ids, index=result1.index)
    now = datetime.datetime.now()
    if not os.path.isdir(os.path.join('subm', 'data')):
        os.mkdir(os.path.join('subm', 'data'))
    suffix = info + '_' + str(now.strftime("%Y-%m-%d-%H-%M"))
    # Save predictions
    pred_file = os.path.join('subm', 'data', 's_' + suffix + '_train_predictions.csv')
    result1.to_csv(pred_file, index=False)
    # Save model
    json_string = model.to_json()
    model_file = os.path.join('subm', 'data', 's_' + suffix + '_model.json')
    open(model_file, 'w').write(json_string)
    # Save code
    cur_code = os.path.realpath(__file__)
    code_file = os.path.join('subm', 'data', 's_' + suffix + '_code.py')
    copy2(cur_code, code_file)


def read_and_normalize_train_data(img_rows, img_cols, color_type=1):
    cache_path = os.path.join('cache', 'train_r_' + str(img_rows) + '_c_' + str(img_cols) + '_t_' + str(color_type) + '_rotated.dat')
    if not os.path.isfile(cache_path) or use_cache == 0:
        train_data, train_target, train_id = load_train(img_rows, img_cols, color_type)
        cache_data((train_data, train_target, train_id), cache_path)
    else:
        print('Restore train from cache!')
        (train_data, train_target, train_id) = restore_data(cache_path)

    train_data = np.array(train_data, dtype=np.uint8)
    train_target = np.array(train_target, dtype=np.uint8)

    if color_type == 1:
        train_data = train_data.reshape(train_data.shape[0], 1, img_rows, img_cols)
    else:
        train_data = train_data.transpose((0, 3, 1, 2))

    train_target = np_utils.to_categorical(train_target, num_classes)
    train_data = train_data.astype('float32')
    train_data /= 255
    print('Train shape:', train_data.shape)
    print(train_data.shape[0], 'train samples')
    return train_data, train_target, train_id


def read_and_normalize_test_data(img_rows, img_cols, color_type=1):
    cache_path = os.path.join('cache', 'test_r_' + str(img_rows) + '_c_' + str(img_cols) + '_t_' + str(color_type) + '_rotated.dat')
    if not os.path.isfile(cache_path) or use_cache == 0:
        test_data, test_id = load_test(img_rows, img_cols, color_type)
        cache_data((test_data, test_id), cache_path)
    else:
        print('Restore test from cache!')
        (test_data, test_id) = restore_data(cache_path)

    test_data = np.array(test_data, dtype=np.uint8)
    if color_type == 1:
        test_data = test_data.reshape(test_data.shape[0], 1, img_rows, img_cols)
    else:
        test_data = test_data.transpose((0, 3, 1, 2))
    # test_data = test_data.swapaxes(3, 1)
    test_data = test_data.astype('float32')
    test_data /= 255
    print('Test shape:', test_data.shape)
    print(test_data.shape[0], 'test samples')
    return test_data, test_id


def merge_several_folds_mean(data, nfolds):
    a = np.array(data[0])
    for i in range(1, nfolds):
        a += np.array(data[i])
    a /= nfolds
    return a.tolist()


def merge_several_folds_geom(data, nfolds):
    a = np.array(data[0])
    for i in range(1, nfolds):
        a *= np.array(data[i])
    a = np.power(a, 1/nfolds)
    return a.tolist()


def copy_selected_data(train_data, train_target):
    data = []
    target = []
    index = []
    for i in range(train_data):
        index.append(i)
    data = np.array(train_data)
    target = np.array(train_target)
    index = np.array(index)
    return data, target, index


def create_model_v1(img_rows, img_cols, color_type=1):
    model = Sequential()
    model.add(Convolution2D(32, 3, 3, input_shape=(color_type, img_rows, img_cols)))
    model.add(Activation('relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))
    model.add(Dropout(0.5))

    model.add(Convolution2D(32, 3, 3))
    model.add(Activation('relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))
    model.add(Dropout(0.5))

    model.add(Convolution2D(64, 3, 3))
    model.add(Activation('relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))
    model.add(Dropout(0.5))

    model.add(Flatten())
    model.add(Dense(64))
    model.add(Activation('relu'))
    model.add(Dropout(0.5))
    model.add(Dense(4))
    model.add(Activation('softmax'))

    model.compile(Adam(lr=1e-3), loss='categorical_crossentropy')
    return model

def get_validation_predictions(train_data, predictions_valid):
    pv = []
    print len(train_data)
    for i in range(len(train_data)):
        pv.append(predictions_valid[i])
    return pv


def run_cross_validation(nfolds=10):
    # input image dimensions
    img_rows, img_cols = 64, 64
    # color type: 1 - grey, 3 - rgb
    color_type_global = 1
    batch_size = 16
    nb_epoch = 50
    random_state = 51
    restore_from_last_checkpoint = 0

    train_data, train_target, train_id = read_and_normalize_train_data(img_rows, img_cols, color_type_global)
    test_data, test_id = read_and_normalize_test_data(img_rows, img_cols, color_type_global)
    model = create_model_v1(img_rows, img_cols, color_type_global)

    yfull_train = dict()
    yfull_test = []
    kf = KFold(train_data.shape[0], n_folds = nfolds, shuffle=True, random_state=random_state)
    num_fold = 0
    sum_score = 0
    for i, (train_index, test_index) in enumerate(kf):

        X_train, X_valid = train_data[train_index], train_data[test_index]

        Y_train, Y_valid = train_target[train_index], train_target[test_index]

        num_fold += 1
        print('Start KFold number {} from {}'.format(num_fold, nfolds))
        print('Split train: ', len(X_train), len(Y_train))
        print('Split valid: ', len(X_valid), len(Y_valid))

        kfold_weights_path = os.path.join('cache', 'weights_kfold_' + str(num_fold) + '.h5')
        if not os.path.isfile(kfold_weights_path) or restore_from_last_checkpoint == 0:
            callbacks = [
                EarlyStopping(monitor='val_loss', patience=1, verbose=0),
                ModelCheckpoint(kfold_weights_path, monitor='val_loss', save_best_only=True, verbose=0),
            ]
            print "Training model!"
            model.fit(X_train, Y_train, batch_size=batch_size, nb_epoch=nb_epoch,
                  shuffle=True, verbose=1, validation_data=(X_valid, Y_valid),
                  callbacks=callbacks)
        if os.path.isfile(kfold_weights_path):
            model.load_weights(kfold_weights_path)

        # score = model.evaluate(X_valid, Y_valid, show_accuracy=True, verbose=0)
        # print('Score log_loss: ', score)

        predictions_valid = model.predict(X_valid, batch_size=batch_size, verbose=1)
        score = log_loss(Y_valid, predictions_valid)
        print('Score log_loss: ', score)
        sum_score += score*len(test_index)

        # Store valid predictions
        for i in range(len(test_index)):
            yfull_train[test_index[i]] = predictions_valid[i]

        # Store test predictions
        test_prediction = model.predict(test_data, batch_size=batch_size, verbose=1)
        yfull_test.append(test_prediction)

    score = sum_score/len(train_data)
    print("Log_loss train independent avg: ", score)

    predictions_valid = get_validation_predictions(train_data, yfull_train)
    score1 = log_loss(train_target, predictions_valid)
    if abs(score1 - score) > 0.0001:
        print('Check error: {} != {}'.format(score, score1))

    print('Final log_loss: {}, rows: {} cols: {} nfolds: {} epoch: {}'.format(score, img_rows, img_cols, nfolds, nb_epoch))
    info_string = 'loss_' + str(score) \
                    + '_r_' + str(img_rows) \
                    + '_c_' + str(img_cols) \
                    + '_folds_' + str(nfolds) \
                    + '_ep_' + str(nb_epoch)

    test_res = merge_several_folds_mean(yfull_test, nfolds)
    # test_res = merge_several_folds_geom(yfull_test, nfolds)
    create_submission(test_res, test_id, info_string)
    save_useful_data(predictions_valid, train_id, model, info_string)


def run_single():
    # input image dimensions
    img_rows, img_cols = 64, 64
    color_type_global = 1
    batch_size = 32
    nb_epoch = 50
    random_state = 51

    train_data, train_target, train_id = read_and_normalize_train_data(img_rows, img_cols, color_type_global)
    test_data, test_id = read_and_normalize_test_data(img_rows, img_cols, color_type_global)

    yfull_test = []
    X_train, Y_train, train_index = copy_selected_data(train_data, train_target)
    X_valid, Y_valid, test_index = copy_selected_data(train_data, train_target)

    print('Start Single Run')
    print('Split train: ', len(X_train))
    print('Split valid: ', len(X_valid))

    callbacks = [
        EarlyStopping(monitor='val_loss', patience=2, verbose=0),
    ]
    model = create_model_v1(img_rows, img_cols, color_type_global)
    model.fit(X_train, Y_train, batch_size=batch_size, nb_epoch=nb_epoch,
              shuffle=True, verbose=1, validation_data=(X_valid, Y_valid),
              callbacks=callbacks)

    # score = model.evaluate(X_valid, Y_valid, show_accuracy=True, verbose=0)
    # print('Score log_loss: ', score[0])

    predictions_valid = model.predict(X_valid, batch_size=batch_size, verbose=1)
    score = log_loss(Y_valid, predictions_valid)
    print('Score log_loss: ', score)

    # Store test predictions
    test_prediction = model.predict(test_data, batch_size=batch_size, verbose=1)
    yfull_test.append(test_prediction)

    print('Final log_loss: {}, rows: {} cols: {} epoch: {}'.format(score, img_rows, img_cols, nb_epoch))
    info_string = 'loss_' + str(score) \
                    + '_r_' + str(img_rows) \
                    + '_c_' + str(img_cols) \
                    + '_ep_' + str(nb_epoch)

    full_pred = model.predict(train_data, batch_size=batch_size, verbose=1)
    score = log_loss(train_target, full_pred)
    print('Full score log_loss: ', score)

    test_res = merge_several_folds_mean(yfull_test, 1)
    create_submission(test_res, test_id, info_string)
    save_useful_data(full_pred, train_id, model, info_string)


if __name__ == '__main__':
    run_cross_validation(10)
    # run_single()
