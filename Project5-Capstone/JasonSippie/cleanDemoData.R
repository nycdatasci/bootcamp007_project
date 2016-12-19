# demographic data


demog2010 = read.csv("demogData2010.csv", stringsAsFactors = FALSE)
demog2011 = read.csv("demogData2011.csv", stringsAsFactors = FALSE)

demog2015 = read.csv("demogData2015.csv", stringsAsFactors = FALSE)

#start with 2010 
demog = demog2010
demog$ObsYear = 2010
for (i in 2001:2009) {
  temp = demog2010
  temp$ObsYear = i
  demog = rbind(demog, temp)
}

for (i in 2012:2015) {
  temp = demog2015
  temp$ObsYear = i
  demog = rbind(demog, temp)
}


#Start a new dataFrame that will house all our percent levels data
demoClean = data_frame(GeoID = demog$GeoID)
demoClean$ObsYear = demog$ObsYear


demoClean$EduAttainBach = demog$EduAttainBachelors/demog$EduAttainTotal
demoClean$EduAttainHS = demog$EduAttainHS/demog$EduAttainTotal

demoClean$HHMedIncome = demog$HHIncomeMedIncome

demoClean$HHMChildUnder18 = demog$HHwChildUnd18/ demog$HHwChildTotal
demoClean$HHMSeniorsOver65 = demog$HHwSeniorsOver65/ demog$HHwSeniorsTotal

demoClean$MedValue = demog$MedValueMedValue

demoClean$Mortgage = demog$MortStatNumWithMort / demog$MortStatTotal
demoClean$MortAnd2ndAndEq = demog$MortStatNumWithMoreAnd / demog$MortStatTotal
demoClean$MortAnd2ndOrEq = demog$MortStatNumWithMoreOr / demog$MortStatTotal

demoClean$RaceWhite = demog$RaceWhite / demog$RaceTotal

demoClean$HHwRetIncome =  demog$RetIncomeRetIncCnt / demog$RetIncomeTotal


# fill with median value
demoClean$MedValue[is.na(demoClean$MedValue)] = mean(demoClean$MedValue, na.rm=TRUE)

# need one for median income too




# load addrGeo
addrGeo = read.csv("addrGeo.csv", stringsAsFactors = FALSE)

addrGeo = addrGeo[,c('OBJECTID', 'AddrQuery')]
addrDemo = addrGeo %>% inner_join(demoClean, by=c("OBJECTID"="GeoID"))

write.csv(addrDemo,"AddrDemoClean.csv",row.names = F)