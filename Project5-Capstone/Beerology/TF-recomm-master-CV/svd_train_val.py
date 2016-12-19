'''
Script to perform SVD++ for colloborative filtering using Tensorflow
Original code from Guocong Song, https://github.com/songgc/TF-recomm (SVD CF with tensorflow)
Modified code to add in implicit feedback term in algorithm (++ part), kfold cross-validation, and early stopping

Written by Nelson Chen 12/13/16 for Beer recommendation project
'''

####################################### Packages ###########################################

import tensorflow as tf
from tensorflow.python.framework import graph_util
from sklearn.cross_validation import KFold
import dataio
import numpy as np
from collections import deque
from six import next
import time
import ops
import pandas as pd
import pickle

np.random.seed(13575)

####################################### hyperparameters ###########################################

BATCH_SIZE = 2000
USER_NUM = 16926
ITEM_NUM = 1269
DIM_VEC = [65]
EPOCH_MAX = 7000
LAMBDA_VEC = [0.15]
LR = 0.001
LR_DECAY = 0.9996
N_FOLD = 10
DEVICE = "/gpu:0"

# decent parameters -> lambda = 0.15, dim = 65

####################################### Main Functions ###########################################
def clip(x):
    'Force ratings to be in the 1 to 20 range'

    return np.clip(x, 1.0, 20.0)

def get_data():
    'Grab data, compute implicit matrix, and do train-test split'

    # Grab data using dataio functions
    df = dataio.read_process("../data_cleaning/data_for_CF/user_item_rating_fac.csv", sep=",")

    # Compute implicit matrix
    implicit_mat = df.pivot(index='user', columns='item', values='rate').notnull().as_matrix().astype(float)

    # Perform data shuffle
    rows = len(df)
    sample_index = np.random.permutation(rows)
    #df = df.iloc[sample_index].reset_index(drop=True)

    # Train-test split
    split_index = int(rows * 0.9)
    #df_train = df[0:split_index]
    df_train = df
    df_test = df[split_index:].reset_index(drop=True)

    return df_train, df_test, implicit_mat


def svd(X_train, X_test,feedback_u, DIM, LAMBDA):
    'Main SVD code'

    # learning rate
    learning = LR

    # finding the number of batches in train data
    samples_per_batch = len(X_train) // BATCH_SIZE


    # initialize earlys topping parameters
    min_err = 100 # store minimum error
    counter = 0 # count number of times validation error was above minimum

    # build iterator objects for train and validation sets
    iter_train = dataio.ShuffleIterator([X_train["user"],
                                             X_train["item"],
                                             X_train["rate"]],
                                            batch_size=BATCH_SIZE)

    iter_val = dataio.OneEpochIterator([X_test["user"],
                                             X_test["item"],
                                             X_test["rate"]],
                                            batch_size=BATCH_SIZE)

    '''iter_test = dataio.OneEpochIterator([test["user"],
                                             test["item"],
                                             test["rate"]],
                                            batch_size=BATCH_SIZE)'''

    # start tensorflow with empty graph (needed when calling svd function multiply times i.e kfold validation)
    with tf.Graph().as_default():

        # Define tensor placeholders (tensor objects that you feed into tensor functions)
        user_batch = tf.placeholder(tf.int32, shape=[None], name="id_user")
        item_batch = tf.placeholder(tf.int32, shape=[None], name="id_item")
        rate_batch = tf.placeholder(tf.float32, shape=[None])
        feedback_batch = tf.placeholder(tf.float32, shape=[None,ITEM_NUM])
        feedback_mat = tf.placeholder(tf.float32, shape=[USER_NUM, ITEM_NUM])

        infer, regularizer = ops.inference_svd(user_batch, item_batch, feedback_batch,
                                               user_num=USER_NUM, item_num=ITEM_NUM, dim=DIM,
                                               device=DEVICE)
        _, train_op = ops.optimiaztion(infer, regularizer, rate_batch, learning_rate=LR, reg=LAMBDA,
                                       device=DEVICE)

        full_ratings = ops.get_pred(feedback_mat, ITEM_NUM, USER_NUM, DIM, DEVICE)

        # Initialize all variables function
        init_op = tf.initialize_all_variables()

        # Start the tensorflow session
        with tf.Session() as sess:

            # initialize variables
            sess.run(init_op)

            print("{} {} {} {}".format("epoch", "train_error", "val_error", "elapsed_time"))
            errors = deque(maxlen=samples_per_batch)

            # Time each epoch
            start = time.time()

            # Iterate through epochs
            for i in range(EPOCH_MAX * samples_per_batch):

                # Generate batch data
                users, items, rates = next(iter_train)
                feedback = feedback_u[users.astype('int'),:]

                # Run the training functions
                _, pred_batch = sess.run([train_op, infer], feed_dict={user_batch: users,
                                                                           item_batch: items,
                                                                           rate_batch: rates,
                                                                           feedback_batch:feedback})
                pred_batch = clip(pred_batch)
                errors.append(np.power(pred_batch - rates, 2))

                # Do prediction on the validation set
                if i % samples_per_batch == 0: #end of epoch
                    train_err = np.sqrt(np.mean(errors)) #train rmse
                    test_err2 = np.array([]) # test rmse

                    # predict validation set using iterator
                    for users, items, rates in iter_val:
                        feedback = feedback_u[users.astype('int'), :]
                        pred_batch = sess.run(infer, feed_dict={user_batch: users,
                                                                    item_batch: items,
                                                                    feedback_batch:feedback})
                        pred_batch = clip(pred_batch)
                        test_err2 = np.append(test_err2, np.power(pred_batch - rates, 2))
                    end = time.time() # end timer

                    # Validation error
                    RMSE_val = np.sqrt(np.mean(test_err2))
                    print("{:3d} {:f} {:f} {:f}(s)".format(i // samples_per_batch, train_err, RMSE_val,
                                                               end - start))

                    start = end #reset clock

                    # Early stopping check: update minimum error variable if needed, if it did not minimize any further
                    # beyond 50 steps, stop the training and print error
                    if min_err > RMSE_val:
                        min_err = RMSE_val
                        counter = 0
                        print('Min error updated')
                    else:
                        counter += 1

                    if counter >= 100:
                        break

            # Output log information
            output_graph_def = graph_util.extract_sub_graph(sess.graph.as_graph_def(),
                                                                             ["svd_inference", "svd_regularizer"])
            tf.train.SummaryWriter(logdir="/tmp/svd", graph_def=output_graph_def)
            ratings_mat = sess.run(full_ratings, feed_dict={feedback_mat: feedback_u})

    return min_err, clip(ratings_mat)


####################################### Main code to perform ###########################################

if __name__ == '__main__':
    full_start = time.time()

    # get data
    df_train, df_test, feedback_u = get_data()

    # initialize grid search dataframe
    error_params = pd.DataFrame(columns=["regularizer","latent","rmse"])

    # build K-Fold indices
    kf = KFold(df_train.shape[0], N_FOLD, shuffle=True)

    # Grid search through regularization and number of latent factors
    for LAMBDA in LAMBDA_VEC:
        for DIM in DIM_VEC:
            val_error = []
            ratings = np.zeros(shape=[USER_NUM,ITEM_NUM])
            k = 1

            # Run cross-fold validation process
            for train_index, val_index in kf:
                print("LAMBDA : " + str(LAMBDA) + " DIM : " + str(DIM) + " K-FOLD: " + str(k))
                X_train = df_train.iloc[train_index,:]
                X_val = df_train.iloc[val_index,:]
                error_val, temp_mat = svd(X_train, X_val, feedback_u, DIM, LAMBDA) # train model and return error
                ratings += temp_mat
                val_error.append(error_val)
                k += 1

            error = np.mean(val_error)
            ratings = ratings/N_FOLD
            np.save('ratings_mat', ratings)
            #print(LAMBDA, DIM, error)
            print('CV Error: ' + str(error))

            # add row to error_params dataframe
            #error_params = pd.concat([error_params, pd.DataFrame({'regularizer':[LAMBDA],
            #                                                      'latent': [DIM],
            #                                                      'rmse': [error]})])
            print('-'*80)

        # Write csv file every once in a while in case code fails
        #error_params.to_csv('error_gridsearch4.csv', index=False)

    #print(error_params)
    # Write final data to csv
    #error_params.to_csv('error_gridsearch4.csv', index=False)
    print("Done!")

    full_end = time.time()
    print(full_start-full_end)


    # Save correct ratings
    '''df_train, df_test, feedback_u = get_data()
    ratings_pred = np.load('ratings_mat.npy')
    df_mat = df_train.pivot(index='user', columns='item', values='rate').as_matrix().astype(float)
    missing_mat = df_train.pivot(index='user', columns='item', values='rate').isnull().as_matrix().astype(float)
    ratings_final = np.nan_to_num(df_mat) + missing_mat*ratings_pred

    np.save('ratings_svdpp',ratings_final)'''



    
