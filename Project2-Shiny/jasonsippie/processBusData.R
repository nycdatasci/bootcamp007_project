library("dplyr", lib.loc="/Library/Frameworks/R.framework/Versions/3.3/Resources/library")
library("tidyr")
library(tools)
library(ggplot2)


usPopulF = 'US population by state.csv'

wd = '~/datascience/Shiny/data'

setwd(wd)

lkupFileCounty = 'County FIPS Codes.csv'
lkupFileState = 'FIPS state codes.txt'
lkupFileIndust = '2-digit_2012_Codes.csv'
usPopulF = 'US population by state.csv'


lkupIndust  <- read.csv(lkupFileIndust, col.names = c('s','code','val'), stringsAsFactors = FALSE)
lkupIndust <- lkupIndust[rowSums(is.na(lkupIndust)) == 0,]
lkupIndust <- setNames(as.character(lkupIndust$val), lkupIndust$code)


lkupState  <- read.csv(lkupFileState, stringsAsFactors = FALSE, col.names = c("Name","fipstate","stateAbbr"))
lkupCounty  <- read.csv(lkupFileCounty, stringsAsFactors = FALSE)
lkupCounty <- lkupCounty %>% filter(FIPS.Entity.Code==0) %>%  select(one_of('State.FIPS.Code', 'County.FIPS.Code','GU.Name'))
colnames(lkupCounty) <- c('fipstate', 'fipscty' , 'County.Name')

# load county geo data and fix lookups
countiesGeo = map_data("county")
countiesGeo$region = toTitleCase(countiesGeo$region)
countiesGeo$subregion = toTitleCase(countiesGeo$subregion)
countiesGeo <- inner_join(countiesGeo, lkupState, by=c("region"="Name"))


# load business data
load("busData1")
load("byCountyData1")
load("byCountyUnempData")
load("countyPopDataN")



# roll up county unemployment data
n = byCountyUnempData %>% group_by(Year, stateAbbr) %>% 
  summarize(emp=sum(Employed), workers=sum(Labor.Force))
n$unempRate = (n$emp / n$workers -1)*-100

n$unempRate[which(n$emp > n$workers)] = NA

n$indLevel = 0

l = busData
m = byCountyData
m$yr = as.numeric(m$yr)

# clean extraneous characters and set industry level
l$naics = gsub('-','', l$naics)
l$naics = gsub('/','', l$naics)

l$indLevel = ifelse(nchar(l$naics)==2, 1, ifelse(l$naics=="", 0, 2))

# don't need detailed data, but could be useful in the future
l <- subset(l, indLevel != 2)

# join in state and county
l <- inner_join(l, lkupState, by="fipstate")
m <- inner_join(m, lkupState, by="fipstate")

m <- left_join(m, lkupCounty, by=c("fipstate","fipscty"))
m[is.na(m$County.Name),"County.Name"] = 'Unknown'

l <- left_join(l, n, by=(c("yr"="Year", "stateAbbr"="stateAbbr", "indLevel"="indLevel")))


# industry name
l$industName <- lkupIndust[l$naics]

l$industName[l$naics==""]="All"

# calculate YoY change

l$prev_yr = l$yr - 1
m$prev_yr = m$yr - 1

# peel off only interesting rows for previous year
rmvCol = c("prev_yr", "stateAbbr", "industName", "indLevel","Name")
cl = colnames(l)
cl = cl[! cl %in% rmvCol]
prevBD = select(l, one_of(cl))
colnames(prevBD) <- paste0("prev_", colnames(prevBD)) 

# SAA but for county data
rmvCol = c("prev_yr", "stateAbbr", "County.Name","Name")
cl = colnames(m)
cl = cl[! cl %in% rmvCol]
prevCountyBD = select(m, one_of(cl))
colnames(prevCountyBD) <- paste0("prev_", colnames(prevCountyBD)) 



# note that prev_yr in the prevBD table is the current year of that row's data
# so the below join uses prev_yr = prev_yr

l = inner_join(l, prevBD, by=c("prev_yr"="prev_yr", "naics"="prev_naics", "fipstate"="prev_fipstate"))

l = mutate(l, num_emp_chg = round(100 * (num_emp / prev_num_emp - 1),1),
                 tot_payroll_chg = round(100 * (tot_payroll  / prev_tot_payroll - 1), 1),
                 num_est_chg = round(100 * (num_est / prev_num_est - 1), 1),
                 num_est_small_chg = round(100 * (num_est_small / prev_num_est_small - 1),1),
                 num_est_med_chg = round(100 * (num_est_med / prev_num_est_med - 1), 1),
                 num_est_large_chg = round(100 * (num_est_large / prev_num_est_large) - 1,1 )
)

# note that prev_yr in the prevBD table is the current year of that row's data
# so the below join uses prev_yr = prev_yr

m = inner_join(m, prevCountyBD, by=c("prev_yr"="prev_yr", "fipstate"="prev_fipstate", "fipscty"="prev_fipscty"))

m = mutate(m, num_emp_chg = round(100 * (num_emp / prev_num_emp - 1),1),
           tot_payroll_chg = round(100 * (tot_payroll  / prev_tot_payroll - 1), 1),
           num_est_chg = round(100 * (num_est / prev_num_est - 1), 1),
           num_est_small_chg = round(100 * (num_est_small / prev_num_est_small - 1),1),
           num_est_med_chg = round(100 * (num_est_med / prev_num_est_med - 1), 1),
           num_est_large_chg = round(100 * (num_est_large / prev_num_est_large) - 1,1 )
)




# get population data
usPopul  <- read.csv(usPopulF, stringsAsFactors = FALSE)

usPopuln <- gather(usPopul,"year","popul", 2:17)

usPopuln$year <- as.numeric(sub("X","",usPopuln$year))

# join in population
l <- inner_join(l, usPopuln, by = c("yr"="year","stateAbbr" ="X"))

# calculate per capital ratios
l = mutate(l, num_emp_pcap = round(num_emp / popul,1),
                 tot_payroll_pcap = round(tot_payroll  / popul, 1),
                 num_est_pcap = round(num_est/popul, 1),
                 num_est_small_pcap = round(num_est_small / popul,1),
                 num_est_med_pcap = round(num_est_med / popul, 1),
                 num_est_large_pcap = round(num_est_large / popul,1 ))

# join in population
m <- inner_join(m, countyPopDataN, by = c("yr","stateAbbr","County.Name"))

# calculate per capital ratios
m = mutate(m, num_emp_pcap = round(num_emp / popul,1),
           tot_payroll_pcap = round(tot_payroll  / popul, 1),
           num_est_pcap = round(num_est/popul, 1),
           num_est_small_pcap = round(num_est_small / popul,1),
           num_est_med_pcap = round(num_est_med / popul, 1),
           num_est_large_pcap = round(num_est_large / popul,1 ))



busData = l
byCountyData = m

save(busData, file='busData')
save(byCountyData, file='byCountyData')
save(countiesGeo, file='countiesGeo')

rm(list=ls())



