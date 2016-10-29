setwd("~/github/bootcamp007_project/Project2-Shiny/frederickcheung_Shiny")
library(dplyr)
library(ggplot2)
library(shinydashboard)
library(googleVis)

healthdf <- readRDS("healthdf")
healthdfcountry <- unique(healthdf$Country.Name)
healthdfcat <- unique(healthdf$Topic)
healthdfcatindic <- unique(healthdf$Indicator.Name.x)

function(input, output, session) {
  set.seed(122)
  histdata <- rnorm(500)

  output$plot1 <- renderPlot({
    data <- histdata[seq_len(input$slider)]
    hist(data)
    

      observe({
        x <- input$inCheckboxGroup
        
        # Can use character(0) to remove all choices
        if (is.null(x))
          x <- character(0)
        
        # Can also set the label and select items
        updateSelectInput(session, "inSelect",
                          label = paste("Select input label", length(x)),
                          choices = x)
      })
    }
  )
}

