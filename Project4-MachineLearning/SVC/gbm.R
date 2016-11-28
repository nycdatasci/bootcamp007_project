#'''
#Boosting Tree
#'''

library(ggplot2)
library(gridExtra)
library(dplyr)
library(corrplot)
library(caret)
library(doMC)
library(parallel)

number_of_cores <- detectCores()
registerDoMC(cores = number_of_cores/2) ## use half of the cores

#setwd("~/Desktop/")
as_train <- read.csv("train.csv")
as_test <- read.csv("test.csv")

dim(as_train)



train <- as_train %>% select(-id)
test <- as_test %>% select(-id)

#loss_transformed <- log(train$loss + 1)

dm_train <- model.matrix(loss ~ ., data = train)
#head(dm_train, n = 4)

dm_test <- model.matrix( ~ ., data = test)
#head(dm_test, n = 4)

preProc <- preProcess(dm_train,
                      method = "nzv")
preProc

dm_train <- predict(preProc, dm_train)
dim(dm_train)

dm_test <- predict(preProc, dm_test)
dim(dm_test)


#Create training and testing data set. 
set.seed(321)
trainIdx <- createDataPartition(train$loss,
                                p = 0.8,
                                list = FALSE,
                                times = 1)

subTrain <- dm_train[trainIdx,]
subTest <- dm_train[-trainIdx,]
lossTrain <- train$loss[trainIdx]
lossTest <- train$loss[-trainIdx]


fitCtrl <- trainControl(method = "cv",
                        number = 10,
                        verboseIter = TRUE,
                        summaryFunction = defaultSummary)

gbmGrid <- expand.grid(n.trees = seq(100,500,50),
                      interaction.depth = c(1,3,5,7),
                      shrinkage = 0.01,
                      n.minobsinnode = 20)

gbmFit <- train(x = subTrain,
               y = lossTrain,
               method = "gbm",
               trControl = fitCtrl,
               tuneGrid = gbmGrid,
               metric = "RMSE",
               maximize = FALSE)


summary(gbmFit)

gbmImp <- varImp(gbmFit, scale = FALSE)
gbmImp
plot(gbmImp, top = 20)

mean(gbmFit$resample$RMSE)

predicted <- predict(gbmFit, subTest)
postResample(pred = predicted, obs = lossTest)

plot(x = predicted, y = lossTest)


