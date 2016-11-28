rm(list = ls()) #If I want my environment reset for testing.
setwd('/Users/nicktalavera/Coding/NYC_Data_Science_Academy/Projects/Allstate-Kaggle---Team-Datasaurus-Rex')
## Read data
library("data.table")
library(caret)
library(dplyr)
library(stringr)
library(doParallel)
if (exists("cl")) {
  try({stopCluster(cl)})
  try({remove(cl)})
}
  cores.number = detectCores(all.tests = FALSE, logical = TRUE)
  cl = makeCluster(2)
  registerDoParallel(cl, cores=cores.number)

as_train <- fread("./Data/train.csv", stringsAsFactors = TRUE)

# Store and remove ids
train_ids = as_train$id
as_train = as_train %>% dplyr::select(-id)
sapply(as_train,class)
as_test <- fread("./Data/test.csv", stringsAsFactors = TRUE)
# Store and remove ids
test_ids = as_test$id
as_test = as_test %>% dplyr::select(-id)

loss_e <- log(as_test$loss + 1)

library(caret)
# Remove variables with one factor
# nzv <- nearZeroVar(as_train)
# as_train <- as_train[, -nzv]
# as_test <- as_test[, -nzv]
uniqueFactors = sapply(as_train, function(x) length(unique(x)))
uniqueFactors
# set.seed(0)
# training_subset = createDataPartition(y = train_ids, p = subset_ratio, list = FALSE)
# as_train <- as_train[training_subset, ]

# Create dummy variables
dm_train = data.frame(predict(dummyVars("loss ~ .", data=as_train), newdata=as_train))
# dm_test = data.frame(predict(dummyVars("~ .", data=test_e), newdata=test_e))
# Remove nero zero variance columns
preProc <- preProcess(dm_train,
                      method = "nzv")
nzvOnes= str_extract('cat[0-9]+', string = preProc$method$remove)
nzvOnes = sort(table(nzvOnes),decreasing=TRUE)
sort(nzvOnes)
lookAtV1 = sort(c("cat67", "cat21", "cat60","cat65", "cat32", "cat30", "cat24", "cat74", "cat85", "cat17", "cat14", "cat18", "cat59", "cat22", "cat63", "cat56", "cat58", "cat55", "cat33", "cat34", "cat46", "cat47", "cat48", "cat68", "cat35", "cat20", "cat69", "cat70", "cat15", "cat62"))
length(lookAtV1)
length(nzvOnes)
sort(uniqueFactors)

print("New Set")
listOfFactorsToToss = c()
for (i in 1:length(uniqueFactors)) {
  uniqueFactorName = names(uniqueFactors[i])
  uniqueFactor = uniqueFactors[i]
  sameNZV = nzvOnes[uniqueFactorName]
  if (!is.na(sameNZV) & !is.na(uniqueFactor) & (uniqueFactor-sameNZV) == 0) {
    listOfFactorsToToss = append(listOfFactorsToToss, uniqueFactorName)
  }
}
listOfFactorsToToss
length(unlist(intersect(lookAtV1,listOfFactorsToToss)))
length(listOfFactorsToToss)

# "cat7"  "cat14" "cat15" "cat16" "cat17" "cat18" "cat19" "cat20" "cat21" "cat22" "cat24" "cat28" "cat29" "cat30" "cat31" "cat32" "cat33" "cat34" "cat35"
# [20] "cat39" "cat40" "cat41" "cat42" "cat43" "cat45" "cat46" "cat47" "cat48" "cat49" "cat51" "cat52" "cat54" "cat55" "cat56" "cat57" "cat58" "cat59" "cat60"
# [39] "cat61" "cat62" "cat63" "cat64" "cat65" "cat66" "cat67" "cat68" "cat69" "cat70" "cat74" "cat76" "cat77" "cat78" "cat85" "cat89"
# # substr(preProc$method$remove, 0, 6)
# dm_train <- predict(preProc, dm_train)
# dm_test <- predict(preProc, dm_test)
# 
# set.seed(321)
# trainIdx <- createDataPartition(loss_e, 
#                                 p = .8,
#                                 list = FALSE,
#                                 times = 1)
# subTrain <- dm_train[trainIdx,]
# subTest <- dm_train[-trainIdx,]
# lossTrain <- loss_e[trainIdx]
# lossTest <- loss_e[-trainIdx]
# 
# fitCtrl <- trainControl(method = "cv",
#                         number = 5,
#                         verboseIter = TRUE,
#                         summaryFunction=defaultSummary)
# 
# gbmGrid <- expand.grid( n.trees = seq(100,500,50), 
#                         interaction.depth = c(1,3,5,7), 
#                         shrinkage = 0.1,
#                         n.minobsinnode = 20)
# 
# gbmFit <- train(x = subTrain, 
#                 y = lossTrain,
#                 method = "gbm", 
#                 trControl = fitCtrl,
#                 tuneGrid = gbmGrid,
#                 metric = 'MAE',
#                 maximize = FALSE)
# 
# plot(gbmFit, plotType = "level")
# gbmImp <- varImp(gbmFit, scale = FALSE)
# importance = gbmImp$importance
# print(gbmImp)
# plot(gbmImp, bottom = 20)
# 
# mean(gbmFit$resample$RMSE)
# 
# predicted <- predict(gbmFit, subTest)
# RMSE(pred = predicted, obs = lossTest)
# stopCluster(cl)