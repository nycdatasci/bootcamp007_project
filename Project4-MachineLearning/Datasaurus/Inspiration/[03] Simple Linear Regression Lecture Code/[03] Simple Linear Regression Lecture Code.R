####################################################
####################################################
#####[03] Simple Linear Regression Lecture Code#####
####################################################
####################################################



##############################################
#####Manual example with the cars dataset#####
##############################################
help(cars)
cars #Investigating the cars dataset.

#Basic numerical EDA for cars dataset.
summary(cars) #Five number summaries.
sapply(cars, sd) #Standard deviations.
cor(cars) #Correlations.

#Basic graphical EDA for cars dataset.
hist(cars$speed, xlab = "Speed in MPH", main = "Histogram of Speed")
hist(cars$dist, xlab = "Distance in Feet", main = "Histogram of Distance")

plot(cars, xlab = "Speed in MPH", ylab = "Distance in Feet",
     main = "Scatterplot of Cars Dataset")

#Manual calculation of simple linear regression coefficients.
beta1 = sum((cars$speed - mean(cars$speed)) * (cars$dist - mean(cars$dist))) /
  sum((cars$speed - mean(cars$speed))^2)

beta0 = mean(cars$dist) - beta1*mean(cars$speed)

#Adding the least squares regression line to the plot.
abline(beta0, beta1, lty = 2)

#Calculating the residual values.
residuals = cars$dist - (beta0 + beta1*cars$speed)

#Note the sum of the residuals is 0.
sum(residuals)

#Visualizing the residuals.
segments(cars$speed, cars$dist,
         cars$speed, (beta0 + beta1*cars$speed),
         col = "red")
text(cars$speed - .5, cars$dist, round(residuals, 2), cex = 0.5)



#################################################
#####Automatic example with the cars dataset#####
#################################################
model = lm(dist ~ speed, data = cars) #Use the linear model function lm() to
                                      #conduct the simple linear regression.

summary(model) #All the summary information for the model in question. Reports:
               #-The five number summary of the residuals.
               #-The coefficient estimates.
               #-The coeffiient standard errors.
               #-The t-test for significance of the coefficient estimates.
               #-The p-values for the significance tests.
               #-The level of significance.
               #-The RSE and degrees of freedom for the model.
               #-The coefficient of determination, R^2.
               #-The overall model F-statistic and corresponding p-value.

#The equation of the model can be constructed from the output:
#Predicted Distance = -17.6 + (3.9)*Speed

#The interpretation for the slope coefficient: With a 1 MPH increase in car speed,
#the stopping distance, on average, increases by approximately 3.9 feet.

#The interpretation for the intercept coefficient: When a car's speed is 0 MPH,
#the stopping distance, on average, is -17.6 MPH. Theoretically, does this make
#sense? Why might this be the case?

#The residual standard error is about 15.38; this is an approximation of how much
#the residuas tend to deviate around the regression line.

#The coefficient of determination is about 0.65; approximately 65% of the variability
#in the distance variable is explained by the speed variable.

#The intercept, slope, and overall regression is extremely significant (p-values
#all below 0.05).

#Notice that the F-statistic value for the overall regression is the same as the
#square of the t-statistic value for the speed coefficient:
t.statistic = 9.464
f.statistic = 89.57
t.statistic^2

confint(model) #Creating 95% confidence intervals for the model coefficients.



####################################################
#####Checking assumptions with the cars dataset#####
####################################################
#Linearity
plot(cars, xlab = "Speed in MPH", ylab = "Distance in Feet",
     main = "Scatterplot of Cars Dataset")
abline(model, lty = 2)

#Constant Variance & Independent Errors
plot(model$fitted, model$residuals,
     xlab = "Fitted Values", ylab = "Residual Values",
     main = "Residual Plot for Cars Dataset")
abline(h = 0, lty = 2)

#Normality
qqnorm(model$residuals)
qqline(model$residuals)

#Using the built-in plot() function to visualize the residual plots.
plot(model) #Note the addition of the loess smoother and scale-location plot
            #in order to assess whether there is a pronounced non-linear
            #relationship. Also the addition of leverage and cook's distance.

#Outliers are observations that have high residual values. The error for these
#observations is relatively large because the observations fall distant from the
#regression line.

#Leverage points are observations that have unusually small or large independent
#variable values; these points fall far from the mean. Thus, these observations
#have a lot of leverage to change the slope of the regression line. The further
#an observation is from the mean of the independent variable, the more leverage
#it has on the slope.

#Cook's distance helps to measure the effect of deleting an observation from the
#dataset and rerunning the regression. Observations that have large residual values
#and also high leverage tend to pose threats to the accuracy of the regression
#line and thus need to be further investigated.

#Visualizing another influence plot for the regression model.
library(car) #Companion to applied regression.
influencePlot(model)



#####################################
#####Predicting New Observations#####
#####################################
model$fitted.values #Returns the fitted values.

newdata = data.frame(speed = c(15, 20, 25)) #Creating a new data frame to pass
                                            #to the predict() function.

predict(model, newdata, interval = "confidence") #Construct confidence intervals
                                                 #for the average value of an
                                                 #outcome at a specific point.

predict(model, newdata, interval = "prediction") #Construct prediction invervals
                                                 #for a single observation's
                                                 #outcome value at a specific point.

#Constructing confidence and prediction bands for the scope of our data.
newdata = data.frame(speed = 4:25)
conf.band = predict(model, newdata, interval = "confidence")
pred.band = predict(model, newdata, interval = "prediction")

#Visualizing the confidence and prediction bands.
plot(cars, xlab = "Speed in MPH", ylab = "Distance in Feet",
     main = "Scatterplot of Cars Dataset")
abline(model, lty = 2) #Plotting the regression line.
lines(newdata$speed, conf.band[, 2], col = "blue") #Plotting the lower confidence band.
lines(newdata$speed, conf.band[, 3], col = "blue") #Plotting the upper confidence band.
lines(newdata$speed, pred.band[, 2], col = "red") #Plotting the lower prediction band.
lines(newdata$speed, pred.band[, 3], col = "red") #Plotting the upper prediction band.
legend("topleft", c("Regression Line", "Conf. Band", "Pred. Band"),
       lty = c(2, 1, 1), col = c("black", "blue", "red"))



####################################
#####The Box-Cox Transformation#####
####################################
bc = boxCox(model) #Automatically plots a 95% confidence interval for the lambda
                   #value that maximizes the likelihhood of transforming to
                   #normality.

lambda = bc$x[which(bc$y == max(bc$y))] #Extracting the best lambda value.

dist.bc = (cars$dist^lambda - 1)/lambda #Applying the Box-Cox transformation.

model.bc = lm(dist.bc ~ cars$speed) #Creating a new regression based on the
                                    #transformed variable.

summary(model.bc) #Assessing the output of the new model.

plot(model.bc) #Assessing the assumptions of the new model.

boxCox(model.bc) #What happens if we want to apply the Box-Cox transformation
                 #a second time?