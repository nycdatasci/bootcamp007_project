setwd("~/Dropbox/Projects_NYCDSA7/Shiny")
library(dplyr)
library(ggplot2)
library(shinydashboard)
library(googleVis)

healthdf <- readRDS("healthdf")
healthdftopic <- unique(healthdf$Topic)

function(input, output) {
  set.seed(122)
  histdata <- rnorm(500)

  output$plot1 <- renderPlot({
    data <- histdata[seq_len(input$slider)]
    hist(data)
    
function(input, output) {
      
      # You can access the value of the widget with input$select, e.g.
      output$value <- renderPrint({healthdftopic}) #map to healthdf$topic
      
    }
  })
}

