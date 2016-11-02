library(dplyr)
library(shinydashboard)


shinyUI(dashboardPage(
  dashboardHeader(title = "Economic Confidence Survey"),
  dashboardSidebar(
    
    sidebarUserPanel("Yehui He",
                     image = "http://1af60cd74e95fe387bc8-1bfee98aeb105b45275a9419b6310abb.r63.cf1.rackcdn.com/146/1/large.jpg"
    ),
    
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("map")),
      menuItem("Charts", tabName = "charts", icon = icon("bar-chart"))),
      menuItem("Bar Charts", tabName = "bar", icon = icon("bar-chart")),
  
        selectizeInput("selected",
                   "Select country to Display",
                   choice)),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "map",
              # gvisGeoChart
              fluidRow(infoBoxOutput("maxBox"),
                       infoBoxOutput("minBox"),
                       infoBoxOutput("avgBox")),
              
              
              fluidRow(box(htmlOutput("map"),
                           height = 300),
                       # gvisHistoGram
                       box(htmlOutput("hist"),
                           height = 300))),
      tabItem(tabName = "bar",      
              fluidRow(box(htmlOutput("bar"),
                          width = "100%"))),
      tabItem(tabName = "charts",
              # datatable
              fluidRow(box(DT::dataTableOutput("table"),
                           width = 12)))
      
    )
  ) # End of dashbody
  ))


