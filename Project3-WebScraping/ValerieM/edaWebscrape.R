####
#### Load the output file from scraping the www.nyrrc.org website
#### Scraped Male top 100 runners and Female top 100 runners, 1999-2015
####
library(dplyr)
library(lubridate)

timeToSecs <-function(timex){
if ( nchar(as.character(timex)) < 7 )
  timex = paste0("00:", timex)
res <- hms(timex)                               # format to 'hours:minutes:seconds'
return
 ((hour(res)*60 + minute(res)) * 60 + second(res))      # convert hours to minutes, and add minutes
}



df = read.csv('~/WebScrape/output.txt',sep = ",")

## clean up data
mutate(df, gender = substr(df$SexAge, 1,1))
mutate(df, age = substr(df$SexAge,2,4))
marathon = df[c(1:3, 5:17)]
marathon$Time = sapply(marathon$Time,timeToSecs)
marathon$X10K = sapply(marathon$X10K,timeToSecs)
marathon$X20M = sapply(marathon$X20M,timeToSecs)
marathon$MinPer = sapply(marathon$MinPer,timeToSecs)
for(i in 1:ncol(marathon)){
  marathon[is.na(marathon[,i]), i] <- mean(marathon[,i], na.rm = TRUE)
}
## reorder columna
marathon = marathon[c(1,2,3,15,16,4:14)]

## Analysis
summary(marathon)

sapply(marathon,sd)

cor(marathan$Year, marathon$MinPer)

cor(marathon$MinPer,marathon$Time)  ## better be 1

cor(marathon$X10K, marathon$Time)

cor(marathon$X13.1M, marathon$Time)

cor(marathon$X20M, marathon$Time)
cor(marathon$Year, marathon$Time)
cor(marathon$Year, marathon$MinPer)

plot(marathon[, 5:6])




 


