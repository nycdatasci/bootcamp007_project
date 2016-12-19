#!/usr/bin/env python

from __future__ import division
import sys

PATH_TO_SOLUTION = '/Users/alexanderlitven/Courses/' \
    + 'nyc_data_science_academy/projects/capstone/kaggle/data/' \
    + 'submission_solution.txt'

PATH_TO_VALIDATION_INDICES = '/Users/alexanderlitven/Courses/' \
    + 'nyc_data_science_academy/projects/capstone/kaggle/data/' \
    + 'year1_valid_triplets_visible_indices.txt'

def precision_at_k(user_songs, predicted_songs, k):
    """
    Compute the precision-at-k, the proportion of correct
    recommendations within the top-k of the predicted ranking.
    """
    num_correct = 0
    for j in range(k):
        i = predicted_songs[j]
        if i in user_songs:
            num_correct += 1
    return num_correct / k

def average_precision(user_songs, predicted_songs, tau):
    """
    Compute the average precision at each recall point.
    """
    n = min(len(user_songs), tau)
    total_precision = 0
    for k in range(1, tau + 1):
        i = predicted_songs[k - 1]
        if i in user_songs:
            precision = precision_at_k(user_songs, predicted_songs, k)
            total_precision += precision
    return total_precision / n

def compute_mAP(path_to_solution, path_to_submission, tau=500,
                validation_only=True):
    """
    Compute the mean average precision of a Kaggle submission file.
    """
    true_songs_by_user = open(path_to_solution, 'r').readlines()
    predicted_songs_by_user = open(path_to_submission, 'r').readlines()

    if validation_only:
        indices = open(PATH_TO_VALIDATION_INDICES, 'r').readlines()
        indices = [int(index) for index in indices]
        true_songs_by_user = [true_songs_by_user[i] for i in indices]
        predicted_songs_by_user = [predicted_songs_by_user[i] for i in indices]

    mAP = 0
    for i in range(len(true_songs_by_user)):
        predicted_songs = [int(u) for u in predicted_songs_by_user[i].split()]
        user_songs = [int(u) for u in true_songs_by_user[i].split()]
        avg_prec = average_precision(user_songs, predicted_songs, tau)
        mAP += avg_prec
    m = len(true_songs_by_user)
    mAP = mAP / m
    return mAP

if __name__ == '__main__':
    if (len(sys.argv) < 2):
        print "Usage: {} submission_file.txt".format(sys.argv[0])
        sys.exit(0)
    mAP = compute_mAP(PATH_TO_SOLUTION, sys.argv[1])
    print "mAP: {}".format(mAP)
