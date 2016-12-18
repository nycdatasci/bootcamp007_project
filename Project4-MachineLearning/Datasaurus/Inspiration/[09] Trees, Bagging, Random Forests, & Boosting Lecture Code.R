######################################################################
######################################################################
#####[09] Trees, Bagging, Random Forests, & Boosting Lecture Code#####
######################################################################
######################################################################



##############################
#####Classification Trees#####
##############################
#Loading the tree library for fitting classification and regression trees.
library(tree)

#Loading the ISLR library in order to use the Carseats dataset.
library(ISLR)

#Making data manipulation easier.
help(Carseats)
attach(Carseats)

#Looking at the variable of interest, Sales.
hist(Sales)
summary(Sales)

#Creating a binary categorical variable High based on the continuous Sales
#variable and adding it to the original data frame.
High = ifelse(Sales <= 8, "No", "Yes")
Carseats = data.frame(Carseats, High)

#Fit a tree to the data; note that we are excluding Sales from the formula.
tree.carseats = tree(High ~ . - Sales, split = "gini", data = Carseats)
summary(tree.carseats)

#The output shows the variables actually used within the tree, the number of
#terminal nodes, the residual mean deviance based on the Gini index, and
#the misclassification error rate.

#Plotting the classification tree.
plot(tree.carseats)
text(tree.carseats, pretty = 0) #Yields category names instead of dummy variables.

#Detailed information for the splits of the classification tree.
tree.carseats

#The output shows the variables used at each node, the split rule, the number
#of observations at each node, the deviance based on the Gini index, the
#majority class value based on the observations in the node, and the associated
#probabilities of class membership at each node. Terminal nodes are denoted
#by asterisks.

#Splitting the data into training and test sets by an 70% - 30% split.
set.seed(0)
train = sample(1:nrow(Carseats), 7*nrow(Carseats)/10) #Training indices.
Carseats.test = Carseats[-train, ] #Test dataset.
High.test = High[-train] #Test response.

#Ftting and visualizing a classification tree to the training data.
tree.carseats = tree(High ~ . - Sales, data = Carseats, subset = train)
plot(tree.carseats)
text(tree.carseats, pretty = 0)
summary(tree.carseats)
tree.carseats

#Using the trained decision tree to classify the test data.
tree.pred = predict(tree.carseats, Carseats.test, type = "class")
tree.pred

#Assessing the accuracy of the overall tree by constructing a confusion matrix.
table(tree.pred, High.test)
(60 + 42)/120

#Performing cross-validation in order to decide how many splits to prune; using
#misclassification as the basis for pruning.
set.seed(0)
cv.carseats = cv.tree(tree.carseats, FUN = prune.misclass)

#Inspecting the elements of the cv.tree() object.
names(cv.carseats)
cv.carseats

#Size indicates the number of terminal nodes. Deviance is the criterion we
#specify; in this case it is the misclassification rate. K is analogous to the
#cost complexity tuning parameter alpha. Method indicates the specified criterion.

#Visually inspecting the results of the cross-validation by considering tree
#complexity.
par(mfrow = c(1, 2))
plot(cv.carseats$size, cv.carseats$dev, type = "b",
     xlab = "Terminal Nodes", ylab = "Misclassified Observations")
plot(cv.carseats$k, cv.carseats$dev, type  = "b",
     xlab = "Alpha", ylab = "Misclassified Observations")

#Pruning the overall tree to have 4 terminal nodes; choose the best tree with
#4 terminal nodes based on cost complexity pruning.
par(mfrow = c(1, 1))
prune.carseats = prune.misclass(tree.carseats, best = 4)
plot(prune.carseats)
text(prune.carseats, pretty = 0)

#Assessing the accuracy of the pruned tree with 4 terminal nodes by constructing
#a confusion matrix.
tree.pred = predict(prune.carseats, Carseats.test, type = "class")
table(tree.pred, High.test)
(53 + 33)/120

#Originally we had 25 terminal nodes and an accuracy of 85%; now, there are
#only 4 terminal nodes with an accuracy of about 71.67%.



##########################
#####Regression Trees#####
##########################
#Inspecting the housing values in the suburbs of Boston.
library(MASS)
help(Boston)

#Creating a training set on 70% of the data.
set.seed(0)
train = sample(1:nrow(Boston), 7*nrow(Boston)/10)

#Training the tree to predict the median value of owner-occupied homes (in $1k).
tree.boston = tree(medv ~ ., Boston, subset = train)
summary(tree.boston)

#Visually inspecting the regression tree.
plot(tree.boston)
text(tree.boston, pretty = 0)

#Performing cross-validation.
set.seed(0)
cv.boston = cv.tree(tree.boston)
par(mfrow = c(1, 2))
plot(cv.boston$size, cv.boston$dev, type = "b",
     xlab = "Terminal Nodes", ylab = "RSS")
plot(cv.boston$k, cv.boston$dev, type  = "b",
     xlab = "Alpha", ylab = "RSS")

#Pruning the tree to have 4 terminal nodes.
prune.boston = prune.tree(tree.boston, best = 4)
par(mfrow = c(1, 1))
plot(prune.boston)
text(prune.boston, pretty = 0)

#Calculating and assessing the MSE of the test data on the overall tree.
yhat = predict(tree.boston, newdata = Boston[-train, ])
yhat
boston.test = Boston[-train, "medv"]
boston.test
plot(yhat, boston.test)
abline(0, 1)
mean((yhat - boston.test)^2)

#Calculating and assessing the MSE of the test data on the pruned tree.
yhat = predict(prune.boston, newdata = Boston[-train, ])
yhat
plot(yhat, boston.test)
abline(0, 1)
mean((yhat - boston.test)^2)



##################################
#####Bagging & Random Forests#####
##################################
library(randomForest)

#Fitting an initial random forest to the training subset.
set.seed(0)
rf.boston = randomForest(medv ~ ., data = Boston, subset = train, importance = TRUE)
rf.boston

#The MSE and percent variance explained are based on out-of-bag estimates,
#yielding unbiased error estimates. The model reports that mtry = 4, which is
#the number of variables randomly chosen at each split. Since we have 13 overall
#variables, we could try all 13 possible values of mtry. We will do so, record
#the results, and make a plot.

#Varying the number of variables used at each step of the random forest procedure.
set.seed(0)
oob.err = numeric(13)
for (mtry in 1:13) {
  fit = randomForest(medv ~ ., data = Boston[train, ], mtry = mtry)
  oob.err[mtry] = fit$mse[500]
  cat("We're performing iteration", mtry, "\n")
}

#Visualizing the OOB error.
plot(1:13, oob.err, pch = 16, type = "b",
     xlab = "Variables Considered at Each Split",
     ylab = "OOB Mean Squared Error",
     main = "Random Forest OOB Error Rates\nby # of Variables")

#Can visualize a variable importance plot.
importance(rf.boston)
varImpPlot(rf.boston)



##################
#####Boosting#####
##################
library(gbm)

#Fitting 10,000 trees with a depth of 4.
set.seed(0)
boost.boston = gbm(medv ~ ., data = Boston[train, ],
                   distribution = "gaussian",
                   n.trees = 10000,
                   interaction.depth = 4)

#Inspecting the relative influence.
par(mfrow = c(1, 1))
summary(boost.boston)

#Partial dependence plots for specific variables; these plots illustrate the
#marginal effect of the selected variables on the response after integrating
#out the other variables.
par(mfrow = c(1, 2))
plot(boost.boston, i = "rm")
plot(boost.boston, i = "lstat")

#As the number of higher prooportion of lower status people in the suburb, the
#lower the value of the housing prices. As the number of rooms increases, so
#does the expected house price.

#Let’s make a prediction on the test set. With boosting, the number of trees is
#a tuning parameter; having too many can cause overfitting. In general, we should
#use cross validation to select the number of trees. Instead, we will compute the
#test error as a function of the number of trees and make a plot for illustrative
#purposes.
n.trees = seq(from = 100, to = 10000, by = 100)
predmat = predict(boost.boston, newdata = Boston[-train, ], n.trees = n.trees)

#Produces 100 different predictions for each of the 152 observations in our
#test set.
dim(predmat)

#Calculating the boosted errors.
par(mfrow = c(1, 1))
berr = with(Boston[-train, ], apply((predmat - medv)^2, 2, mean))
plot(n.trees, berr, pch = 16,
     ylab = "Mean Squared Error",
     xlab = "# Trees",
     main = "Boosting Test Error")

#Include the best OOB error from the random forest.
abline(h = min(oob.err), col = "red")

#Increasing the shrinkage parameter; a higher proportion of the errors are
#carried over.
set.seed(0)
boost.boston2 = gbm(medv ~ ., data = Boston[train, ],
                    distribution = "gaussian",
                    n.trees = 10000,
                    interaction.depth = 4,
                    shrinkage = 0.1)
predmat2 = predict(boost.boston2, newdata = Boston[-train, ], n.trees = n.trees)

berr2 = with(Boston[-train, ], apply((predmat2 - medv)^2, 2, mean))
plot(n.trees, berr2, pch = 16,
     ylab = "Mean Squared Error",
     xlab = "# Trees",
     main = "Boosting Test Error")