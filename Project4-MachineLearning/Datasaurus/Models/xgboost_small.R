# Model parameters
model_method = "xgbTree"
<<<<<<< HEAD
model_grid <- NULL
#model_grid <- expand.grid(nrounds = c(100, 200),
#                          eta = c(0.01),
#                          max_depth = c(2, 4, 8),
#                          gamma = 1,
#                          colsample_bytree = 0.5,
#                          min_child_weight = 1)
#                          subsample = c(0.8))
=======
model_grid = NULL
>>>>>>> ebf538d2dbc61c7d5b89c82a7d2698ae6f314789
extra_params = NULL

# Cross-validation parameters
do_cv = TRUE
partition_ratio = .8 # for cross-validation
<<<<<<< HEAD
cv_folds = 5 # for cross-validation
=======
cv_folds = 10 # for cross-validation
>>>>>>> ebf538d2dbc61c7d5b89c82a7d2698ae6f314789
verbose_on = TRUE # output cv folds results?
metric = 'MAE' # metric use for evaluating cross-validation

# Misc parameters
subset_ratio = 0.01 # for testing purposes (set to 1 for full data)
create_submission = FALSE # create a submission for Kaggle?
<<<<<<< HEAD
use_log = TRUE # take the log transform of the response?
=======
use_log = TRUE # take the log transform of the response?
>>>>>>> ebf538d2dbc61c7d5b89c82a7d2698ae6f314789
