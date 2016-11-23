rm(list = ls())
#===============================================================================
#                       LOAD PACKAGES AND MODULES                              #
#===============================================================================
library("data.table")
library("DataCombine")
library(dplyr)
na_count <-function (x) sapply(x, function(y) sum(is.na(y)))
#===============================================================================
#                                SETUP PARALLEL                                #
#===============================================================================
library(foreach)
library(parallel)
library(doParallel)
if(!exists("cl")){
  library(doParallel)
  cores.number = detectCores(all.tests = FALSE, logical = TRUE)
  cl = makeCluster(2)
  registerDoParallel(cl, cores=cores.number)
}


#===============================================================================
#                                 IMPORT DATA                                  #
#===============================================================================
if (dir.exists('/home/bc7_ntalavera/Dropbox/Data Science/Data Files/Xbox Back Compat Data/')) {
  dataLocale = '/home/bc7_ntalavera/Dropbox/Data Science/Data Files/Xbox Back Compat Data/'
} else if (dir.exists('/Volumes/SDExpansion/Data Files/bootcamp007_project/Project3-WebScraping/NickTalavera/Data/')) {
  dataLocale = '/Volumes/SDExpansion/Data Files/bootcamp007_project/Project3-WebScraping/NickTalavera/Data/'
  setwd('/Volumes/SDExpansion/Data Files/bootcamp007_project/Project3-WebScraping/NickTalavera')
}  else if (dir.exists('/home/bc7_ntalavera/Data/Xbox/')) {
  dataLocale = '/home/bc7_ntalavera/Data/Xbox/'
}
markdownFolder = paste0(dataLocale,'MarkdownOutputs/')
data = data.frame(fread(paste0(dataLocale,'dataUlt.csv'), stringsAsFactors = TRUE, drop = c("V1")))
nums <- parSapply(cl = cl, data, is.logical)
nums = names(nums[nums==TRUE])
for (column in nums) {
  data[,column] = as.factor(data[,column])
}
na_count(data)
data$gameName = as.character(data$gameName)
data$releaseDate = as.numeric(data$releaseDate)
sapply(data,class)
#===============================================================================
#                               MACHINE LEARNING                               #
#===============================================================================
# This script trains and runs a model using the caret package
# It will then output a time stamped folder with the model results
#
########### File parameters ###########
# 
# model_method - the name of the model (e.g. "gbm")
# model_grid <- grid for cross-validation
# 
# subset_ratio - for testing purposes (set to 1 for full data)
# partition_ratio - proportion of training used for cross-validation
# cv_folds - # folds for cross-validation 
# 
# parallelize - parallelize the computation?
# create_submission - create a submission for kaggle?
# use_log - take the log transform of the response?
# use_mae_metric - use mean aboslute error for cross-validation?
# 
# data_path - data path containing train and test sets
# output_path - output path for storing results
# Add parallelization

# Model parameters
model_method = "gbm"
model_grid <- expand.grid( n.trees = seq(100, 1000, 100), 
                           interaction.depth = c(1, 3, 5, 7), 
                           shrinkage = 0.1,
                           n.minobsinnode = 20)

# Misc Parameters
subset_ratio = .01 # for testing purposes (set to 1 for full data)
partition_ratio = .8 # for cross-validation
cv_folds = 2 # for cross-validation 

parallelize = TRUE # parallelize the computation?
create_submission = FALSE # create a submission for Kaggle?
use_log = FALSE # take the log transform of the response?
verbose_on = TRUE
metric = 'MAE' # metric use for evaluating cross-validation

#===============================================================================
#                                   MODELS                                     #
#===============================================================================
# Make array of unwanted columns
unwantedPredictors = c("gameName","developer","gameUrl","highresboxart")
# Read training and test data
sapply(data, function(y) sum(length(which(is.na(y)))))
library(mice)
data <- mice(data,m=1,maxit=1,meth='pmm',seed=0)
# Store and remove ids
as_train = data[which(data$isBCCompatible == TRUE | data$usesRequiredPeripheral == TRUE | data$isKinectRequired == TRUE),]
train_ids = as_train$gameName
as_train = VarDrop(as_train, unwantedPredictors)

# Store and remove ids
as_test = data[-which(data$isBCCompatible == TRUE | data$usesRequiredPeripheral == TRUE | data$isKinectRequired == TRUE),]
test_ids = as_test$gameName
as_test = VarDrop(as_test, unwantedPredictors)

# Subset the data
library(caret)
set.seed(0)
duplicated(train_ids)
training_subset = createDataPartition(y = train_ids, p = subset_ratio, list = FALSE)
as_train <- as_train[training_subset, ]

# Transform the bcCompat to log
if(use_log){
  bcCompat = log(as_train$isBCCompatible + 1)
}else{
  bcCompat = as_train$isBCCompatible
}

# Pre-processing
print("Pre-processing...")

# Convert categorical to dummy variables
as_train = model.matrix(bcCompat ~ . -1 , data = as_train) # - 1 to ignore intercept
as_test = model.matrix( ~ . -1, data = as_test)
dim(as_train)
# # Run caret's pre-processing methods
# preProc <- preProcess(as_train,
#                       method = c("nzv","knnImpute"))
# 
# # Transform the predictors
# dm_train = predict(preProc, newdata = as_train)
# dim(dm_train)
# dm_test = predict(preProc, newdata = as_test)
# print("...Done!")
# 
# # Setting up the cross-validatias_trainon
# set.seed(0)
# 
# # Partition training data into train and test split
# trainIdx <- createDataPartition(bcCompat,
#                                 p = partition_ratio,
#                                 list = FALSE,
#                                 times = 1)
# dim(dm_train)
# dim(trainIdx)
# sub_train <- dm_train[trainIdx,]
# sub_test <- dm_train[-trainIdx,]
# isBCCompatible_train <- bcCompat[trainIdx]
# isBCCompatible_test <- bcCompat[-trainIdx]
# 
# # Setting up the model
# fitCtrl <- trainControl(method = "cv",
#                         number = cv_folds,
#                         verboseIter = verbose_on,
#                         summaryFunction = defaultSummary,
#                         allowParallel = parallelize)
# 
# # Run the model on the bcCompat
# print("Running the model...")
# training_model <- train(x = sub_train,
#                         y = isBCCompatible_train,
#                         method = model_method,
#                         trControl = fitCtrl,
#                         tuneGrid = model_grid,
#                         metric = metric,
#                         maximize = FALSE)
# print("...Done!")
# 
# # Estimated RMSE and MAE
# test.predicted <- predict(training_model, sub_test)
# if(use_log){
#   test.predicted = exp(test.predicted) - 1
#   isBCCompatible_test = exp(isBCCompatible_test) - 1
# }
# estimated_rmse = postResample(pred = test.predicted, obs = isBCCompatible_test)
# 
# cv_results = training_model$results
# method_name = training_model$method
# best_params = training_model$bestTune
# 
# # Output plot
# tryCatch({
#   png(file.path(directory, 'tuning_plot.png'))
#   print(plot(training_model))
#   dev.off()
# }, error = function(e){
#   print("No tuning parameters found. Skipping plot.")
# })
# 
# # Output grid, control, time stamp, and model name
# model_results = list(grid = model_grid, train_control = fitCtrl, best_params = best_params,
#                      estimated_rmse = estimated_rmse, estimated_mae = estimated_mae,
#                      cv_results = cv_results, name = method_name, time_stamp = Sys.time())
# save(model_results, file = file.path(directory, "results.RData"))
# 
# # Create the Kaggle submission file
# if(create_submission){
#   print("Training final model for Kaggle...")
#   # Train final model on all of the data with best tuning parameters
#   final_model = train(x = dm_train,
#                       y = isBCCompatible,
#                       method = model_method,
#                       tuneGrid = best_params,
#                       metric = metric,
#                       maximize = FALSE)
# 
#   # Get the predicted isBCCompatible for the test set
#   predicted_isBCCompatible = predict(final_model, newdata = dm_test)
#   if(use_log){
#     predicted_isBCCompatible = exp(predicted_isBCCompatible) - 1
#   }
# 
#   # Output Kaggle submission
#   submission = data.frame(id=test_ids, isBCCompatible=predicted_isBCCompatible)
#   write.csv(submission, file = file.path(directory, "kaggle_submission.csv"), row.names = FALSE)
#   print("...Done!")
# }
# 
# # Stop parallel clusters
# if(parallelize & !exists("cl")){
#   stopCluster(cl)
# }