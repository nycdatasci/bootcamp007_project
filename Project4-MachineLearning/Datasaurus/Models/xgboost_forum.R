# Model parameters
model_method = "xgbTree"
best_nrounds = 545
model_grid = expand.grid(nrounds = seq(as.integer(best_nrounds/0.8)),
                         eta = 0.05,
                         max_depth = 12,
                         gamma = 2,
                         colsample_bytree = 0.5,
                         min_child_weight = 1,
                         subsample = 0.8)
extra_params = list(alpha = 1)

# Cross-validation parameters
do_cv = TRUE
partition_ratio = .8 # for cross-validation
cv_folds = 2 # for cross-validation
verbose_on = TRUE # output cv folds results?
metric = 'MAE' # metric use for evaluating cross-validation

# Misc parameters
subset_ratio = .01 # for testing purposes (set to 1 for full data)
create_submission = TRUE # create a submission for Kaggle?
use_log = TRUE # take the log transform of the response?