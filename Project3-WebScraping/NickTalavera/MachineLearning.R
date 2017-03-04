rm(list = ls())
#===============================================================================
#                       LOAD PACKAGES AND MODULES                              #
#===============================================================================
library("data.table")
library("DataCombine")
library(dplyr)
na_count <-function (x) sapply(x, function(y) sum(is.na(y)))
#===============================================================================
#                                SETUP PARALLEL                                #
#===============================================================================
library(foreach)
library(parallel)
library(neuralnet)
library(stringr)
library(doParallel)
if(!exists("cl")){
  library(doParallel)
  cores.number = detectCores(all.tests = FALSE, logical = TRUE) -1
  cl = makeCluster(2)
  registerDoParallel(cl, cores=cores.number)
}


#===============================================================================
#                                 IMPORT DATA                                  #
#===============================================================================
if (dir.exists('/home/bc7_ntalavera/Dropbox/Data Science/Data Files/Xbox Back Compat Data/')) {
  dataLocale = '/home/bc7_ntalavera/Dropbox/Data Science/Data Files/Xbox Back Compat Data/'
} else if (dir.exists('/Volumes/SDExpansion/Data Files/Xbox Back Compat Data/')) {
  dataLocale = '/Volumes/SDExpansion/Data Files/Xbox Back Compat Data/'
  # setwd('/Users/nicktalavera/Coding/Data Science/Xbox-One-Backwards-Compatability-Predictions/Xbox Back Compat Data')
}  else if (dir.exists('/home/bc7_ntalavera/Data/Xbox/')) {
  dataLocale = '/home/bc7_ntalavera/Data/Xbox/'
}
markdownFolder = paste0(dataLocale,'MarkdownOutputs/')
dataOriginal = data.frame(fread(paste0(dataLocale,'dataUlt.csv'), stringsAsFactors = TRUE, drop = c("V1")))
data = data.frame(fread(paste0(dataLocale,'dataUltImputed.csv'), stringsAsFactors = TRUE, drop = c("V1")))
nums <- parSapply(cl = cl, data, is.logical)
nums = names(nums[nums==TRUE])
for (column in nums) {
  data[,column] = as.factor(data[,column])
}
na_count(data)
data$gameName = as.character(data$gameName)
data$releaseDate = as.numeric(data$releaseDate)
#===============================================================================
#                               PREPARE DATA                                   #
#===============================================================================
#We now apply our normalization function to all the variables within our dataset;
#we store the result as a data frame for future manipulation.
library(Ecfun)
library(normalr)

normalize = function(x) { 
  return((x - min(x)) / (max(x) - min(x)))
}

# Box cox transform continuous variables
lambdaVal = getLambda(data[sapply(data, is.numeric)], lambda = seq(-10, 10, 1/100), parallel = TRUE)
data[sapply(data, is.numeric)] = BoxCox(data[sapply(data, is.numeric)], lambdaVal, rescale=TRUE)
# Scale and center continuous variables
data[sapply(data, is.numeric)] <- as.data.frame(lapply(data[sapply(data, is.numeric)], normalize))

data = VarDrop(data,"isInProgress")
bcTemp = data$isBCCompatible
gameNameTemp = data$gameName
data = as.data.frame(model.matrix(~ . -gameName -gameUrl -highresboxart, data))
data$isBCCompatible = bcTemp
data$gameName = gameNameTemp
# library(stringr)
names(data) = str_replace_all(names(data), "[^[:alnum:]]", "")
#===============================================================================
#                               TRAINING/TESTING                               #
#===============================================================================
# Make array of unwanted columns
unwantedPredictors = c("gameName","gameUrl","highresboxart")
# Training set
xb_train = data[which(data$isBCCompatible == TRUE | data$usesRequiredPeripheral == TRUE | data$isKinectRequired == TRUE),]
train_ids = xb_train$gameName
xb_train = VarDrop(xb_train, unwantedPredictors)
train_BC = xb_train$isBCCompatible
# Test set
xb_test = data[-which(data$isBCCompatible == TRUE | data$usesRequiredPeripheral == TRUE | data$isKinectRequired == TRUE),]
test_ids = xb_test$gameName
xb_test = VarDrop(xb_test, unwantedPredictors)
test_BC = xb_test$isBCCompatible
#===============================================================================
#                                   MODELS                                     #
#===============================================================================
#Inspecting the output to ensure that the range of each variable is now between
#0 and 1.
summary(data)


#Verifying that the split has been successfully made into 75% - 25% segments.
nrow(xb_train)/nrow(data)
nrow(xb_test)/nrow(data)

#Training the simplest multilayer feedforward neural network that includes only
#one hidden node.
set.seed(0)
xb_train$isBCCompatible = as.numeric(xb_train$isBCCompatible)
# xb_train$isBCCompatible = as.numeric(xb_train$isBCCompatible)
xb_train = xb_train[sapply(xb_train,is.numeric) | sapply(xb_train,is.logical)]

n <- names(xb_train)
f <- as.formula(paste("isBCCompatible ~", paste(n[!n %in% "isBCCompatible"], collapse = " + ")))



concrete_model = neuralnet(formula = f,
                           hidden=c(5,3,3), #Default number of hidden neurons.
                           linear.output = TRUE,
                           data = xb_train)

#Visualizing the network topology using the plot() function.
# plot(concrete_model)

#Generating model predictions on the testing dataset using the compute()
#function.
model_results = compute(concrete_model, xb_test[sapply(xb_test,is.numeric) | sapply(xb_test,is.logical)])

#The model_results object stores the neurons for each layer in the network and
#also the net.results which stores the predicted values; obtaining the
#predicted values.
predicted_strength = as.data.frame(cbind(as.character(test_ids), as.logical(round(model_results$net.result - 1))))
predicted_strength = dplyr::select(predicted_strength, gameName = V1, predicted_isBCCompatible = V2)
dataOut = merge(x = dataOriginal, y = predicted_strength, by = "gameName", all.x = TRUE)
dataOut$predicted_isBCCompatible[dataOut$isBCCompatible == TRUE | dataOut$isKinectRequired == TRUE | dataOut$usesRequiredPeripheral == TRUE] = dataOut$isBCCompatible[dataOut$isBCCompatible == TRUE | dataOut$isKinectRequired == TRUE | dataOut$usesRequiredPeripheral == TRUE]

# #Examining the correlation between predicted and actual values.
# cor(predicted_strength$predicted_isBCCompatible, xb_test$isBCCompatible)
plot(predicted_strength$predicted_isBCCompatible, xb_test$isBCCompatible)

write.csv(dataOut, file = file.path(dataLocale, "dataWPrediction.csv"), row.names = FALSE)
print("...Done!")

# Stop parallel clusters
stopCluster(cl)