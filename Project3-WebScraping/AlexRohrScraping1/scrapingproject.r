library(dplyr)
data = read.csv("craigslist_data_new.csv")
head(data)
summary(data)
data = mutate_each(data, funs(toupper))
data$price = gsub(",","",gsub("\\$","", data$price))
data$br = 0

data$neighborhoods = gsub(".+INWOOD.+", "INWOOD", data$neighborhoods)
data$neighborhoods = gsub(".+ALLERTON.+", "ALLERTON", data$neighborhoods)
data$neighborhoods = gsub(".+BAYCHESTER.+", "BAYCHESTER", data$neighborhoods)
data$neighborhoods = gsub(".+STUY.+", "BEDSTUY", data$neighborhoods)
data$neighborhoods = gsub(".+BRIARWOOD.+", "BRIARWOOD", data$neighborhoods)
data$neighborhoods = gsub(".+BRONX.+", "BRONX", data$neighborhoods)
data$neighborhoods = gsub(".+CAMBRIA.+", "CAMBRIA HEIGHTS", data$neighborhoods)
data$neighborhoods = gsub(".+CANARSIE.+", "CANARSIE", data$neighborhoods)
data$neighborhoods = gsub(".+STAMFORD.+", "STAMFORD", data$neighborhoods)
data$neighborhoods = gsub(".+HARLEM.+", "HARLEM", data$neighborhoods)
data$neighborhoods = gsub(".+JAMAICA.+", "JAMAICA", data$neighborhoods)
data$neighborhoods = gsub(".+KEW.+", "KEW GARDENS", data$neighborhoods)
data$neighborhoods = gsub(".+MANHATTAN.+", "MANHATTAN", data$neighborhoods)
data$neighborhoods = gsub(".+PARK SLOPE.+", "PARK SLOPE", data$neighborhoods)
data$neighborhoods = gsub(".+REGO PARK.+", "REGO PARK", data$neighborhoods)
data$neighborhoods = gsub(".+ROCHEDALE.+", "ROCHEDALE", data$neighborhoods)

sort(table(data$neighborhoods),decreasing=TRUE)[1:50]


summary(data)
data$X = NULL

head(data)

data6 = data

regexMatch <- function(pattern,x) {
  result <- character(0)
    for(y in x) {
      fields <- unlist(strsplit(y, '[[:space:]]+'))
      match <- ifelse(length(grepl(pattern, fields)) >0,
                      fields[grepl(pattern, fields)],
                      NA)
      result <- c(result, match)
    }
    result
}

data$br = regexMatch('BR', data$sqft)

data$ft2 = regexMatch('FT2', data$sqft)

data$br = gsub("BR","", data$br)
data$ft2 = gsub("FT2","",data$ft2)

data = data[!(is.na(data$price)),] 

sum(is.na(data$title))

library(VIM)
data$X.4 = NULL
aggr(data)
missing = aggr(data)
missingft = aggr(data$ft2)
summary (missing)

library(ggplot2)
plot(data$br, data$price)
g = ggplot(data = data, aes(x = br, y = price))
g + geom_point(shape=1, color="red") + geom_smooth(method = lm)
plot(data_complete$br, data_complete$price)
g = ggplot(data = data_complete, aes(x = br, y = price))
g + geom_point(shape=1, color="red") + geom_smooth(method = lm)

plot(data$ft2, data$price)
g = ggplot(data = data, aes(x = ft2, y = price))
g + geom_point(shape=1, color="red") + geom_smooth(method = lm)
plot(data_complete$ft2, data_complete$price)
g = ggplot(data = data_complete, aes(x = ft2, y = price))
g + geom_point(shape=1, color="red") + geom_smooth(method = lm)

plot(data1_complete$ft2, data1_complete$price)
g = ggplot(data = data1_complete, aes(x = ft2, y = price))
g + geom_point(shape=1, color="red") + geom_smooth(method = lm)

plot(data$br, data1ft2)
plot(data1_hist$RPSF, data1_hist$price)
g = ggplot(data = data1_hist, aes(x = RPSF, y = price))
g + geom_point(shape=1, color="red") + geom_smooth(method = lm)

data$neighborhoods = as.factor(data$neighborhoods)

model0 = lm(price ~neighborhoods, data=data)
summary(model0)
model1 = lm(ft2 ~ br, data=data)
summary(model1)
plot(model1)
model2 = lm(price ~ br + ft2, data=data)
summary(model2)
plot(model2)
model3 = lm(price ~ ft2, data=data)
summary(model3)
plot(model3)
model4 = lm(price ~ ft2 + neighborhoods, data=data)
summary(model4)
model5 = lm(price ~ ft2 + neighborhoods + br, data=data)
summary(model5)
plot (model5)
plot(data1$price, data1$ft2)


data$RPSF = (data$price) / (data$ft2)
data$RPSFT
as.numeric(data$price)
data$ft2 = as.numeric(data$ft2)


data$price = as.integer(data$price)

data1

plot(data1)
data1$neighborhoods = as.factor(data1$neighborhoods)

data_complete = data[!(is.na(data$ft2)),]

data1_hist = data1[!(is.na(data$ft2)),]

data$RPSF = data$price / data$ft2 

data$price = as.numeric(data$price)
data$ft2 = as.numeric(data$ft2)

as.numeric(data1_hist$price)
data1_hist$ft2 = as.numeric(data1_hist$ft2)

length(unique(data1_hist$neighborhoods))


data1_hist

datastats = data[!(is.na(data$neighborhoods)),]

d1=
datastats %>% 
  group_by(neighborhoods) %>% 
  summarise_each(funs(mean),RPSF)

d2=
  datastats %>% 
  group_by(neighborhoods) %>% 
  summarise_each(funs(mean),ft2)

d3=
  datastats %>% 
  group_by(neighborhoods) %>% 
  summarise_each(funs(mean),price)

datastats %>%
  group_by(neighborhoods) %>%
  (summarise(max(ft2)))


