setwd("~/github/bootcamp007_project/Project2-Shiny/frederickcheung_Shiny")
library(dplyr)
library(ggplot2)
library(shinydashboard)
library(dygraphs)

healthdf <- readRDS("healthdf")
healthdfcountry <- unique(healthdf$Country.Name)
healthdfcat <- unique(healthdf$Topic)
healthdfcatindic <- unique(healthdf$Indicator.Name.x)

function(input, output, session) {
  set.seed(122)
  histdata <- rnorm(500)

  #this controls my 'Controls" box
  observe({
    x <- healthdf %>% filter(., Topic==input$inSelect) %>% select(., Indicator.Name.y)
    x <- unique(x)
    # Can use character(0) to remove all choices
    if (is.null(x))
    x <- character(0)
    # Can also set the label and select items
    updateSelectInput(session, "inSelect2",
                      label = paste("Category Indicator", length(x)),
                      choices = x)
      })#end observe
  
  #this renders my time series graph
  
  
  } #end function
 


