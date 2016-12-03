setwd("~/Desktop/Project4")
library('glmnet')
grid <- 10^seq(-5, 10, length = 200)
df_train <- data.frame(data.table::fread("input/train.csv", stringsAsFactors = T))
# do not use log here, because the "mae" function in cross-validation 
# will calculate mae of the "y" in ridge regression.
loss <- df_train$loss 
#dm_train is the train dataset transformed into data matrix and preprocessed with "nzv" in caret
#Important: do df_test$loss = -99, rbind(df_train, df_test), preprocess in caret then split dm_train
#and dm_test to make sure dm_train and dm_test are preprocessed the same way.
dm_train <- readRDS("dm_train.RDS")    

ridge_mod <- glmnet(dm_train, loss, alpha = 0, lambda = grid)
#Important: plot against "lambda", default is "L1 norm", this is the mistake we made the first time!!
plot(ridge_mod, xvar = "lambda")

set.seed(0)
train <- sample(1:nrow(dm_train), 7*nrow(dm_train)/10)
test <- (-train)
## use cross-validation to find best lambda, need to set type.measure="mae"
set.seed(0)
cv.ridge.out <- cv.glmnet(dm_train[train,], loss[train], type.measure="mae",
                         lambda = grid, alpha = 0, nfolds = 10)
plot(cv.ridge.out, main = "Ridge Regression\n")

bestlambda.ridge <- cv.ridge.out$lambda.min
bestlambda.ridge
log(bestlambda.ridge)
cv.ridge.out$lambda.1se
min(cv.ridge.out$cvm)
#min(cv.ridge.out$cvm) is the minimum mae(1352.409) from cross-validated lambda, 
#it is bad because we had to run regression on loss instead of log(loss+200) in 
#order to use "mae" in cross-validation
#we could use log(loss+200) and default "mse" in cross-validation, which actually 
#gave better mae(~1257) on loss, but both are not very good mae anyway.

#refit the glmnet
ridge.out <- glmnet(dm_train, loss, alpha = 0)
#coef is the coefficients of our ridge regression model.
coef <- predict(ridge.out, type = "coefficients", s = bestlambda.ridge)

#predict using test
dm_test <- readRDS("dm_test.RDS")
new_pred_ridge <- predict(ridge.out, s = bestlambda.ridge, newx = dm_test)
#prepare submission file
submission <- data.table::fread("input/sample_submission.csv", colClasses = c("integer", "numeric"))
submission$loss <- new_pred_ridge
#### check file name, don't over wirte
write.csv(submission, paste0("submission_RidgeRegression.csv"), row.names = FALSE)





#set alpha=1 in glmnet to run lasso regression if we want to
#lasso_mod <- glmnet(dm_train, loss, alpha = 1, lambda = grid)

