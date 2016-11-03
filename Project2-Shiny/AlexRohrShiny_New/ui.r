library(shiny)
library(ggplot2) # for the IGN dataset
source('calcs.r')
shinyUI(pageWithSidebar(
  headerPanel('Videogame Review Data since 2012 from IGN'),
  sidebarPanel(
    checkboxGroupInput('show_vars', 'Columns in Reviews to show:',
                       names(Reviews),
                       selected = names(Reviews)),
    helpText('We can select data to show in the table')
  ),
  mainPanel(
    tabsetPanel(
      tabPanel('Reviews', dataTableOutput("mytable1"))
    )
  )
  
))