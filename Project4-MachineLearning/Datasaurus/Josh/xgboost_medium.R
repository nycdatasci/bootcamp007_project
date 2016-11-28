# Model parameters
model_method = "xgbLinear"
model_grid <- expand.grid(nrounds = 2400,
                          eta = c(0.01,0.001,0.0001),
                          lambda = 1,
                          alpha = 0)

# Cross-validation parameters
partition_ratio = .8 # for cross-validation
cv_folds = 5 # for cross-validation
verbose_on = TRUE # output cv folds results?
metric = 'RMSE' # metric use for evaluating cross-validation

# Misc parameters
subset_ratio = .1 # for testing purposes (set to 1 for full data)
parallelize = TRUE # parallelize the computation?
create_submission = FALSE # create a submission for Kaggle?
use_log = TRUE # take the log transform of the response?