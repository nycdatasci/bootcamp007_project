# This R environment comes with all of CRAN preinstalled, as well as many other helpful packages
# The environment is defined by the kaggle/rstats docker image: https://github.com/kaggle/docker-rstats
# For example, here's several helpful packages to load in 

library(ggplot2) # Data visualization
library(readr) # CSV file I/O, e.g. the read_csv function

# Input data files are available in the "../input/" directory.
# For example, running this (by clicking run or pressing Shift+Enter) will list the files in the input directory

system("ls ../Data")

# Any results you write to the current directory are saved as output.
# ------------------------------------------------------------------
# R version of some Machine Learning Method starter code using H2O. 
# Average of multiple H2O DNN models

# Fork from https://www.kaggle.com/kumareshd/allstate-claims-severity/performance-of-different-methods-in-r-using-h2o/discussion
# Example parameters https://github.com/h2oai/h2o-3/blob/0d3e52cdce9f699a8d693b5d3b11c8bd3e15ca02/h2o-r/h2o-package/R/deeplearning.R
# See: http://mlwave.com/kaggle-ensembling-guide/
# See 

# Load H2O
library(h2o)
kd_h2o<-h2o.init(nthreads = -1, max_mem_size = "16g")

# Locally start jar and then use this line
# kd_h2o<-h2o.init(ip = "localhost", port = 54323 ,nthreads = -1, max_mem_size = "10g")

#Reading Data, old school read.csv. Using fread is faster. 
set.seed(12345)
train<-read.csv('../Data/train.csv')
test<-read.csv('../Data/test.csv')

train<-train[,-1]
test_label<-test[,1]
test<-test[,-1]

index<-sample(1:(dim(train)[1]), 0.2*dim(train)[1], replace=FALSE)

train_frame<-train[-index,]
valid_frame<-train[index,]

valid_predict<-valid_frame[,-ncol(valid_frame)]
valid_loss<-valid_frame[,ncol(valid_frame)]

# log transform
train_frame[,ncol(train_frame)]<-log(train_frame[,ncol(train_frame)])
valid_frame[,ncol(train_frame)]<-log(valid_frame[,ncol(valid_frame)])

# load H2o data frame // validate that H2O flow looses all continous data
train_frame.hex<-as.h2o(train_frame)
valid_frame.hex<-as.h2o(valid_frame)
valid_predict.hex<-as.h2o(valid_predict)
test.hex<-as.h2o(test)

## DNN Neural net 1 // increase epochs for higher accuracy
start<-proc.time()
dnn_model_1<-h2o.deeplearning(x=1:(ncol(train_frame.hex)-1), y=ncol(train_frame.hex), 
                              training_frame=train_frame.hex, validation_frame=valid_frame.hex,
                              epochs=10, 
                              stopping_rounds=2,
                              overwrite_with_best_model=T,
                              activation="Rectifier",
                              distribution="huber",
                              hidden=c(91,91))
print("DNN_1 runtime:")
print(proc.time()-start)
pred_dnn_1<-as.matrix(predict(dnn_model_1, valid_predict.hex))
score_dnn_1=mean(abs(exp(pred_dnn_1)-valid_loss))
cat("score_dnn_1:",score_dnn_1,"\n")

## DNN Neural net 2 // increase epochs for higher accuracy
start<-proc.time()
dnn_model_2<-h2o.deeplearning(x=1:(ncol(train_frame.hex)-1), y=ncol(train_frame.hex), 
                              training_frame=train_frame.hex, validation_frame=valid_frame.hex,
                              epochs=10, 
                              stopping_rounds=5,
                              overwrite_with_best_model=T,
                              activation="Rectifier",
                              distribution="huber",
                              hidden=c(90,90))
print("DNN_2 runtime:")
print(proc.time()-start)
pred_dnn_2<-as.matrix(predict(dnn_model_2, valid_predict.hex))
score_dnn_2=mean(abs(exp(pred_dnn_2)-valid_loss))
cat("score_dnn_2:",score_dnn_2,"\n")

## DNN Neural net 3 // increase epochs for higher accuracy
start<-proc.time()
dnn_model_3<-h2o.deeplearning(x=1:(ncol(train_frame.hex)-1), y=ncol(train_frame.hex), 
                              training_frame=train_frame.hex, validation_frame=valid_frame.hex,
                              epochs=20, 
                              stopping_rounds=2,
                              overwrite_with_best_model=T,
                              activation="Rectifier",
                              distribution="huber",
                              hidden=c(53, 53))
print("DNN_3 runtime:")
print(proc.time()-start)
pred_dnn_3<-as.matrix(predict(dnn_model_3, valid_predict.hex))
score_dnn_3=mean(abs(exp(pred_dnn_3)-valid_loss))
cat("score_dnn_3:",score_dnn_3,"\n")

## DNN Neural net 4 // increase epochs for higher accuracy
start<-proc.time()
dnn_model_4<-h2o.deeplearning(x=1:(ncol(train_frame.hex)-1), y=ncol(train_frame.hex), 
                              training_frame=train_frame.hex, validation_frame=valid_frame.hex,
                              epochs=20, 
                              stopping_rounds=2,
                              overwrite_with_best_model=T,
                              activation="Rectifier",
                              distribution="huber",
                              hidden=c(51, 51))
print("DNN_4 runtime:")
print(proc.time()-start)
pred_dnn_4<-as.matrix(predict(dnn_model_4, valid_predict.hex))
score_dnn_4=mean(abs(exp(pred_dnn_4)-valid_loss))
cat("score_dnn_4:",score_dnn_4,"\n")

## DNN Neural net 5 // increase epochs for higher accuracy
start<-proc.time()
dnn_model_5<-h2o.deeplearning(x=1:(ncol(train_frame.hex)-1), y=ncol(train_frame.hex), 
                              training_frame=train_frame.hex, validation_frame=valid_frame.hex,
                              epochs=20, 
                              stopping_rounds=5,
                              overwrite_with_best_model=T,
                              activation="Rectifier",
                              distribution="huber",
                              hidden=c(50,50))
print("DNN_5 runtime:")
print(proc.time()-start)
pred_dnn_5<-as.matrix(predict(dnn_model_5, valid_predict.hex))
score_dnn_5=mean(abs(exp(pred_dnn_5)-valid_loss))
cat("score_dnn_5:",score_dnn_5,"\n")

# Average everything
pred_ensemble=(pred_dnn_1+pred_dnn_2+pred_dnn_3+pred_dnn_4+pred_dnn_5)/5
score_ensemble=mean(abs(exp(pred_ensemble)-valid_loss))

# predict results
pred_dnn_1<-(as.matrix(predict(dnn_model_1, test.hex)))
pred_dnn_2<-(as.matrix(predict(dnn_model_2, test.hex)))
pred_dnn_3<-(as.matrix(predict(dnn_model_3, test.hex)))
pred_dnn_4<-(as.matrix(predict(dnn_model_4, test.hex)))
pred_dnn_5<-(as.matrix(predict(dnn_model_5, test.hex)))

pred_all<-exp((pred_dnn_1+pred_dnn_2+pred_dnn_3+pred_dnn_4+pred_dnn_5)/5)

# Write submissions
submission = read.csv('../Data/sample_submission.csv', colClasses = c("integer", "numeric"))
submission$loss = pred_all
write.csv(submission, 'h2o_blend.csv', row.names=FALSE)

# Summary of Performance 
# Deep Learning
cat("DNN_1 score: " ,score_dnn_1,"\n")
cat("DNN_2 score: " ,score_dnn_2,"\n")
cat("DNN_3 score: " ,score_dnn_3,"\n")
cat("DNN_4 score: " ,score_dnn_4,"\n")
cat("DNN_5 score: " ,score_dnn_5,"\n")

# Ensemble 
cat("Ensemble score: " ,score_ensemble,"\n")

# --------------------------------------
# Score in Public Leaderboard:  
# Run time: 600s
# DNN_1 score (100,100)   :  1140.699 
# DNN_2 score (120,100)   :  1146.967 
# DNN_3 score (120, 120)  :  1143.756 
# DNN_4 score (80, 80, 80):  1139.492 
# Ensemble score          :  1127.951 
# --------------------------------------