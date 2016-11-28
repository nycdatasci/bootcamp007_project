# Model parameters
# Find best nrounds again
# Result: 98 rounds best
model_method = "xgbTree"
model_grid = expand.grid(nrounds = seq(1000),
                         eta = .1,
                         max_depth = 4,
                         gamma = 0.8,
                         colsample_bytree = 0.5,
                         min_child_weight = 4,
                         subsample = 0.8)
extra_params = NULL

# Cross-validation parameters
do_cv = TRUE
partition_ratio = .8 # for cross-validation
cv_folds = 10 # for cross-validation
verbose_on = TRUE # output cv folds results?
metric = 'MAE' # metric use for evaluating cross-validation

# Misc parameters
subset_ratio = .01 # for testing purposes (set to 1 for full data)
create_submission = FALSE # create a submission for Kaggle?
use_log = TRUE # take the log transform of the response?