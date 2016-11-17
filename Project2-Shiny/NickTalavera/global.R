# Darknet Market Visualizer
# By Nick Talavera
# Created on October 25, 2016

# global.R

###############################################################################
#                         LOAD PACKAGES AND MODULES                          #
###############################################################################
# rm(list = ls())
usePackage <- function(p) {
  if (!is.element(p, installed.packages()[,1]))
    install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}

#options(RCHART_LIB = 'polycharts')
usePackage("ggplot2")
usePackage("plotly")
usePackage("rCharts")
usePackage("shiny")
usePackage("shinydashboard")
usePackage("TTR")
usePackage("lettercase")
usePackage("dplyr")
usePackage("scales")
usePackage("RColorBrewer")
usePackage("flexdashboard")
usePackage("DT")
usePackage("wordcloud")
usePackage("shinythemes")
usePackage("tm")
usePackage("SnowballC")
usePackage("leaflet")
usePackage("wordcloud")
usePackage("RColorBrewer")
################################################################################
#                             GLOBAL VARIABLES                                 #
################################################################################
#Default  Values
dflt <- list(state = "", county = "", city = "", zip = "", model = "ARIMA", 
             split = as.integer(2014), maxValue = as.integer(1000000), stringsAsFactors = FALSE)

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
###############################################################################
#                               LOAD DATA                                     #
###############################################################################
#Delete the following line before deploying this to shiny.io
options(scipen=999)

# Read model data
if (dir.exists('/home/bc7_ntalavera/Dropbox/Data Science/Data Files/Darknet Data/')) {
  dataLocale = '/home/bc7_ntalavera/Dropbox/Data Science/Data Files/Darknet Data/' 
} else if (dir.exists('/Volumes/SDExpansion/Data Files/Darknet Data/')) {
  dataLocale = '/Volumes/SDExpansion/Data Files/Darknet Data/'
}
if (!exists("dnmData")) { 
  dnmData <- read.csv(paste0(dataLocale,"DNMdata.csv"), header = TRUE, nrows = 2000000)
  dnmData$Sheet_Date = as.Date(dnmData$Sheet_Date)
  dnmData$Time_Added = as.Date(dnmData$Time_Added)
  dnmData$X = NULL
  dnmData$X = NULL
  dnmData$Item_Name_Full_Text = NULL
  dnmData$Vendor_Name = NULL
  dnmData$Drug_Quantity = NULL
  dnmData$Drug_Quantity_In_Order_Unit = NULL
  dnmData$Drug_Weight = NULL
  dnmData$Price = NULL
  dnmData$Drug_Weight_Unit = NULL
  dnmData = dnmData[dnmData$Price_Per_Gram <= 150000,]
  dnmData = dnmData[!is.na(dnmData$Market_Name),]
  dnmData$Price_Per_Gram[is.infinite(abs(dnmData$Price_Per_Gram))] = NA
  dnmData$Price_Per_Gram[dnmData$Price_Per_Gram == 0] = NA
}
unitString = "grams"
timeAddedRange = range(dnmData$Time_Added, na.rm = TRUE)
sheetDateRange = range(dnmData$Sheet_Date, na.rm = TRUE)
maxPricePerWeight = roundUpNice(max(dnmData$Price_Per_Gram, na.rm = TRUE))
par(bg="transparent")