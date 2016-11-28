# This script trains and runs a model using the caret package
# It will then output a time stamped folder with the model results


########### Functions parameters ###########
# 
# model_method - the name of the model (e.g. "gbm")
# model_grid <- grid for cross-validation
# 
# subset_ratio - for testing purposes (set to 1 for full data)
# partition_ratio - proportion of training used for cross-validation
# cv_folds - # folds for cross-validation 
# 
# create_submission - create a submission for kaggle?
# use_log - take the log transform of the response?
# use_mae_metric - use mean aboslute error for cross-validation?
# 
# data_path - data path containing train and test sets
# output_path - output path for storing results
make_model = function(model_params, data_path, output_path){
  
  # For reproducibility
  set.seed(0)
  
  model_method = model_params$model_method
  model_grid = model_params$model_grid
  extra_params = model_params$extra_params
  partition_ratio = model_params$partition_ratio
  cv_folds = model_params$cv_folds
  verbose_on = model_params$verbose_on
  metric = model_params$metric
  subset_ratio = model_params$subset_ratio
  create_submission = model_params$create_submission
  use_log = model_params$use_log
  do_cv = model_params$do_cv
  
  # Read training and test data
  library(data.table)
  library(dplyr)
  
  #Remove columns where all factors had non-zero variance according to exploratory data analysis
  removeableVariablesEDA = c("cat7","cat14", "cat15", "cat16", "cat17", "cat18", "cat19", "cat20", "cat21", "cat22", "cat24", "cat28", "cat29", "cat30", "cat31", 
                             "cat32", "cat33", "cat34", "cat35", "cat39", "cat40", "cat41", "cat42", "cat43", "cat45", "cat46", "cat47", "cat48", "cat49", "cat51", 
                             "cat52", "cat54", "cat55", "cat56", "cat57", "cat58", "cat59", "cat60", "cat61", "cat62", "cat63", "cat64", "cat65", "cat66", "cat67", 
                             "cat68", "cat69", "cat70", "cat74", "cat76", "cat77", "cat78", "cat85", "cat89")
  
  as_train <- fread(file.path(data_path, "train.csv"), stringsAsFactors = TRUE,
                    drop = removeableVariablesEDA)
  # Store and remove ids
  train_ids = as_train$id
  loss = as_train$loss
  as_train = as_train %>% dplyr::select(-id, -loss)
  
  as_test <- fread(file.path(data_path, "test.csv"), stringsAsFactors = TRUE,
                   drop = removeableVariablesEDA)
  # Store and remove ids
  test_ids = as_test$id
  as_test = as_test %>% dplyr::select(-id)
  
  # Subset the data
  library(caret)
  training_subset = createDataPartition(y = train_ids, p = subset_ratio, list = FALSE)
  as_train <- as_train[training_subset, ]
  loss = loss[training_subset]
  
  # Pre-processing
  print("Pre-processing...")
  
  # Transform the loss to log?
  shift = 1 # from forums
  if(use_log){
    loss = log(loss + shift)
  }
  max_loss = max(loss)
  min_loss = min(loss)
  
  # normalize loss
  loss = (loss - min_loss) / (max_loss - min_loss) 

  # Convert categorical to dummy variables
  ntrain = nrow(as_train)
  train_test = rbind(as_train, as_test)
  train_test_dummies = model.matrix( ~ ., data = train_test)
  
  as_train = train_test_dummies[1:ntrain,]
  as_test = train_test_dummies[(ntrain+1):nrow(train_test),]
  
  # Run caret's pre-processing methods
  preProc <- preProcess(as_train, 
                       method = c("nzv", "scale", "center"))
  
  # Transform the predictors
  dm_train = predict(preProc, newdata = as_train)
  dm_test = predict(preProc, newdata = as_test)
  #dm_train = as_train
  #dm_test = as_test

  print("...Done!")
  
  # Setting up the cross-validation
  
  # Partition training data into train and test split
  trainIdx <- createDataPartition(loss, 
                                  p = partition_ratio,
                                  list = FALSE,
                                  times = 1)
  sub_train <- dm_train[trainIdx,]
  sub_test <- dm_train[-trainIdx,]
  loss_train <- loss[trainIdx]
  loss_test <- loss[-trainIdx]
  indices_train <- training_subset[trainIdx]
  indices_test <- training_subset[-trainIdx]
  
  # Setting up the model
  library(Metrics)
  
  maeSummary <- function (data,
                          lev = NULL,
                          model = NULL) {
    out <- Metrics::mae(exp(data$obs), exp(data$pred)) * (max_loss - min_loss) + min_loss
    #out <- Metrics::mae(data$obs, data$pred) 
    names(out) <- "MAE"
    out
  }
  
  if(metric == 'MAE'){
    summary_function = maeSummary
  }else{
    summary_function = defaultSummary
  }
  
  if(do_cv){
    train_method = "cv"
  }else{
    train_method = "none"
  }
  
  fitCtrl <- trainControl(method = train_method,
                          number = cv_folds,
                          verboseIter = TRUE,
                          summaryFunction = summary_function,
                          allowParallel = TRUE)
  #fitCtrl = trainControl(method = "oob")
          
  # Start the clock!
  ptm <- proc.time()
  
  # Run the model on the loss
  print("Running the model...")
  # Append all arguments to extra parameters
  args = append(list(x = sub_train, 
                    y = loss_train, 
                    method = model_method, 
                    trControl = fitCtrl, 
                    tuneGrid = model_grid, 
                    metric = metric,
                    maximize = FALSE),
                    extra_params)
  training_model = do.call(train, args)
  print("...Done!")
  print(training_model)
  
  # Stop the clock
  run_time = proc.time() - ptm
  
  # Estimated RMSE and MAE
  test.predicted <- predict(training_model, sub_test)
  
  # Unnormalize
  loss_test = loss_test * (max_loss - min_loss) + min_loss
  test.predicted = test.predicted * (max_loss - min_loss) + min_loss
  
  # Transform prediction
  if(use_log){
    test.predicted = exp(test.predicted) - shift
    loss_test = exp(loss_test) - shift
  }

  estimated_rmse = postResample(pred = test.predicted, obs = loss_test)
  estimated_mae = Metrics::mae(loss_test, test.predicted)
  
  cv_results = training_model$results
  method_name = training_model$method
  best_params = training_model$bestTune
  
  # Print quick summary of results
  print("Estimated RMSE:")
  print(estimated_rmse)
  print("Estimated MAE:")
  print(estimated_mae)
  print("Best Parameters:")
  print(best_params)
  print("Run time:")
  print(run_time)
  
  # Output validation results
  validation_results = data.frame(original_index = indices_test, predicted = test.predicted, 
                                  loss = loss_test, abs_error = abs(test.predicted - loss_test))
  
  # Output plot
  tryCatch({
    png(file.path(output_path, 'tuning_plot.png'))
    print(plot(training_model))
    dev.off()
  }, error = function(e){
    print("No tuning parameters found. Skipping plot.")
  })
  
  # Output grid, control, time stamp, and model name
  model_results = list(grid = model_grid, best_params = best_params, run_time = run_time,
                       estimated_rmse = estimated_rmse, estimated_mae = estimated_mae,
                       cv_results = cv_results, name = method_name, time_stamp = Sys.time(),
                       validation_results = validation_results)
  save(model_results, file = file.path(output_path, "results.RData"))
  
  # Create the Kaggle submission file
  if(create_submission){
    print("Training final model for Kaggle...")
    # Train final model on all of the data with best tuning parameters
    args = append(list(x = dm_train, 
                       y = loss, 
                       method = model_method, 
                       trControl = trainControl(method = "none"), 
                       tuneGrid = best_params, 
                       metric = metric,
                       maximize = FALSE),
                  extra_params)
    final_model = do.call(train, args)
    #final_model = training_model$finalModel
    
    # Get the predicted loss for the test set
    print("Outputting prediction...")
    predicted_loss = predict(final_model, newdata = dm_test)
    predicted_loss =  predicted_loss * (max_loss - min_loss) + min_loss
    if(use_log){
      predicted_loss = exp(predicted_loss) - shift
    }
    
    # Output Kaggle submission
    submission = data.frame(id=test_ids, loss=predicted_loss)
    write.csv(submission, file = file.path(output_path, paste0(method_name, "_submission.csv")), row.names = FALSE)
    print("...Done!")
  }

}
