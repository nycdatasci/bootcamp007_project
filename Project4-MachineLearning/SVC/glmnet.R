
##Lasso Regression

library(ggplot2)
library(gridExtra)
library(dplyr)
library(corrplot)
library(caret)
library(doMC)
library(parallel)
timestamp()
number_of_cores <- detectCores()
registerDoMC(cores = number_of_cores/2) ## use half of the cores

#setwd("~/Desktop/")
as_train <- read.csv("train.csv")
as_test <- read.csv("test.csv")

dim(as_train)

#'''
#grid.arrange(
#ggplot(as_train) + geom_histogram(aes(loss), bins = 50),
#ggplot(as_train) + geom_histogram(aes(log(loss + 1)), bins = 50),
#ncol = 2
#)

#corrs <- cor(as_train %>% select(contains("cont")), method = "pearson")
#corrplot.mixed(corrs, upper = "square", order = "hclust")
#table(as_train$cat112)
#'''

train <- as_train %>% select(-id)
test <- as_test %>% select(-id)

loss_transformed <- log(train$loss + 1)

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
trainIdx <- createDataPartition(loss_transformed,
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

lambda.grid = 10^seq(5, -2, length = 100)

glmnetGrid <- expand.grid(alpha = 1,
                          lambda = lambda.grid)

glmnetFit <- train(x = subTrain,
                   y = lossTrain,
                   method = "glmnet",
                   trControl = fitCtrl,
                   tuneGrid = glmnetGrid,
                   metric = "RMSE",
                   maximize = FALSE)


summary(glmnetFit)

glmnetImp <- varImp(glmnetFit, scale = FALSE)
glmnetImp
plot(glmnetImp, top = 20)

mean(glmnetFit$resample$RMSE)

predicted <- predict(glmnetFit, subTest)
postResample(pred = predicted, obs = lossTest)

plot(x = predicted, y = lossTest)

timestamp()
