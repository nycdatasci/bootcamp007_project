library(shiny)
library(shinydashboard)
library(shinyjs)

ui <-dashboardPage(
  dashboardHeader(),
  dashboardSidebar(
  ),
  dashboardBody(
    useShinyjs(),
    div(id = "greetbox-outer",
        box( id ="greetbox",
             width  = 12, 
             height = "100%",
             solidHeader = TRUE, 
             status = "info",
             div(id="greeting", "Greeting here") 
        )
    ),
    box( id ="box",
         width  = 12, 
         height = "100%",
         solidHeader = TRUE, 
         status = "success",
         
         textInput("txtbx","Enter text: ")
    )
  )
)

server <- shinyServer(function(input, output, session) {
  observeEvent(input$txtbx,{
    if (input$txtbx == "") return(NULL)
    hide(id = "greetbox-outer", anim = TRUE)
    print(input$txtbx)
  })
})

shinyApp(ui = ui, server = server) 
