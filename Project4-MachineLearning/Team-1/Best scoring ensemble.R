##### using h2o #####
# the script below does the following
# preprocess data by rbinding train and test
# combine.levels at 2% minlev
# dummiVar all categorical variables
# h2o ensemble using DEFAULT setting of glm, randomForest, gbm, deeplearning
# using glm metalearner
# create a submission csv for submitting to kaggle.
# to create custom learners… changing parameters such as n.trees and others, you may check this out. https://github.com/h2oai/h2o-tutorials/tree/master/tutorials/ensembles-stacking. See the SPECIFIYING NEW LEARNERS section.
# This https://github.com/h2oai/h2o-tutorials/blob/master/tutorials/ensembles-stacking/H2O_World_2015_Ensembles.pdf is also a good overview on what h2o does.

library(ggplot2) # Data visualization
library(readr) # CSV file I/O, e.g. the read_csv function


# Any results you write to the current directory are saved as output.
# ------------------------------------------------------------------
# R version of some Machine Learning Method starter code using H2O. 
# Average of multiple H2O DNN models


# Fork from https://www.kaggle.com/kumareshd/allstate-claims-severity/performance-of-different-methods-in-r-using-h2o/discussion
# Example parameters https://github.com/h2oai/h2o-3/blob/0d3e52cdce9f699a8d693b5d3b11c8bd3e15ca02/h2o-r/h2o-package/R/deeplearning.R
# See: http://mlwave.com/kaggle-ensembling-guide/


# Load H2O
library(h2o)
kd_h2o<-h2o.init(nthreads = -1, max_mem_size = "7g")


# Installation of H2O-Ensemble, does not work on Kaggle cloud
# install.packages("https://h2o-release.s3.amazonaws.com/h2o-ensemble/R/h2oEnsemble_0.1.8.tar.gz", repos = NULL)
install.packages("https://h2o-release.s3.amazonaws.com/h2o-ensemble/R/h2oEnsemble_0.1.8.tar.gz", repos = NULL)
library(h2oEnsemble)


#### Loading data ####
#Reading Data, old school read.csv. Using fread is faster. 
setwd("~/Downloads")
set.seed(0)
train<-read.csv('train.csv')
test<-read.csv('test 2.csv')
train.index <- train[,1]
test.index <- test[,1]
train.loss <- train[,ncol(train)]

library(caret)
library(mlbench)
library(Hmisc)

#### Pre-processing dataset ####
#Combining train and test data for joint pre-processing
bulk <- rbind(train[,-ncol(train)], test)
bulk$id <- NULL
#Converting categories to numeric
#this is done by first splitting the binary level, multi-level, and 
#continuous variables
#colnames(all.train)
bin.bulk <- bulk[,1:72]
cat.bulk <- bulk[,73:116]
cont.bulk <- bulk[,117:130]
#Combine levels
#Combining multiple levels using combine.levels
#minimum frequency = minlev
temp <- sapply(cat.bulk, combine.levels, minlev = 0.02)
temp <- as.data.frame(temp)
str(temp)
#Column bind binary and reduced categorical variables
# comb.train <- cbind(bin.train, cat.train)
comb.bulk <- cbind(bin.bulk, temp)
#Dummify all factor variables 
dmy <- dummyVars(" ~ .", data = comb.bulk, fullRank=T)
temp <- as.data.frame(predict(dmy, newdata = comb.bulk))
dim(temp)
#Combine dummified with cont vars
bulk <- cbind(temp, cont.bulk)
dim(bulk)


#Split pre-cprocessed dataset into train and test
train.e = bulk[1:nrow(train),]
test.e = bulk[(nrow(train)+1):nrow(bulk),]
#Re-attach index
train.e <- cbind(train.index, train.e)
test.e <- cbind(test.index, test.e)
#Re-attach loss
train.e$loss <- train.loss
#Pre-processed data for training and validation
train <- train.e
test <- test.e

#### Start of H2O part ####
#Removing index column
train <- train[,-1]
test_label <- test[,1]
test <- test[,-1]


#Getting index of test subset
index <- sample(1:(dim(train)[1]), 0.2*dim(train)[1], replace=FALSE)


#Creating training=train_frame and test=valid_frame subsets
train_frame<-train[-index,]
valid_frame<-train[index,]


#Separating loss variable from test set. valid_predict has NO LOSS variable
valid_predict<-valid_frame[,-ncol(valid_frame)]
valid_loss<-valid_frame[,ncol(valid_frame)]


#Log transform
train_frame[,ncol(train_frame)]<-log(train_frame[,ncol(train_frame)])
valid_frame[,ncol(train_frame)]<-log(valid_frame[,ncol(valid_frame)])


# load H2o data frame // validate that H2O flow looses all continous data
train_frame.hex<-as.h2o(train_frame)
valid_frame.hex<-as.h2o(valid_frame)
valid_predict.hex<-as.h2o(valid_predict)
test.hex<-as.h2o(test)

# create custom learners
# h2o.randomForest.1 <- function(..., ntrees = 600, nbins = 100, seed = 1) {
#   h2o.randomForest.wrapper(..., ntrees = ntrees, nbins = nbins, seed = seed)
# }
# h2o.randomForest.2 <- function(..., ntrees = 100, seed = 1) {
#   h2o.randomForest.wrapper(..., ntrees = ntrees,seed = seed)
# }
# h2o.randomForest.3 <- function(..., ntrees = 600, seed = 1) {
#   h2o.randomForest.wrapper(..., ntrees = ntrees, seed = seed)
# }
h2o.glm.1 <- function(..., alpha = 0.0, lambda_search=TRUE) h2o.glm.wrapper(..., alpha = alpha, lambda_search=lambda_search)
# h2o.glm.2 <- function(..., alpha = 0.5, lambda_search=TRUE) h2o.glm.wrapper(..., alpha = alpha,  lambda_search=lambda_search)
# h2o.glm.3 <- function(..., alpha = 1.0, lambda_search=TRUE) h2o.glm.wrapper(..., alpha = alpha,  lambda_search=lambda_search)

h2o.gbm.1 <- function(..., ntrees = 300, max_depth=5, nbins=100, min_rows=100, sample_rate=1, seed = 1){
  h2o.gbm.wrapper(...,ntrees = ntrees, max_depth=max_depth, nbins=nbins, min_rows=min_rows, sample_rate=sample_rate, seed = seed)
}

h2o.gbm.2 <- function(..., ntrees = 300,max_depth=5, nbins=100, min_rows=100, sample_rate=1, seed = 1){
  h2o.gbm.wrapper(..., ntrees = ntrees, max_depth=max_depth, nbins=nbins, min_rows=min_rows, sample_rate=sample_rate, seed = seed)
}

h2o.gbm.3 <- function(..., ntrees = 300, max_depth=5, nbins=100, min_rows=100, sample_rate=1, seed = 1){
  h2o.gbm.wrapper(..., ntrees = ntrees, max_depth=max_depth, nbins=nbins, min_rows=min_rows, sampl_rate=sample_rate, seed = seed)
}

h2o.gbm.4 <- function(..., ntrees = 300, max_depth=10, nbins=200, min_rows=100, sample_rate=1, seed = 1){
  h2o.gbm.wrapper(..., ntrees = ntrees, max_depth=max_depth, nbins=nbins, min_rows=min_rows, sampl_rate=sample_rate, seed = seed)
}

h2o.deeplearning.1 <- function(...,hidden = c(100,50,25), epochs=200, input_dropout_ratio=0.1, elastic_averaging=True, seed = 1){
  h2o.deeplearning.wrapper(...,hidden = hidden, epochs=epochs, input_dropout_ratio=input_dropout_ratio, elastic_averaging=elastic_averaging, seed = seed)
}

h2o.deeplearning.2 <- function(...,hidden = c(200,100,50), epochs=100, input_dropout_ratio=0.1, elastic_averaging=True, seed = 1){
  h2o.deeplearning.wrapper(...,hidden = hidden, epochs=epochs, input_dropout_ratio=input_dropout_ratio, elastic_averaging=elastic_averaging, seed = seed)
}

h2o.deeplearning.3 <- function(...,hidden = c(70,35,15), epochs=100, input_dropout_ratio=0.1, elastic_averaging=True, seed = 1){
  h2o.deeplearning.wrapper(...,hidden = hidden, epochs=epochs, input_dropout_ratio=input_dropout_ratio, elastic_averaging=elastic_averaging, seed = seed)
}
h2o.deeplearning.4 <- function(...,hidden = c(70,35), epochs=100, input_dropout_ratio=0.1, elastic_averaging=True, seed = 1){
  h2o.deeplearning.wrapper(...,hidden = hidden, epochs=epochs, input_dropout_ratio=input_dropout_ratio, elastic_averaging=elastic_averaging, seed = seed)
}

h2o.deeplearning.5 <- function(...,hidden = c(20,20), epochs=100, input_dropout_ratio=0.1, elastic_averaging=True, seed = 1){
  h2o.deeplearning.wrapper(...,hidden = hidden, epochs=epochs, input_dropout_ratio=input_dropout_ratio, elastic_averaging=elastic_averaging, seed = seed)
}

# 2o.deeplearning.2 <- function(..., hidden = c(20,20), activation = "Tanh", seed = 1) {
#   h2o.deeplearning.wrapper(..., hidden = hidden, activation = activation, seed = seed)
# }

#----------------------------------------------------------
learner <- c( "h2o.deeplearning.1", "h2o.gbm.1", "h2o.gbm.2", "h2o.gbm.3", "h2o.gbm.4",
             "h2o.deeplearning.2", "h2o.deeplearning.3", "h2o.deeplearning.4", "h2o.deeplearning.5" )
metalearner <- "h2o.glm.1"
#----------------------------------------------------------
# Passing the validation_frame to h2o.ensemble does not currently do anything. 
# Right now, you must use the predict.h2o.ensemble function to generate predictions on a test set.

fit_gd <- h2o.ensemble(x = 1:(ncol(train_frame.hex)-1), y = ncol(train_frame.hex), 
                        train_frame.hex, validation_frame=valid_frame.hex,
                        family = "gaussian", 
                        learner = learner, 
                        metalearner = metalearner,
                        cvControl = list(V = 10))	     

h2o.save_ensemble(fit_gd, path="GD")  
pred_gd <- predict(fit_gd,valid_frame.hex)

# show stacked prediction and all 4 independent learners
# h2o.glm.wrapper h2o.randomForest.wrapper h2o.gbm.wrapper h2o.deeplearning.wrapper
head(pred_gd)

# show combined only
head(pred_gd[1])

# show h2o.glm.wrapper
head(pred_gd$basepred[1]) 
dim(pred_gd$basepred[1])

# #glms
# pred_m1_gd <-as.matrix(pred_gd$basepred[1])
# score_m1_gd=mean(abs(exp(pred_m1_gd)-valid_loss))
# cat("score_m1 (h2o.glm.wrapper) :",score_m1_gd,"\n") # 1232.722 
# 
# pred_m2_gd <-as.matrix(pred_gd$basepred[2])
# score_m2_gd=mean(abs(exp(pred_m2_gd)-valid_loss))
# cat("score_m2 ( h2o.randomForest.wrapper) :",score_m2_gd,"\n") #1232.769 
# 
# pred_m3_gd <-as.matrix(pred_gd$basepred[3])
# score_m3_gd=mean(abs(exp(pred_m3_gd)-valid_loss))
# cat("score_m3 (h2o.gd.wrapper ):",score_m3_gd,"\n")#1232.821

#gbms
pred_m2_gd <-as.matrix(pred_gd$basepred[2])
score_m2_gd=mean(abs(exp(pred_m2_gd)-valid_loss))
cat("score_m2 (h2o.deeplearning.2):",score_m2_gd,"\n") #1139.182

pred_m3_gd <-as.matrix(pred_gd$basepred[3])
score_m3_gd=mean(abs(exp(pred_m3_gd)-valid_loss))
cat("score_m3 (h2o.deeplearning.3):",score_m3_gd,"\n") #1139.182

pred_m4_gd <-as.matrix(pred_gd$basepred[4])
score_m4_gd=mean(abs(exp(pred_m4_gd)-valid_loss))
cat("score_m4 (h2o.deeplearning.4):",score_m4_gd,"\n") #1139.182

pred_m5_gd <-as.matrix(pred_gd$basepred[5])
score_m5_gd=mean(abs(exp(pred_m5_gd)-valid_loss))
cat("score_m5 (h2o.gdearning.5):",score_m5_gd,"\n") #1135.386 

#neural nets
pred_m1_gd <-as.matrix(pred_gd$basepred[1])
score_m1_gd=mean(abs(exp(pred_m1_gd)-valid_loss))
cat("score_m1 (h2o.deeplearning.1):",score_m1_gd,"\n") #1172.293

pred_m6_gd <-as.matrix(pred_gd$basepred[6])
score_m6_gd=mean(abs(exp(pred_m6_gd)-valid_loss))
cat("score_m6 (h2o.deeplearning.6):",score_m6_gd,"\n") #1162.193

pred_m7_gd <-as.matrix(pred_gd$basepred[7])
score_m7_gd=mean(abs(exp(pred_m7_gd)-valid_loss))
cat("score_m7 (h2o.deeplearning.wrapper):",score_m7_gd,"\n") #1159.169

pred_m8_gd <-as.matrix(pred_gd$basepred[8])
score_m8_gd=mean(abs(exp(pred_m8_gd)-valid_loss))
cat("score_m8 (h2o.deeplearning.8):",score_m8_gd,"\n") #1159.432

pred_m9_gd <-as.matrix(pred_gd$basepred[9])
score_m9_gd=mean(abs(exp(pred_m9_gd)-valid_loss))
cat("score_m9 (h2o.gdearning.9):",score_m9_gd,"\n") #1170.663 

# Average everything
pred_average_gd=exp((pred_m1_gd+pred_m2_gd+pred_m3_gd+pred_m4_gd+pred_m5_gd+pred_m6_gd+pred_m7_gd+pred_m8_gd+pred_m9_gd)/9)
colnames(pred_average_gd) = "predict"
score_average_gd=mean(abs((pred_average_gd)-valid_loss))
cat("Ensemble score: (simple average) " ,score_average_gd,"\n")# 1138.292

# get the H2O.ensemble score
pred_ensemble_gd <-exp(as.matrix(pred_gd[[1]]))
score_ensemble_gd=mean(abs((pred_ensemble_gd)-valid_loss))
cat("score_meta (h2o.ensemble):",score_ensemble_gd,"\n")# 1126.093

# final predict the full test sets
pred_test_gd <- as.matrix(predict(fit_gd,test.hex))

# Write ensemble submissions
# local: submission = read.csv('sample_submission.csv', colClasses = c("integer", "numeric"))
submission_gd = read.csv('sample_submission 2.csv', colClasses = c("integer", "numeric"))
submission_gd$loss = as.numeric(as.matrix((exp(pred_test_gd[[1]]))))
write.csv(submission_gd, 'ensemble_gd.csv', row.names=FALSE)


