##########################################################
##########################################################
#####[02] Missingness, Imputation, & KNN Lecture Code#####
##########################################################
##########################################################



##################################
#####Visualizing Missing Data#####
##################################
library(VIM) #For the visualization and imputation of missing values.

help(sleep) #Inspecting the mammal sleep dataset.
sleep

summary(sleep) #Summary information for the sleep dataset.
sapply(sleep, sd) #Standard deviations for the sleep dataset; any issues?

aggr(sleep) #A graphical interpretation of the missing values and their
            #combinations within the dataset.

library(mice) #Load the multivariate imputation by chained equations library.
md.pattern(sleep) #Can also view this information from a data perspective.



###############################
#####Mean Value Imputation#####
###############################
#Creating a dataset that has missing values.
missing.data = data.frame(x1 = 1:20, x2 = c(1:10, rep(NA, 10)))
missing.data

mean(missing.data$x2, na.rm = TRUE) #Mean of x2 prior to imputation.
sd(missing.data$x2, na.rm = TRUE) #Standard deviation of x2 prior to imputation.
cor(missing.data, use = "complete.obs") #Correlation prior to imputation.

#Mean value imputation method 1.
missing.data$x2[is.na(missing.data$x2)] = mean(missing.data$x2, na.rm=TRUE)
missing.data

#Mean value imputation method 2.
missing.data = data.frame(x1 = 1:20, x2 = c(1:10, rep(NA, 10))) #Recreating dataset.
missing.data = transform(missing.data, x2 = ifelse(is.na(x2),
                                                   mean(x2, na.rm=TRUE),
                                                   x2))
missing.data

#Mean value imputation method 3.
library(Hmisc) #Load the Harrell miscellaneous library.
missing.data = data.frame(x1 = 1:20, x2 = c(1:10, rep(NA, 10))) #Recreating dataset.
imputed.x2 = impute(missing.data$x2, mean) #Specifically calling the x2 variable.
imputed.x2

summary(imputed.x2) #Summary information for the imputed variable.
is.imputed(imputed.x2) #Boolean vector indicating imputed values.

missing.data$x2 = imputed.x2 #Replacing the old vector.

mean(missing.data$x2) #Mean of x2 after imputation.
sd(missing.data$x2) #Standard deviation of x2 after imputation.
cor(missing.data, use = "complete.obs") #Correlation afterto imputation.

plot(missing.data) #What are some potential problems with mean value imputation?



##################################
#####Simple Random Imputation#####
##################################
#Recreating a dataset that has missing values.
missing.data = data.frame(x1 = 1:20, x2 = c(1:10, rep(NA, 10)))
missing.data

mean(missing.data$x2, na.rm = TRUE) #Mean of x2 prior to imputation.
sd(missing.data$x2, na.rm = TRUE) #Standard deviation of x2 prior to imputation.
cor(missing.data, use = "complete.obs") #Correlation prior to imputation.

set.seed(0)
imputed.x2 = impute(missing.data$x2, "random") #Simple random imputation using the
                                           #impute() function from the Hmisc package.
imputed.x2

summary(imputed.x2) #Summary information for the imputed variable.
is.imputed(imputed.x2) #Boolean vector indicating imputed values.

missing.data$x2 = imputed.x2 #Replacing the old vector.

mean(missing.data$x2) #Mean of x2 after imputation.
sd(missing.data$x2) #Standard deviation of x2 after imputation.
cor(missing.data, use = "complete.obs") #Correlation afterto imputation.

plot(missing.data) #What are some potential problems with mean value imputation?



#############################
#####K-Nearest Neighbors#####
#############################
#Recreating a dataset that has missing values.
missing.data = data.frame(x1 = 1:20, x2 = c(1:10, rep(NA, 10)))
missing.data

imputed.1nn = kNN(missing.data, k = 1) #Imputing using 1NN.
imputed.5nn = kNN(missing.data, k = 5) #Imputing using 5NN.
imputed.9nn = kNN(missing.data, k = 9) #Imputing using 9NN.

imputed.1nn #Inspecting the imputed values of each of the methods;
imputed.5nn #what is going on here? Given our dataset, should we
imputed.9nn #expect these results?



#K-Nearest Neighbors regression on the sleep dataset.
sqrt(nrow(sleep)) #Determining K for the sleep dataset.

sleep.imputed8NN = kNN(sleep, k = 8) #Using 8 nearest neighbors.
sleep.imputed8NN

summary(sleep) #Summary information for the original sleep dataset.
summary(sleep.imputed8NN[, 1:10]) #Summary information for the imputed sleep dataset.



#K-Nearest Neighbors classification on the iris dataset.
help(iris) #Inspecting the iris measurement dataset.
iris

iris.example = iris[, c(1, 2, 5)] #For illustration purposes, pulling only the
                                  #sepal measurements and the flower species.

#Throwing some small amount of noise on top of the data for illustration
#purposes; some observations are on top of each other.
set.seed(0)
iris.example$Sepal.Length = jitter(iris.example$Sepal.Length, factor = .5)
iris.example$Sepal.Width = jitter(iris.example$Sepal.Width, factor= .5)

col.vec = c(rep("red", 50), #Creating a color vector for plotting purposes.
            rep("green", 50),
            rep("blue", 50))

plot(iris.example$Sepal.Length, iris.example$Sepal.Width,
     col = col.vec, pch = 16,
     main = "Sepal Measurements of Iris Data")
legend("topleft", c("Setosa", "Versicolor", "Virginica"),
       pch = 16, col = c("red", "green", "blue"), cex = .75)

missing.vector = c(41:50, 91:100, 141:150) #Inducing missing values on the Species
iris.example$Species[missing.vector] = NA  #vector for each category.
iris.example

col.vec[missing.vector] = "purple" #Creating a new color vector to
                                   #mark the missing values.

plot(iris.example$Sepal.Length, iris.example$Sepal.Width,
     col = col.vec, pch = 16,
     main = "Sepal Measurements of Iris Data")
legend("topleft", c("Setosa", "Versicolor", "Virginica", "NA"),
       pch = 16, col = c("red", "green", "blue", "purple"), cex = .75)

#Inspecting the Voronoi tesselation for the complete observations in the iris
#dataset.
library(deldir) #Load the Delaunay triangulation and Dirichelet tesselation library.
info = deldir(iris.example$Sepal.Length[-missing.vector],
              iris.example$Sepal.Width[-missing.vector])
plot.tile.list(tile.list(info),
               fillcol = col.vec[-missing.vector],
               main = "Iris Voronoi Tessellation\nDecision Boundaries")

#Adding the observations that are missing species information.
points(iris.example$Sepal.Length[missing.vector],
       iris.example$Sepal.Width[missing.vector],
       pch = 16, col = "white")
points(iris.example$Sepal.Length[missing.vector],
       iris.example$Sepal.Width[missing.vector],
       pch = "?", cex = .66)

#Conducting a 1NN classification imputation.
iris.imputed1NN = kNN(iris.example, k = 1)

#Assessing the results by comparing to the truth known by the original dataset.
table(iris$Species, iris.imputed1NN$Species)

#Conducting a 12NN classification imputation based on the square root of n.
sqrt(nrow(iris.example))
iris.imputed12NN = kNN(iris.example, k = 12)

#Assessing the results by comparing to the truth known by the original dataset.
table(iris$Species, iris.imputed12NN$Species)



##################################################
#####Using Minkowski Distance Measures in KNN#####
##################################################
library(kknn) #Load the weighted knn library.

#Separating the complete and missing observations for use in the kknn() function.
complete = iris.example[-missing.vector, ]
missing = iris.example[missing.vector, -3]

#Distance corresponds to the Minkowski power.
iris.euclidean = kknn(Species ~ ., complete, missing, k = 12, distance = 2)
summary(iris.euclidean)

iris.manhattan = kknn(Species ~ ., complete, missing, k = 12, distance = 1)
summary(iris.manhattan)