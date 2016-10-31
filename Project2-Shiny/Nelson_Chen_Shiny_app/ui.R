###################################################
# Nelson Chen
# nchen9191@gmail.com
# NYC Data Science Academy
# Shiny Project
# UI code
###################################################

library(shiny)
library(shinydashboard)
library(dplyr)
library(maps)
library(DT)
library(leaflet)
library(geosphere)
library(ggplot2)
library(ggthemes)

shinyUI(dashboardPage(
    dashboardHeader(title = "2008 Airline Delays"),
    dashboardSidebar(
        sidebarMenu(
            # Tab buttons
            menuItem("Introduction", tabName = "info", icon = icon('bolt')),
            menuItem("Map", tabName = "Map", icon = icon("map")),
            menuItem("Stats", tabName = "Stats", icon = icon("line-chart")),
            #menuItem("Delay Causes", tabName = "delay_causes", icon = icon('clock-o')),
            menuItem("Future Improvements", tabName = "future", icon = icon("file"))
        )
    ),
    dashboardBody(
      tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
      ),
        tabItems(
          
            # Introduction to App
            tabItem(tabName = 'info',
                    div(style = 'overflow-y: scroll',
                        mainPanel(
                          box(h1("Deeper Look into Airline Delays"),
                              h3(),
                              img(src="http://damhyul3s75yv.cloudfront.net/photos/8651/original_Flight_Cancellation_or_Delay-Tips_for_What_to_Do.jpg", 
                                  style="max-width: 80%; max-height: 80%"),
                              h3(),
                              h2("The Flight Delayed Experience:"),
                              h3(),
                              h4("You spend an hour making your way to the airport on the outskirts of town.
                                 You get there an hour or two early to make sure you make your flight. Now you
                                 have to get through security dealing with long lines, body scanners, random searches,
                                 and putting your laptop in a separate bin. Finally you make it to your gate, to find
                                 out that your flight is delayed for any number of reasons (usually they don't tell you).
                                 Now you're stuck waiting at the gate indefinitely until you can get on your flight."),
                              h3(),
                              h2("Flight Delay Shiny app"),
                              h3(),
                              h4("This app was made to visualize the flight delays in the U.S. in 2008 to have a better 
                                 sense of how likely and often a delay occurs based on your airport, route, and airline.
                                 In the Map tab, the user can choose the airport and time frame to see the routes on the
                                 US map of the top 10 (or max routes) originating from the chosen airport. In the stats
                                 tab, the user can specify the route and airline to see the delay trends by day of the week
                                 and month."),
                              h3(),
                              h2("Data Set"),
                              h3(),
                              h4("2008 Flight data from Stat Computing Data Expo:"),
                              h4("http://stat-computing.org/dataexpo/2009/the-data.html"),
                              h3(),
                              h4("Airport Data"),
                              h4("http://datasets.flowingdata.com/tuts/maparcs/ airports.csv"),
                              h5(""), 
                              width = 12)))),
          
            # Map tab
            tabItem(tabName = "Map",
                fluidRow(
                    column(width = 8,
                           box(width = NULL, solidHeader = TRUE,
                              leafletOutput("mymap", height = 400), # US map
                              DT::dataTableOutput("table") # Corresponding data table
                             )
                            ),
                    column(width = 4,
                           box(width = NULL, status = "warning",
                               selectInput("airport", "Airport Letter Code", selected = 'JFK',
                                               airport_codes),
                               selectInput("sort_choice", "Sorting Factor",
                                               choices = c('Total Delays', 'Percentage')),
                               sliderInput('months', 'Month Range',min=1, max=12,
                                               value=c(1,12)))
                          )
                        )
                    ),
            
            # Summary stats
            tabItem(tabName = 'Stats',
                fluidRow(
                    
                    # Choose starting airport from drop down menu
                    column(width = 4,
                           box(width = NULL, status = "warning",
                               selectInput("airport_start", "Origin Airport", selected = 'JFK',
                                             c('All',airport_codes))
                                
                          )
                      ),
                    # Choose ending airport from drop down menu
                    column(width = 4,
                           box(width = NULL, status = "warning",
                               selectInput("airport_end", "Destination Airport", selected = 'SFO',
                                             c('All',airport_codes))
                                 
                             )
                      ),
                    
                    # Choose airline from drop down menu
                    column(width = 4,
                           box(width = NULL, status = "warning",
                               selectInput("AirLine", "Air Line Carrier", selected = 'AA',
                                             c('All' = 'All', names(Airlines)))
                                 
                             )
                      )
                      
                    ),
                
                    # Plot bar chart and line graph 
                    fluidRow(
                      plotOutput("barchart", height = 300, width = 900),
                      plotOutput("lineGraph", height = 300, width = 900)
                    )
              
            ),
            #tabItem(tabName = 'delay_causes',
                    
              
            #),
            
            tabItem(tabName = 'future',
                    mainPanel(
                      h1("Future Improvements"),
                      h3(),
                      h3("- Include more data (i.e 2015 Flights)"),
                      h3("- Include delay times"),
                      h3("- Include delay reasons"),
                      h3("- Find data of flight prices to study correlation with delays")
                    )
              
            )
        )
    )
))