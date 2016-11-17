setwd("~/Documents/wine")
library(jsonlite)
d <- stream_in(file("data_utf8.json"))
head(d)
str(d)
head(d$price)
head(d$name_location)
d[2,][, 3]
head(d[,3])
tail(d$wtype)
d$wtype <- NULL
head(d[d$name_year=="character(0)",])
d <- d[!d$name_year=="character(0)",]
head(d,50)
dim(d)
d$rating_avg <- 
  as.numeric(unlist(a))
ti3[ti3==''] <- NA
d[d==''] <-NA
d[d=="character(0)"] <- NA
for (i in 1:nrow(d)){
  d$rating_avg[i] <- mean(as.numeric(unlist(d[,9][i])))
}
mean(as.numeric(unlist(d[5,][,9])))
head(unlist(d[,9][5]))
