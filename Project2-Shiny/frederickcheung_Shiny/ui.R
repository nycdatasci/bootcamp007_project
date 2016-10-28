#This is my data processing of my healthdf file

setwd("~/Dropbox/Projects_NYCDSA7/Shiny")
library(dplyr)
library(ggplot2)
library(shinydashboard)
library(googleVis)
library(dplyr)

#healthdf <- readRDS("healthdf")

healthdfcountry <- unique(healthdf$Country.Name)
healthdftopic <- unique(healthdf$Topic)
healthdfsubtopic <- unique(healthdf$Indicator.Name.x)


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
                      choices = healthdftopic, 
                      selected = 1),
          # selectInput("select", label = h3("Select box"), 
          #             choices = healthdfsubtopic, 
          #             selected = 1),
          
          hr(),
          fluidRow(column(3, verbatimTextOutput("value")))
        )
        
    )#/tabItem
      )
    )
  )
