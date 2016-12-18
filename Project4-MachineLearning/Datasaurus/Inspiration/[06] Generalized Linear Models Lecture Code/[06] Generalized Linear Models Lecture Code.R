#####################################################
#####################################################
#####[06] Generalized Linear Models Lecture Code#####
#####################################################
#####################################################



########################################################
#####Example using Graduate Schools Admissions Data#####
########################################################
setwd('/Users/nicktalavera/Downloads/[06] Generalized Linear Models Lecture Code')
GradSchools = read.table("[06] Graduate Schools.txt")

head(GradSchools)

#Variables in the dataset:
#-Admit: A binary variable indicating whether or not a student was admitted to
#        the graduate school.
#-GRE: A continuous variable indicating a student's score on the GRE.
#-GPA: A contunuous variable indicating a student's undergraduate grade point
#      average.
#-Rank: A categorical variable indicating the level of prestige of a school; 1
#       indicates the highest prestige, 4 indicates the lowest prestige.

summary(GradSchools) #Looking at the five number summary information.
sapply(GradSchools, sd) #Looking at the individual standard deviations.
sapply(GradSchools, class) #Looking at the variable classes.

#Notice that the admit variable is being treated as continuous at the moment. What
#does the mean of the admit variable indicate in this scenario? Approximately
#31.75% of the applications in our dataset received acceptances.

table(GradSchools$admit)/nrow(GradSchools) #Manually calculating the proportions.

table(GradSchools$admit, GradSchools$rank) #Checking to see that we have data
                                           #available in all combinations of
                                           #the categorical variables.

plot(GradSchools, col = GradSchools$admit + 2) #Basic graphical EDA.

GradSchools$rank = as.factor(GradSchools$rank) #Converting the rank variable to
                                               #a categorical variable.

#Being naïve at first and fitting a multiple linear regression model.
bad.model = lm(admit ~ gre + gpa + rank, data = GradSchools)

summary(bad.model) #Looks like everything is significant, so what's bad?

plot(bad.model) #Severe violations to the assumptions of linear regression.

summary(bad.model$fitted.values)

#Fitting the logistic regression with all variables; the family parameter
#specifies the error distribution and link function to be used. For logistic
#regression, this is binomial.
logit.overall = glm(admit ~ gre + gpa + rank,
                    family = "binomial",
                    data = GradSchools)

#Residual plot for logistic regression with an added loess smoother; we would
#hope that, on average, the residual values are 0.
scatter.smooth(logit.overall$fit,
               residuals(logit.overall, type = "deviance"),
               lpars = list(col = "red"),
               xlab = "Fitted Probabilities",
               ylab = "Deviance Residual Values",
               main = "Residual Plot for\nLogistic Regression of Admission Data")
abline(h = 0, lty = 2)

library(car)
influencePlot(logit.overall) #Can still inspect the influence plot.

summary(logit.overall) #Investigating the overall fit of the model.

#Coefficient interpretations on the log odds scale:
#-Intercept: The log odds of a student getting admitted to a graduate school
#            when they attended a top tier undergraduate school and received a
#            0 on the GRE and a 0 as their GPA is approximately -3.990.
#-GRE: For every additional point a student scores on the GRE, their log odds
#      of being admitted to graduate school increase by approximately 0.002,
#      holding all other variables constant.
#-GPA: For every additional point a student raises their GPA, their log odds of
#      being admitted to graduate school increase by approximately 0.804, holding
#      all other variables constant.
#-Rank: The change in log odds associated with attending an undergraduate school
#       with prestige of rank 2, 3, and 4, as compared to a school with prestige
#       rank 1, is approximately -0.675, -1.340, and -1.552, respectively, holding
#       all other variables constant.

exp(logit.overall$coefficients)

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
cbind("Log Odds" = logit.overall$coefficients,
      "Odds" = exp(logit.overall$coefficients))

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
logit.norank = glm(admit ~ gre + gpa,
                   family = "binomial",
                   data = GradSchools)

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
newdata = with(GradSchools, data.frame(gre = mean(gre),
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
cbind(newdata, "Prob. Admitted" = predict(logit.overall, newdata, type = "response"))

#Converting the fitted probabilities to binary:
admitted.predicted = round(logit.overall$fitted.values)

#Comparing the true values to the predicted values:
table(truth = GradSchools$admit, prediction = admitted.predicted)

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
table(GradSchools$admit) #Our data contains 273 unadmitted students and 127
                         #admitted students.
table(admitted.predicted) #The model we created predicts that 351 students will
                          #not be admitted, and only 49 will be admitted.
table(truth = GradSchools$admit, prediction = admitted.predicted)

#The table of the truth against the prediction shows that we only have an accuracy
#of (254 + 30)/400 = 71%; yet, if we were to simply predict "unadmitted" for
#everyone uniformly, we would have an accuracy of 273/400 = 68.25%! No wonder
#why the overall test of deviance was insignificant -- predicting only the
#intercept of the baseline probability was just as sufficient!