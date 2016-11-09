library(shiny)
runApp(list(ui= fluidPage(
  titlePanel("opening web pages"),
  sidebarPanel(
    selectInput(inputId='test',label=1,choices=1:5)
  ),
  mainPanel(
    htmlOutput("inc")
  )
),
server = function(input, output) {
  getPage<-function() {
    return((HTML(readLines('http://www.google.com'))))
  }
  output$inc<-renderUI({
    x <- input$test  
    getPage()
  })
})
)