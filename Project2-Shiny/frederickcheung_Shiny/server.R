#This is the server to my UI 

# setwd("~/Dropbox/Projects_NYCDSA7/Shiny/Test Project")
library(dplyr)
library(shinydashboard)
library(googleVis)

USLifeExpectancyGender <<- readRDS("USLifeExpectancyGender")

function(input, output) {
  set.seed(122)
  histdata <- rnorm(500)
    
  output$LifeExpect <- renderGvis({
    
    LExpect=gvisMotionChart(USLifeExpectancyGender, 
                            idvar="Indicator.Name", 
                            timevar="year")
    LExpect
      
    }) #end render Gvis
  } #end function
 


