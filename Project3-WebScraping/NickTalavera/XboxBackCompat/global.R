# shinyHome
# Real Estate Analytics and Forecasting
# Nick Talavera
# Date: October 25, 2016

# global.R
rm(list = setdiff(ls(), lsf.str()))
################################################################################
#                                   FUNCTIONS                                 #
################################################################################
usePackage <- function(p) {
  if (!is.element(p, installed.packages()[,1]))
    install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}

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
###############################################################################
#                         LOAD PACKAGES AND MODULES                          #
###############################################################################
#require(rCharts)
#options(RCHART_LIB = 'polycharts')
usePackage("ggplot2")
usePackage("plotly")
usePackage("rCharts")
usePackage("shiny")
usePackage("shinydashboard")
usePackage("TTR")
usePackage("lettercase")
usePackage("dplyr")
usePackage("scales")
usePackage("RColorBrewer")
usePackage("MASS")
usePackage("car")
usePackage("rmarkdown")
usePackage("flexdashboard")
################################################################################
#                             GLOBAL VARIABLES                                 #
################################################################################

if (dir.exists('/home/bc7_ntalavera/Dropbox/Data Science/Data Files/Xbox Back Compat Data')) {
  dataLocale = '/home/bc7_ntalavera/Dropbox/Data Science/Data Files/Xbox Back Compat Data' 
} else if (dir.exists('/Volumes/SDExpansion/Data Files/bootcamp007_project/Project3-WebScraping/NickTalavera/XboxBackCompat')) {
  setwd('/Volumes/SDExpansion/Data Files/bootcamp007_project/Project3-WebScraping/NickTalavera/XboxBackCompat')
  dataLocale = '../Data/'
}  else if (dir.exists('/home/bc7_ntalavera/Data/Xbox')) {
  dataLocale = '/home/bc7_ntalavera/Data/Xbox'
}
dataUltKNN  = read.csv(paste0(dataLocale,'dataUltKNN.csv'), stringsAsFactors = TRUE)
dataUlt = read.csv(paste0(dataLocale,'dataUlt.csv'), stringsAsFactors = TRUE)
dataUltKNN$X = NULL
dataUltKNN$gameName = as.character(dataUltKNN$gameName)
dataUltKNN$releaseDate = as.Date(dataUltKNN$releaseDate)
dataUlt$X = NULL
dataUlt$gameName = as.character(dataUltKNN$gameName)
dataUlt$releaseDate = as.Date(dataUltKNN$releaseDate)
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
model.empty = glm(isBCCompatible ~ -isBCCompatible -gameName -features -isOnUserVoice, family = "binomial", data = dataUltKNN) #The model with an intercept ONLY.
glogit.overall = glm(isBCCompatible ~ . -isBCCompatible -gameName -features -isOnUserVoice, family = "binomial", data = dataUltKNN)
scope = list(lower = formula(model.empty), upper = formula(glogit.overall))
# forwardAIC = step(model.empty, scope, direction = "forward", k = 2)
# glogit.optimizedFoAIC = glm(forwardAIC$formula, family = "binomial", data = dataUltKNN)
glogit.optimizedFoAIC = glm(isBCCompatible ~ gamesOnDemandorArcade + reviewScorePro + releaseDate +
                              xbox360Rating + isOnXboxOne + isConsoleExclusive + isAvailableToPurchaseDigitally + 
                              isKinectRequired + isMetacritic + DLavatarItems + votes + 
                              price + numberOfReviews + DLgameAddons + isInProgress + DLgameVideos, family = "binomial", data = dataUltKNN)
summary(glogit.optimizedFoAIC)
class(glogit.optimizedFoAIC)
# #Residual plot for logistic regression with an added loess smoother; we would
# #hope that, on average, the residual values are 0.
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
xboxData = cbind(dataUlt,bcGuess = round(glogit.optimizedFoAIC$fitted.values), percentProb = round(glogit.optimizedFoAIC$fitted.values,3)*100)
xboxData = moveMe(data = xboxData, c("gameName", "isBCCompatible", "bcGuess", "percentProb"), "first")
# #Comparing the true values to the predicted values:
table(truth = dataUltKNN$isBCCompatible, prediction = admitted.predicted)/nrow(dataUltKNN)
# #It seems like this model made a lot of mistakes (116 out of 400)! This is quite
# #dreadful in this case. Let's do a little bit more exploring. We never looked at
# #the overall test of deviance:
pchisq(glogit.optimizedFoAIC$deviance, glogit.optimizedFoAIC$df.residual, lower.tail = FALSE)

# #The p-value for the overall test of deviance is <.05, indicating that this model
# #is not a good overall fit!
# 
# #What about checking the McFadden's pseudo R^2 based on the deviance?
1 - glogit.optimizedFoAIC$deviance/glogit.optimizedFoAIC$null.deviance

# #Only about 8.29% of the variability in admission appears to be explained by
# #the predictors in our model; while the model is valid, it seems as though it
# #isn't extremely informative.
# 
# #What have we found out? The overall model we created doesn't give us much
# #predictive power in determining whether a student will be admitted to
# #graduate school.
table(dataUltKNN$isBCCompatible) #Our data contains 273 unadmitted students and 127
# #admitted students.
table(admitted.predicted) #The model we created predicts that 351 students will
# #not be admitted, and only 49 will be admitted.
table(truth = dataUltKNN$isBCCompatible, prediction = admitted.predicted)
# 
# glogit.publisherOnly = glm(isBCCompatible ~ as.factor(publisher), family = "binomial", data = dataUltKNN)
# summary(glogit.publisherOnly)
# glogit.publisherOnly$fitted.values*100

# sapply(xboxData, class) #Looking at the variable classes.
includeMarkdown("../Explanation.Rmd")
