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
cl <- makeCluster(2)
registerDoParallel(cl, cores=cores.Number)
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
} else if (dir.exists('/Volumes/SDExpansion/Data Files/bootcamp007_project/Project3-WebScraping/NickTalavera/Data/')) {
  dataLocale = '/Volumes/SDExpansion/Data Files/bootcamp007_project/Project3-WebScraping/NickTalavera/Data/'
  setwd('/Volumes/SDExpansion/Data Files/bootcamp007_project/Project3-WebScraping/NickTalavera')
}  else if (dir.exists('/home/bc7_ntalavera/Data/Xbox/')) {
  dataLocale = '/home/bc7_ntalavera/Data/Xbox/'
}
markdownFolder = paste0(dataLocale,'MarkdownOutputs/')
dataUlt = data.frame(fread(paste0(dataLocale,'dataUlt.csv'), stringsAsFactors = TRUE, drop = c("V1")))
dataUltTraining = kNN(dplyr::select(dataUlt, -gameUrl, -highresboxart, -developer), dist_var = c("xbox360Rating","publisher","ESRBRating","usesRequiredPeripheral","releaseDate","reviewScorePro","votes","gamesOnDemandorArcade","isKinectSupported"), k = sqrt(nrow(dataUlt)))[1:ncol(dplyr::select(dataUlt, -gameUrl, -highresboxart, -developer))]
dataUltTraining$gameName = as.character(dataUltTraining$gameName)
dataUltTraining$releaseDate = as.Date(dataUltTraining$releaseDate)
dataUlt$gameName = as.character(dataUltTraining$gameName)
dataUlt$releaseDate = as.numeric(dataUltTraining$releaseDate)
dataUltTraining[sapply(dataUltTraining, is.numeric)] = as.data.frame(scale(dataUltTraining[sapply(dataUltTraining, is.numeric)]))
# dataUltTraining = dataUltTraining[dataUltTraining$isBCCompatible == TRUE | dataUltTraining$usesRequiredPeripheral == TRUE | dataUltTraining$isKinectRequired == TRUE,]
model.empty = glm(isBCCompatible ~ -gameName, family = "binomial", data = dataUltTraining) #The model with an intercept ONLY.
model.full = glm(isBCCompatible ~ . -gameName, family = "binomial", data = dataUltTraining)
scope = list(lower = formula(model.empty), upper = formula(model.full))
forwardAIC = step(model.empty, scope, direction = "forward", k = 2)
logit.overall = eval(forwardAIC$call)
predict(logit.overall, dataUltTraining, type = "response")
xboxData = cbind(dataUlt,bcGuess = round(logit.overall$fitted.values), percentProb = round(logit.overall$fitted.values,3)*100)
pchisq(logit.overall$deviance, logit.overall$df.residual, lower.tail = FALSE)
isBC.predicted = round(logit.overall$fitted.values)
table(truth = dataUltTraining$isBCCompatible, prediction = isBC.predicted)
pchisq(logit.overall$deviance, logit.overall$df.residual, lower.tail = FALSE)
1 - logit.overall$deviance/logit.overall$null.deviance
