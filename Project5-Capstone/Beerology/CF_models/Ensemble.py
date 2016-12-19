'''
Script to ensemble svd++ and rbm models
'''

import numpy as np

# Directories of models
dir1 = '../'
dir2 = '../'
save_dir = '../'

# load matrices
ratings_svdpp = np.load(dir1)
ratings_rbm = np.load(dir2)

# Assign weights
weight = [0.9, 0.1]

# Linear combination of models
ratings_ensemble = weight[0]*ratings_svdpp + weight[1]*ratings_rbm

# Save final ensembled model
np.save(save_dir + '/ratings_ensemble', ratings_ensemble)