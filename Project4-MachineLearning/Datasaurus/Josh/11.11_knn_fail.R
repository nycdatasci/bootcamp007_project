# Perform eda on the training set
library(kknn) #Load the weighted knn library.

# Goal: Reduce the mean aboslute error

# Load and inspect the data
train = read.csv('../data/train.csv')
summary(train)
# 116 categorical variables
# 14 continuous variables
# continuous variables look normalized

sum(is.na(train))
# no NA values

# What shape is the loss variable?
hist(train$loss)
# Loss is heavily skewed right, looks like a poisson distribution

test = read.csv('../Data/test.csv')
summary(test)

allstate.euclidean = kknn(loss ~ ., train, test) # This fails