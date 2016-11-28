# Let's try random forests on numeric variables only
library(randomForest)

train = read.csv('../data/train.csv')
test = read.csv('../Data/test.csv')

# Goal: Run random forests on continuous variables
cts.vars = colnames(train)[sapply(train, class) == "numeric"]
train.cts = train[ , cts.vars]
rf.allstate = tree(loss ~ ., data = train.cts)

predicted.loss = predict(rf.allstate, newdata = test)

submission = data.frame(id=test$id, loss=predicted.loss)

write.csv(submission, 'rf_submission.csv')