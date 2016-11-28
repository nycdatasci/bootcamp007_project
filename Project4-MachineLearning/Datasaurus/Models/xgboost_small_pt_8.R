# Model parameters
# The next step would be try different subsample and colsample_bytree values. 
# Lets do this in 2 stages as well and take values 0.6,0.7,0.8,0.9 for both to start with.

model_method = "xgbTree"
model_grid = expand.grid(nrounds = 1000,
                         eta = .1,
                         max_depth = 4,
                         gamma = 0.8,
                         colsample_bytree = seq(0.6, 0.9, 0.1),
                         min_child_weight = 4,
                         subsample = seq(0.2, 0.9, 0.1))
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