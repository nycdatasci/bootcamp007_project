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
  cores.number = detectCores(all.tests = FALSE, logical = TRUE) -1
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
dataOriginal = data.frame(fread(paste0(dataLocale,'dataUlt.csv'), stringsAsFactors = TRUE, drop = c("V1")))
data = data.frame(fread(paste0(dataLocale,'dataUltImputed.csv'), stringsAsFactors = TRUE, drop = c("V1")))
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
# model_method = "nnet"
# model_grid <- expand.grid(.decay = c(0.5, 0.1), .size = c(5, 6, 7))

model_method = "nnet"
# model_grid <- expand.grid(.decay = c(0.5, 0.1), .size = c(5, 6, 7))
# model_grid <- expand.grid(.decay = c(0.4, 0.45, 0.5), .size = c(4, 4.25, 4.5))
model_grid <- expand.grid(.decay = c(0.45), .size = c(4.25, 4.5, 4.75))

# Misc Parameters
subset_ratio = 1 # for testing purposes (set to 1 for full data)
partition_ratio = .8 # for cross-validation
cv_folds = 5 # for cross-validation 

parallelize = TRUE # parallelize the computation?
create_submission = TRUE # create a submission for Kaggle?
use_log = FALSE # take the log transform of the response?
verbose_on = TRUE
metric = 'Accuracy' # metric use for evaluating cross-validation

#===============================================================================
#                                   MODELS                                     #
#===============================================================================
# Make array of unwanted columns
unwantedPredictors = c("gameName","gameUrl","highresboxart")
# Read training and test data
sapply(data, function(y) sum(length(which(is.na(y)))))



# data = data[complete.cases(data),]
# data <- (preProcess(data, method = c("knnImpute")))
# imp <- mice(data, m=5, maxit=10, printFlag=TRUE) 
# Datimp <- complete(imp, "long", include=TRUE)

# Store and remove ids
as_train = data[which(data$isBCCompatible == TRUE | data$usesRequiredPeripheral == TRUE | data$isKinectRequired == TRUE),]
as_trainUnMod = dataOriginal[which(data$isBCCompatible == TRUE | data$usesRequiredPeripheral == TRUE | data$isKinectRequired == TRUE),]
train_ids = as_train$gameName
as_train = VarDrop(as_train, unwantedPredictors)
train_BC = as_train$isBCCompatible
# Store and remove ids
as_test = data[-which(data$isBCCompatible == TRUE | data$usesRequiredPeripheral == TRUE | data$isKinectRequired == TRUE),]
as_testUnMod = dataOriginal[-which(data$isBCCompatible == TRUE | data$usesRequiredPeripheral == TRUE | data$isKinectRequired == TRUE),]
test_ids = as_test$gameName
as_test = VarDrop(as_test, unwantedPredictors)
test_BC = as_test$isBCCompatible

# Subset the data
library(caret)
set.seed(0)
duplicated(train_ids)
training_subset = createDataPartition(y = train_ids, p = subset_ratio, list = FALSE)
as_train <- as_train[training_subset, ]

# Transform the bcCompat to log
if(use_log){
  bcCompatTrain = log(train_BC + 1)
}else{
  bcCompatTrain = train_BC
}

# Pre-processing
print("Pre-processing...")

# Convert categorical to dummy variables
as_train = model.matrix(isBCCompatible ~ . -1 -isBCCompatible, data = as_train) # - 1 to ignore intercept
as_test = model.matrix( ~ . -1 -isBCCompatible, data = as_test)
# as_train = cbind(as_train,bcCompatTrain)
dim(as_train)
# Run caret's pre-processing methods
preProc <- preProcess(as_train,
                      method = c("nzv"))

# Transform the predictors
dm_train = predict(preProc, newdata = as_train)
dm_test = predict(preProc, newdata = as_test)
# dm_train$isBCCompatible = bcCompat
print("...Done!")

# Setting up the cross-validatias_trainon
set.seed(0)

# Partition training data into train and test split
trainIdx <- createDataPartition(bcCompatTrain,
                                p = partition_ratio,
                                list = FALSE,
                                times = 1)
sub_train <- dm_train[trainIdx,]
sub_test <- dm_train[-trainIdx,]

isBCCompatible_train <- bcCompatTrain[trainIdx]
isBCCompatible_test <- bcCompatTrain[-trainIdx]

# Setting up the model
fitCtrl <- trainControl(method = "cv",
                        number = cv_folds,
                        verboseIter = verbose_on,
                        summaryFunction = defaultSummary,
                        allowParallel = parallelize)

# Run the model on the bcCompat
print("Running the model...")
training_model <- train(x = sub_train,
                        y = isBCCompatible_train,
                        method = model_method,
                        trControl = fitCtrl,
                        tuneGrid = model_grid,
                        metric = metric,
                        maximize = FALSE)
print("...Done!")

# Estimated RMSE and MAE
test.predicted <- predict(training_model, sub_test)
if(use_log){
  test.predicted = exp(test.predicted) - 1
  isBCCompatible_test = exp(isBCCompatible_test) - 1
}
estimated_rmse = postResample(pred = test.predicted, obs = isBCCompatible_test)

cv_results = training_model$results
method_name = training_model$method
best_params = training_model$bestTune
directory = getwd()
# Output plot
tryCatch({
  png(file.path(directory, 'tuning_plot.png'))
  print(plot(training_model))
  dev.off()
}, error = function(e){
  print("No tuning parameters found. Skipping plot.")
})

# Output grid, control, time stamp, and model name
model_results = list(grid = model_grid, train_control = fitCtrl, best_params = best_params,
                     estimated_rmse = estimated_rmse,
                     cv_results = cv_results, name = method_name, time_stamp = Sys.time())
save(model_results, file = file.path(directory, "results.RData"))

if (dir.exists('/home/bc7_ntalavera/Dropbox/Data Science/Data Files/Xbox Back Compat Data/')) {
  dataLocale = '/home/bc7_ntalavera/Dropbox/Data Science/Data Files/Xbox Back Compat Data/'
} else if (dir.exists('/Volumes/SDExpansion/Data Files/bootcamp007_project/Project3-WebScraping/NickTalavera/Data/')) {
  dataLocale = '/Volumes/SDExpansion/Data Files/bootcamp007_project/Project3-WebScraping/NickTalavera/Data/'
  setwd('/Volumes/SDExpansion/Data Files/bootcamp007_project/Project3-WebScraping/NickTalavera')
}  else if (dir.exists('/home/bc7_ntalavera/Data/Xbox/')) {
  dataLocale = '/home/bc7_ntalavera/Data/Xbox/'
}

# Create the final file
if(create_submission){
  print("Training final model...")
  # Train final model on all of the data with best tuning parameters
dim(dm_train)
  length(bcCompatTrain)
  
  final_model = train(x = dm_train,
                      y = bcCompatTrain,
                      method = model_method,
                      tuneGrid = best_params,
                      metric = metric, maxit = 1000,
                      maximize = FALSE)
  print("Finished processing final model...")
  # Get the predicted isBCCompatible for the test set
  sort(names(final_model$trainingData))
  predicted_isBCCompatible = predict(final_model, newdata = dm_test)
  if(use_log){
    predicted_isBCCompatible = exp(predicted_isBCCompatible) - 1
  }
  # Output final file
  # submission = data.frame(test_ids,predicted_isBCCompatible)
  submission = cbind(as_testUnMod, predicted_isBCCompatible)
  submission = rbind(submission, cbind(as_trainUnMod, predicted_isBCCompatible = as_trainUnMod$isBCCompatible))
  for (column in nums) {
    submission[,column] = as.logical(submission[,column])
  }
  submission = data.frame(as.data.frame(submission))
  write.csv(submission, file = file.path(dataLocale, "dataWPrediction.csv"), row.names = FALSE)
  print("...Done!")
}

# Stop parallel clusters
if(parallelize & !exists("cl")){
  stopCluster(cl)
}
submissionNew = submission[submission$isBCCompatible==FALSE & submission$isKinectRequired == FALSE & submission$usesRequiredPeripheral == FALSE & submission$predicted_isBCCompatible == FALSE,]