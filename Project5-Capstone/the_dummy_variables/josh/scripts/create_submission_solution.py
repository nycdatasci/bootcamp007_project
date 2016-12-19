#!/usr/bin/env python

"""
This script converts the user-song-count file to the kaggle
submission format for easy comparison.
"""
import os
dirname = os.path.dirname
abspath = os.path.abspath
join = os.path.join

# Path to project
# Assumption is that the project is one directory up
path_to_project = dirname(dirname(abspath(__file__)))

# Path to hidden triplet files
path_to_labrosa = join(path_to_project, 'raw_data/fromLabrosa')

# Path to Kaggle users and songs
path_to_kaggle = join(path_to_project, 'raw_data/fromKaggle')

# Path to processed data
path_to_processed_data = join(path_to_project, 'processed_data')

# Load canonical ordering of users
f = open(os.path.join(path_to_kaggle, 'kaggle_users.txt'), 'r')
canonical_users = map(lambda line: line.strip(), f.readlines())
f.close()

# We do not submit actual song ids, but index in canonical
# list of songs
# Let's create map from song ID to song index
f = open(os.path.join(path_to_kaggle, 'kaggle_songs.txt'), 'r')
song_to_index = dict(map(lambda line: line.strip().split(' '),
                         f.readlines()))
f.close()


# Convert a user-song-play triplet file to a submission format
path_to_files = [os.path.join(path_to_labrosa,
                              'year1_valid_triplets_hidden.txt'),
                 os.path.join(path_to_labrosa,
                              'year1_test_triplets_hidden.txt')]

# Create mapping from user to their played songs
user_to_songs = dict()
for path_to_file in path_to_files:
    with open(path_to_file, 'r') as f:
        for line in f:
            user, song, _ = line.strip().split('\t')
            if user in user_to_songs:
                user_to_songs[user].add(song)
            else:
                user_to_songs[user] = set([song])

# Create output
path_to_output = os.path.join(path_to_processed_data, 'submission_solution.txt')
with open(path_to_output, 'w') as f:
    for user in canonical_users:
        # Transform song IDs to song indexes
        indices = map(lambda s: song_to_index[s],
                      user_to_songs[user])
        f.write(' '.join(indices) + '\n')
