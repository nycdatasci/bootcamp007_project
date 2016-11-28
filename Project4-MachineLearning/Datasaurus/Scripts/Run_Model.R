#!/usr/bin/env Rscript
ptm <- proc.time()
# Script to run a model created from model_template.R
# If model_file == "all", then all models in the model_output folder is run
model_files = c("neuralnet_full.R") # Run this model in interactive mode
parallelize = TRUE # parallelize models?

local_dir = '~/Courses/nyc_data_science_academy/projects/Allstate-Kaggle---Team-Datasaurus-Rex/'
server_dir = '~/Allstate-Kaggle---Team-Datasaurus-Rex/'


# Directory parameters
data_path = "Data" # data path containing train and test sets
output_path = "Output" # output path for storing results
scripts_path = "Scripts" # contains the model_maker.R file
models_path = "Models" # path to models

# Get the name of the model to run
if(!interactive()){
  # Get input arguments
  args = commandArgs(trailingOnly=TRUE)
  # Test if there is at least one argument: if not, return an error
  if (length(args) == 0) {
    stop("Usage: Run_Model [model_1.R] [model_2.R] [model_3.R] ...", call. = FALSE)
  }else {
    model_files = args
    print(model_files)
  }
}

# Add parallelization
library(doParallel)
if (exists("cl")) {
  try({stopCluster(cl)})
  try({remove(cl)})
}
if (parallelize){
  cores.number = detectCores(all.tests = FALSE, logical = TRUE)
  cl = makeCluster(2)
  registerDoParallel(cl, cores=cores.number)
}

# Set the working directory based on local or server
if(dir.exists(local_dir)){
  setwd(local_dir)
} else if(dir.exists(server_dir)) {
  setwd(server_dir)
}

# Create the output directory
if (!dir.exists(output_path)) {
  print("Creating output directory..")
  dir.create(output_path)
}

# Make sure data directory exists
stopifnot(dir.exists('Data'))

# Source the model maker
source(file.path(scripts_path, 'model_maker.R'))

# Create the results directory, run and output the model
# input: 
#   model_file - file name of the model
# output:
#   none
run_model = function(model_file, output_path, models_path, data_path, make_model){
  
  # Create the time-stamped results directory
  model_name = gsub(".R", "", model_file)
  model_output_path = file.path(output_path, 
                        paste0(format(Sys.time(), "%d_%m_%Y_%H.%M.%S_"), model_name))
  dir.create(model_output_path)
  
  # Copy the model R file to the results directory
  print("Copying model file...")
  file.copy(file.path(models_path, model_file), to = file.path(model_output_path, model_file))
  
  # Load model parameters
  source(file.path(models_path, model_file))
  
  # Create a named list storing the model
  named.list <- function(...) { 
    l <- setNames( list(...) , as.character( match.call()[-1]) ) 
    l
  }
  model_params = named.list(model_method,
                     model_grid,
                     partition_ratio,
                     cv_folds,
                     verbose_on,
                     metric,
                     subset_ratio,
                     create_submission,
                     use_log,
                     extra_params,
                     do_cv)
  
  # Run the model and output results
  make_model(model_params, data_path, model_output_path)
}

# Run all models?
if(model_files[1] == "all"){
  model_files = list.files(path = paste0(getwd(),"/",models_path), pattern= "*.R$", full.names = FALSE, ignore.case = TRUE)
  model_files = model_files[model_files != 'model_template.R']
}

#if(parallelize){
#  parSapply(cl, model_files, run_model, output_path, models_path, data_path, make_model)
#} else{
thanks_giving = sapply(model_files, run_model, output_path, models_path, data_path, make_model)
#}

# Stop parallel clusters
if (exists("cl")) {
  try({stopCluster(cl)})
  try({remove(cl)})
}
proc.time() - ptm
