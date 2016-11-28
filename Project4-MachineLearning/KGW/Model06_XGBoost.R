library(caret)
library(xgboost)

# setting wd
setwd("C:/Users/Chuan.Shu-PC/Desktop/AllState")

# when using the new train and test datasets
ntrain = read.csv('new_train.csv')
ntest = read.csv('new_test.csv')

# drop the original cats over 15 levels
replaced_features = c('cat116', 'cat115', 'cat114', 'cat113', 'cat112',
                      'cat111', 'cat110', 'cat109', 'cat107', 'cat106',
                      'cat105', 'cat104', 'cat101', 'cat99')

allstate.train = ntrain[, !names(ntrain) %in% replaced_features]
allstate.test = ntest[, !names(ntest) %in% replaced_features]

loss.log = log((allstate.train$loss) + 1)

# dummy transfromation
dm.astrain = model.matrix(loss ~., data = allstate.train[, -1])[, -1]
dim(dm.astrain) # [1] 188318    336
dm.astest = model.matrix(~., data = allstate.test[, -1])[, -1]
dim(dm.astest) # [1] 125546    367  

# if cannot use "predict" function, drop the different vars in dm.astest, uncomment next line
dm.astest = dm.astest[, colnames(dm.astest) %in% colnames(dm.astrain)]

# drop near zero variances
# prep = preProcess(dm.astrain, method = 'nzv')
# dm.astrain = predict(prep, dm.astrain)
# dim(dm.astrain) 
# dm.astest = predict(prep, dm.astest)
# dim(dm.astest)

# based on train.csv to create train and test sets
set.seed(0)
train.index = createDataPartition(loss.log, times = 1, p = 0.8, list = F)

sub.dmtrain = dm.astrain[train.index, ]
sub.dmtest = dm.astrain[-train.index, ]
loss.train = loss.log[train.index]
loss.test = loss.log[-train.index]


# System set
library(doParallel) 
library(parallel)
number_of_cores <- detectCores()
registerDoParallel(cores = number_of_cores - 1)

##############################################################################
# (1) train xgbtree.default
system.time(
  xgbtree <- train(x = sub.dmtrain, 
                   y = loss.train,
                   # trControl = xgb.ctrl,
                   # tuneGrid = xgb.grid,
                   method="xgbTree")
)

saveRDS(xgbtree, file = "xgbtree_default_dell.rds")

summary(xgbtree)

xgbImp <- varImp(xgbtree, scale = FALSE)
xgbImp
plot(xgbImp,top = 10)

plot(xgbtree)

mean(xgbtree$resample$RMSE) #[1] 0.5486895

predicted <- predict(xgbtree, sub.dmtest)
sqrt(sum((predicted-loss.test)^2)/length(predicted)) #RMSE 0.5489225

plot(x = predicted, y = loss.test, pch=16)


# Predict test table

xgbtreedefault.grid <- expand.grid( # set up the parameter
  nrounds= 150,
  max_depth=3,
  eta=0.3,
  gamma=0,
  colsample_bytree=0.8,
  min_child_weight=1,
  subsample=0.75
  # lambda = 1,
  # alpha =0
)

system.time(
  xgbtreedefault.fit <- train(x = dm.astrain,
                              y = loss.log,
                              tuneGrid = xgbtreedefault.grid,
                              method="xgbTree") # xgbLinear/xgbtree
)

summary(xgbtreedefault.fit)

xgbfitImp <- varImp(xgbtreedefault.fit, scale = FALSE)
xgbfitImp
plot(xgbfitImp,top = 10)

mean(xgbtreedefault.fit$resample$RMSE) # [1] 0.5486051

predicted <- predict(xgbtreedefault.fit, dm.astest)

submit1 <- data.frame(id = allstate.test$id, loss = exp(predicted) - 1)
write.csv(submit, "./submission_1.csv", row.names = FALSE)

#############################################################################

## Train xgboost w/ caret
library(xgboost)
xgb.grid <- expand.grid( 
  nrounds=2400 ,
  eta = c(0.01,0.001,0.0001),
  lambda = c(0, 0.001, 0.01, 1),
  alpha = c(0, 0.001, 0.01, 1)
)

xgb.ctrl <- trainControl(
  method="cv",
  number = 5,
  verboseIter = TRUE,
  returnData=FALSE,
  returnResamp = "all",
  allowParallel = TRUE
)

system.time(
  xgbtree <- train(x = sub.dmtrain, 
                   y = loss.train,
                   trControl = xgb.ctrl,
                   tuneGrid = xgb.grid,
                   method="xgbTree")
)

summary(xgbFit)

xgbImp <- varImp(xgbFit, scale = FALSE)
xgbImp
plot(xgbImp,top = 20)

mean(xgbFit$resample$RMSE) #[1] 0.5949048

predicted <- predict(xgbFit, subTest)
RMSE(pred = predicted, obs = lossTest) #[1]0.5902948

plot(x = predicted, y = lossTest, pch=16)

saveRDS(xgbFit, file = "~/Desktop//AllState/Data/xgbFit_2400_1_0.rds")


## Refit w/ entire training dataset

system.time(
  xgbTree.Fit <- train(x = sub.dmtrain, 
                       y = lossTrain,
                       # trControl = xgb.ctrl,
                       # tuneGrid = xgb.grid,
                       method="xgbTree")
)


## xgbLinear with Random search
xgbCtrl <- trainControl(method = "cv",
                        number = 5,
                        search = "random", 
                        verboseIter = TRUE,
                        allowParallel = TRUE)

system.time(
  xgbLinear.fit <- train(x = sub.dmtrain, 
                         y = loss.train,
                         method="xgbLinear",
                         trControl = xgbCtrl,
                         tuneLength = 20)
)

mean(xgbLinear.fit$resample$RMSE) #[1] 0.5458552

predicted <- predict(xgbLinear.fit, sub.dmtest)
sqrt(sum((predicted-loss.test)^2)/length(predicted)) #[1] 0.5462348


saveRDS(xgbLinear.fit, file = "xgbLinear_random_1.rds")




