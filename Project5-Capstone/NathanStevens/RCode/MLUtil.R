# utility library for running ML code on NYC tree census data
library(dplyr)
library(caret)
library(xgboost)
library(ModelMetrics)
library(doParallel)
library(nnet)
#library(klaR)

# specify the numboer cores for fitting
num.cores = 3

# create a subset of the data
loadTrainData = function() {
  #df = read.csv("../raw_data/trees_2005_train.csv")
  #train_2005 <<- select(df, -tree_id, -year, -spc_common, -address, -zipcode, -block_code)
  #sidewalk_2005 <<- train_2005$sidewalk
  
  df = read.csv("../raw_data/trees_2015_train.csv")
  
  # impute any zero width trees to the median of the dbh
  df$tree_dbh[df$tree_dbh == 0] <- median(df$tree_dbh)
  
  train_2015 <<- select(df, -tree_id, -year, -spc_common, -address, -zipcode, -block_code)
  sidewalk_2015 <<- train_2015$sidewalk
}

# function to create the data for training
createTrainDM = function(train.df) {
 dm_train <- model.matrix(sidewalk ~ ., data = train.df)
 preProc <- preProcess(dm_train, method = "nzv")
 dm_train <<- predict(preProc, dm_train)
}

# create the test data matrix
createTestDM = function(test.df) {
  dm_test <- model.matrix(sidewalk ~ ., data = test.df)
  preProc <- preProcess(dm_test, method = "nzv")
  dm_test <<- predict(preProc, dm_test)
}

# this creates test function based on df
createSubTrainAndTest = function(dm_train, sidewalk) {
  set.seed(321)
  trainIdx <- createDataPartition(sidewalk, 
                                  p = .8,
                                  list = FALSE,
                                  times = 1)
  subTrain <<- dm_train[trainIdx,]
  subTest <<- dm_train[-trainIdx,]
  sidewalkTrain <<- sidewalk[trainIdx]
  sidewalkTest <<- sidewalk[-trainIdx]
}

# fit data using glm
fitDataGLM = function() {
  glmFit <<- train(x = subTrain, 
               y = sidewalkTrain,
               method = "glm",
               family = "binomial")
  
  return(getTrainPerf(glmFit))
}

# test the glm performance of the test data
testFitGLM = function() {
  predicted <- predict(glmFit, subTest)
  return(postResample(pred = predicted, obs = sidewalkTest))
}

# fit data using glm aic step
fitDataGLMStep = function() {
  glmSFit <<- train(x = subTrain, 
                   y = sidewalkTrain,
                   method = "glmStepAIC",
                   family = "binomial")
  
  return(getTrainPerf(glmSFit))
}

# test the glm AIC step performance of the test data
testFitGLMStep = function() {
  predicted <- predict(glmSFit, subTest)
  return(postResample(pred = predicted, obs = sidewalkTest))
}

# tune control for glmnet
tuneGLMNet = function() {
  fitCtrl <<- trainControl(method = "repeatedCV",
                          number=10,
                          repeats=5,
                          returnResamp = "all",
                          classProbs = TRUE,
                          summaryFunction=twoClassSummary)
  
  glmnetGrid <<- expand.grid(.alpha=c(0,0.25,0.5,1),.lambda=seq(0,0.05,by=0.01))
}

# method to perform glmnet on data
fitDataGLMNet = function() {
  glmnetFit <<- train(x = subTrain, 
                  y = sidewalkTrain, 
                  method="glmnet",
                  trControl=fitCtrl,
                  tuneGrid = glmnetGrid,
                  metric="ROC",
                  preProc = c("center", "scale"))
  
  return(getTrainPerf(glmnetFit))
}

# test fit the glmnet model
testFitGLMNet = function() {
  predicted <- predict(glmnetFit, subTest)
  return(postResample(pred = predicted, obs = sidewalkTest))
}

# tune control for KNN
tuneKNN = function() {
  fitCtrl <<- trainControl(method="repeatedcv", number=10, repeats=3)
}

# method to perform knn on data
fitDataKNN = function() {
  knnFit <<- train(x = subTrain, 
                  y = sidewalkTrain, 
                  method="knn",
                  trControl=fitCtrl,
                  metric="Accuracy",
                  tuneLength=20,
                  preProc=c("range"))
}

# test fit the KNN data
testFitKNN = function() {
  predicted <- predict(knnFit, subTest)
  return(postResample(pred = predicted, obs = sidewalkTest))
}

# tune control for Naive Bayes
tuneNB = function() {
  fitCtrl <<- trainControl(method="repeatedcv", number=10, repeats=3)
}

# method to perform naive bayes on data
fitDataNB = function() {
  nbFit <<- train(x = subTrain, 
                   y = sidewalkTrain, 
                   method="nb",
                   trControl=fitCtrl,
                   metric="Accuracy",
                   preProc=c("range"))
}

# test fit the Naive Bayes model
testFitNB = function() {
  predicted <- predict(nbFit, subTest)
  return(postResample(pred = predicted, obs = sidewalkTest))
}

## tune the gbm models
tuneGBM = function() {
  fitCtrl <<- trainControl(method = "cv",
                          number = 5,
                          verboseIter = TRUE,
                          summaryFunction=twoClassSummary,
                          classProbs = TRUE)

  gbmGrid <<- expand.grid( n.trees = seq(100,500,50),
                          interaction.depth = c(1,3,5,7),
                          shrinkage = 0.1,
                          n.minobsinnode = 20)
}

## run gbm fit
fitDataGBM = function() {
   gbmFit <<- train(x = subTrain, 
                  y = sidewalkTrain,
                  method = "gbm",
                  trControl = fitCtrl,
                  metric = 'ROC',
                  preProc = c("center", "scale"))

  return (getTrainPerf(gbmFit))
} 
 
## function to make prediction with data
testFitGBM = function() {
   predicted <- predict(gbmFit, subTest)
   return(postResample(pred = predicted, obs = sidewalkTest))
}
 
## tune xgb parameters
tuneXGB = function() {
  xgbCtrl <<- trainControl(method = "repeatedcv",
                         repeats = 1,
                         number = 5,
                         allowParallel=T,
                         verboseIter = TRUE,
                         classProbs = TRUE)
  
  xgbGrid <<- expand.grid(nrounds = 1000,
                          max_depth = 10,
                          eta = 0.01,
                          gamma = 1,
                          colsample_bytree = 0.5,
                          min_child_weight = 1,
                          subsample = 0.8)
}
 
## use xgb to fit the data
fitDataXGB = function() {
  xgbFit <<- train(x = subTrain,
                   y = sidewalkTrain,
                   method = "xgbTree",
                   trControl = xgbCtrl,
                   tuneGrid = xgbGrid,
                   metric = 'Accuracy',
                   verbose = TRUE)

  return (getTrainPerf(xgbFit))
}

## function to test the predicted power of the model
testFitXGB = function() {
  predicted <- predict(xgbFit, subTest)
  return(postResample(pred = predicted, obs = sidewalkTest))
}

## tune the svm models
tuneSVM = function() {
  svmCtrl <<- trainControl(method = "repeatedcv",
                           number = 5,
                           verboseIter = TRUE,
                           summaryFunction=twoClassSummary,
                           classProbs = TRUE)
  
  # polynomial grid
  #svmGrid <<- expand.grid(degree = 2,
  #                        scale = c(0.1, 0.01),
  #                        C = 1)
  # radial grid
  svmGrid <<- expand.grid(#sigma = c(.01, .015, 0.2),
                          sigma = c(0.2),
                          C = 1)
}

## use svm to fit the data
fitDataSVM = function() {
  svmFit <<- train(x = subTrain,
                   y = sidewalkTrain,
                   method = "svmRadial",
                   trControl = svmCtrl,
                   tuneGrid = svmGrid,
                   metric = 'ROC',
                   preProc=c('center','scale'))
  
  return (getTrainPerf(svmFit))
}

## test the predictive power of the svm model
testFitSVM = function() {
  predicted <- predict(svmFit, subTest)
  return(postResample(pred = predicted, obs = sidewalkTest))
}

## tune for neral network classification
tuneNNET = function() {
  nnetCtrl <<- trainControl(method = 'cv', number = 10, classProbs = TRUE, verboseIter = TRUE, summaryFunction = twoClassSummary)
  
  nnetGrid <<- expand.grid(size = c(10,20,30), decay=10^seq(-4, -1, 1))
}

## use nnet to fit the data
fitDataNNET = function() {
  nnetFit <<- train(x = subTrain,
                   y = sidewalkTrain,
                   method = "nnet",
                   trControl = nnetCtrl,
                   tuneGrid = nnetGrid,
                   metric = 'ROC',
                   preProc=c('center','scale'))
  
  return (getTrainPerf(nnetFit))
}

## test the predicted power of the svm model
testFitNNET = function() {
  predicted <- predict(nnetFit, subTest)
  return(postResample(pred = predicted, obs = sidewalkTest))
}


#
# load on the train data
#
loadTrainData()
createTrainDM(train_2015)
createSubTrainAndTest(dm_train, sidewalk_2015)

## Do logistic regression
set.seed(123)
start.time <- Sys.time()

cl <- makeCluster(num.cores)
registerDoParallel(cl)
fitDataGLM()
stopCluster(cl)
testFitGLM()
end.time <- Sys.time()
time.takenGLM <- end.time - start.time
time.takenGLM

## Do glmnet logistic regression
set.seed(123)
start.time <- Sys.time()

tuneGLMNet()
cl <- makeCluster(num.cores)
registerDoParallel(cl)
fitDataGLMNet()
stopCluster(cl)
testFitGLMNet()

end.time <- Sys.time()
time.takenGLMNet <- end.time - start.time
time.takenGLMNet

cat('WE here')

## Do stepwise AIC logistic regression
# start.time <- Sys.time()
# 
# fitDataGLMStep()
# testFitGLMStep()
# 
# end.time <- Sys.time()
# time.takenGLMS <- end.time - start.time
# time.takenGLMS

# ## Do knn classification using 3 cores
# set.seed(123)
# start.time <- Sys.time()
# 
# tuneKNN()
# cl <- makeCluster(num.cores)
# registerDoParallel(cl)
# fitDataKNN()
# stopCluster(cl)
# testFitKNN()
# 
# end.time <- Sys.time()
# time.takenKNN <- end.time - start.time
# time.takenKNN
# 
# ## Do naive bayes classification
# set.seed(123)
# start.time <- Sys.time()
# 
# tuneNB()
# cl <- makeCluster(num.cores)
# registerDoParallel(cl)
# fitDataNB()
# stopCluster(cl)
# testFitNB()
# 
# end.time <- Sys.time()
# time.takenNB <- end.time - start.time
# time.takenNB
# 
# ## Do GBM classification
# set.seed(123)
# start.time <- Sys.time()
# 
# tuneGBM()
# cl <- makeCluster(num.cores)
# registerDoParallel(cl)
# fitDataGBM()
# stopCluster(cl)
# testFitGBM()
# 
# end.time <- Sys.time()
# time.takenGBM <- end.time - start.time
# time.takenGBM
# 
# ## Do xgboost classification
# set.seed(123)
# start.time <- Sys.time()
# 
# tuneXGB()
# cl <- makeCluster(num.cores)
# registerDoParallel(cl)
# fitDataXGB()
# stopCluster(cl)
# testFitXGB()
# 
# end.time <- Sys.time()
# time.takenXGB <- end.time - start.time
# time.takenXGB
# 
# ## Do svm classfication
# set.seed(123)
# start.time <- Sys.time()
# 
# tuneSVM()
# cl <- makeCluster(num.cores)
# registerDoParallel(cl)
# fitDataSVM()
# stopCluster(cl)
# testFitSVM()
# 
# end.time <- Sys.time()
# time.takenSVM <- end.time - start.time
# time.takenSVM
# 
# ## Do neural network classification
# set.seed(123)
# start.time <- Sys.time()
# 
# tuneNNET()
# cl <- makeCluster(num.cores)
# registerDoParallel(cl)
# fitDataNNET()
# stopCluster(cl)
# testFitNNET()
# 
# end.time <- Sys.time()
# time.takenNNET <- end.time - start.time
# time.takenNNET
# 
# total.time = time.takenGLM + time.takenKNN + time.takenNB + 
# time.takenGBM + time.takenXGB + time.takenSVM + time.takenNNET
# cat("\n\nTotal Time Taken in Minutes:", total.time/60)

## Gather information about model performance
#getTrainPerf(nnetFit)
#testFitNNET()
#time.takenNNET
#plot(varImp(nnetFit, scale = TRUE))