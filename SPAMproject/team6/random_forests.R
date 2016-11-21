library(kernlab)
library(tree)
library(VIM)
library(mice) #Load the multivariate imputation by chained equations library.


data(spam)
help(spam)
md.pattern(spam) #Can also view this information from a data perspective.
aggr(spam)

attach(spam)


##################################
#####Bagging & Random Forests#####
##################################
library(randomForest)


#Splitting the data into training and test sets by an 70% - 30% split.
set.seed(0)
train = sample(1:nrow(spam), 7*nrow(spam)/10) #Training indices.
spam.test = spam[-train, ] #Test dataset.
type.test = type[-train] #Test response.

#Fitting an initial random forest to the training subset.
set.seed(0)
email = randomForest(type ~ ., data = spam, subset = train, importance = TRUE)
email


#The MSE and percent variance explained are based on out-of-bag estimates,
#yielding unbiased error estimates. The model reports that mtry = 4, which is
#the number of variables randomly chosen at each split. Since we have 13 overall
#variables, we could try all 13 possible values of mtry. We will do so, record
#the results, and make a plot.

#Varying the number of variables used at each step of the random forest procedure.
set.seed(0)
oob.err = numeric(57)
for (mtry in 1:57) {
  fit = randomForest(type ~ ., data = spam[train, ], mtry = mtry)
  oob.err[mtry] = fit$err.rate[500]
  cat("We're performing iteration", mtry, "\n")
}

#Visualizing the OOB error.
plot(1:57, oob.err, pch = 16, type = "b",
     xlab = "Variables Considered at Each Split",
     ylab = "OOB Mean Squared Error",
     main = "Random Forest OOB Error Rates\nby # of Variables")

#Can visualize a variable importance plot.
importance(email)
varImpPlot(email)

min.mtry = 8
set.seed(0)
email.total = randomForest(type ~ ., data = spam, mtry = min.mtry, subset = train, importance = TRUE)


#Ftting and visualizing a classification tree to the training data.
plot(email.total)
text(email.total, pretty = 0)
summary(email.total)
email.total

importance(email.total)
varImpPlot(email.total)
#Using the trained decision tree to classify the test data.
tree.pred = predict(email.total, spam.test, type = "class")
tree.pred

#Assessing the accuracy of the overall tree by constructing a confusion matrix.
table(tree.pred, spam.test$type)
(50 + 27)/(807 + 497 + 50 + 27)
