library(ggplot2)
library(car)
library(dplyr)
library(corrplot)
library(caret)
library(gbm)
set.seed(0)
data<-read.csv("train.csv")
train<-sample(1:nrow(data),0.8*nrow(data))
data.train<-data[train,-1]
data.test<-data[-train,-1]
loss.train<-log(data$loss[train])
loss.test<-log(data$loss[-train])
colname<-names(data)
length(colname)

###sebset catergory data
data.t.cat<- data.train[,sapply(data.train,function(x) ifelse(class(x)=="factor",TRUE,FALSE))]
data.t.con<- data.train[,sapply(data.train,function(x) ifelse(!class(x)=="factor",TRUE,FALSE))]
data.t.con$loss<-log(data.t.con$loss+1)
scatterplotMatrix(data.t.con[1:1000,])
model.lm <- lm(loss~ .,data = data.t.con)
summary(model.lm)
plot(model.lm)
vif(model.lm)
model.lm.re<-lm(loss~. -cont12 -cont6 -cont1,data = data.t.con)
vif(model.lm.re)
summary(model.lm.re)
cor(data.t.con)  ###11,12 0.99 correlation;cont 1-9 0.931;1-10, 0.81; cont6-1 0.76; cont6-7 0.66; con6-9 0.8;con6-10,0.88;
###con9-10,0.787, con11-6,11-7,11-9;con12-1,12-6 0.8
corrs<-cor(data.t.con,method = "pearson")
corrplot.mixed(corrs,upper = "square",order="hclust")

###create dummy variables and preprocess data


dm.train.pre<-model.matrix(loss~ .,data=data.train)
dm.test.pre<-model.matrix(loss~ .,data=data.test)

preProc<-preProcess(dm.train.pre, method = "nzv")
preProc

dm.train<-predict(prep,dm.train)
dm.test<-predict(prep,dm.test)

##write.csv(dm.train,"dm.train.csv")
##write.csv(dm.test,"dm.test.csv")

dm.train<-read.csv("dm.train.csv")[,-1]
dm.test<-read.csv("dm.test.csv")[,-1]

dm.train.cat<-select(dm.train,contains("cat"))
wss = function(data, nc = 15, seed = 0) {
  wss = (nrow(data) - 1) * sum(apply(data, 2, var))
  for (i in 2:nc) {
    set.seed(seed)
    wss[i] = sum(kmeans(data, centers = i, iter.max = 100, nstart = 100)$withinss)
  }
  return(wss)
}
Ktune<-wss(dm.train.cat,20)
plot(1:20, Ktune, type = "b",
     xlab = "Number of Clusters",
     ylab = "Within-Cluster Variance",
     main = "Scree Plot for the K-Means Procedure")
names(dm.train)
model.lm.dm<-lm(Loss~ .-cont12 -cont6 -cont1, data =dm.train)
summary(model.lm.dm)



###### PCA
library(psych)
dm.tr
model.pca<-fa.parallel(dm.train[,-c(1,141,146,152)],fa="pc",n.iter = 10)
model.pca.50<- principal(dm.train[,-c(1,141,146,149,150,152)],nfactors = 48,rotate = "none")


####Gradient boosting machine
fitCtrl<-trainControl(method = "cv",
                      number = 10,
                      verboseIter = TRUE,
                      summaryFunction = defaultSummary)
gbmGrid<-expand.grid(n.trees=seq(100,10000,100),
                     interaction.depth=5,
                     shrinkage=0.1,
                     n.minobsinnode=50)
gbmFit<-train(x=dm.train,
              y=loss.train,
              method="gbm",
              trControl=fitCtrl,
              tuneGrid=gbmGrid,
              metric="RMSE",
              maximize = FALSE)
predict.test<-predict(gbmFit,dm.test)
predict.test
RMSE(pred = predict.test, obs = loss.test)
sum((predict.test-loss.test)^2)/(2*length(loss.test))


kag.test<-read.csv("test.csv")[,-1]
dm.kag.test<-model.matrix(~.,kag.test)
kag.test.dm<-predict(preProc,dm.kag.test)
predict.kag.test<-predict(gbmFit,kag.test.dm)h


###2nd try
input<-cbind(as.data.frame(dm.train),loss.train)
model.gbm<-gbm(loss.train ~ ., data = input,
               distribution = "gaussian",
               n.trees =2600,
               interaction.depth = 5,
               shrinkage = 0.1)
save(model.gbm,file = "./model.gbm.rda")
kag.test<-read.csv("test.csv")[,-1]
dm.kag.test<-model.matrix(~.,kag.test)
kag.test.dm<-predict(prep,dm.kag.test)
predict.kag.test<-predict(model.gbm,newdata = as.data.frame(kag.test.dm), n.trees = 2600)
final<-exp(predict.kag.test)
final
write.csv(final,"submit.csv")

###3rd try
input.all.x<-rbind(as.data.frame(dm.train),as.data.frame(dm.test))
input.all.y<-c(loss.train,loss.test)
input<-cbind(input.all.x,input.all.y)
names(input$input.all.y)<-c("loss")
model.gbm.2640<-gbm(input.all.y ~ ., data = input,
               distribution = "gaussian",
               n.trees =2640,
               interaction.depth = 5,
               shrinkage = 0.1)
