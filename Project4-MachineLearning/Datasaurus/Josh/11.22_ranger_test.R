# Model parameters
model_method = "rf"
model_grid <- expand.grid(mtry = 50)

# Misc Parameters
subset_ratio = .01 # for testing purposes (set to 1 for full data)
partition_ratio = .8 # for cross-validation
cv_folds = 2 # for cross-validation 

parallelize = TRUE # parallelize the computation?
create_submission = FALSE # create a submission for Kaggle?
use_log = FALSE # take the log transform of the response?
verbose_on = TRUE
metric = 'MAE' # metric use for evaluating cross-validation

data_path = "../Data" # data path containing train and test sets
output_path = "../Output" # output path for storing results

# Create the output directory
if (!dir.exists(output_path)) {
  dir.create(output_path)
}
directory = file.path(output_path, 
                      paste(format(Sys.time(), "%d_%m_%Y %H.%M.%S"), model_method))
dir.create(directory)

# Copy this file to directory
file.copy(sys.frame(1)$ofile,
          to = file.path(directory,
                         paste0(model_method, ".R")))

# Run the model and output results
source('11.21_model_maker.R')