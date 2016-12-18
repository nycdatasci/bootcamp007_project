# Darknet Market Analyzer
# Darknet Market Analysis
# Nick Talavera
# Date: October 25, 2016

# global.R

rm(list = ls()) #If I want my environment reset for testing.
#===============================================================================
#                       LOAD PACKAGES AND MODULES                              #
#===============================================================================
library("ggplot2")
library("plotly")
library("rCharts")
library("shiny")
library("shinydashboard")
library("TTR")
library("lettercase")
library("dplyr")
library("scales")
library("RColorBrewer")
library("flexdashboard")
library("DT")
library("wordcloud")
library("shinythemes")
library("tm")
library("SnowballC")
library("leaflet")
library("wordcloud")
library("RColorBrewer")
library("DataCombine")
library("data.table")
#===============================================================================
#                                SETUP PARALLEL                                #
#===============================================================================
library("foreach")
library("parallel")
library("doParallel")
cores.Number = max(1, detectCores() - 1)
cl <- makeCluster(2)
registerDoParallel(cl, cores=cores.Number)
#===============================================================================
#                               GENERAL FUNCTIONS                              #
#===============================================================================
roundUpNice <- function(x, nice=c(1,2,4,5,6,8,10)) {
  if(length(x) != 1) stop("'x' must be of length 1")
  10^floor(log10(x)) * nice[[which(x <= 10^floor(log10(x)) * nice)[[1]]]]
}

printCurrency <- function(value, currency.sym="$", digits=2, sep=",", decimal=".") {
  paste(
    currency.sym,
    formatC(value, format = "f", big.mark = sep, digits=digits, decimal.mark=decimal),
    sep=""
  )
}
#===============================================================================
#                                    LOAD DATA                                 #
#===============================================================================
if (dir.exists('/home/bc7_ntalavera/Dropbox/Data Science/Data Files/Darknet Data/')) {
  dataLocale = '/home/bc7_ntalavera/Dropbox/Data Science/Data Files/Darknet Data/' 
} else if (dir.exists('/Volumes/SDExpansion/Data Files/Darknet Data/')) {
  dataLocale = '/Volumes/SDExpansion/Data Files/Darknet Data/'
}
if (!exists("dnmData")) { 
  dnmData <- data.frame(fread(paste0(dataLocale,"DNMdata.csv"), header = TRUE, nrows = 500000*1.5,
                              stringsAsFactors = TRUE,
                              drop = c("X","V1","Ask","Bid","Last","BitcoinVolume","Item_Name_Full_Text",
                                       "Vendor_Name","Drug_Quantity","Drug_Quantity_In_Order_Unit","Drug_Weight",
                                       "Price","Drug_Weight_Unit")))
  dnmData$Sheet_Date = as.Date(dnmData$Sheet_Date)
  dnmData$Time_Added = as.Date(dnmData$Time_Added)
  unlist(lapply(dnmData,class))
  dnmData = dnmData[dnmData$Price_Per_Gram <= 150000,]
  dnmData = dnmData[!is.na(dnmData$Market_Name),]
  dnmData$Price_Per_Gram[is.infinite(abs(dnmData$Price_Per_Gram))] = NA
  # dnmData$Price_Per_Gram[dnmData$Price_Per_Gram == 0] = NA
}
#===============================================================================
#                                SETUP VARIABLES                               #
#===============================================================================
unitString = "grams"
timeAddedRange = range(dnmData$Time_Added, na.rm = TRUE)
sheetDateRange = range(dnmData$Sheet_Date, na.rm = TRUE)
AvailableMarkets = str_title_case(sort(c(as.character(unique(dnmData$Market_Name)))))
AvailableDrugs = str_title_case(sort(c(as.character(unique(dnmData$Drug_Type)))))
AvailableCountries = str_title_case(sort(c(as.character(unique(dnmData$Shipped_From)))))
maxPricePerWeight = roundUpNice(max(dnmData$Price_Per_Gram, na.rm = TRUE))
par(bg="transparent")
stopCluster(cl)