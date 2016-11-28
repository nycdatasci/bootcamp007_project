allstate.train = read.csv('train.csv')
allstate.test = read.csv('test.csv')

train_e = allstate.train %>% select(-id)
test_e = allstate.test %>% select(-id)

loss_e = log(train_e$loss + 1)

#dummify
dm_train = model.matrix(loss ~ ., data = train_e)

preProc <- preProcess(dm_train,
                      method = "nzv")

dm_train <- predict(preProc, dm_train)
dim(dm_train)

dm_test <- predict(preProc, dm_test)
dim(dm_test)

#data split 
set.seed(0)
trainIdx <- createDataPartition(loss_e, 
                                p = .8,
                                list = FALSE,
                                times = 1)
subTrain <- dm_train[trainIdx,]
subTest <- dm_train[-trainIdx,]
lossTrain <- loss_e[trainIdx]
lossTest <- loss_e[-trainIdx]

#train nzv model 
lm.nzv = train(y = lossTrain, x=subTrain, method = 'lm')

summary(lm.nzv)

#Variables importance 
lmImp <- varImp(lm.nzv, scale = FALSE)
plot(lmImp,top = 20)

#model evaluation 
mean(lm.nzv$resample$RMSE)
# 0.5774509451

predicted <- predict(lm.nzv, subTest)

postResample(pred = predicted, obs = lossTest)
# 0.5765940241

plot(x = predicted, y = lossTest)


########################################################
library(caret)
library(hydroGOF)
# setwd()

# when using the new train and test datasets
ntrain = read.csv('new_train.csv')
ntest = read.csv('new_test.csv')

# drop the original cats over 15 levels
replaced_features = c('cat116', 'cat115', 'cat114', 'cat113', 'cat112',
                      'cat111', 'cat110', 'cat109', 'cat107', 'cat106',
                      'cat105', 'cat104', 'cat101', 'cat99')

allstate.train = ntrain[, !names(ntrain) %in% replaced_features]
allstate.test = ntest[, !names(ntest) %in% replaced_features]

loss.log = log((allstate.train$loss) + 1)

#drop high correlation
cont = 104:117
cors = cor(allstate.train[ ,cont])
highlyCors = findCorrelation(cors, cutoff = .75)
filtered.astrain = cbind(allstate.train[,-cont], allstate.train[,cont][,-highlyCors])
filtered.astest = cbind(allstate.test[,-cont], allstate.test[,cont][,-highlyCors])


# dummy
dm.filtered.astrain = model.matrix(loss ~., data = filtered.astrain[, -1])[,-1]
dim(dm.filtered.astrain) # [1] 188318    332

filtered.astest = model.matrix(~., data = allstate.test[, -1])[,-1]
dim(filtered.astest) # [1] 125546    367  
# if cannot use "predict" function, drop the different vars in dm.astest, uncomment next line
# dm.astest = dm.astest[, colnames(dm.astest) %in% colnames(dm.astrain)]

# # drop near zero variables
# prep = preProcess(dm.astrain, method = 'nzv')
# dm.astrain = predict(prep, dm.astrain)
# dim(dm.astrain) 
# dm.astest = predict(prep, dm.astest)
# dim(dm.astest)


# based on train.csv to create train and test sets
set.seed(0)
train.index = createDataPartition(loss.log, times = 1, p = 0.8, list = F)

sub.dmtrain = dm.filtered.astrain[train.index, ]
sub.dmtest = dm.filtered.astrain[-train.index, ]
loss.train = loss.log[train.index]
loss.test = loss.log[-train.index]

#train nzv model 
lm.group = train(y = loss.train, x=sub.dmtrain, method = 'lm')

summary(lm.group)

#Variables importance 
lmImp.group <- varImp(lm.group, scale = FALSE)
plot(lmImp.group,top = 20)

#model evaluation 
mean(lm.group$resample$RMSE)
# 0.566255370

predicted <- predict(lm.group, sub.dmtest)

postResample(pred = predicted, obs = loss.test)
# 0.5655655930

plot(x = predicted, y = loss.test)