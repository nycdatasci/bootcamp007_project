# Model parameters
model_method = "xgbTree"
model_grid <- expand.grid(nrounds = c(1000, 2000, 4000),
                          eta = c(0.01),
                          max_depth = c(2, 4, 8, 16),
                          gamma = 1,
                          colsample_bytree = 0.5,
                          min_child_weight = 1,
                          subsample = c(0.8)) # REMEMBER TO ADD/REMOVE 
extra_params = NULL

# Cross-validation parameters
do_cv = TRUE
partition_ratio = .8 # for cross-validation
cv_folds = 2 # for cross-validation
verbose_on = TRUE # output cv folds results?
metric = 'MAE' # metric use for evaluating cross-validation

# Misc parameters
subset_ratio = .01 # for testing purposes (set to 1 for full data)
create_submission = FALSE # create a submission for Kaggle?
use_log = FALSE # take the log transform of the response?