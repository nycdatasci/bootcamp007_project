library(glmnet)
library(caret)

setwd("~/Kaggle")

allstate.train = read.csv('train.csv')
allstate.test = read.csv('test.csv')
sample_submission = read.csv('sample_submission.csv')


dm.astrain = model.matrix(loss ~., data = allstate.train[, -1])
dm.astest = model.matrix(~., data = allstate.test[, -1])

prep = preProcess(dm.astrain, method = 'nzv')
dm.astrain = predict(prep, dm.astrain)
dim(dm.astrain) # [1] 188318   153
dm.astest = predict(prep, dm.astest)
dim(dm.astest)

loss = allstate.train$loss

# create train and test sets
set.seed(0)
train.index = createDataPartition(loss, times = 1, p = 0.8, list = F)

sub.dmtrain = dm.astrain[train.index, ]
sub.dmtest = dm.astrain[-train.index, ]
loss.train = loss[train.index]
loss.test = loss[-train.index]

# ridge
x = sub.dmtrain
y = loss.train

grid = 10^seq(10, -2, length = 100)
ridge.model = glmnet(x, y, alpha = 0, lambda = grid)
plot(ridge.model, xvar = 'lambda', label = T, main = "Ridge Regression")

set.seed(0)
cv.ridge.out = cv.glmnet(x, y, lambda = grid, alpha = 0, nfolds = 10)
plot(cv.ridge.out, main = "Ridge Regression\n")
bestlambda.ridge = cv.ridge.out$lambda.min

x.test = sub.dmtest
y.test = loss.test
ridge.bestlambdatrain = predict(ridge.model, s = bestlambda.ridge, newx = x.test)
RMSE.ridge = sqrt(mean((ridge.bestlambdatrain - y.test)^2))  # [1] 2097.646 --> [1] 2007.712

x.all = dm.astrain
y.all = loss

ridge.bestmodel = glmnet(x.all, y.all, alpha = 0, lambda = bestlambda.ridge)
ridgeImp = varImp(ridge.bestmodel, lambda = bestlambda.ridge)
save(ridge.bestmodel, file = 'ridge.bestmodel_allfeatures.rda')

ridge_all_pred = predict(ridge.bestmodel, s = bestlambda.ridge, newx = dm.astest)


# lasso
grid = 10^seq(5, -5, length = 100)
lasso.model = glmnet(x, y, alpha = 1, lambda = grid)
plot(lasso.model, xvar = 'lambda', label = T, main = "Lasso Regression")

set.seed(0)
cv.lasso.out = cv.glmnet(x, y, lambda = grid, alpha = 1, nfolds = 10)
plot(cv.lasso.out, main = "Lasso Regression\n")
bestlambda.lasso = cv.lasso.out$lambda.min

lasso.bestlambdatrain = predict(lasso.model, s = bestlambda.lasso, newx = x.test)
RMSE.lasso = sqrt(mean((lasso.bestlambdatrain - y.test)^2)) # [1] 2097.539 --> [1] 2006.082

lasso.bestmodel = glmnet(x.all, y.all, alpha = 0, lambda = bestlambda.lasso)
lassoImp = varImp(lasso.bestmodel, lambda = bestlambda.lasso)

save(lasso.bestmodel, file = 'lasso.bestmodel_allfeatures.rda')

