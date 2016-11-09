#install.packages("shinydashboard")

library(shinydashboard)
library(googleVis)
library(dplyr)
library(DT)

shinyUI(dashboardPage(
  dashboardHeader(title="911 Calls Seattle"),
  dashboardSidebar(
    sidebarUserPanel(""), # image= <URL>
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("map"))#,
      #menuItem("Data", tabName = "data", icon = icon("database"))
      ),
    selectizeInput("Zoom", label="Zoom", Zoom),
    selectizeInput("Type of call", label="Type of call", Type),
    sliderInput(inputId="Hour", label="Hour", min=0, max=23, value="0"),
    sliderInput(inputId="Day", label="Day", min=1, max=7, value="0")
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "map",
              # 
              fluidRow(infoBoxOutput("maxBox", width=6),
                       infoBoxOutput("minBox", width=6)),
              # 
              fluidRow(box(plotOutput("plot_hour", height = 600 ), width= 12)
              )
      )))
  #tabItem(tabName = "data",
  # datatable
  #fluidRow(box(DT::dataTableOutput("table"))))
   )
  )


