#rm(list = ls())
library(class)
library(qdapRegex)
library(kknn) #Load the weighted knn library.
library(VIM) #For the visualization and imputation of missing values.
library(ggplot2)
library(stringr)
library(Hmisc)
library(stringi)
library(dplyr)
library(plyr)
library(foreach)
library(parallel)
library(doParallel)
cores.Number = max(1,detectCores(all.tests = FALSE, logical = TRUE)-1)
cl <- makeCluster(2)
registerDoParallel(cl, cores=cores.Number)
if (dir.exists('/Users/nicktalavera/Coding/NYC_Data_Science_Academy/Projects/Allstate-Kaggle---Team-Datasaurus-Rex')) {
  setwd('/Users/nicktalavera/Coding/NYC_Data_Science_Academy/Projects/Allstate-Kaggle---Team-Datasaurus-Rex')
} else if (dir.exists("~/Allstate-Kaggle---Team-Datasaurus-Rex")) {
  setwd("~/Allstate-Kaggle---Team-Datasaurus-Rex")
}

dataFolder = './Data/'
if (!exists("testData")) { 
  testData = read.csv(paste0(dataFolder,'test.csv'))
}
if (!exists("trainData")) { 
  trainData = read.csv(paste0(dataFolder,'train.csv'))
}
trainData_cat <- cbind(trainData[,2:117])
trainData_catNoStates = select(trainData_cat, -cat112)
trainData_num <- cbind(trainData[,118:ncol(trainData)])
# head(trainData_num)
# trainData_num.describe()
# trainData[, grepl("cont", names(trainData))]
# head(trainData)
testData$loss = NA

chiSquareAllColumns = function(data){
  #chiResults = data.frame(matrix(ncol = ncol(data), nrow = ncol(data)))
  
  chiResults = foreach (i = 1:length(data), .combine=cbind) %dopar% {
    columnName = colnames(data)[i]
    print(paste("Column Name:", columnName))
    return(columnName = apply(data, 2 , function(i) chisq.test(table(data[, columnName], i ))$p.value))
  }
  chiResults[chiResults > 0.05] = Inf
  names(chiResults) = colnames(data)
  return(chiResults)
}
a = data.frame(chiSquareAllColumns(trainData_cat))
a = data.frame(a)
head(a)
stopCluster(cl)