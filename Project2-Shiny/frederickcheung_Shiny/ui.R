#This is my data processing of my healthdf file

setwd("~/github/bootcamp007_project/Project2-Shiny/frederickcheung_Shiny")
library(dplyr)
library(ggplot2)
library(shinydashboard)
library(googleVis)
library(dplyr)

#healthdf <- readRDS("healthdf")

healthdfcountry <- unique(healthdf$Country.Name)
healthdfcat <- unique(healthdf$Topic)
healthdfcatindic <- unique(healthdf$Indicator.Name.x)

dashboardPage(
  dashboardHeader(title = "World Health Data"),
  dashboardSidebar(

    sidebarMenu(
          menuItem("Barchart", tabName = "Barchart", icon = icon("bar-chart-o")),
          menuItem("Map", tabName = "Map", icon = icon("map"))
        )
    ),
  dashboardBody(
    # Boxes need to be put in a row (or column)

    tabItems(
      # First tab content
      
      tabItem(tabName = "Barchart",
        h2("Health Graph by Topic"),
              fluidRow(
          box(plotOutput("plot1", height = 250)),
          box(
            
            selectInput("inCheckboxGroup", "Input checkbox",
                        c("Item A", "Item B", "Item C")),
            selectInput("inSelect", label = "Select input",
                        choices = c("Item A", "Item B", "Item C")),
            
            title = "Controls",
            sliderInput("slider", "Number of observations:", 1, 100, 50)
          )
        )
      ),
      # Second tab content
      tabItem(tabName = "Map",
        h2("Maps of Countries"),
        fluidRow(
          selectInput("select", label = h3("Select box"),
                      choices = healthdfcountry,
                      selected = 1),
          selectInput("select", label = h3("Select box"),
                      choices = healthdfcat,
                      selected = 1),
          # selectInput("select", label = h3("Select box"), 
          #             choices = healthdfcatindic, 
          #             selected = 1),
          
          hr(),
          fluidRow(column(3, verbatimTextOutput("value")))
        )
        
    )#/tabItem2
      )
    )
  )
