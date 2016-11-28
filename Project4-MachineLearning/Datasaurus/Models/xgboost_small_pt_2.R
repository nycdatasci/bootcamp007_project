# Model parameters
# We tune these first as they will have the highest impact on model outcome. 
# To start with, let’s set wider ranges and then we will perform another iteration for smaller ranges.
# From part 1, 110 rounds gave optimal parameters
# Source: https://www.analyticsvidhya.com/blog/2016/03/complete-guide-parameter-tuning-xgboost-with-codes-python/
model_method = "xgbTree"
model_grid = expand.grid(nrounds = 110,
               eta = .1,
               max_depth = seq(3, 10, 2),
               gamma = 0,
               colsample_bytree = 0.5,
               min_child_weight = seq(1, 6, 2),
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