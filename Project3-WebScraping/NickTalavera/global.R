# Xbox 360 Backwards Compatability Predictor
# Nick Talavera
# Date: November 1, 2016

# global.R
rm(list = ls())
#===============================================================================
#                       LOAD PACKAGES AND MODULES                              #
#===============================================================================
library("shiny")
library("shinydashboard")
library("flexdashboard")
library("knitr")
library("rmarkdown")
library("shinythemes")
library("lettercase")
library("data.table")
library("DataCombine")
#===============================================================================
#                                SETUP PARALLEL                                #
#===============================================================================
library(foreach)
library(parallel)
library(doParallel)
cores.Number = detectCores(all.tests = FALSE, logical = TRUE)
# cl <- makeCluster(2)
# registerDoParallel(cl, cores=cores.Number)
#===============================================================================
#                               GENERAL FUNCTIONS                              #
#===============================================================================
roundUp <- function(x, nice=c(1,2,4,5,6,8,10)) {
  if(length(x) != 1) stop("'x' must be of length 1")
  10^floor(log10(x)) * nice[[which(x <= 10^floor(log10(x)) * nice)[[1]]]]
}
#===============================================================================
#                             GLOBAL VARIABLES                                 #
#===============================================================================
programName = "Xbox One Backwards Compatibility Predictor"
sideBarWidth = 450
if (dir.exists('/home/bc7_ntalavera/Dropbox/Data Science/Data Files/Xbox Back Compat Data/')) {
  dataLocale = '/home/bc7_ntalavera/Dropbox/Data Science/Data Files/Xbox Back Compat Data/'
} else if (dir.exists('/Users/nicktalavera/Coding/Data Science/Xbox-One-Backwards-Compatability-Predictions/Xbox Back Compat Data/')) {
  dataLocale = '/Users/nicktalavera/Coding/Data Science/Xbox-One-Backwards-Compatability-Predictions/Xbox Back Compat Data/'
  # setwd('/Users/nicktalavera/Coding/Data Science/Xbox-One-Backwards-Compatability-Predictions/Xbox Back Compat Data')
}  else if (dir.exists('/home/bc7_ntalavera/Data/Xbox/')) {
  dataLocale = '/home/bc7_ntalavera/Data/Xbox/'
}
markdownFolder = paste0(dataLocale,'MarkdownOutputs/')
xboxData = as.data.frame(fread(paste0(dataLocale,'dataWPrediction.csv'), stringsAsFactors = TRUE, drop = c("V1")))
print(xboxData)
xboxData$gameName = as.character(xboxData$gameName)
xboxData$releaseDate = as.numeric(xboxData$releaseDate)
for (i in 1:length(names(xboxData))) {
  if (sum(xboxData[,names(xboxData)[i]] == TRUE, na.rm = TRUE) + sum(xboxData[,names(xboxData)[i]] == FALSE, na.rm = TRUE) + sum(is.na(xboxData[,names(xboxData)[i]])) == nrow(xboxData)) {
    xboxData[,names(xboxData)[i]] = as.logical(xboxData[,names(xboxData)[i]])
  }
}