library(httr)
library(rjson)
library(RJSONIO)
library(shiny)
library(shinydashboard)
library(dplyr)
library(leaflet)
library(googleVis)
library(data.table)
library(DT)

shinyUI(dashboardPage(
  dashboardHeader(title = "Citibike Analysis"),
  
  dashboardSidebar(
    sidebarUserPanel("Jhonasttan Regalado", image = "JhonasttanRegalado.jpg"),
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("map")),
      menuItem("Data", tabName = "data", icon = icon("database"))),
    
    #selectizeInput("selected",
    #               "Select Item to Display",
    #               choice)
    selectInput("selected", "Select Location (MAX = 2)", c("Stations"="", cb_station_df$stationName), 
                multiple=TRUE,selected = c("W 38 St & 8 Ave","Pershing Square South"))
    
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "map",
              fluidRow(infoBoxOutput("station"),
                       infoBoxOutput("destination"),
                       infoBoxOutput("avgBox")),
              fluidRow(box(tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
                           leafletOutput("map"), height = 500, width = 12))),#,
                       #box(htmlOutput("hist"), height = 300))),
      
      tabItem(tabName = "data",
              fluidRow(box(DT::dataTableOutput("table"), 
                           width = 12)))))
      
  
))