require(shiny)
require(visNetwork)

server <- function(input, output) {
  output$network <- renderVisNetwork({
    # minimal example
    nodes <- data.frame(id = 1:3)
    edges <- data.frame(from = c(1,2), to = c(1,3))
    
    visNetwork(nodes, edges) %>% visNodes(color = "blue")
  })
  
  
  observe({
    visNetworkProxy("network") %>%
      visFocus(id = input$Focus, scale = 4)
  })
  
  observe({
    visNetworkProxy("network") %>%
      visNodes(color = input$color)
  })
  
}

ui <- fluidPage(
  fluidRow(
    column(
      width = 4,
      selectInput("color", "Color :",
                  c("blue", "red", "green")),
      selectInput("Focus", "Focus on node :",
                  c(1:3))
    ),
    column(
      width = 8,
      visNetworkOutput("network", height = "400px")
    )
  )
)

shinyApp(ui = ui, server = server)
