#'''
#Random Forests
#'''

library(ggplot2)
library(gridExtra)
library(dplyr)
library(randomForest)
library(corrplot)
library(caret)
library(doMC)
library(parallel)

timestamp()


number_of_cores <- detectCores()
registerDoMC(cores = number_of_cores) ## use all of the cores

#setwd("~/Desktop/")
as_train <- read.csv("train.csv")
as_test <- read.csv("test.csv")

dim(as_train)


train <- as_train %>% select(-id, -cat109, -cat110, -cat116)
test <- as_test %>% select(-id, -cat109, -cat110, -cat116)

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


fitCtrl <- trainControl(method = "oob",
                        verboseIter = TRUE,
                        summaryFunction = defaultSummary)

rfGrid <- expand.grid(mtry = c(1,2))

rfFit <- train(x = subTrain,
                y = lossTrain,
                method = "rf",
                trControl = fitCtrl,
                tuneGrid = rfGrid,
                metric = "RMSE",
                maximize = FALSE)


summary(rfFit)

rfImp <- varImp(rfFit, scale = FALSE)
rfImp
plot(rfImp, top = 20)

mean(rfFit$resample$RMSE)

predicted <- predict(rfFit, subTest)
postResample(pred = predicted, obs = lossTest)

plot(x = predicted, y = lossTest)
timestamp()

