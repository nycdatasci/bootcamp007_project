model = lm(dist ~ speed, data = cars)
summary(model)

summary(aov(model))

TSS = sum((cars$dist - mean(cars$dist))^2)
RSS = sum((cars$dist - model$fitted.values)^2) #Or sum(model$residuals^2)
(TSS - RSS)/(RSS/48)