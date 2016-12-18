# Model parameters
model_method = "knn"
model_grid = expand.grid(k = 434) # sqrt(x = 188318)
extra_params = NULL

# Cross-validation parameters
do_cv = TRUE
partition_ratio = .8 # for cross-validation
cv_folds = 5 # for cross-validation
verbose_on = TRUE # output cv folds results?
metric = 'MAE' # metric use for evaluating cross-validation

# Misc parameters
subset_ratio = 1 # for testing purposes (set to 1 for full data)
create_submission = TRUE # create a submission for Kaggle?
use_log = TRUE # take the log transform of the response?