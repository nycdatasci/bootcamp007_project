library(shiny)
library(shinydashboard)
library(rpivotTable)
library(googleVis) 

shinyUI(
  dashboardPage(
  ## Title              
  dashboardHeader(title="Kickstarter Explorer"),
  
  ## Sidebar
  dashboardSidebar(
    sidebarMenu(
      menuItem("Summary", tabName = "sumTab", icon = icon("bar-chart")),
      menuItem("Project Explorer", tabName = "bubble", icon = icon("dot-circle-o")),
      menuItem("Crosstab", tabName = "sum1", icon = icon("map")),
      menuItem("Data", tabName = "data", icon = icon("database")),
      
      ## Location filter
      selectInput(
        "f_location",
        label = "Choose a location",
        choices = pledged %>% 
                  filter(Country=='US', nchar(State) == 2) %>% 
                  distinct(State) %>% 
                  arrange(State),
        selected = "NY"
      ),
      
      ## Status filter
      checkboxGroupInput(
        "f_status",
        label = "Choose status(es)",
        choices = c("canceled", "failed", "live", "successful", "suspended"),
        selected = "live"
      )
    )
  ),
  dashboardBody(
    ## CSS head tag
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    
    tabItems(
      tabItem(tabName = "sumTab",
              fluidRow(
                column(width=7,
                  box(
                    h2("Welcome to the Kickstarter Explorer"),
                    p('This app is built off a dataset from:', a('webrobots.io', href="http://webrobots.io/kickstarter-datasets/"), 
                      '. It contains data scraped from Kickstarter up to 2016-10-15. I limited the scope of data to only ', strong('U.S Kickstarter projects'), 'who have at least some money pledged to it.'))
                  ),
                column(width=4, DT::dataTableOutput("sumTable"))
                #column(width=12),
                #column(width=12),
                #column(width=12),
                #column(width=12)
              )
            ),
      tabItem(tabName = "bubble",
              fluidRow(
                box(htmlOutput("bubbles"), width = 10)
              )),
      tabItem(tabName = "sum1",
              fluidRow(
                rpivotTableOutput("pivotSum")
              )),
      tabItem(tabName = "data",
              fluidRow(box(DT::dataTableOutput("table"), width = 12)
              ))
    )
  )
))
