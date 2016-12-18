# install.packages("caret")
# install.packages("mlbench")
library(caret)
library(mlbench)
library(Hmisc)
library(doMC)
registerDoMC(cores = 6)
##Reading the dataset
all.train <- read.csv("train.csv", row.names = "id")
all.test <- read.csv("test.csv", row.names = "id")

#make new train to combine into single model to split later into train/test
all.train2 = all.train
all.train2$loss = NULL
all.test2 = rbind(all.test, all.train2)


##Converting categories to numeric
#this is done by first splitting the binary level, multi-level, and 
#continuous variables
#colnames(all.train)
bin.train <- all.test2[,1:72]
cat.train <- all.test2[,73:116]
cont.train <- all.test2[,117:130]
##Combine levels
#combining multiple levels using combine.levels
#minimum 5%
#unique(bin.train$cat7)
# table(cat.train$cat100)
# unique(combine.levels(cat.train$cat100))
test <- sapply(cat.train, combine.levels)
test <- as.data.frame(test)
# unique(test$cat100)
# table(test$cat100)
str(test)
#cbind binary and reduced categorical levels
comb.train <- cbind(bin.train, test)
##Dummify all factor variables 
dmy <- dummyVars(" ~ .", data = comb.train, fullRank=T)
test <- as.data.frame(predict(dmy, newdata = comb.train))
dim(test)
###writing to file
#write.csv(test, "comb_dum_train.csv")
##Combine dummified with cont vars
all.cd.train <- cbind(test, cont.train)
dim(all.cd.train)

#split dataset into new train and new test with combine
new.all.cd.test = all.cd.train[1:125546,]
new.all.cd.train = all.cd.train[125547:313864,]
#verify index checked
#head(new.all.cd.test)
#head(new.all.cd.train)
#head(all.test)
#head(all.train)

#log transformation
#all.cd.train$loss <- log(all.cd.train$loss + 200)

#add log loss values to train set 
new.all.cd.train$loss = log(all.train$loss +200)

#make new csv for easy access later
#write.csv(new.all.cd.train, "new_all_cd_train.csv")
#write.csv(new.all.cd.test, "new_all_cd_test.csv")

new.all.cd.test = read.csv("new_all_cd_test.csv")
new.all.cd.train = read.csv("new_all_cd_train.csv")
new.all.cd.train$X = NULL #in case you finished the preprocessing and want to start from the read.csv after writing it into a csv for quick future use
new.all.cd.test$X = NULL #in case you finished the preprocessing and want to start from the read.csv after writing it into a csv for quick future use
