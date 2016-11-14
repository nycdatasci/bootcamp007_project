

hot_100 <- read.csv(file = "billboard.csv", stringsAsFactors = FALSE) 

cor(x = hot_100$peak_position, y = hot_100$wks_on_chart)

plot(x = hot_100$peak_position, y = hot_100$wks_on_chart, main = "Peak Position vs. Weeks on Chart",
     xlab = "Peak Position", ylab = "Weeks on Chart")

model = lm(formula = wks_on_chart ~ peak_position, data = hot_100)

abline(model, lty = 2)

plot(model)

newdata = data.frame(peak_position = c(1,8,14,16,21,63,70,77,87))

conf.band = predict(object = model, newdata = newdata, interval = "confidence")
pred.band = predict(object = model, newdata = newdata, interval = "prediction")

plot(x = hot_100$peak_position, y = hot_100$wks_on_chart, main = "Peak Position vs. Weeks on Chart",
     xlab = "Peak Position", ylab = "Weeks on Chart")
abline(model, lty = 2)

lines(newdata$peak_position, conf.band[, 2], col = "blue") #Plotting the lower confidence band.
lines(newdata$peak_position, conf.band[, 3], col = "blue") #Plotting the upper confidence band.
lines(newdata$peak_position, pred.band[, 2], col = "red") #Plotting the lower prediction band.
lines(newdata$peak_position, pred.band[, 3], col = "red") #Plotting the upper prediction band.
legend("topleft", c("Regression Line", "Conf. Band", "Pred. Band"),
       lty = c(2, 1, 1), col = c("black", "blue", "red"))

summary(model)
