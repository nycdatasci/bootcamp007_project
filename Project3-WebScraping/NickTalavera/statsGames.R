rm(list = setdiff(ls(), lsf.str()))
library(MASS) #The Modern Applied Statistics library.
library(car)
setwd('/Volumes/SDExpansion/Data Files/Xbox Back Compat Data')
dataUltKNN  = read.csv('dataUltKNN.csv', stringsAsFactors = TRUE)
dataUltKNN$X = NULL
dataUltKNN$gameName = as.character(dataUltKNN$gameName)
dataUltKNN$releaseDate = as.Date(dataUltKNN$releaseDate)
# model.empty = lm(isBCCompatible ~ 1, data = dataUltKNN) #The model with an intercept ONLY.
# model.full = lm(isBCCompatible ~ . -genre -developer -features -isBCCompatible -gameName, data = dataUltKNN) #The model with ALL variables.
# summary(model.full)
# scope = list(lower = formula(model.empty), upper = formula(model.full))
# 
# forwardAIC = step(model.full, scope, direction = "forward", k = sqrt(nrow(dataUltKNN)))
# summary(forwardAIC)
# plot(forwardAIC)
# influencePlot(forwardAIC)
# vif(forwardAIC)
# avPlots(forwardAIC)
# 
# confint(forwardAIC)
# notBCYet = dataUltKNN[dataUltKNN$isBCCompatible == FALSE,]
# cPredict = predict(forwardAIC, notBCYet, interval = "confidence") 
# pPredict = predict(forwardAIC, notBCYet, interval = "prediction")





head(dataUltKNN)

#Variables in the dataset:
#-Admit: A binary variable indicating whether or not a student was admitted to
#        the graduate school.
#-GRE: A continuous variable indicating a student's score on the GRE.
#-GPA: A contunuous variable indicating a student's undergraduate grade point
#      average.
#-Rank: A categorical variable indicating the level of prestige of a school; 1
#       indicates the highest prestige, 4 indicates the lowest prestige.

summary(dataUltKNN) #Looking at the five number summary information.
sapply(dataUltKNN, sd) #Looking at the individual standard deviations.
sapply(dataUltKNN, class) #Looking at the variable classes.

#Notice that the admit variable is being treated as continuous at the moment. What
#does the mean of the admit variable indicate in this scenario? Approximately
#31.75% of the applications in our dataset received acceptances.
table(dataUltKNN$isBCCompatible)/nrow(dataUltKNN) #Manually calculating the proportions.

table(dataUltKNN$isBCCompatible, dataUltKNN$isKinectSupported) #Checking to see that we have data
#available in all combinations of
#the categorical variables.

#Fitting the logistic regression with all variables; the family parameter
#specifies the error distribution and link function to be used. For logistic
#regression, this is binomial.
logit.overall = glm(isBCCompatible ~ . -isBCCompatible -gameName -developer -features, family = "binomial", data = dataUltKNN)

#Residual plot for logistic regression with an added loess smoother; we would
#hope that, on average, the residual values are 0.
scatter.smooth(logit.overall$fit, 
               residuals(logit.overall, type = "deviance"),
               lpars = list(col = "red"),
               xlab = "Fitted Probabilities",
               ylab = "Deviance Residual Values",
               main = "Residual Plot for\nLogistic Regression of Admission Data")
abline(h = 0, lty = 2)
influencePlot(logit.overall) #Can still inspect the influence plot.
summary(logit.overall) #Investigating the overall fit of the model.
exp(logit.overall$coefficients)


# Make a subeset of gauranteed games
# make linear model without kinect variable
# Use model to predict opposite subset



#Coefficient interpretations on the odds scale:
#-Intercept: The odds of a student getting admitted to a graduate school
#            when they attended a top tier undergraduate school and received a
#            0 on the GRE and a 0 as their GPA is approximately 0.019.
#-GRE: For every additional point a student scores on the GRE, their odds
#      of being admitted to graduate school multiply by approximately 1.002,
#      holding all other variables constant.
#-GPA: For every additional point a student raises their GPA, their odds of
#      being admitted to graduate school multiply by approximately 2.235, holding
#      all other variables constant.
#-Rank: The multiplicative change in odds associated with attending an undergraduate school
#       with prestige of rank 2, 3, and 4, as compared to a school with prestige
#       rank 1, is approximately 0.509, 0.262, and 0.212, respectively, holding
#       all other variables constant.

#Inspecting the relationship between log odds and odds.
cbind("Log Odds" = logit.overall$coefficients, "Odds" = exp(logit.overall$coefficients))

confint(logit.overall) #For logistic regression objects, the confint() function
#defaults to using the log likelihood to generate confidence
#intervals; this is similar to inverting the likelihood
#ratio test.

confint.default(logit.overall) #To generate confidence intervals for logistic
#regression models based on the standard errors
#as we are accustomed to, we can use the
#confint.default() function.

#Generating confidence intervals for the coefficients on the odds scale.
exp(confint(logit.overall))
exp(confint.default(logit.overall))

#Do the categories for rank add any predictive power to the model? Let's
#conduct the drop in deviance test:
logit.norank = glm(isBCCompatible ~ . -isBCCompatible -gameName -developer -features, family = "binomial", data = dataUltKNN)

reduced.deviance = logit.norank$deviance #Comparing the deviance of the reduced
reduced.df = logit.norank$df.residual    #model (the one without rank) to...

full.deviance = logit.overall$deviance #...the deviance of the full model (the
full.df = logit.overall$df.residual    #one with the rank terms).

pchisq(reduced.deviance - full.deviance,
       reduced.df - full.df,
       lower.tail = FALSE)

#The p-value is extremely small (<.0005); we have evidence to conclude that the
#model with the factors for rank is preferable to the model without the factors
#for rank.

#More simply, we can use the anova() function and set the test to "Chisq".
anova(logit.norank, logit.overall, test = "Chisq")

#How does the probability of admission change across ranks for a student
#who has an average GRE and an average GPA?
newdata = with(dataUltKNN, data.frame(gre = mean(gre),
                                       gpa = mean(gpa),
                                       rank = factor(1:4)))
newdata #Creating a data frame with the average GRE and GPA for each level of
#the rank variable.

predict(logit.overall, newdata) #This gives us the log odds; but we want
#the probabilities.

#Using the formula to convert to probabilities:
exp(predict(logit.overall, newdata))/(1 + exp(predict(logit.overall, newdata)))

#Setting the type to "response" converts the predictions to probabilities for
#us automatically:
predict(logit.overall, newdata, type = "response")

#Making it easier to see the effects of the rank variable by printing out the
#results side-by-side:
cbind(newdata, "Prob. Backwards Compatible" = predict(logit.overall, newdata, type = "response"))

#Converting the fitted probabilities to binary:
admitted.predicted = round(logit.overall$fitted.values)

#Comparing the true values to the predicted values:
table(truth = dataUltKNN$isBCCompatible, prediction = admitted.predicted)

#It seems like this model made a lot of mistakes (116 out of 400)! This is quite
#dreadful in this case. Let's do a little bit more exploring. We never looked at
#the overall test of deviance:
pchisq(logit.overall$deviance, logit.overall$df.residual, lower.tail = FALSE)

#The p-value for the overall test of deviance is <.05, indicating that this model
#is not a good overall fit!

#What about checking the McFadden's pseudo R^2 based on the deviance?
1 - logit.overall$deviance/logit.overall$null.deviance

#Only about 8.29% of the variability in admission appears to be explained by
#the predictors in our model; while the model is valid, it seems as though it
#isn't extremely informative.

#What have we found out? The overall model we created doesn't give us much
#predictive power in determining whether a student will be admitted to
#graduate school.
table(dataUltKNN$isBCCompatible) #Our data contains 273 unadmitted students and 127
#admitted students.
table(admitted.predicted) #The model we created predicts that 351 students will
#not be admitted, and only 49 will be admitted.
table(truth = dataUltKNN$isBCCompatible, prediction = admitted.predicted)

#The table of the truth against the prediction shows that we only have an accuracy
#of (254 + 30)/400 = 71%; yet, if we were to simply predict "unadmitted" for
#everyone uniformly, we would have an accuracy of 273/400 = 68.25%! No wonder
#why the overall test of deviance was insignificant -- predicting only the
#intercept of the baseline probability was just as sufficient!