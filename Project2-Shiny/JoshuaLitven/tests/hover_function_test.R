library(visNetwork)
library(shiny)

server <- function(input, output) {
  output$network <- renderVisNetwork({
    # minimal example
    nodes <- data.frame(id = 1:3, label = 1:3)
    edges <- data.frame(from = c(1,2), to = c(1,3))
    
    visNetwork(nodes, edges) %>%
      visInteraction(hover = TRUE) %>%
      visEvents(hoverNode = "function(nodes) {
                Shiny.onInputChange('current_node_id', nodes);
                ;}")
})
  
  output$shiny_return <- renderPrint({
    input$current_node_id
  })
}

ui <- fluidPage(
  visNetworkOutput("network"),
  verbatimTextOutput("shiny_return")
)

shinyApp(ui = ui, server = server)
