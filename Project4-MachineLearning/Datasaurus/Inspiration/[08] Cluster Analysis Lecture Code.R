############################################
############################################
#####[08] Cluster Analysis Lecture Code#####
############################################
############################################



###########################
#####Tools for K-Means#####
###########################
#Retrieving the numerical measures of the iris dataset.
iris.meas = iris[, -5]
summary(iris.meas)
sapply(iris.meas, sd)

#Standardizing the variables.
iris.scale = as.data.frame(scale(iris.meas))
summary(iris.scale)
sapply(iris.scale, sd)

#Visualizing the width measurements.
plot(iris.scale$Petal.Width, iris.scale$Sepal.Width,
     xlab = "Petal Width", ylab = "Sepal Width",
     main = "Scaled Iris Data")

#Conducting the K-Means algorithm on the whole dataset.
set.seed(0)
km.iris = kmeans(iris.scale, centers = 3)

#Inspecting the output of the kmeans() function.
km.iris

#Visualizing the results against the truth.
par(mfrow = c(1, 2))
plot(iris.scale$Petal.Width, iris.scale$Sepal.Width,
     xlab = "Petal Width", ylab = "Sepal Width",
     main = "Single K-Means Attempt", col = km.iris$cluster)
plot(iris.scale$Petal.Width, iris.scale$Sepal.Width,
     xlab = "Petal Width", ylab = "Sepal Width",
     main = "True Species", col = iris$Species)

#Plotting the cluster centers over the data.
par(mfrow = c(1, 1))
plot(iris.scale$Petal.Width, iris.scale$Sepal.Width,
     xlab = "Petal Width", ylab = "Sepal Width",
     main = "Single K-Means Attempt", col = km.iris$cluster)
points(km.iris$centers[, 4], km.iris$centers[, 2], pch = 16, col = "blue")

#A function to help determine the number of clusters when we do not have an
#idea ahead of time.
wssplot = function(data, nc = 15, seed = 0) {
  wss = (nrow(data) - 1) * sum(apply(data, 2, var))
  for (i in 2:nc) {
    set.seed(seed)
    wss[i] = sum(kmeans(data, centers = i, iter.max = 100, nstart = 100)$withinss)
  }
  plot(1:nc, wss, type = "b",
       xlab = "Number of Clusters",
       ylab = "Within-Cluster Variance",
       main = "Scree Plot for the K-Means Procedure")
}

#Visualizing the scree plot for the scaled iris data; 3 seems like a plausible
#choice.
wssplot(iris.scale)

#It is important to note the non-determininstic nature of the K-Means algorithm.
#Using the Old Faithful dataset.
faithful.scale = scale(faithful)
summary(faithful.scale)

#Visualizing the scaled data.
par(mfrow = c(1, 1))
plot(faithful.scale)

#Determining the number of clusters.
wssplot(faithful.scale)

#Clearly, by both visual inspection and an analysis of the scree plot, a 2
#cluster solution is the most appropriate; however, let's see what happens if
#we search for a 3 cluster solution.
set.seed(0)
km.faithful1 = kmeans(faithful.scale, centers = 3) #Running the K-means procedure
km.faithful2 = kmeans(faithful.scale, centers = 3) #5 different times, but with
km.faithful3 = kmeans(faithful.scale, centers = 3) #only one convergence of the
km.faithful4 = kmeans(faithful.scale, centers = 3) #algorithm each time.
km.faithful5 = kmeans(faithful.scale, centers = 3)

#Running the algorithm 100 different times and recording the solution with the
#lowest total within-cluster variance.
set.seed(0)
km.faithfulsim = kmeans(faithful.scale, centers = 3, nstart = 100)

#Visually & numerically inspecting the results.
par(mfrow = c(2, 3))
plot(faithful, col = km.faithful1$cluster,
     main = paste("Single K-Means Attempt #1\n WCV: ",
                  round(km.faithful1$tot.withinss, 4)))
plot(faithful, col = km.faithful2$cluster,
     main = paste("Single K-Means Attempt #2\n WCV: ",
                  round(km.faithful2$tot.withinss, 4)))
plot(faithful, col = km.faithful3$cluster,
     main = paste("Single K-Means Attempt #3\n WCV: ",
                  round(km.faithful3$tot.withinss, 4)))
plot(faithful, col = km.faithful4$cluster,
     main = paste("Single K-Means Attempt #4\n WCV: ",
                  round(km.faithful4$tot.withinss, 4)))
plot(faithful, col = km.faithful5$cluster,
     main = paste("Single K-Means Attempt #5\n WCV: ",
                  round(km.faithful5$tot.withinss, 4)))
plot(faithful, col = km.faithfulsim$cluster,
     main = paste("Best K-Means Attempt out of 100\n WCV: ",
                  round(km.faithfulsim$tot.withinss, 4)))



###########################################
#####Tools for Hierarchical Clustering#####
###########################################
library(flexclust) #Loading the flexclust library.
data(nutrient) #Loading the nutrient data.
help(nutrient) #Inspecting the data set; nutrients in meat, fish, and fowel.
nutrient

#Notice that the nutrient columns are in different measurements: calories,
#grams, and milligrams.
summary(nutrient)
sapply(nutrient, sd)

#We should scale the data.
nutrient.scaled = as.data.frame(scale(nutrient))
summary(nutrient.scaled)
sapply(nutrient.scaled, sd)

#We need to calcualte the pairwise distances between observations.
d = dist(nutrient.scaled)

#Using the hclust() function, we define the linkage manner by which we will
#cluster our data.
fit.single = hclust(d, method = "single")
fit.complete = hclust(d, method = "complete")
fit.average = hclust(d, method = "average")

#Creating various dendrograms.
par(mfrow = c(1, 3))
plot(fit.single, hang = -1, main = "Dendrogram of Single Linkage")
plot(fit.complete, hang = -1, main = "Dendrogram of Complete Linkage")
plot(fit.average, hang = -1, main = "Dendrogram of Average Linkage")

#Cut the dendrogram into groups of data.
clusters.average = cutree(fit.average, k = 5)
clusters.average

#Viewing the groups of data.
table(clusters.average)

#Aggregating the original data by the cluster assignments.
aggregate(nutrient, by = list(cluster = clusters.average), median)

#Aggregating the scaled data by the cluster assignments.
aggregate(nutrient.scaled, by = list(cluster = clusters.average), median)

#Visualizing the groups in the dendrogram.
par(mfrow = c(1, 1))
plot(fit.average, hang = -1, main = "Dendrogram of Average Linkage\n5 Clusters")
rect.hclust(fit.average, k = 5)

#-Sardines form their own cluster and are much higher in calcium than the other
# food groups.
#-Beef heart is also a singleton and is high in protein and iron.
#-The clam cluster is low in protein and high in iron.
#-The items in the cluster containing beef roast to simmered pork are high in
# energy and fat.
#-The largest group (from mackerel to bluefish) is relatively low in iron.