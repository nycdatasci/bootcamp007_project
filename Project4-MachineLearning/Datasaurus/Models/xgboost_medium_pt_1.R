# Model parameters
# Keeping all this in mind, we can take the following approach:
#   
# 1. Choose a relatively high learning rate. Generally the default value of 0.1 works but somewhere between 0.05 to 0.2 should work for different problems
# 2. Determine the optimum number of trees for this learning rate. This should range around 40-70. Remember to choose a value on which your system can work fairly fast. This is because it will be used for testing various scenarios and determining the tree parameters.
# 3. Tune tree-specific parameters for decided learning rate and number of trees. Note that we can choose different parameters to define a tree and I’ll take up an example here.
# 4. Lower the learning rate and increase the estimators proportionally to get more robust models.
# In order to decide on boosting parameters, we need to set some initial values of other parameters. Lets take the following values:
#   
# max_depth = 5 : This should be between 3-10. I’ve started with 5 but you can choose a different number as well. 4-6 can be good starting points.
# min_child_weight = 1 : A smaller value is chosen because it is a highly imbalanced class problem and leaf nodes can have smaller size groups.
# gamma = 0 : A smaller value like 0.1-0.2 can also be chosen for starting. This will anyways be tuned later.
# subsample, colsample_bytree = 0.8 : This is a commonly used used start value. Typical values range between 0.5-0.9.
# scale_pos_weight = 1: Because of high class imbalance.
# Source: https://www.analyticsvidhya.com/blog/2016/03/complete-guide-parameter-tuning-xgboost-with-codes-python/

model_method = "xgbTree"
model_grid = expand.grid(nrounds = 2000,
               eta = .1,
               max_depth = 5,
               gamma = 0,
               colsample_bytree = 0.5,
               min_child_weight = 1,
               subsample = 0.8)
extra_params = NULL

# Cross-validation parameters
do_cv = TRUE
partition_ratio = .8 # for cross-validation
cv_folds = 10 # for cross-validation
verbose_on = TRUE # output cv folds results?
metric = 'MAE' # metric use for evaluating cross-validation

# Misc parameters
subset_ratio = .1 # for testing purposes (set to 1 for full data)
create_submission = FALSE # create a submission for Kaggle?
use_log = TRUE # take the log transform of the response?