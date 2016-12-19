######################################################################################
#
#  Predict House Sales
#
#  This script loads the master house observations file, filters it based on year and 
#  excludes observations with key missing features (e.g., if there's no house value, 
#  the the record is probably the results of a failed extrapolation, such as no prior
#  transaction to extrapolate from). 
#  
#  It then does some basic imputation
#
#
######################################################################################



# tClean is the whole data from 2006 onwards. 
# Missingness:
# some rows are omitted (e.g., no Yrssincesold values,etc)
# Others use averages or regressions
# Some missing remain in cols that aren't important and not used in modeling
library(dplyr)
library(tidyr)
library(ROCR)
library(caret)
library(randomForest)
library(glmnet)
library(data.table)
library(Matrix)
library(xgboost)
library(Metrics)
library(ROSE)


t2 = read.csv("allHouseObsAndDemo20161213.csv", row.names = 1)
t2$X = NULL


tClean = t2 %>% filter(ObsYear>2009 & !is.na(HouseValPctDevPrevSale) & !is.na(TrueHouseValue))
filterYear = 0
# tClean = t2 %>% filter(ObsYear==filterYear & !is.na(HouseValPctDevPrevSale) & !is.na(TrueHouseValue))

tClean$NumBeds[is.na(tClean$NumBeds)]=3
tClean$NumBaths[is.na(tClean$NumBaths)]=2
tClean$RaceOther = log(1.01-tClean$RaceWhite)
tClean$RaceWhite = NULL


tClean= tClean %>% mutate(Sqft=ifelse(is.na(Sqft), -100 + 690*NumBeds,Sqft))

tClean$SoldPrevYear = as.integer(tClean$YrsSinceSoldLag<1)

tClean$LotSize[is.na(tClean$LotSize)]=median(tClean$LotSize, na.rm=TRUE)

tClean$YrsSinceSoldLag[is.na(tClean$YrsSinceSoldLag)]=mean(tClean$YrsSinceSoldLag, na.rm=TRUE)


#tClean$YrsOld[is.na(tClean$YrsOld)]=26
tClean$YrsSinceRemodel[is.na(tClean$YrsSinceRemodel)]=22

tClean$HHMedIncome[is.na(tClean$HHMedIncome)]=mean(tClean$HHMedIncome, na.rm=TRUE)

#filter out other missingness
#tClean <- tClean[rowSums(is.na(tClean)) == 0,] 


tClean$LotSize = log(tClean$LotSize)
tClean$Sqft = log(tClean$Sqft)
tClean$HouseValPrevYear = log(tClean$HouseValPrevYear)



# tClean at this point should match up to tClean in order to later extract address data

# treg = tClean %>% 
#   select(LotSize,NumBeds,SaleFlg,
#          YrsSinceRemodel,YrsSinceSoldLag, SoldPrevYear,
#          HouseValPrevYear, HouseValPctDevPrevSale, ZipCode,
#          YoYPctChgLaborForce, YoYChgUnempRate,
#          HHMChildUnder18,
#          MortAnd2ndOrEq, RaceOther, YoYChg)

# logistic regression significant features
#
# treg = tClean %>%
#   select(LotSize, NumBaths, NumBeds, Sqft, YrsSinceRemodel, YrsSinceSoldLag, SoldPrevYear, HouseValPctDevPrevSale, ZipCode, YoYPctChgLaborForce, YoYChgUnempRate, EduAttainBach, HHMChildUnder18, MedValue, YoYChg, RaceOther
# )
# full version
treg = tClean %>%
select(LotSize,NumBaths,NumBeds,SaleFlg,
       Sqft, YrsSinceRemodel,YrsSinceSoldLag, SoldPrevYear,
       HouseValPrevYear, HouseValPctDevPrevSale, ZipCode, unempRate,
       YoYPctChgLaborForce, YoYChgUnempRate,
       EduAttainBach,HHMedIncome,  HHMChildUnder18,HHMSeniorsOver65,MedValue,
       Mortgage,MortAnd2ndAndEq,MortAnd2ndOrEq, RaceOther, HHwRetIncome, YoYChg, Rate)

# lasso removed:
#NumBaths, Sqft, unempRate, EduAttainBach, HHMedIncome, HHMSeniorsOver65, MedValue, Mortgage, MortAnd2ndOrEq, HHwRetIncome, Rate



######################################################################################
#
#  Build Test and Training sets
#
######################################################################################


y = treg[,"SaleFlg", drop=FALSE]
treg$SaleFlg = NULL
treg = scale(treg)
treg = cbind(treg, SaleFlag=y)

tregX = treg
tregX$SaleFlg = NULL

#write.csv(treg, "allHouseObsAndDemoNoNAs.csv")


#treg$SaleFlg = as.integer(as.character(treg$SaleFlg)) # for regression
treg$SaleFlg = as.factor(treg$SaleFlg)

set.seed(999)
train = createDataPartition(treg$SaleFlg, p = 0.7, list=FALSE)

tregTest = treg[-train,]
tregTestX = tregX[-train,]
tregTrain = treg[train,]

# do overtraining

tregTrainOver = ROSE(SaleFlg ~ ., data=tregTrain, p=0.3)$data




######################################################################################
#
#  Logistic Regresssion
#
#
######################################################################################


logit.sat = glm(SaleFlg ~.,
                    family = "binomial",
                    data = tregTrainOver, control = list(maxit = 200))

summary(logit.sat)


lsumAll = summary(logit.sat)



logit.featToKeep = paste(names(which(lsumAll$coefficients[,4]<0.1))[-1],sep = "", collapse = ", ")

logit.featToKeep # this can be used to modify the feature set


pchisq(logit.sat$deviance, logit.sat$df.residual, lower.tail = FALSE)

# explains 3% of the variance
1 - logit.sat$deviance/logit.sat$null.deviance


################################
# reduced set of features
################################

tregTrainOver.reduced = tregTrainOver %>% select(
  LotSize, 
  NumBaths, 
  NumBeds, 
  Sqft, 
  YrsSinceRemodel, 
  YrsSinceSoldLag, 
  SoldPrevYear, 
  HouseValPctDevPrevSale, 
  YoYPctChgLaborForce, 
  YoYChgUnempRate, 
  EduAttainBach, 
  HHMedIncome, 
  HHMChildUnder18, 
  RaceOther, 
  YoYChg,
  SaleFlg
)

tregTest.reduced = tregTest %>% select(
  LotSize, NumBaths, NumBeds, Sqft, YrsSinceRemodel, YrsSinceSoldLag, SoldPrevYear, HouseValPctDevPrevSale, YoYPctChgLaborForce, YoYChgUnempRate, EduAttainBach, HHMedIncome, HHMChildUnder18, RaceOther, YoYChg, SaleFlg
)

logit.reduced = glm(SaleFlg ~.,
                family = "binomial",
                data = tregTrainOver.reduced, control = list(maxit = 200))
summary(logit.reduced)



################################
# Lasso Regression
################################

grid = 10^seq(1, -5, length = 100)

# need matrices for glmnet
x_train = model.matrix(SaleFlg ~ ., tregTrainOver)[,-1]
y_train = as.integer(as.character(tregTrainOver$SaleFlg))

x_test = model.matrix(SaleFlg ~ ., tregTest)[,-1]
y_test = as.integer(as.character(tregTest$SaleFlg))

lasso.models.train = glmnet(x_train, y_train, alpha = 1, lambda = grid)

#Running 5-fold cross validation.
set.seed(0)
cv.lasso.out = cv.glmnet(x_train, y_train,
                         lambda = grid, alpha = 1, nfolds = 5)

bestlambda.lasso = cv.lasso.out$lambda.min

# who got shrunk
lasso.coeff = coef(cv.lasso.out, s = "lambda.min")


################################
# Random Forest
################################


# convert to integer so RF does a regression
tregTrainOver$SaleFlg = as.integer(as.character(tregTrainOver$SaleFlg))

rf.houses = randomForest(SaleFlg ~ ., data = tregTrainOver, importance = TRUE, ntree=500)


################################
# Summarize
################################

getCutoffs = function(perf, cutoff) {
  x = perf@x.values[[1]]
  cutoffIndex = which(round(x,4)==round(cutoff,4))[1]
  
  a = perf@alpha.values[[1]]
  cutoffVal = a[cutoffIndex]
  
  y = perf@y.values[[1]]
  cutoffY = y[xidx]
  
  return (c("cutoffIndex"=cutoffIndex, "cutoffVal"=cutoffVal, "cutoffY"=cutoffY))
}

# logistic
lr.pval = predict(logit.sat, tregTest, type = "response")
lr.predict = prediction(lr.pval, tregTest$SaleFlg)
lr.sat.roc.perf = performance(lr.predict, measure = 'tpr', x.measure = 'fpr')
lr.cutoffs = getCutoffs(lr.sat.roc.perf, 0.5)

sale.predicted = ifelse(lr.pval>lr.cutoffs["cutoffVal"], 1, 0)
logRes = data.frame("ObsNum"=row.names(tregTest), 'type'="LogitFull", "truth"= as.character(tregTest$SaleFlg), "Predict" = sale.predicted, 'Prob'=lr.pval)

table(logRes[,3:4])


# logistic reduced
lr.red.pval = predict(logit.sig, tregTest, type = "response")
lr.red.predict = prediction(lr.red.pval, tregTest$SaleFlg)
lr.red.roc.perf = performance(lr.red.predict, measure = 'tpr', x.measure = 'fpr')
lr.red.cutoffs = getCutoffs(lr.red.roc.perf, 0.5)

sale.predicted = ifelse(lr.red.pval>lr.red.cutoffs["cutoffVal"], 1, 0)
logRes.red = data.frame("ObsNum"=row.names(tregTest), 'type'="LogitRed", "truth"= as.character(tregTest$SaleFlg), "Predict" = sale.predicted, 'Prob'=lr.red.pval)

table(logRes.red[,3:4])



# lasso

las.pval = predict(lasso.models.train, s = bestlambda.lasso, newx = x_test)
las.predict = prediction(las.pval, tregTest$SaleFlg)
las.roc.perf = performance(las.predict, measure = 'tpr', x.measure = 'fpr')
las.cutoffs = getCutoffs(las.roc.perf, 0.5)

sale.predicted = ifelse(las.pval>las.cutoffs["cutoffVal"], 1, 0)
lasRes = data.frame("ObsNum"=row.names(tregTest), 'type'="Lasso", "truth"= as.character(tregTest$SaleFlg), "Predict" = as.numeric(sale.predicted), 'Prob'=as.numeric(las.pval))

table(lasRes[,3:4])


# random forest

rf.pval = log(predict(rf.houses, tregTest))
rf.predict = prediction(rf.pval, tregTest$SaleFlg)

rf.roc.perf = performance(rf.predict, measure = 'tpr', x.measure = 'fpr')
rf.cutoffs = getCutoffs(rf.roc.perf, 0.5)

sale.predicted = ifelse(rf.pval>rf.cutoffs["cutoffVal"], 1, 0)
rfRes = data.frame("ObsNum"=row.names(tregTest), 'type'="RF", "truth"= as.character(tregTest$SaleFlg), "Predict" = as.numeric(sale.predicted), 'Prob'=as.numeric(rf.pval))

table(rfRes[,3:4])

allRes = rbind(rfRes, logRes, logRes.red)
allRes$Correct = allRes$truth == allRes$Predict


allRes %>% group_by(truth, Correct, ObsNum) %>% summarize(cnt=sum(Predict)) %>% 
 group_by(truth, Correct, cnt) %>% count() %>% ungroup()

agg1 = allRes %>% select(-Prob, -Correct) %>% spread(type, Predict) 
agg2 = allRes %>% select(-Prob, -Predict) %>% spread(type, Correct) 
colnames(agg2) <- c("ObsNum","truth","RF.Cor","LogitFull.Cor","LogitRed.Cor")
agg = cbind(agg1, agg2[,3:5])


%>% group_by(ObsNum, truth) %>% summarize(RF=sum(RF, na.rm=T), LogitFull=sum(LogitFull, na.rm=T), LogitRed=sum(LogitRed, na.rm=T)) %>% 
  group_by(truth) %>% summarize(RF=sum(RF), LogitFull=sum(LogitFull), LogitRed=sum(LogitRed))


consensus = allRes %>% group_by(ObsNum) %>% summarize(cnt=sum(Predict)) %>% ungroup()
consensus = cbind(logRes, consensus)
consensus[which(consensus$cnt %in% c(1)),"Predict"]=0
table(consensus[,3:4])






plot(las.roc.perf, colorize = TRUE, main="ROC for 4 Models")
plot(lr.red.roc.perf, add = TRUE, colorize = TRUE)
plot(lr.sat.roc.perf, add = TRUE, colorize = TRUE)
plot(rf.roc.perf, add = TRUE, colorize = TRUE)
abline(a=0, b= 1, col='grey')
abline(a=y[xidx], b= 0, col='red')
abline(v= x[xidx],col='red')



logRes$truth = as.factor(logRes$truth)
ggplot(logRes, aes(x=Prob, fill=truth)) + geom_histogram(bins = 60, position='identity') + geom_vline(xintercept=lr.cutoffs["cutoffVal"]) +
  theme_minimal()  + xlab('Prediction (prob)') + ggtitle("Sale vs Non-Sale Logit Prediction") +
  scale_fill_manual(values=c("paleturquoise3", "red4"), 
                      name=NULL,
                      breaks=c(0,1 ),
                      labels=c("No Sale", "Sale"))

lasRes$truth = as.factor(lasRes$truth)
ggplot(lasRes, aes(x=Prob, fill=truth)) + geom_histogram(bins = 60, position='identity') + geom_vline(xintercept=las.cutoffs["cutoffVal"]) +
  theme_minimal()  + xlab('Prediction (prob)') + ggtitle("Sale vs Non-Sale Logit Prediction") +
  scale_fill_manual(values=c("paleturquoise3", "red4"), 
                    name=NULL,
                    breaks=c(0,1 ),
                    labels=c("No Sale", "Sale"))




plot(lr.sat.roc.perf, main="ROC for 4 Models")
abline(a=0, b= 1)
abline(a=y[xidx], b= 0)
abline(v= x[xidx])


sale.predicted = ifelse(pval>lr.cutoff, 1, 0)
logRes = data.frame("truth"= as.character(tregTest$SaleFlg), "Predict" = sale.predicted, 'Prob'=pval)

table(logRes[,1:2])


logRes$truth = as.factor(logRes$truth)
ggplot(subset(logRes,truth==0), aes(x=Prob)) + geom_histogram(bins = 60, fill='cadetblue4') +
  geom_histogram(data=subset(logRes,truth==1), aes(x=Prob), fill='brown4', bins = 60) + geom_vline(xintercept=lr.cutoff) +
  theme_minimal()  + xlab('Prediction (prob)') + ggtitle("Sale(blue) vs Non-Sale(red) Logit Prediction")


summary(logRes$truth)









rfRes$truth = as.factor(rfRes$truth)
ggplot(subset(rfRes,truth==0), aes(x=log(Prob))) + geom_histogram(bins = 60, fill='blue') +
  geom_histogram(data=subset(rfRes,truth==1), aes(x=log(Prob)), fill='red', bins = 60) + 
  geom_vline(xintercept=log(rf.cutoff)) +
  theme_minimal()

importance(rf.houses, type=1)
varImpPlot(rf.houses, type=1, main="Variable Importance for RF")




# combine Logistic and RF
logRes = data.frame("truth"= as.character(tregTest$SaleFlg), "Predict" = sale.predicted, 'Prob'=pval)
rfRes =data.frame('truth'=tregTest$SaleFlg, "Predict" = sale.rf.predicted,"Prob"=rf.pval)


comp.pred = cbind(logRes, rfRes)
comp.pred[,4]=NULL

names(comp.pred) <- c("Truth", "LR.pred", "LR.Prob", "RF.Pred","RF.Prob")

comp.pred$RF.LogProb = log(comp.pred$RF.Prob)

comp.pred$combPred = comp.pred$RF.LogProb > lr.cutoff | comp.pred$LR.Prob > lr.cutoff
comp.pred$RF.LogProb = scale(comp.pred$RF.LogProb)

cp =comp.pred[,c( 3, 5)]

cp = scale(cp)

cpp = comp.pred[,1, drop=F]

cpp = cbind(cp, cpp)

ggplot(subset(comp.pred,Truth==0), aes(x=RF.LogProb)) + geom_histogram(alpha=0.3, bins = 60, fill='blue') +
  geom_histogram(data=subset(comp.pred,Truth==1), aes(x=RF.LogProb), fill='red', alpha=0.3, bins = 60) + 
  theme_minimal()

table(treg$SaleFlg, treg$LotSize<=0.46)



630/9859

library(parallel)

# Calculate the number of cores
no_cores <- detectCores() - 1

# Initiate cluster
cl <- makeCluster(no_cores)




tregTrainOverX = tregTrainOver
y_train = as.integer(as.character(tregTrainOverX$SaleFlg))
tregTrainOverX[,"SaleFlg"] = NULL

tregTestX = tregTest
y_test = as.integer(as.character(tregTestX$SaleFlg))
tregTestX[,"SaleFlg"] = NULL

dtrain = xgb.DMatrix(as.matrix(tregTrainOverX), label=y_train)
dtest = xgb.DMatrix(as.matrix(tregTestX), label = y_test)


xgb_params = list(
  colsample_bytree = 1,
  subsample = 1,
  eta = 0.04,
  objective = 'binary:logistic', #reg:linear'
  max_depth = 5,
  num_parallel_tree = 1,
  min_child_weight = 1
)

res = xgboost(dtrain,
              y_train,
              params= xgb_params,
             nrounds=500,
             early_stopping_rounds=15,
             print_every_n = 50)


test.predict = predict(res, dtest)


test.predictBin = ifelse(test.predict<0.75,0, 1)
xgbRes = data.frame("truth"=y_test, "predict"=test.predictBin, "Prob"=test.predict)
table(xgbRes[,1:2])

xgbRes$truth = as.factor(xgbRes$truth)
ggplot(subset(xgbRes,truth==0), aes(x=Prob)) + geom_histogram(bins = 70, fill='blue') +
  geom_histogram(data=subset(xgbRes,truth==1), aes(x=Prob), fill='red', bins = 70) + geom_vline(xintercept=0.14) +
  theme_minimal()


# double hit ratio with 500 rounds, eta 0.04, max depth 5 and predict threshold of 0.15

# plot

model <- xgb.dump(res, with.stats = T)

names = colnames(tregTrainOverX)

importance_matrix <- xgb.importance(names, model = res)


# Nice graph
library(Ckmeans.1d.dp)
xgb.plot.importance(importance_matrix[1:15,])


tregFeat = treg
tregFeat$SaleFlg = NULL


treg$TrueHouseValue





 # cross=validate XGB

xgb_params = list(
  seed = 0,
  colsample_bytree = 1,
  subsample = 1,
  eta = 0.075,
  objective = 'binary:logistic',
  max_depth = 6,
  num_parallel_tree = 1,
  min_child_weight = 1,
  base_score = 0.5
)

watchList = list(train=dtrain, test=dtest)

res = xgb.train(
             data=dtrain,
             max.depth=6, eta=0.075, nthread = 2, 
             nround=1000,
             watchList = watchList,
             base_score=5,
             print.every.n = 1,
             verbose = 1,
             eval.metric="error")


test.predict = predict(res, dtest)
plot(test.predict, y_test)

test.predictBin = ifelse(test.predict<0.02, 0, 1)
x = data.frame("truth"=y_test, "predict"=test.predictBin)
table(x)

x1 = data.frame("truth"=y_test, "predict"=test.predict)
x1$truth = as.factor(x1$truth)
ggplot(subset(x1,truth==0), aes(x=predict)) + geom_histogram(bins = 70, fill='blue') +
  geom_histogram(data=subset(x1,truth==1), aes(x=predict), fill='red', bins = 70)


names = colnames(tregTrainOverX)

importance_matrix <- xgb.importance(names, model = res)
xgb.plot.importance(importance_matrix = importance_matrix)




# create unique list of addresses for submission to census

allRec1 = read.csv("ncresidents_zip28786.csv", stringsAsFactors = F)
allRec2 = read.csv("ncresidents_zip28803.csv", stringsAsFactors = F)

allRec = rbind(allRec1, allRec2)


uniqueAddr = allRec %>% group_by(addrQuery) %>% 
  summarize(zipCode=min(zipCode), 
            cityName=min(cityName),
            streetAddr=min(streetAddr),
            countyName=min(countyName),
            houseID=min(rowID)) %>% arrange(houseID)

# only pull off addresses we actually use
a = data.frame(addrQuery = unique(t$AddrQuery))


uaf = a %>% inner_join(uniqueAddr, by="addrQuery")


write.csv(uaf, file="addr.csv", row.names = F)




library(ggplot2)


t$HouseID = as.factor(t$HouseID)
t$YrsSinceSoldF = as.factor(t$YrsSinceSold)

tCut$SaleFlg = as.factor(tCut$SaleFlg)
tCut$ObsYearF = as.factor(tCut$ObsYear)

t$SaleFlgF = as.factor(t$SaleFlg)
ggplot(t, aes(y=TrueHouseValue, x=ObsYear, color=SaleFlgF)) + 
  geom_point(alpha=0.5) + theme(legend.position="none")




tClean$SaleFlgF = as.integer(as.character(tClean$SaleFlg))
tClean$OwnershipID = as.factor(tClean$OwnershipID)


temp = unique(tClean$HouseID)
temp2 = sample(temp, 20)

temp3= tClean[tClean$HouseID %in% temp2,]
#temp3$OwnershipID = as.factor(temp3$OwnershipID)
tempSales= temp3[temp3$SaleFlg==1,]


ggplot(temp3, aes(x=ObsYear, y=log(TrueHouseValueAdj), color=HouseID)) + 
  geom_line() + theme(legend.position="none") + 
  geom_point(data=tempSales, aes(x=ObsYear, y=log(TrueHouseValueAdj)))


# box plots

ggplot(treg, aes(x=SaleFlg, y=log(LotSize), color=SaleFlg)) + 
  geom_boxplot() + theme(legend.position="none") + ylim(c(-5,5))

test = t.test(log(LotSize)~SaleFlg, data=treg) 
print(test)

ggplot(subset(treg, SaleFlg ==0), aes(x=log(LotSize))) + geom_histogram(bins = 70, fill='blue') +
  geom_histogram(data=subset(treg, SaleFlg ==1), aes(x=log(LotSize)), fill='red', bins = 70) +
  theme_minimal()

