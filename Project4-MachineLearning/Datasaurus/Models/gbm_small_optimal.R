# Model parameters
model_method = "gbm"
model_grid <- expand.grid( n.trees = 1000, 
                           interaction.depth = 5, 
                           shrinkage = 0.01,
                           n.minobsinnode = 20)
extra_params = NULL

# Cross-validation parameters
do_cv = TRUE # perform cross-validation?
partition_ratio = .8 # for cross-validation
cv_folds = 5 # for cross-validation
verbose_on = TRUE # output cv folds results?
metric = 'MAE' # metric use for evaluating cross-validation

# Misc parameters
subset_ratio = .1 # for testing purposes (set to 1 for full data)
create_submission = FALSE # create a submission for Kaggle?
use_log = FALSE # take the log transform of the response?
