# Let's try xgboost
library(xgboost)
library(dplyr)
library(caret)

train = read.csv('../Data/train.csv')
test = read.csv('../Data/test.csv')

# Convert character to factor variables
train[, 2:117] <- lapply(train[, 2:117], as.factor)

# Extract the predictor variables
trainX <- data.matrix(select(train, -loss, -id))
testX <- data.matrix(select(test, -id))

# Build the model
xgb = xgboost(data=trainX, label=train$loss, nrounds=1000, object = "binary:logistic")

test.predict = predict(xgb, testX)
submission = data.frame(id=test$id, loss=test.predict)
write.csv(submission, '11.17_xgboost_submission.csv')

