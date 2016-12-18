library(xgboost)
library(caret)
library(dtplyr)
library(tidyr)
library(data.table)
library(Matrix)
library(Metrics)
library(doMC)
library(doParallel)
library(arm)


# read in data
t.train = read.csv("train.csv", stringsAsFactors = T)


t.train$isSmall = factor(ifelse(t.train$loss>4500, F, T))


ID = 'id'
TARGET = 'isSmall'
SEED = 0


y_train = train[,TARGET]

set.seed(313)
index.sub = createDataPartition(t.train$cat80, p=0.8,list = FALSE)

train <- t.train[index.sub,]
test <- t.train[-index.sub,]


train[, c(ID,"X","loss")] = NULL
test[, c(ID,"X","loss")] = NULL


ntrain = nrow(train)
train_test = rbind(train, test)

features = names(train)

x_train = train_test[1:ntrain,]
x_test = train_test[(ntrain+1):nrow(train_test),]


varsToKeep = c("cat80","cont2","cat12","cat79","cont7","cont14","cat81","cat57","cat1","isSmall")

x_val= x_train[,varsToKeep]

logit.overall = glm(isSmall~., data=train,
                    family = "binomial")

summary(logit.overall)

logit.overall$coefficients/(1-logit.overall$coefficients)

p = predict(logit.overall, x_val, type = "response")


thresh = 0.8
d = data.frame(pred=ifelse(p>thresh, T, F), t=x_train$isSmall)
confusionMatrix(table(d))


# translate confusion matrices into business interpretation
spec = data.frame(thresh=double(), gain=double(), same=double(), risk=double())
pop = sum(table(d))
for (thresh in (20:90)/100) {
  tbl = table(data.frame(pred=ifelse(p>thresh, T, F), t=x_train$isSmall))
  gain = round((tbl[1,1] + tbl[2,2])/pop*100)
  same = round(tbl[1,2]/pop*100)
  risk = round(tbl[2,1]/pop*100)
  spec = rbind(spec, data.frame(thresh=thresh, gain=gain, same= same, risk=risk))
}

specNorm = spec %>% gather("metric","val", 2:4)

ggplot(specNorm, aes(x=thresh, y=val, col=metric)) + geom_line() + theme_minimal() + xlab("Cutoff") + ylab("Customers Affected per 100")

