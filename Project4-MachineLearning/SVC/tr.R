###
###
library(ggplot2)
library(gridExtra)
library(dplyr)
library(corrplot)
library(caret)
library(readr) 


train = read.csv("~/proj4/train.csv")

### EDA
head(train)
names(train)

dim(train)
## No missing values in continuous variables
## No negative values are presest
## Can use chi2
## categorical variables 2:117 ->   115 categ. variables
## continuous  variables 118:132 -> 15  cont.  variables
## summary on contin. var
summary(train[c(118:132)])

sapply(train[c(118:132)], sd)
cor(train[c(118:132)])

contd = train[c(118:132)]
par(mfrow = c(7, 2))
nm = names(contd)
layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE))

## visualize all the continuous attributes
##
p <- ggplot(contd$cont1, aes(y=contd$cont1))
p + geom_violin()

###### Cluster & PCA ##########

contIdx <- grep( 'cont', names(train) )
contInput <- unique(train[,contIdx])
## why choose 2 and 20 ?

minClusters <- 2
maxClusters <- 20
clustersNum <- minClusters:maxClusters
ratioSs <- rep(0, maxClusters-minClusters+1)
clusters <-matrix(nrow = nrow(contInput), ncol =  maxClusters-minClusters+1)

for( i in minClusters:maxClusters ){
  cl <- kmeans(contInput,i)
  ratioSs[i-minClusters+1] <- cl$tot.withinss / cl$totss
  clusters[,i-minClusters+1] <- cl$cluster
}
ggplot( as.data.frame(cbind(clustersNum, ratioSs)), aes(x=clustersNum, y=ratioSs)) +
  geom_line() +
  theme_light() +
  xlab("Number of clusters") +
  ylab("Total within-cluster Variance / Total Variance")

# Use PCA to reduce dimensionality
pcaOut <- princomp(contInput)$scores[,1:3]
summary(pcaOut)
loadings(pcaOut)
plot(pcaOut)
biplot(pcaOut)

pcaOut <-as.data.frame(princomp(contInput)$scores[,1:3])

gp <- list()

for( i in 1:9){
  g <- ggplot(data = pcaOut, aes(x=Comp.1, y=Comp.2)) +
    geom_point(colour=as.factor(clusters[,i]), shape=as.factor(clusters[,i])) +
    theme_light() +
    xlab("") +
    ylab("") +
    ggtitle( paste("Clusters:", i+minClusters-1, "Ratio:", ratioSs[i]) )
  gp <- c(gp, list(g))
}

do.call("grid.arrange", c(gp, ncol=3))



for (i in nm) {
  plot(nm[i])
}
## cannot have log 0 so shifts by 1, reduce skewness
## loss is normally distributed
grid.arrange(
  ggplot(train) + geom_histogram(aes(loss), bins = 50),
  ggplot(train) + geom_histogram(aes(log(loss + 1)), bins = 50),
  ncol = 2)



corrs <- cor(train %>% select(contains("cont")), method = "pearson")
#corrplot.mixed(corrs, upper = "square", order="hclust")
corrplot(corrs, method = "number")


## print out correlations above .5
corA = which(corrs > .5, arr.ind = TRUE)
for (i in 1:nrow(corA)) {
  if (corA[i,1] == corA[i,2])
    next;
  cat(sep ="", "cont", corA[i,2], " ", "cont", corA[i,1], "\t", formatC(corrs[corA[i,1], corA[i,2]], width=5), '\n')
}
## can plot other relationships as well
## plot the highly correlated
plot(contd$cont11, contd$cont12, main="Scatterplot cont12 vs. cont11", 
     xlab="cont11", ylab="cont12", pch=19)
plot(contd$cont1, contd$cont9, main="Scatterplot cont1 vs. cont9", 
     xlab="cont1", ylab="cont9", pch=19)
plot(contd$cont6, contd$cont10, main="Scatterplot cont6 vs. cont10", 
     xlab="cont6", ylab="cont10", pch=19)

## plot or put in table unique values of categorical
table(train$cat112)
table(train$cat111)
table(train$cat110)
table(train$cat109)
table(train$cat108)
barplot(train$cat108, names.arg=levels(train$cat108),col=c(rainbow(length(levels(train$cat108)))),cex.names=0.5,
        xlab="abc", ylab="cat108",
        main="count of cat108")

counts <- table(train$cat2)
dcount = data.frame(counts)
barplot(counts, main="Cat2Distribution", 
        xlab="cat2")
counts <- table(train$cat3)
barplot(counts, main="Cat3Distribution", 
        xlab="cat3")

# Repeat first example with new order


## create subset with cat112 == "E"
train_e <- train %>% filter(cat112 == "E") %>% select(-cat112, -id)


### perform on full data set
dm_train <- model.matrix(loss ~ ., data = train)
head(dm_train, n = 4)
## why? apply nearZeroVar with the default parameters
# (freqCut = 95/5) to exclude “near zero-variance” predictors
preProc <- preProcess(train,
                      method = "nzv")
preProc