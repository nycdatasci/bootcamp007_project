
library(dplyr)
library(corrplot)

example_predictions <- read.csv("~/Downloads/numerai_datasets1214/example_predictions.csv")
numerai_tournament_data <- read.csv("~/Downloads/numerai_datasets1214/numerai_tournament_data.csv")
numerai_training_data <- read.csv("~/Downloads/numerai_datasets1214/numerai_training_data.csv")

x_numerai_training <- numerai_training_data[ ,1:21]
y_numerai_training <- numerai_training_data[ ,22]

set.seed(0)
train = sample(1:nrow(numerai_training_data), 8*nrow(numerai_training_data)/10)
test = (-train)


library(car)
logit = glm(target ~., family = "binomial",data = numerai_training_data[train,] )
summary(logit)

logit.predit <- predict(logit, numerai_training_data[-train,])
table(truth = numerai_training_data[-train,22], prediction = logit.predit)


corrs <- cor(numerai_training_data%>% select(contains("feature")), method="pearson")
corrplot.mixed(corrs, upper="square",order="hclust")

##test on a XGBoost