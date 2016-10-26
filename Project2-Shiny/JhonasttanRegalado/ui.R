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
library(googleVis)


shinyUI(dashboardPage(
  dashboardHeader(title = "Citibike Analysis"),
  
  dashboardSidebar(
    sidebarUserPanel("Jhonasttan Regalado", image = "JhonasttanRegalado.jpg"),
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("map")),
      menuItem("Gauge", tabName = "gauge", icon = icon("line_chart",lib = "font-awesome")),
      menuItem("Data", tabName = "data", icon = icon("database"))),
    
    selectInput("selected", "Select Location(s)", c("Stations"="", cb_station_df$stationName), 
                multiple=TRUE,selected = c("Pershing Square South"))
    
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "map",
              fluidRow(infoBoxOutput("station"),
                       infoBoxOutput("destination")#,
                       #infoBoxOutput("avgBox")
                       ),
              fluidRow(box(tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
                           leafletOutput("map"), height = 500, width = 12))),#,
                       #box(htmlOutput("hist"), height = 300))),
      
      tabItem(tabName = "data",
              fluidRow(box(DT::dataTableOutput("table"), 
                           width = 12))),
      tabItem(tabName = "gauge",
              fluidRow(box(htmlOutput("gauge"), height = 30000,width = 18)))
      ))
      
  
))