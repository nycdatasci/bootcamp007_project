# Model parameters
model_method = "lasso"
model_grid = NULL
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
use_log = TRUE # take the log transform of the response?