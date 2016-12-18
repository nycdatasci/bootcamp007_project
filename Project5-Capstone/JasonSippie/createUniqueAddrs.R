setwd("/Users/sippiejason/datascience/webscraping/realestate/data")

allRec = read.csv("ncresidents_zip28786.csv", stringsAsFactors = F)

uniqueAddr = allRec %>% group_by(addrQuery) %>% 
  summarize(StreetAddr=min(streetAddr), ZipCode=min(zipCode), CityName=min(cityName),
            CountyName=min(countyName),
            HouseID=min(rowID)) %>% arrange(HouseID)
uniqueAddr = sample_frac(uniqueAddr)
names(uniqueAddr)[names(uniqueAddr)=="addrQuery"] <- "AddrQuery"

uniqueAddr$batch = factor(round(as.integer(rownames(uniqueAddr))/500, 0))

write.csv(uniqueAddr, file="uniqueAddrs28786.csv", row.names = F)










