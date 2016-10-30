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
  dashboardHeader(title = "Citi Bike Availability Analysis"),
  
  dashboardSidebar(
    sidebarUserPanel("Jhonasttan Regalado", image = "JhonasttanRegalado.jpg"),
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("binoculars")),
      menuItem("Bike Gauge", tabName = "gaugeBikes", icon = icon("bicycle",lib = "font-awesome")),
      menuItem("Dock Gauge", tabName = "gaugeDocks", icon = icon("stop-circle-o",lib = "font-awesome")),
      menuItem("Data", tabName = "data", icon = icon("database")),
      menuItem("Intro", tabName = "introVideo", icon = icon("file-video-o"))),
    
    selectInput("selected", "Station Location(s)", c("Stations"="", cb_station_df$stationName), 
                multiple=TRUE), #,selected = c("Pershing Square South")),
    
    textInput("manualAddress", "Street Address (within NY)",placeholder = "Lexington Ave"),
    
    selectInput("zoom","Map Zoom Level", choices = c(11,13,15,17),selected = 13),
    
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
              fluidRow(column(12 ,div(align = "left", HTML("<br><h2>NYC Citi Bike Data via REST API<h2><br>"))),
                       column(12, box(DT::dataTableOutput("table"), width = 12)))),
      tabItem(tabName = "gaugeBikes",
              fluidRow(column(12 ,div(align = "left", HTML("<br><h2>Bike Capacity by Station in Descending Order<h2><br>"))),
                       column(12, box(htmlOutput("gaugeBikes"), height = 30000,width = 18)))),
      tabItem(tabName = "gaugeDocks",
              fluidRow(column(12 ,div(align = "left", HTML("<br><h2>Dock Capacity by Station in Descending Order<h2><br>"))),
                       column(12, box(htmlOutput("gaugeDocks"), height = 30000,width = 18)))),
      tabItem(tabName = "introVideo",
              fluidRow(column(12, div(align = "left", HTML("<br><h2>Analyze NYC Citi Bike Bike / Station Capacity and Plan your Trip<h2><br>"))),
                       column(6, div(align = "left", HTML("<p><h3>I have been fascinated by the number of people riding NYC Citi Bikes to and from work. 
                                                           I’ve asked a few Citi Bike subscribers about their experience, and yes, some have dealt with a pothole or two; therefore, was interested in understanding the logistics. 
                                                           How are the stations replenished and how do users typically deal with bike capacity constraints when they really need a bike. 
                                                           Do they go to a nearby station, or hail a cab? 
                                                          The Citibike Station Capacity Analysis product was developed and implemented within a two-week timeline using the Lean Startup methodology. 
                                                          The goal of this working prototype is to help users address the identified gaps. I welcome you to try the product and 
                                                          provide constructive feedback. Thanks!</p>"))),
                       column(12, div(align = "left", HTML("<br><h2>How to Video<h2><br>"))),
                       column(12, div(align = "left", embed_youtube(id = "StMAiYCMuco", frameborder = 50))),
                       column(12, div(align = "left", HTML("<br><h2>Features<h2>"))),
                       column(12,tags$div(
                                   tags$ul(
                                      tags$li(HTML("<h3><b>Map</b>: Locate and view capacity for multiple stations<h3>")),
                                      tags$li(HTML("<h3><b>Map</b>: View travel time between two stations with cycling directions<h3>")),
                                      tags$li(HTML("<h3><b>Map</b>: Filter on Bike / Dock capacity<h3>")),
                                      tags$li(HTML("<h3><b>Map</b>: Pin map to your location<h3>")),
                                      tags$li(HTML("<h3><b>Bike / Dock Gauge</b>: Gauge Bike / Dock capacity by station<h3>")),
                                      tags$li(HTML("<h3><b>Data</b>: Query NYC Citi Bike station data<h3>"))
                                      
                            )
                          )),
                       column(12, div(align = "left", HTML("<br><h3><b>Feedback<b>: <a href='mailto:jhonasttan@gmail.com?Subject=[Shiny%20App%20Feedback]%20NYC%20Citi%20Bike%20Availability%20Analysis' target='_top'>Jhonasttan Regalado, PMP</a><h3>")))
                       ))
      
      ))
      
  
))