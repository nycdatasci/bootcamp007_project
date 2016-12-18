setwd("~/Proj4")
dt_test <- read.csv("test.csv", header = T, stringsAsFactors = T)
dt_train <- read.csv("train.csv", header = T, stringsAsFactors = T)
summary(dt_train$loss)
summary(log(dt_train$loss+200))
summary(dt_train$cont1)
summary(dt_train$cont2)
summary(dt_train$cont3)


plotBox <- function(data_in, i, lab) {
    data <- data.frame(x=data_in[[i]], y=lab)
    p <- ggplot(data=data, aes(x=x, y=y)) +geom_boxplot()+ xlab(colnames(data_in)[i]) + theme_light() + 
        ylab("log(loss)") + theme(axis.text.x = element_text(angle = 90, hjust =1))
    return (p)
}

doPlots <- function(data_in, fun, ii, lab, ncol=3) {
    pp <- list()
    ii <- ii+1
    for (i in ii) {
        p <- fun(data_in=data_in, i=i, lab=lab)
        pp <- c(pp, list(p))
    }
    do.call("grid.arrange", c(pp, ncol=ncol))
}

plotScatter <- function(data_in, i, lab){
    data <- data.frame(x=data_in[[i]], y = lab)
    p <- ggplot(data= data, aes(x = x, y=y)) + geom_point(size=1, alpha=0.3)+ geom_smooth(method = lm) +
        xlab(paste0(colnames(data_in)[i], '\n', 'Corr: ', round(cor(data_in[[i]], lab, use = 'complete.obs'), 2)))+
        ylab("log(loss)") + theme_light()
    return(suppressWarnings(p))
} 

plotDen <- function(data_in, i, lab){
    data <- data.frame(x=data_in[[i]], y=lab)
    p <- ggplot(data= data) + geom_density(aes(x = x), size = 1,alpha = 1.0) +
        xlab(paste0((colnames(data_in)[i]), '\n', 'Skewness: ',round(skewness(data_in[[i]], na.rm = TRUE), 2))) +
        theme_light() 
    return(p)
}
#library(dplyr)
library(data.table)
library(gridExtra)
library(corrplot)
library(GGally)
library(ggplot2)
library(e1071)
dt_train_cat <- dt_train[,1:117]
dt_train_cont <- dt_train[,c(1, 118:132)]
dt_test_cat <- dt_test[,1:117]
dt_test_cont <- dt_test[,c(1,118:131)]
#dt_train <- train

doPlots(dt_train_cat, fun = plotBox, ii =1:12, lab=log(dt_train$loss), ncol = 3)
doPlots(dt_train_cat, fun = plotBox, ii =13:24, lab=log(dt_train$loss), ncol = 3)
doPlots(dt_train_cat, fun = plotBox, ii =25:36, lab=log(dt_train$loss), ncol = 3)
doPlots(dt_train_cat, fun = plotBox, ii =37:48, lab=log(dt_train$loss), ncol = 3)
doPlots(dt_train_cat, fun = plotBox, ii =49:60, lab=log(dt_train$loss), ncol = 3)
doPlots(dt_train_cat, fun = plotBox, ii =61:72, lab=log(dt_train$loss), ncol = 3)
doPlots(dt_train_cat, fun = plotBox, ii =73:84, lab=log(dt_train$loss), ncol = 3)
doPlots(dt_train_cat, fun = plotBox, ii =85:96, lab=log(dt_train$loss), ncol = 3)
doPlots(dt_train_cat, fun = plotBox, ii =97:108, lab=log(dt_train$loss), ncol = 3)
doPlots(dt_train_cat, fun = plotBox, ii =109:110, lab=log(dt_train$loss), ncol = 1)
doPlots(dt_train_cat, fun = plotBox, ii =111:112, lab=log(dt_train$loss), ncol = 1)
doPlots(dt_train_cat, fun = plotBox, ii =113:114, lab=log(dt_train$loss), ncol = 1)
doPlots(dt_train_cat, fun = plotBox, ii =115:116, lab=log(dt_train$loss), ncol = 1)

doPlots(dt_train_cont, fun = plotScatter, ii =1:6, lab=log(dt_train$loss), ncol = 3)
doPlots(dt_train_cont, fun = plotScatter, ii =7:14, lab=log(dt_train$loss), ncol = 3)

dt_train_cont <- dt_train[,c(118:131)]
correlations_train <- cor(dt_train_cont)
corrplot(correlations_train, method="square", order="hclust")
dt_test_cont <- dt_test[,c(118:131)]
correlations_test <- cor(dt_test_cont)
corrplot(correlations_test, method="square", order="hclust")
#number of levels in categorical var
sapply(dt_train[,2:117], function(x) length(unique(x)))
dt_train_cat$group <- "train"
dt_test_cat$group <- "test"
dt_cat <- rbind(dt_train_cat, dt_test_cat)
#cat116, cat111, cat102
ggplot(dt_cat, aes(x=group) ) + geom_bar(aes(fill= cat116), position ="dodge") + theme_light() + xlab("cat116") + theme(legend.position="none")

plot_bar <- function(i){
  
  ggplot(dt_cat, aes(x=group) ) +
    geom_bar(aes_string(fill= dt_cat[i]), position ="dodge") +
    theme_light() + xlab(names(dt_cat[i])) +
    theme(legend.position="none")
}
plot_bar(47)
#2-sample t-test for cat1-73
dt_train2 <- dt_train
dt_train2$LogLoss <- log(dt_train$loss)
t_test_train_log <- data.frame(Var = character(), p_value = numeric())
for (i in c(2:74)){
    vecA <- dt_train2$LogLoss[dt_train2[,i] == "A"]
    #print(length(vecA))
    vecB <- dt_train2$LogLoss[dt_train2[,i] == "B"]
    #print(length(vecB))
    var_name <- names(dt_train2)[i]
    temp<-t.test(vecA, vecB, alternative = "two.sided")
    p <- temp$p.value
    temp1 <- data.frame(Var = var_name, p_value = p)
    t_test_train_log <- rbind(t_test_train_log, temp1)
}
t_test_train_log$drop <- ifelse(t_test_train_log$p_value >0.05, TRUE, FALSE)
sum(t_test_train_log$drop)  #only 2 insignificant :(
t_test_train_log$Var[which(t_test_train_log$drop == TRUE)] #cat15, cat70 can be dropped

t_test_train <- data.frame(Var = character(), p_value = numeric())
for (i in c(2:74)){
    vecA <- dt_train$loss[dt_train[,i] == "A"]
    #print(length(vecA))
    vecB <- dt_train$loss[dt_train[,i] == "B"]
    #print(length(vecB))
    var_name <- names(dt_train)[i]
    temp<-t.test(vecA, vecB, alternative = "two.sided")
    p <- temp$p.value
    temp1 <- data.frame(Var = var_name, p_value = p)
    t_test_train <- rbind(t_test_train, temp1)
}
t_test_train$drop <- ifelse(t_test_train$p_value >0.05, TRUE, FALSE)
sum(t_test_train$drop)  #only 3 insignificant :(
t_test_train$Var[which(t_test_train$drop == TRUE)] #cat15, cat22, cat70 can be dropped



fit_lm <-lm(loss ~ . -id -cont1 -cont6 -cont10 - cont9 - cont3 -cont11 -cont12 -cont13, data = dt_train_cont)
summary(fit_lm)
library(car)
vif(fit_lm)    

library(psych)
fa.parallel(dt_train_cont[,c(-1,-16)], n.obs = 188318, fa ="pc", n.iter = 100)
abline(h = 1)

prcp <- principal(dt_train_cont[,c(-1,-16)], nfactors = 6, rotate = "none")
prcp
x_train <- dt_train[,c(-1, -132)]
set.seed(0)
sample1p <- sample(c(1:nrow(x_train)), 0.01*nrow(x_train))
set.seed(0)
sample10p <- sample(c(1:nrow(x_train)), 0.1*nrow(x_train))
test1 <- FAMD(x_train[sample1p,], ncp = 400)
sum(test1$eig[,1]) #588.93
test10 <- FAMD(x_train[sample10p,], ncp = 400)
sum(test10$eig[,1]) #631.3611
set.seed(0)
sample20p <- sample(c(1:nrow(x_train)), 0.2*nrow(x_train))
test20 <- FAMD(x_train[sample20p,], ncp = 400)
sum(test20$eig[,1]) #630.1429


### check cat var.
### k-fold cross-validate in model has learning rate
###
dt_train <- read.csv("train.csv", header = T, stringsAsFactors = T)
dt_test <- read.csv("test.csv", header = T, stringsAsFactors = T)
dt <- rbind(dt_train[,-132], dt_test)
saveRDS(dt, "dt.RDS")
id_all <- dt$id
dt<-dt[,-1]
id_train <- dt_train$id
id_test <- dt_test$id






set.seed(0)
index_10 <- sample(c(1:nrow(dt_train)), 0.1*nrow(dt_train))
train10 <- dt_train[index_10,]
