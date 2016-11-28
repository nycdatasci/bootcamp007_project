# Model parameters
#model_method = "neuralnet"
model_method = "nnet"
#model_grid <- NULL
#model_grid <- expand.grid(layer1 = c(5), layer2 = c(1), layer3 = c(1))
model_grid <- expand.grid(size = c(5), decay = c(0.0))
extra_params = list(MaxNWts = 100000, linout = TRUE)

# Cross-validation parameters
do_cv = TRUE
partition_ratio = .8 # for cross-validation
cv_folds = 2 # for cross-validation
verbose_on = TRUE # output cv folds results?
metric = 'MAE' # metric use for evaluating cross-validation

# Misc parameters
subset_ratio = .10 # for testing purposes (set to 1 for full data)
parallelize = TRUE # parallelize the computation?
create_submission = FALSE # create a submission for Kaggle?
use_log = TRUE # take the log transform of the response?
