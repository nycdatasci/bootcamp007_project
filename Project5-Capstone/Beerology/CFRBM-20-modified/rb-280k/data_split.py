import pandas as pd
import numpy as np

# random.seed
dat_whole = pd.read_csv("user_item_rating_fac.csv", dtype={"user":int, "item":int, "rating":int})
msk = np.random.rand(len(dat_whole)) <= 0.9
print msk
print len(msk)
dat_train = dat_whole[msk]

dat_test = dat_whole[~msk]
print dat_train.head()
print dat_train.shape
print dat_test.head()
print dat_test.shape
train_out = dat_train.sample(frac=1.0)
print train_out.head()
print train_out.shape
test_out = dat_test.sample(frac=1.0)
print test_out.head()
print test_out.shape

train_out = train_out.to_csv("rb_train.data", header=None, sep="\t", index=None)

test_out = test_out.to_csv("rb_test.data", header=None, sep="\t", index=None)