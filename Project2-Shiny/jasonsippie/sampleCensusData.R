library("dplyr", lib.loc="/Library/Frameworks/R.framework/Versions/3.3/Resources/library")


allFiles = c('cbp07co.txt',
             'cbp08co.txt',
             'cbp09co.txt',
             'cbp10co.txt',
             'cbp11co.txt',
             'cbp12co.txt',
             'cbp13co.txt',
             'cbp14co.txt')


lkupFileState = 'FIPS state codes.txt'
lkupFileIndust = '2-digit_2012_Codes.csv'

wd = '~/datascience/Shiny/data'



setwd(wd)

lkup  <- read.csv(lkupFileState)
lkupState <- setNames(as.character(lkup$Official.USPS.Code), lkup$FIPS.State.Numeric.Code)

lkup  <- read.csv(lkupFileIndust, col.names = c('s','code','val'))
lkup <- lkup[rowSums(is.na(lkup)) == 0,]
lkupIndust <- setNames(as.character(lkup$val), lkup$code)

firstLoopFlg = TRUE

for (f in allFiles) {
  print(paste("Working on file", f))
  
  l  <- read.csv(f, stringsAsFactors = FALSE)
  
  
  l <- l %>% filter((substr(l$naics,3, 6) == '----' |substr(l$naics,4, 6) == '///')) 
  
  l <- l %>% group_by(fipstate, naics) %>%  
    summarize(num_emp = sum(emp), tot_payroll = sum(ap), num_est = sum(est),
              # ap_small = sum(a5_9 + n5_9 + a10_19 + a10_19 + a20_49 + n20_49 + a50_99 + n50_99),
              # ap_med = sum(a100_249 + a250_499),
              # ap_large = sum(a500_999 + a1000),
              num_est_small = sum(n1_4, n5_9 + n5_9 + n10_19 + n10_19 + n20_49 + n20_49 + n50_99 + n50_99),
              num_est_med = sum(n100_249 + n250_499),
              num_est_large = sum(n500_999 + n1000)) %>% 
    ungroup
  
  l$naics = gsub('-','', l$naics)
  l$naics = gsub('/','', l$naics)
  
  l$indLevel = ifelse(nchar(l$naics)==2, 1, ifelse(l$naics=="", 0, 2))
  l$stateAbbr <- lkupState[l$fipstate]
  l$industName <- lkupIndust[l$naics]
  l$yr <- as.numeric(paste0('20', substr(f,4, 5)))

  if (firstLoopFlg) {
    busData = l
    firstLoopFlg = FALSE
  }  else {
    busData <- bind_rows(busData, l)
  }

}

busData$prev_yr = busData$yr - 1
busData$seq = 0:(nrow(busData)-1)

rmvCol = c("prev_yr", "stateAbbr", "industName", "indLevel")
cl = colnames(busData)
cl = cl[! cl %in% rmvCol]

prevBD = select(busData, one_of(cl))

colnames(prevBD) <- paste0("prev_", colnames(prevBD)) 

# note that prev_yr in the prevBD table is the current year of that row's data
# so the below join uses prev_yr = prev_yr

busData = inner_join(busData, prevBD, by=c("prev_yr"="prev_yr", "naics"="prev_naics", "fipstate"="prev_fipstate"))

busData = mutate(busData, num_emp_chg = round((num_emp / prev_num_emp - 1)*100, 1),
       tot_payroll_chg = round((tot_payroll / prev_tot_payroll - 1)*100, 1),
       num_est_chg = round((num_est / prev_num_est - 1)*100, 1),
       num_est_small_chg = round((num_est_small / prev_num_est_small - 1)*100, 1),
       num_est_med_chg = round((num_est_med / prev_num_est_med - 1)*100, 1),
       num_est_large_chg = round((num_est_large / prev_num_est_large - 1)*100, 1))

busData$industName[busData$naics==""]="All"

# busData$indLevel = factor(busData$indLevel)
busData$stateAbbr = factor(busData$stateAbbr)
# busData$industName = factor(busData$industName)
# busData$yr = factor(busData$yr)

busData$indLevel = as.character(busData$indLevel)
busData$industName = as.character(busData$industName)
busData$yr = factor(busData$yr)

save(busData, file='busData')


# ggplot(subset(busData, stateAbbr == "CA" & indLevel==1),aes(x=yr, y=tot_payroll, fill=industName)) +
#   geom_bar(stat = 'identity')

