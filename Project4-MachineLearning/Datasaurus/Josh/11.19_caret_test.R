## Read data
library("data.table")

as_train <- fread("../Data/train.csv")
as_test <- fread("../Data/test.csv")
dim(as_train)

table(as_train$cat112)
library(dplyr)
## create subset with cat112 == "E"
train_e <- as_train %>% filter(cat112 == "E") %>% select(-cat112, -id)
test_e <- as_test %>% filter(cat112 == "E") %>% select(-cat112, -id)
## log transform loss
loss_e <- log(train_e$loss + 1)

library(caret)
# Remove variables with one factor
nzv <- nearZeroVar(train_e)
train_e <- train_e[, -nzv]
test_e <- test_e[, -nzv]

# Create dummy variables
dm_train = data.frame(predict(dummyVars("loss ~ .", data=train_e), newdata=train_e))
dm_test = data.frame(predict(dummyVars("~ .", data=test_e), newdata=test_e))
# Remove nero zero variance columns
preProc <- preProcess(dm_train,
                      method = "nzv")

dm_train <- predict(preProc, dm_train)
dm_test <- predict(preProc, dm_test)

set.seed(321)
trainIdx <- createDataPartition(loss_e, 
                                p = .8,
                                list = FALSE,
                                times = 1)
subTrain <- dm_train[trainIdx,]
subTest <- dm_train[-trainIdx,]
lossTrain <- loss_e[trainIdx]
lossTest <- loss_e[-trainIdx]

fitCtrl <- trainControl(method = "cv",
                        number = 5,
                        verboseIter = TRUE,
                        summaryFunction=defaultSummary)

gbmGrid <- expand.grid( n.trees = seq(100,500,50), 
                        interaction.depth = c(1,3,5,7), 
                        shrinkage = 0.1,
                        n.minobsinnode = 20)

gbmFit <- train(x = subTrain, 
                y = lossTrain,
                method = "gbm", 
                trControl = fitCtrl,
                tuneGrid = gbmGrid,
                metric = 'MAE',
                maximize = FALSE)

plot(gbmFit)
plot(gbmFit, plotType = "level")
gbmImp <- varImp(gbmFit, scale = FALSE)
plot(gbmImp,top = 20)

mean(gbmFit$resample$RMSE)

predicted <- predict(gbmFit, subTest)
RMSE(pred = predicted, obs = lossTest)
