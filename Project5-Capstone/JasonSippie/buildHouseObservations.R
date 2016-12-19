library(dplyr)
library(tidyr)

setwd("/Users/sippiejason/datascience/webscraping/realestate/data")

######################################################################################
#
#  Build House Observations
#
#  This script merges several key data files and creates most derived features, 
#  such as house value imputation and lagged features (to avoid predicting the present)
#
######################################################################################

# load all records from webscraping process
allRec = read.csv("allHouseObservations20161213.csv", stringsAsFactors = F)

# duplicate indexes; can delete
allRec$X = NULL 

t$PriorYear = t$ObsYear -1

# group by houseID to set boundaries to windowoing functions
t = allRec %>% group_by(HouseID) %>% arrange(HouseID, ObsYear)

t$LastSalePrice = t$SalePrice
t$LastSaleYear = ifelse(t$SaleFlg == 1, t$ObsYear, NA) # set the last sale year to current year if sold

# fill from past to future for each house
t = tidyr::fill(t, LastSalePrice)
t = tidyr::fill(t, LastSaleYear)
t = tidyr::fill(t, Tax)

# UID for the tenure of someone at the house
t$OwnershipID = paste(as.character(t$HouseID), as.character(t$LastSaleYear),sep = "-")

t$YrsSinceSold = t$ObsYear - t$LastSaleYear

t <- t %>% mutate(YrsSinceSoldLag=lag(YrsSinceSold)) # shift sale age by 1 year
# some other features
t$SoldPrev3Years = as.integer(t$YrsSinceSoldLag<=2)
t$SoldPrev2Years = as.integer(t$YrsSinceSoldLag<=1)
t$SoldPrevYear = as.integer(t$YrsSinceSoldLag<1)
t = t %>% ungroup() 


######################################################################################
#
# Case/Shiller-derived metrics
#
######################################################################################

csInputFile = 'CaseShillerCharlotteYoY.csv'
cs = read.csv(csInputFile, stringsAsFactors = F )

t = t %>% left_join(cs, by=c("ObsYear"="Year"))

t$YoYLnChg = 1 + t$YoYLnChg # add one so we can multiply across rows to get cumchange

# for each house's window of years between sales
# adjust value by YoY change in case-shiller index
t = t %>% group_by(HouseID, LastSaleYear) %>% mutate(YoYLnChgCum=cumprod(YoYLnChg))

t$TrueHouseValue = ifelse(is.na(t$SalePrice), t$YoYLnChgCum * t$LastSalePrice,t$SalePrice) 

t = t %>% group_by(HouseID) %>% mutate(HouseValPrevYear=lag(TrueHouseValue)) %>% ungroup()

t$HouseValChgYoY = t$TrueHouseValue - t$HouseValPrevYear

# calculate adjustment based on real sales in zip code
tSale = subset(t, SaleFlg == 1 & !is.na(HouseValPrevYear))
slsAdjustment = tSale  %>% group_by(ObsYear, ZipCode)  %>% summarize(adj=1+(mean(HouseValChgYoY)/mean(HouseValPrevYear))) %>% ungroup()
t = t %>% left_join(slsAdjustment, by=c("ObsYear","ZipCode"))

# adjusted values if not a sale year
t$TrueHouseValueAdj = ifelse(is.na(t$SalePrice), t$TrueHouseValue * t$adj,t$TrueHouseValue) 

# pct deviations in price from last sale
t$HouseValPctDevSale = 100* (t$TrueHouseValue/t$LastSalePrice-1)
t$HouseValPctDevSaleAdj = 100* (t$TrueHouseValueAdj/t$LastSalePrice-1)

#add the lag
t <- t %>% group_by(HouseID) %>% mutate(HouseValPctDevPrevSale=lag(HouseValPctDevSale), HouseValPctDevPrevSaleAdj=lag(HouseValPctDevSaleAdj)) %>% ungroup()

######################################################################################
#
# Unemployment data
#
######################################################################################

unempFile = 'NC_countyUnempData.csv'
unemp = read.csv(unempFile, stringsAsFactors = F)
unemp <- unemp %>% select(County.Name, Year, unempRate, YoYPctChgLaborForce, YoYPctChgEmployed, YoYChgUnempRate)
t = left_join(t, unemp, by=c("CountyName"="County.Name", "PriorYear"="Year"))

######################################################################################
#
# Census demographic data
#
######################################################################################


# demographics linked to addresses
addrDemo = read.csv("AddrDemoClean.csv")

t2 = t %>% inner_join(addrDemo, by=c('AddrQuery','ObsYear'))


######################################################################################
#
# Mortgage Rates
#
######################################################################################

# Mortgage Rates
mortPrimeRate = read.csv("YoYMortgageRtChange.csv", stringsAsFactors = FALSE)


t2 = t2 %>% inner_join(mortPrimeRate, by=c('ObsYear'='Year'))


######################################################################################
#
# Data from previous iteration
#
######################################################################################


# tYest= read.csv("allHouseObsAndDemo20161211.csv", stringsAsFactors = F)
# 
# 
# t2 = rbind(tYest, t2)

######################################################################################
#
# Write file
#
######################################################################################


write.csv(t2, "allHouseObsAndDemo20161213.csv")


# Keep an updated lists of finished addresses
write.csv(unique(t2$AddrQuery), file="AddrAlreadyLoaded.csv")

