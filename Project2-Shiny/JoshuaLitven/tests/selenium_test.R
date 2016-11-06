devtools::install_github("ropensci/RSelenium", force=TRUE)

library(RSelenium)
library(RCurl)

checkForServer()

startServer(javaargs=c("~/Downloads/chromedriver"), log=FALSE, invisible=FALSE)
remDr = remoteDriver(browserName="chrome")
remDr$open()
