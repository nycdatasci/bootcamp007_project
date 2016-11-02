library(shiny)
library(ggplot2) # for the IGN dataset
shinyUI(pageWithSidebar(
  headerPanel('Videogame Review Data since 2012 from IGN'),
  sidebarPanel(
    checkboxGroupInput('show_vars', 'Columns in Reviews to show:',
                       names(Reviews),
                       selected = names(diamonds)),
    helpText('We can select data to show in the table')
    ),
  mainPanel(
    tabsetPanel(
      tabPanel('Reviews', dataTableOutput("mytable1"))
    )
  )
    
))


fluidPage(
  # Application title
  titlePanel("Word Cloud"),
  
  sidebarLayout(
    # Sidebar with a slider and selection inputs
    sidebarPanel(
      selectInput("selection", "Choose a book:",
                  choices = books),
      actionButton("update", "Change"),
      hr(),
      sliderInput("freq",
                  "Minimum Frequency:",
                  min = 1,  max = 50, value = 15),
      sliderInput("max",
                  "Maximum Number of Words:",
                  min = 1,  max = 300,  value = 100)
    ),
    
    # Show Word Cloud
    mainPanel(
      plotOutput("plot")
    )
  )
)