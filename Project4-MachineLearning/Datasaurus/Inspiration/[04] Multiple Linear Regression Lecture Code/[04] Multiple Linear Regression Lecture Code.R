######################################################
######################################################
#####[04] Multiple Linear Regression Lecture Code#####
######################################################
######################################################



#####################################################
#####Example using the State Information Dataset#####
#####################################################
help(state.x77)
state.x77 #Investigating the state.x77 dataset.

states = as.data.frame(state.x77) #Forcing the state.x77 dataset to be a dataframe.

#Cleaning up the column names so that there are no spaces.
colnames(states)[4] = "Life.Exp"
colnames(states)[6] = "HS.Grad"

#Creating a population density variable.
states[,9] = (states$Population*1000)/states$Area
colnames(states)[9] = "Density"

#Basic numerical EDA for states dataset.
summary(states)
sapply(states, sd)
cor(states)

#Basic graphical EDA for the states dataset.
plot(states)

#Can we estimate an individual's life expectancy based upon the state in which
#they reside?

#Creating a saturated model (a model with all variables included).
model.saturated = lm(Life.Exp ~ ., data = states)

summary(model.saturated) #Many predictor variables are not significant, yet the
                         #overall regression is significant.

plot(model.saturated) #Assessing the assumptions of the model.

library(car) #Companion to applied regression.
influencePlot(model.saturated)

vif(model.saturated) #Assessing the variance inflation factors for the variables
                     #in our model.

#Added variable plots for assessing the contribution of each additional variable.
avPlots(model.saturated) #Distinct patterns are indications of good contributions
                         #to the model; absent patterns usually are pointers to
                         #variables that could be dropped from the model.

#We note that Illiteracy has a large VIF, an insignificant p-value in the overall
#regression, and no strong distinct pattern in the added-variable plot. What
#happens when we remove it from the model?
model2 = lm(Life.Exp ~ . - Illiteracy, data = states)

summary(model2) #R^2 adjusted went up, model still significant, etc.

plot(model2) #No overt additional violations.

influencePlot(model2) #No overt additional violations; Hawaii actually lowers
                      #its hat value (leverage).

vif(model2) #VIFs all decrease.

#We can compare these two models using a partial F-test using the anova function.
#Here, the first model we supply is the reduced model, and the second is the full
#model.
anova(model2, model.saturated) #The p-value is quite large, indicating that we
                               #retain the null hypothesis. Recall that the null
                               #hypothesis is that the slope coefficients of the
                               #variables in the subset of interest are all 0.
                               #We retain this hypothesis and conclude that the
                               #Illiteracy variable is not informative in our
                               #model; we move forward with the reduced model.

#Let's use the partial F-test to test multiple predictors at once. As compared
#to the saturated model, does the subset of Illiteracy, Area, and Income have
#any effect on our prediction of Life.Exp?
model.full = lm(Life.Exp ~ ., data = states)
model.reduced = lm(Life.Exp ~ . - Illiteracy - Area - Income, data = states)

anova(model.reduced, model.full) #The p-value is quite large; thus, the reduced
                                 #model is sufficient.

#Checking the model summary and assumptions of the reduced model.
summary(model.reduced)
plot(model.reduced)
influencePlot(model.reduced)
vif(model.reduced)

#We can also inspect the AIC and BIC values to compare various models.
AIC(model.full,    #Model with all variables.
    model2,        #Model with all variables EXCEPT Illiteracy.
    model.reduced) #Model with all variables EXCEPT Illiteracy, Area, and Income.

BIC(model.full,
    model2,
    model.reduced) #Both the minimum AIC and BIC values appear alongside the
                   #reduced model that we tested above.

#We can use stepwise regression to help automate the variable selection process.
#Here we define the minimal model, the full model, and the scope of the models
#through which to search:
model.empty = lm(Life.Exp ~ 1, data = states) #The model with an intercept ONLY.
model.full = lm(Life.Exp ~ ., data = states) #The model with ALL variables.
scope = list(lower = formula(model.empty), upper = formula(model.full))

library(MASS) #The Modern Applied Statistics library.

#Stepwise regression using AIC as the criteria (the penalty k = 2).
forwardAIC = step(model.empty, scope, direction = "forward", k = 2)
backwardAIC = step(model.full, scope, direction = "backward", k = 2)
bothAIC.empty = step(model.empty, scope, direction = "both", k = 2)
bothAIC.full = step(model.full, scope, direction = "both", k = 2)

#Stepwise regression using BIC as the criteria (the penalty k = log(n)).
forwardBIC = step(model.empty, scope, direction = "forward", k = log(50))
backwardBIC = step(model.full, scope, direction = "backward", k = log(50))
bothBIC.empty = step(model.empty, scope, direction = "both", k = log(50))
bothBIC.full = step(model.full, scope, direction = "both", k = log(50))

#In this case, all procedures yield the model with only the Murder, HS.Grad,
#Frost, and Population variables intact.

#Checking the model summary and assumptions of the reduced model.
summary(forwardAIC)
plot(forwardAIC)
influencePlot(forwardAIC)
vif(forwardAIC)
avPlots(forwardAIC)
confint(forwardAIC)

#Predicting new observations.
forwardAIC$fitted.values #Returns the fitted values.

newdata = data.frame(Murder = c(1.5, 7.5, 12.5),
                     HS.Grad = c(60, 50, 40),
                     Frost = c(75, 55, 175),
                     Population = c(7500, 554, 1212))

predict(forwardAIC, newdata, interval = "confidence") #Construct confidence intervals
                                                      #for the average value of an
                                                      #outcome at a specific point.

predict(forwardAIC, newdata, interval = "prediction") #Construct prediction invervals
                                                      #for a single observation's
                                                      #outcome value at a specific point.



#####################################
#####Extending Model Flexibility#####
#####################################
tests = read.table("[04] Test Scores.txt")

#Basic numerical EDA for states dataset.
summary(tests)
sd(tests$Test.Score)
sd(tests$Hours.Studied)
cor(tests$Test.Score, tests$Hours.Studied)

#Basic graphical EDA for tests dataset.
plot(tests$Hours.Studied, tests$Test.Score)

#############################################
#####Fitting a simple linear regression.#####
#############################################
model.simple = lm(Test.Score ~ Hours.Studied, data = tests)

summary(model.simple) #Investigating the model and assessing some diagnostics.
plot(model.simple)
influencePlot(model.simple)

#Constructing confidence and prediction bands for the scope of our data.
newdata = data.frame(Hours.Studied = seq(1, 3, length = 100))
conf.band = predict(model.simple, newdata, interval = "confidence")
pred.band = predict(model.simple, newdata, interval = "prediction")

plot(tests$Hours.Studied, tests$Test.Score,
     xlab = "Hours Studied", ylab = "Test Score",
     main = "Simple Linear Regression Model\nTests Dataset")
abline(model.simple, lty = 2)
lines(newdata$Hours.Studied, conf.band[, 2], col = "blue") #Plotting the lower confidence band.
lines(newdata$Hours.Studied, conf.band[, 3], col = "blue") #Plotting the upper confidence band.
lines(newdata$Hours.Studied, pred.band[, 2], col = "red") #Plotting the lower prediction band.
lines(newdata$Hours.Studied, pred.band[, 3], col = "red") #Plotting the upper prediction band.
legend("topleft", c("Regression Line", "Conf. Band", "Pred. Band"),
       lty = c(2, 1, 1), col = c("black", "blue", "red"))

##################################
#####Adding a quadratic term.#####
##################################
model.quadratic = lm(Test.Score ~ Hours.Studied + I(Hours.Studied^2), data = tests)

summary(model.quadratic) #Investigating the model and assessing some diagnostics.
plot(model.quadratic)
influencePlot(model.quadratic)

#Constructing confidence and prediction bands for the scope of our data.
conf.band = predict(model.quadratic, newdata, interval = "confidence")
pred.band = predict(model.quadratic, newdata, interval = "prediction")

plot(tests$Hours.Studied, tests$Test.Score,
     xlab = "Hours Studied", ylab = "Test Score",
     main = "Quadratic Regression Model\nTests Dataset")
lines(tests$Hours.Studied[order(tests$Hours.Studied)],
      model.quadratic$fitted.values[order(tests$Hours.Studied)], lty = 2)
lines(newdata$Hours.Studied, conf.band[, 2], col = "blue") #Plotting the lower confidence band.
lines(newdata$Hours.Studied, conf.band[, 3], col = "blue") #Plotting the upper confidence band.
lines(newdata$Hours.Studied, pred.band[, 2], col = "red") #Plotting the lower prediction band.
lines(newdata$Hours.Studied, pred.band[, 3], col = "red") #Plotting the upper prediction band.
legend("topleft", c("Regression Line", "Conf. Band", "Pred. Band"),
       lty = c(2, 1, 1), col = c("black", "blue", "red"))

##########################
#####Adding a factor.#####
##########################
model.factor = lm(Test.Score ~ Hours.Studied + Gender, data = tests)

summary(model.factor) #Investigating the model and assessing some diagnostics.
plot(model.factor)
influencePlot(model.factor)

col.vec = c(rep("pink", 250), rep("blue", 250))

plot(tests$Hours.Studied, tests$Test.Score, col = col.vec,
     xlab = "Hours Studied", ylab = "Test Score",
     main = "Linear Regression Model w/ Factor\nTests Dataset")
abline(model.factor$coefficients[1], #Intercept for females.
       model.factor$coefficients[2], #Slope for females.
       lwd = 3, lty = 2, col = "pink")
abline(model.factor$coefficients[1] + model.factor$coefficients[3], #Intercept for males.
       model.factor$coefficients[2], #Slope for males.
       lwd = 3, lty = 2, col = "blue")
legend("topleft", c("Female Regression", "Male Regression"),
       lwd = 3, lty = 2, col = c("pink", "blue"))