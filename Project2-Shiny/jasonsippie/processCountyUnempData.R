library("dplyr")
library("tidyr")

wd = '~/datascience/Shiny/data'

setwd(wd)

lkupFileCounty = 'County FIPS Codes.csv'
lkupFileState = 'FIPS state codes.txt'

lkupState  <- read.csv(lkupFileState, stringsAsFactors = FALSE, col.names = c("Name","fipstate","stateAbbr"))
lkupCounty  <- read.csv(lkupFileCounty, stringsAsFactors = FALSE)
lkupCounty <- lkupCounty %>% filter(FIPS.Entity.Code==0) %>%  select(one_of('State.FIPS.Code', 'County.FIPS.Code','GU.Name'))
colnames(lkupCounty) <- c('fipstate', 'fipscty' , 'County.Name')


#unemployment data
m <- read.csv("countyLevelUnemployment.csv", stringsAsFactors = FALSE)

m$Labor.Force = as.numeric(m$Labor.Force)
m$Employed = as.numeric(m$Employed)
m$unempRate = (m$Employed / m$Labor.Force -1)*-100

m <- inner_join(m, lkupState, by=(c("State.FIPS.Code"="fipstate")))

m <- left_join(m, lkupCounty, by=c("State.FIPS.Code"="fipstate","County.FIPS.Code"="fipscty"))
m[is.na(m$County.Name),"County.Name"]='Unknown'

m$Year  = as.numeric(m$Year)

byCountyUnempData = m

byCountyUnempData$unempRate = pmax(round(as.numeric(byCountyUnempData$Employed)/as.numeric(byCountyUnempData$Labor.Force)-1,3) *-100, 0)

byCountyUnempData$unempRate[which(byCountyUnempData$Employed>byCountyUnempData$Labor.Force)]=NA

byCountyUnempData <- subset(byCountyUnempData, byCountyUnempData$County.Name!="Unknown")

save(byCountyUnempData, file='byCountyUnempData')

rm(list=ls())

