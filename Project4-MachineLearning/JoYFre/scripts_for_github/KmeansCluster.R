dm_train <- readRDS("dm_train.RDS")
dm_test <- readRDS("dm_test.RDS")
dm_train_kmeans <- as.data.frame(dm_train)
dm_test_kmeans <- as.data.frame(dm_test)
#names(dm_train_kmeans)
set.seed(123)
test_idx <- sample(1:nrow(dm_test_kmeans), 0.01*nrow(dm_test_kmeans))
set.seed(123)
train_idx <- sample(1:nrow(dm_train_kmeans), 0.01*nrow(dm_train_kmeans))
dm_train_kmeans_1 <- dm_train_kmeans[train_idx,]
dm_train_kmeans_1 <- scale(dm_train_kmeans_1)
dm_test_kmeans_1 <- dm_test_kmeans[test_idx,]
dm_test_kmeans_1 <- scale(dm_test_kmeans_1)
wss = function(data, nc = 15, seed = 0) {
    wss = (nrow(data) - 1) * sum(apply(data, 2, var))
    for (i in 2:nc) {
        set.seed(seed)
        wss[i] = sum(kmeans(data, centers = i, iter.max = 100, nstart = 100)$withinss)
    }
    return(wss)
}
Ktune_train<-wss(dm_train_kmeans_1,20)
Ktune_test<-wss(dm_test_kmeans_1,20)
par(mfrow = c(1, 2))
plot(1:20, Ktune_train, type = "b", col ="red",
     xlab = "Number of Clusters",
     ylab = "Within-Cluster Variance",
     main = "Scree Plot for the K-Means Procedure\n Training Dataset")
plot(1:20, Ktune_test, type = "b", col = "blue",
     xlab = "Number of Clusters",
     ylab = "Within-Cluster Variance",
     main = "Scree Plot for the K-Means Procedure\n Testing Dataset")
