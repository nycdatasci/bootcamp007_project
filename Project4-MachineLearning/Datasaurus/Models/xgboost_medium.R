# Model parameters
model_method = "xgbTree"
model_grid = expand.grid(nrounds = 1000,
                         eta = .05,
                         max_depth = 12,
                         gamma = 2,
                         colsample_bytree = 0.5,
                         min_child_weight = 1,
                         subsample = 0.8)
extra_params = list(alpha = 1)

# Cross-validation parameters
do_cv = FALSE
partition_ratio = .8 # for cross-validation
cv_folds = 1 # for cross-validation
verbose_on = TRUE # output cv folds results?
metric = 'MAE' # metric use for evaluating cross-validation

# Misc parameters
subset_ratio = 0.01 # for testing purposes (set to 1 for full data)
create_submission = TRUE # create a submission for Kaggle?
use_log = TRUE # take the log transform of the response?
