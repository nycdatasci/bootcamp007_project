# Model parameters
# Continue searching max tree depth as we haven't seen the minium
model_method = "xgbTree"
model_grid = expand.grid(nrounds = 110,
               eta = .1,
               max_depth = c(4, 5, 6),
               gamma = 0,
               colsample_bytree = 0.5,
               min_child_weight = c(4, 5, 6),
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