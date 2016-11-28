# Model parameters
model_method = "xgbTree"
model_grid <- NULL

extra_params = NULL

# Cross-validation parameters
do_cv = TRUE
partition_ratio = .8 # for cross-validation
cv_folds = 10 # for cross-validation
verbose_on = TRUE # output cv folds results?
metric = 'RMSE' # metric use for evaluating cross-validation

# Misc parameters
subset_ratio = 1 # for testing purposes (set to 1 for full data)
create_submission = TRUE # create a submission for Kaggle?
use_log = FALSE # take the log transform of the response?
