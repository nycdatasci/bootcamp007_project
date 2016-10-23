library(shinydashboard)
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
    
    selectizeInput("selected",
                   "Select Item to Display",
                   choice)
    
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "map",
              fluidRow(infoBoxOutput("maxBox"),
                       infoBoxOutput("minBox"),
                       infoBoxOutput("avgBox")),
              fluidRow(box(tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
                           leafletOutput("map"), height = 300, width = 12))),#,
                       #box(htmlOutput("hist"), height = 300))),
      
      tabItem(tabName = "data",
              fluidRow(box(DT::dataTableOutput("table"), 
                           width = 12)))))
      
  
))