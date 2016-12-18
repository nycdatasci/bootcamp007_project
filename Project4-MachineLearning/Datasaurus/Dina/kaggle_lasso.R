#DTM 11/17/2016  Lasso regression on just the continuous variables of training set
#Did not get rig of any of the variables.  All B1>0.
setwd("~/PROJECTS/Kaggle/")
train = read.csv(file="train.csv", header=TRUE, sep=",")

###Lasso
grid = 10^seq(5, -2, length = 100)
x = model.matrix(loss ~ cont1 + cont2 + cont3 + cont4
                 + cont5 + cont6 + cont7 + cont8
                 + cont9 + cont10 + cont11 + cont12
                 + cont13 + cont14,train)[, -1] 
y = train$loss
library(glmnet)
#Fitting the lasso regression. Alpha = 1 for lasso regression.
lasso.models = glmnet(x, y, alpha = 1, lambda = grid)
dim(coef(lasso.models))#15 different coefficients, estimated 100 times --
#once each per lambda value.
coef(lasso.models) #Inspecting the various coefficient estimates.
#Visualizing the lasso regression shrinkage.
plot(lasso.models, xvar = "lambda", label = TRUE, main = "Lasso Regression")

##Do cross validation to get optimal Lambda
#Running 10-fold cross validation.
set.seed(0)
cv.lasso.out = cv.glmnet(x, y,
                         lambda = grid, alpha = 1, nfolds = 10)
plot(cv.lasso.out, main = "Lasso Regression\n")
bestlambda.lasso = cv.lasso.out$lambda.min
bestlambda.lasso  ##0.01
log(bestlambda.lasso)

#Refit the lasso regression on the overall dataset using the best lambda value
#from cross validation; inspect the coefficient estimates.
lasso.out = glmnet(x, y, alpha = 1)
predict(lasso.out, type = "coefficients", s = bestlambda.lasso)

