as_train <- read.csv("train.csv")
as_test <- read.csv("test.csv")
dim(as_train)


table(as_train$cat112)
train_e <- as_train %>% select(-id)

loss_e = log(train_e$loss + 1)
loss_e = data.frame(loss_e)

summary(as_train[2:117])
sapply(as_train[,90:117], levels)

#traform cat. variables to dummy variables 
dm_train = model.matrix(loss ~ ., data = train_e)

#drop variables that near 0
preProc = preProcess(dm_train, method = "nzv")
dm_train = predict(preProc, dm_train)
dm_train = as.data.frame(dm_train)
dm_train = data.frame(dm_train, loss = as_train$loss)

#data spliting(drop nzv)
set.seed(0)
train = sample(1:nrow(dm_train), 7*nrow(dm_train)/10)
as.train = dm_train[train,]
as.test = dm_train[-train,]
loss.train = loss_e[train,]
loss.test = loss_e[-train,]

#data spliting(no id)
as.train.all=  train_e[train,]
as.test.all =train_e[-train,] 
####################################initial tree

#fit the model 
library(randomForest)

set.seed(0)
rf.as = randomForest(loss ~ ., data = as.train, ntree = 500, importance = TRUE)
summary(rf.as)

save(rf.as, file='rfmodel.rda')
rf.as = load('rfmodel.rda')

# randomForest(formula = loss ~ ., data = as.train, ntree = 500,      importance = TRUE) 
# Type of random forest: regression
# Number of trees: 500
# No. of variables tried at each split: 51
# 
# Mean of squared residuals: 3993603
# % Var explained: 52.24

yhat = predict(rf.as, newdata = as.test)
yhat

#4057070
sqrt(4057070)