# Directory parameters
local_dir = '~/Courses/nyc_data_science_academy/projects/Allstate-Kaggle---Team-Datasaurus-Rex/'
server_dir = '~/ML'

# Model parameters
model_method = "gbm"
model_grid <- expand.grid( n.trees = seq(100, 1000, 100), 
                           interaction.depth = c(1, 3, 5, 7), 
                           shrinkage = 0.1,
                           n.minobsinnode = 20)

# Misc Parameters
subset_ratio = .01 # for testing purposes (set to 1 for full data)
partition_ratio = .8 # for cross-validation
cv_folds = 2 # for cross-validation 

parallelize = TRUE # parallelize the computation?
create_submission = FALSE # create a submission for Kaggle?
use_log = FALSE # take the log transform of the response?
verbose_on = TRUE
metric = 'MAE' # metric use for evaluating cross-validation

data_path = "Data" # data path containing train and test sets
output_path = "Output" # output path for storing results
group_path = "Group"

# Create the output directory
if (!dir.exists(output_path)) {
  dir.create(output_path)
}
directory = file.path(output_path, 
                      paste0(format(Sys.time(), "%d_%m_%Y_%H.%M.%S_"), model_method))
dir.create(directory)

# Copy this file to directory
library(base)
thisFile <- function() {
  cmdArgs <- commandArgs(trailingOnly = FALSE)
  needle <- "--file="
  match <- grep(needle, cmdArgs)
  if (length(match) > 0) {
    # Rscript
    return(file.path(script_dir, sub(needle, "", cmdArgs[match])))
  } else {
    # 'source'd via R console
    return(normalizePath(sys.frames()[[1]]$ofile))
  }
}

file.copy(thisFile(), to = file.path(directory, paste0(model_method, ".R")))

# Run the model and output results
source(file.path(group_path, 'model_maker.R'))