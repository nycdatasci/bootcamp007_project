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
library(vembedr)
library(htmltools)


shinyUI(dashboardPage(
  dashboardHeader(title = "Citibike Analysis"),
  
  dashboardSidebar(
    sidebarUserPanel("Jhonasttan Regalado", image = "JhonasttanRegalado.jpg"),
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("binoculars")),
      menuItem("Bike Gauge", tabName = "gaugeBikes", icon = icon("bicycle",lib = "font-awesome")),
      menuItem("Dock Gauge", tabName = "gaugeDocks", icon = icon("stop-circle-o",lib = "font-awesome")),
      menuItem("Data", tabName = "data", icon = icon("database")),
      menuItem("Intro", tabName = "introVideo", icon = icon("file-video-o"))),
    
    selectInput("selected", "Type Location(s)", c("Stations"="", cb_station_df$stationName), 
                multiple=TRUE), #,selected = c("Pershing Square South")),
    
    sliderInput("bikesAvailable", "Bikes Available:",  
                min = 0, max = 50, value = 0, step = 5, round = TRUE),
    
    sliderInput("docksAvailable", "Docks Available:",  
                min = 0, max = 50, value = 0, step = 5, round = TRUE)#,
    
    #actionButton("refresh", "Refresh")
    
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "map",
              fluidRow(infoBoxOutput("station"),
                       infoBoxOutput("destination"),
                       infoBoxOutput("avgBox")
                       ),
              fluidRow(box(tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
                           leafletOutput("map"), height = 500, width = 12))),#,
                       #box(htmlOutput("hist"), height = 300))),
      
      tabItem(tabName = "data",
              fluidRow(box(DT::dataTableOutput("table"), 
                           width = 12))),
      tabItem(tabName = "gaugeBikes",
              fluidRow(box(htmlOutput("gaugeBikes"), height = 30000,width = 18))),
      tabItem(tabName = "gaugeDocks",
              fluidRow(box(htmlOutput("gaugeDocks"), height = 30000,width = 18))),
      tabItem(tabName = "introVideo",
              fluidRow(div(align = "center", embed_youtube(id = "HCRWyB5VSCw"))))
      
      ))
      
  
))