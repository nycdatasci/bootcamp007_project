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
library(h2oEnsemble)


#### Loading data ####
#Reading Data, old school read.csv. Using fread is faster. 
set.seed(12345)
train<-read.csv('train.csv')
test<-read.csv('test.csv')
train.index <- train[,1]
test.index <- test[,1]
train.loss <- train[,ncol(train)]


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


#----------------------------------------------------------
learner <- c("h2o.glm.wrapper", "h2o.randomForest.wrapper", 
             "h2o.gbm.wrapper", "h2o.deeplearning.wrapper")
metalearner <- "h2o.glm.wrapper"
 
#----------------------------------------------------------
# Passing the validation_frame to h2o.ensemble does not currently do anything. 
# Right now, you must use the predict.h2o.ensemble function to generate predictions on a test set.

fit <- h2o.ensemble(x = 1:(ncol(train_frame.hex)-1), y = ncol(train_frame.hex), 
                    train_frame.hex, validation_frame=valid_frame.hex,
                    family = "gaussian", 
                    learner = learner, 
                    metalearner = metalearner,
                    cvControl = list(V = 5))	     

pred <- predict(fit,valid_frame.hex)

# show stacked prediction and all 4 independent learners
# h2o.glm.wrapper h2o.randomForest.wrapper h2o.gbm.wrapper h2o.deeplearning.wrapper
head(pred)

# show combined only
head(pred[1])

# show h2o.glm.wrapper
head(pred$basepred[1]) 

pred_m1 <-as.matrix(pred$basepred[1])
score_m1=mean(abs(exp(pred_m1)-valid_loss))
cat("score_m1 (h2o.glm.wrapper) :",score_m1,"\n")

pred_m2 <-as.matrix(pred$basepred[2])
score_m2=mean(abs(exp(pred_m2)-valid_loss))
cat("score_m2 ( h2o.randomForest.wrapper) :",score_m2,"\n")

pred_m3 <-as.matrix(pred$basepred[3])
score_m3=mean(abs(exp(pred_m3)-valid_loss))
cat("score_m3 (h2o.gbm.wrapper ):",score_m3,"\n")

pred_m4 <-as.matrix(pred$basepred[4])
score_m4=mean(abs(exp(pred_m4)-valid_loss))
cat("score_m4 (h2o.deeplearning.wrapper):",score_m4,"\n")

# Average everything
pred_average=exp((pred_m1+pred_m2+pred_m3+pred_m4)/4)
colnames(pred_average) = "predict"
score_average=mean(abs((pred_average)-valid_loss))
cat("Ensemble score: (simple average) " ,score_average,"\n")

# get the H2O.ensemble score
pred_ensemble <-exp(as.matrix(pred[[1]]))
score_ensemble=mean(abs((pred_ensemble)-valid_loss))
cat("score_meta (h2o.ensemble):",score_ensemble,"\n")

# final predict the full test sets
pred_test <- as.matrix(predict(fit,test.hex))

# Write ensemble submissions
# local: submission = read.csv('sample_submission.csv', colClasses = c("integer", "numeric"))
submission = read.csv('sample_submission.csv', colClasses = c("integer", "numeric"))
submission$loss = as.numeric(as.matrix((exp(pred_test[[1]]))))
write.csv(submission, 'h2o_ensemble.csv', row.names=FALSE)
