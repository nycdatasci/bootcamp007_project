moveMe <- function(data, tomove, where = "last", ba = NULL) {
  temp <- setdiff(names(data), tomove)
  x <- switch(
    where,
    first = data[c(tomove, temp)],
    last = data[c(temp, tomove)],
    before = {
      if (is.null(ba)) stop("must specify ba column")
      if (length(ba) > 1) stop("ba must be a single character string")
      data[append(temp, values = tomove, after = (match(ba, temp)-1))]
    },
    after = {
      if (is.null(ba)) stop("must specify ba column")
      if (length(ba) > 1) stop("ba must be a single character string")
      data[append(temp, values = tomove, after = (match(ba, temp)))]
    })
  x
}

rm(list = setdiff(ls(), lsf.str()))
library(MASS) #The Modern Applied Statistics library.
library(car)
setwd('/Volumes/SDExpansion/Data Files/Xbox Back Compat Data')
dataUltKNN  = read.csv('dataUltKNN.csv', stringsAsFactors = TRUE)
dataUltKNN$X = NULL
dataUltKNN$gameName = as.character(dataUltKNN$gameName)
dataUltKNN$releaseDate = as.Date(dataUltKNN$releaseDate)
head(dataUltKNN)
summary(dataUltKNN) #Looking at the five number summary information.
sapply(dataUltKNN, sd) #Looking at the individual standard deviations.
sapply(dataUltKNN, class) #Looking at the variable classes.
table(dataUltKNN$isBCCompatible)/nrow(dataUltKNN) #Manually calculating the proportions.
table(dataUltKNN$isBCCompatible, dataUltKNN$isKinectSupported) #Checking to see that we have data
#Fitting the logistic regression with all variables; the family parameter
#specifies the error distribution and link function to be used. For logistic
#regression, this is binomial.
# FINDING MODEL
model.empty = glm(isBCCompatible ~ 1, family = "binomial", data = dataUltKNN) #The model with an intercept ONLY.
glogit.overall = glm(isBCCompatible ~ . -isBCCompatible -gameName -features, family = "binomial", data = dataUltKNN)
scope = list(lower = formula(model.empty), upper = formula(glogit.overall))
forwardAIC = step(model.empty, scope, direction = "forward", k = 2)
glogit.optimizedFoAIC = glm(formula = isBCCompatible ~ isOnUserVoice + gamesOnDemandorArcade + 
                              isMetacritic + reviewScorePro + isKinectRequired + isOnXboxOne + 
                              isAvailableToPurchaseDigitally + xbox360Rating + releaseDate + 
                              DLavatarItems + DLgameAddons + isInProgress + hasDemoAvailable + 
                              price, family = "binomial", data = dataUltKNN)
summary(glogit.optimizedFoAIC)
class(glogit.overall)
#Residual plot for logistic regression with an added loess smoother; we would
#hope that, on average, the residual values are 0.
scatter.smooth(glogit.optimizedFoAIC$fit, 
               residuals(glogit.optimizedFoAIC, type = "deviance"),
               lpars = list(col = "red"),
               xlab = "Fitted Probabilities",
               ylab = "Deviance Residual Values",
               main = "Residual Plot for\nLogistic Regression of Admission Data")
abline(h = 0, lty = 2)
influencePlot(glogit.optimizedFoAIC) #Can still inspect the influence plot.
summary(glogit.optimizedFoAIC) #Investigating the overall fit of the model.
exp(glogit.optimizedFoAIC$coefficients)

admitted.predicted = round(glogit.optimizedFoAIC$fitted.values)
modelN = cbind(glogit.optimizedFoAIC$data,bcGuess = round(glogit.optimizedFoAIC$fitted.values), percentProb = round(glogit.optimizedFoAIC$fitted.values,3)*100)
modelN = moveMe(data = modelN, c(gameName, isBCCompatible, BCGuess, percentProb), "first")
#Comparing the true values to the predicted values:
table(truth = dataUltKNN$isBCCompatible, prediction = admitted.predicted)/nrow(dataUltKNN)
#It seems like this model made a lot of mistakes (116 out of 400)! This is quite
#dreadful in this case. Let's do a little bit more exploring. We never looked at
#the overall test of deviance:
pchisq(glogit.optimizedFoAIC$deviance, glogit.optimizedFoAIC$df.residual, lower.tail = FALSE)

#The p-value for the overall test of deviance is <.05, indicating that this model
#is not a good overall fit!

#What about checking the McFadden's pseudo R^2 based on the deviance?
1 - glogit.optimizedFoAIC$deviance/glogit.optimizedFoAIC$null.deviance

#Only about 8.29% of the variability in admission appears to be explained by
#the predictors in our model; while the model is valid, it seems as though it
#isn't extremely informative.

#What have we found out? The overall model we created doesn't give us much
#predictive power in determining whether a student will be admitted to
#graduate school.
table(GradSchools$admit) #Our data contains 273 unadmitted students and 127
#admitted students.
table(admitted.predicted) #The model we created predicts that 351 students will
#not be admitted, and only 49 will be admitted.
table(truth = GradSchools$admit, prediction = admitted.predicted)

glogit.publisherOnly = glm(isBCCompatible ~ publisher, family = "binomial", data = dataUltKNN)
summary(glogit.publisherOnly)
glogit.publisherOnly$fitted.values*100
