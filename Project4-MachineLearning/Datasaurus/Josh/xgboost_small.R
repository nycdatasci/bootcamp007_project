# Model parameters
model_method = "xgbLinear"
model_grid <- expand.grid(nrounds = c(100, 500, 1000),
                          eta = .01,
                          lambda = 1,
                          alpha = 0)

# Cross-validation parameters
partition_ratio = .8 # for cross-validation
cv_folds = 5 # for cross-validation
verbose_on = TRUE # output cv folds results?
metric = 'MAE' # metric use for evaluating cross-validation

# Misc parameters
subset_ratio = .01 # for testing purposes (set to 1 for full data)
create_submission = FALSE # create a submission for Kaggle?
use_log = FALSE # take the log transform of the response?