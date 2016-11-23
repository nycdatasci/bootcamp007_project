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
if(parallelize & !exists("cl")){
  library(doParallel)
  cores.number = detectCores(all.tests = FALSE, logical = TRUE)
  cl = makeCluster(2)
  registerDoParallel(cl, cores=cores.number)
}

# Read training and test data
library(data.table)
library(dplyr)
as_train <- fread(file.path(data_path, "train.csv"), stringsAsFactors = TRUE)
# Store and remove ids
train_ids = as_train$id
as_train = as_train %>% dplyr::select(-id)

as_test <- fread(file.path(data_path, "test.csv"), stringsAsFactors = TRUE)
# Store and remove ids
test_ids = as_test$id
as_test = as_test %>% dplyr::select(-id)

# Subset the data
library(caret)
set.seed(0)
training_subset = createDataPartition(y = train_ids, p = subset_ratio, list = FALSE)
as_train <- as_train[training_subset, ]

# Transform the loss to log
if(use_log){
  loss = log(as_train$loss + 1)
}else{
  loss = as_train$loss
}

# Pre-processing
print("Pre-processing...")

# Convert categorical to dummy variables
as_train = model.matrix(loss ~ . -1, data = as_train) # - 1 to ignore intercept
as_test = model.matrix( ~ . -1, data = as_test)

# Run caret's pre-processing methods
preProc <- preProcess(as_train, 
                      method = c("nzv"))

# Transform the predictors
dm_train = predict(preProc, newdata = as_train)
dm_test = predict(preProc, newdata = as_test)
print("...Done!")

# Setting up the cross-validation
set.seed(0)

# Partition training data into train and test split
trainIdx <- createDataPartition(loss, 
                                p = partition_ratio,
                                list = FALSE,
                                times = 1)
sub_train <- dm_train[trainIdx,]
sub_test <- dm_train[-trainIdx,]
loss_train <- loss[trainIdx]
loss_test <- loss[-trainIdx]

# Setting up the model
library(Metrics)
maeSummary <- function (data,
                        lev = NULL,
                        model = NULL) {
  out <- Metrics::mae(data$obs, data$pred)  
  names(out) <- "MAE"
  out
}

if(metric == 'MAE'){
  summary_function = maeSummary
}else{
  summary_function = defaultSummary
}
fitCtrl <- trainControl(method = "cv",
                        number = cv_folds,
                        verboseIter = verbose_on,
                        summaryFunction = summary_function,
                        allowParallel = parallelize)

# Run the model on the loss
print("Running the model...")
training_model <- train(x = sub_train, 
                y = loss_train,
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
  loss_test = exp(loss_test) - 1
}
estimated_rmse = postResample(pred = test.predicted, obs = loss_test)
estimated_mae = Metrics::mae(loss_test, test.predicted)

cv_results = training_model$results
method_name = training_model$method
best_params = training_model$bestTune

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
                     estimated_rmse = estimated_rmse, estimated_mae = estimated_mae,
                     cv_results = cv_results, name = method_name, time_stamp = Sys.time())
save(model_results, file = file.path(directory, "results.RData"))

# Create the Kaggle submission file
if(create_submission){
  print("Training final model for Kaggle...")
  # Train final model on all of the data with best tuning parameters
  final_model = train(x = dm_train,
                      y = loss,
                      method = model_method,
                      tuneGrid = best_params,
                      metric = metric,
                      maximize = FALSE)
  
  # Get the predicted loss for the test set
  predicted_loss = predict(final_model, newdata = dm_test)
  if(use_log){
    predicted_loss = exp(predicted_loss) - 1
  }
  
  # Output Kaggle submission
  submission = data.frame(id=test_ids, loss=predicted_loss)
  write.csv(submission, file = file.path(directory, "kaggle_submission.csv"), row.names = FALSE)
  print("...Done!")
}

# Stop parallel clusters
if(parallelize & !exists("cl")){
  stopCluster(cl)
}