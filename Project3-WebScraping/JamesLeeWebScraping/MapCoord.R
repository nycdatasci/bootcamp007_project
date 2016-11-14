opentable = read.csv("OpenTableData3.csv", stringsAsFactors = F)
library(ggmap)
data2 = cbind(data, geocode(opentable$Address))
write.csv(data2, "OpenTable_LatLong.csv")
