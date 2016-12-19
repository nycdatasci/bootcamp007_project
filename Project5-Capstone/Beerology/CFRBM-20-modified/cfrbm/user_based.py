import json
import sys

from collections import defaultdict
from math import sqrt

import numpy as np
import theano.tensor as T

from rbm import CFRBM
from experiments import read_experiment
from utils import chunker, revert_expected_value, expand, iteration_str
from dataset import load_dataset

import pickle

def run(name, dataset, config, all_users, all_movies, tests, initial_v, sep):
    config_name = config['name']
    number_hidden = config['number_hidden']
    epochs = config['epochs']
    ks = config['ks']
    momentums = config['momentums']
    l_w = config['l_w']
    l_v = config['l_v']
    l_h = config['l_h']
    lr_decay = config['lr_decay'][0]
    decay = config['decay']
    batch_size = config['batch_size']

    config_result = config.copy()
    config_result['results'] = []

    vis = T.matrix()
    vmasks = T.matrix()

    rbm = CFRBM(len(all_movies) * 20, number_hidden)

    profiles = defaultdict(list)

    with open(dataset, 'rt') as data:
        for i, line in enumerate(data):
            uid, mid, rat = line.strip().split(sep)
            profiles[uid].append((mid, float(rat)))

    current_l_w = l_w[0]
    current_l_v = l_v[0]
    current_l_h = l_h[0]


    print("Users and ratings loaded")

    for j in range(epochs):

        print "epochs: ", j
        def get_index(col):
            if j/(epochs/len(col)) < len(col):
                return j/(epochs/len(col))
            else:
                return -1

        index = get_index(ks)
        mindex = get_index(momentums)
        #icurrent_l_w = get_index(l_w)
        #icurrent_l_v = get_index(l_v)
        #icurrent_l_h = get_index(l_h)

        k = ks[index]
        momentum = momentums[mindex]
        current_l_w *= lr_decay
        current_l_v *= lr_decay
        current_l_h *= lr_decay

        train = rbm.cdk_fun(vis,
                            vmasks,
                            k=k,
                            w_lr=current_l_w,
                            v_lr=current_l_v,
                            h_lr=current_l_h,
                            decay=decay,
                            momentum=momentum)
        predict = rbm.predict(vis)

        n_batch = 0
        users_ids = []
        for batch in chunker(tests.keys(), batch_size):

            n_batch += 1

            # print "&*&*" * 20
            # print "START OF A BATCH"
            # print "batch: ", batch
            users_ids.extend(batch)

            size = min(len(batch), batch_size)

            # create needed binary vectors
            bin_profiles = {}
            masks = {}
            for userid in batch:
                user_profile = [0.] * len(all_movies)
                mask = [0] * (len(all_movies) * 20)

                for movie_id, rat in profiles[userid]:
                    user_profile[all_movies.index(movie_id)] = rat

                    for _i in range(20):
                        mask[20 * all_movies.index(movie_id) + _i] = 1

                example = expand(np.array([user_profile])).astype('float32')
                bin_profiles[userid] = example
                masks[userid] = mask
                #print np.sum(mask)

            positions = {profile_id: pos for pos, profile_id
                         in enumerate(batch)}
            profile_batch = [bin_profiles[el] for el in batch]

            # print profile_batch[0]
            # print len(profile_batch[0])

            test_batch = np.array(profile_batch).reshape(size,
                                                         len(all_movies) * 20)

            # print batch

            # print "test batch :"
            # print test_batch
            # print test_batch.shape
            #print test_batch[:3,:3]
            batch_preds = predict(test_batch)
            user_preds = revert_expected_value(batch_preds, do_round=False)
            if n_batch == 1:
                print user_preds[:4, :5]

        train_batch_i = 0
        for batch_i, batch in enumerate(chunker(profiles.keys(),
                                                batch_size)):
            size = min(len(batch), batch_size)

            train_batch_i += 1


            # create needed binary vectors

            bin_profiles = {}
            masks = {}
            for userid in batch:

                user_profile = [0.] * len(all_movies)
                mask = [0] * (len(all_movies) * 20)


                for movie_id, rat in profiles[userid]:
                    user_profile[all_movies.index(movie_id)] = rat
                    for _i in range(20):
                        mask[20 * all_movies.index(movie_id) + _i] = 1

                example = expand(np.array([user_profile])).astype('float32')
                bin_profiles[userid] = example
                masks[userid] = mask

            # print example
            # print len(example[0])

            profile_batch = [bin_profiles[id] for id in batch]
            # print profile_batch[0][0]
            # print len(profile_batch[0][0])

            masks_batch = [masks[id] for id in batch]
            train_batch = np.array(profile_batch).reshape(size,
                                                          len(all_movies) * 20)

            train_masks = np.array(masks_batch).reshape(size,
                                                        len(all_movies) * 20)
            train_masks = train_masks.astype('float32')
            train(train_batch, train_masks)

            if (train_batch_i % 200 == 0):
                sys.stdout.write('.')
                sys.stdout.flush()

        # print "number of train batches: ", train_batch_i

        ratings = []
        predictions = []

        # pickle.dump(all_movies, open("item_ids.pickle", "wb"))

        # print "###############################################"
        # print "user ids"
        # print tests.keys()[1:100]
        # # print len(tests.keys)
        # # print type(tests.keys)
        # print "all users"
        # print all_users[1:100]
        # print len(all_users)
        # print type(all_users)
        # print "beer ids"
        # print all_movies[1:100]
        # print len(all_movies)
        # print type(all_movies)

        #reconstruct_mat = np.array([]).reshape(0, 1269)

        n_batch = 0
        users_ids = []
        for batch in chunker(tests.keys(), batch_size):

            n_batch += 1

            # print "&*&*" * 20
            # print "START OF A BATCH"
            # print "batch: ", batch
            users_ids.extend(batch)

            size = min(len(batch), batch_size)

            # create needed binary vectors
            bin_profiles = {}
            masks = {}
            for userid in batch:
                user_profile = [0.] * len(all_movies)
                mask = [0] * (len(all_movies) * 20)

                for movie_id, rat in profiles[userid]:
                    user_profile[all_movies.index(movie_id)] = rat

                    for _i in range(20):
                        mask[20 * all_movies.index(movie_id) + _i] = 1


                example = expand(np.array([user_profile])).astype('float32')
                bin_profiles[userid] = example
                masks[userid] = mask
                #print np.sum(mask)


            positions = {profile_id: pos for pos, profile_id
                         in enumerate(batch)}
            profile_batch = [bin_profiles[el] for el in batch]

            # print profile_batch[0]
            # print len(profile_batch[0])

            test_batch = np.array(profile_batch).reshape(size,
                                                         len(all_movies) * 20)

            #print batch

            # print "test batch :"
            # print test_batch
            # print test_batch.shape
            batch_preds = predict(test_batch)
            user_preds = revert_expected_value(batch_preds, do_round=False)
            #if n_batch == 1:
            #    print test_batch[:2,:]

            # reconstruct_mat = np.concatenate((reconstruct_mat, user_preds))

            # print predict(test_batch)

            # print "user pred: ", user_preds
            # print user_preds.shape

            for profile_id in batch:
                test_movies = tests[profile_id]
                try:
                    for movie, rating in test_movies:
                        current_profile = user_preds[positions[profile_id]]
                        predicted = current_profile[all_movies.index(movie)]
                        rating = float(rating)
                        ratings.append(rating)
                        predictions.append(predicted)
                except Exception:
                    pass

        #print (np.array(predictions))[0:10]
        # print "number of test batches: ", n_batch

        # print reconstruct_mat

        # pickle.dump(users_ids, open("users_ids.pickle", "wb"))
        # pickle.dump(reconstruct_mat, open("reconstruct_mat.pickle", "wb"))

        vabs = np.vectorize(abs)
        distances = np.array(ratings) - np.array(predictions)


        mae = vabs(distances).mean()
        rmse = sqrt((distances ** 2).mean())

        iteration_result = {
            'iteration': j,
            'k': k,
            'momentum': momentum,
            'mae': mae,
            'rmse': rmse,
            'lrate': current_l_w
        }

        config_result['results'].append(iteration_result)

        print(iteration_str.format(j, k, current_l_w, momentum, mae, rmse))

        with open('{}_{}.json'.format(config_name, name), 'wt') as res_output:
            res_output.write(json.dumps(config_result, indent=4))

        w = rbm.weights.eval()
        np.save('weights',w)

if __name__ == "__main__":
    path = "../ubased.json"
    experiments = read_experiment(path)

    for experiment in experiments:
        name = experiment['name']
        train_path = experiment['train_path']
        test_path = experiment['test_path']
        sep = experiment['sep']
        configs = experiment['configs']

        all_users, all_movies, tests = load_dataset(train_path, test_path,
                                                    sep, user_based=True)

        # print all_users
        # print len(all_users)
        # print "*" * 40
        # print all_movies
        # print len(all_movies)
        # print "*" * 40
        # print len(tests)
        # print tests
        for config in configs:
            run(name, train_path, config, all_users, all_movies, tests,
                None, sep)
