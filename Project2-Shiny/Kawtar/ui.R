library(shiny)




shinyUI(pageWithSidebar(
  
  headerPanel("Co2 emmisions Europe & USA"),
  
  sidebarPanel(
    sliderInput("Years", "Select a Year:",
                min = 2007, max = 2013, value = 0, step = 1,
                animate=FALSE)
  ),
  mainPanel(
    htmlOutput("map"),
    htmlOutput('bar')
  )
)
)


