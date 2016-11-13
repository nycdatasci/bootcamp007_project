# shinyHome
# Real Estate Analytics and Forecasting
# Nick Talavera
# Date: October 25, 2016

# global.R

###############################################################################
#                         LOAD PACKAGES AND MODULES                          #
###############################################################################
rm(list = setdiff(ls(), lsf.str()))
#require(rCharts)
#options(RCHART_LIB = 'polycharts')
# library(datasets)
# library(forecast)
library(ggplot2)
library(plotly)
# library(plyr)
library(rCharts)
#library(reshape)
library(shiny)
library(shinydashboard)
library(TTR)
library(lettercase)
library(dplyr)
library(scales)
library(RColorBrewer)
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
dnmData <- read.csv("./Data/DNMdata.csv", header = TRUE)
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
unitString = "grams"
#dnmData$Price_Per_Gram = as.numeric(dnmData$Price_Per_Gram)
dnmData = dnmData[dnmData$Price_Per_Gram <= 150000,]
dnmData = dnmData[!is.na(dnmData$Market_Name),]
dnmData$Price_Per_Gram[is.infinite(abs(dnmData$Price_Per_Gram))] = NA
dnmData$Price_Per_Gram[dnmData$Price_Per_Gram == 0] = NA
timeAddedRange = range(dnmData$Time_Added, na.rm = TRUE)
sheetDateRange = range(dnmData$Sheet_Date, na.rm = TRUE)
maxPricePerWeight = roundUpNice(max(dnmData$Price_Per_Gram, na.rm = TRUE))
setwd(home)