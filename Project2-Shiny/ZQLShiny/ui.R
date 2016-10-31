library(shiny)
library(shinythemes)
library(googleCharts)

indicator_names <- colnames(data[,5:12])

shinyUI(
    navbarPage("World Health Indicators",
               theme = shinytheme("flatly"),
               id = "nav",
               tabPanel("By Years",
                       sidebarLayout(
                         sidebarPanel(
                                     sliderInput(
                                       "year",
                                       "Year",
                                       min = min(data$Year),
                                       max = max(data$Year),
                                       value = min(data$Year),
                                       animate = FALSE,
                                       step = 1
                                     ),
                                     selectInput("indicator", "Pick one indicator:",
                                                  indicator_names)), # End of sidebarLayout
                         mainPanel(
                               # This line loads the Google Charts JS library
                               googleChartsInit(),
                               
                               # Use the Google webfont "Source Sans Pro"
                               tags$link(
                                 href = paste0(
                                   "http://fonts.googleapis.com/css?",
                                   "family=Source+Sans+Pro:300,600,300italic"
                                 ),
                                 rel = "stylesheet",
                                 type = "text/css"
                               ),
                               tags$style(type = "text/css",
                                          "body {font-family: 'Source Sans Pro'}"),
                               
                               h2("World Health Development Indicator"),
                               
                               googleBubbleChart(
                                 "chart",
                                 width = "100%",
                                 height = "475px"
                               )
                           
                           )# End of mainPanel
                  )) # End of tabPanel "By years"
)) # End of shinyUI
