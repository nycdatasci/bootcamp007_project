# Run artist_network first
require(shiny)
require(visNetwork)

nodes <- data.frame(id = 1:3, names=c("oasis", "radiohead", "stars"))
edges <- data.frame(from = c(1,2), to = c(1,3))

server <- function(input, output) {
  output$network <- renderVisNetwork({

    network

  })
  output$shiny_return <- renderPrint({
    
    if(input$network_selected == ""){
      "No Artist Selected"
    }else{
      cat(get_artist_bio(as.character(filtered_nodes[filtered_nodes$id == input$network_selected, ][['name']])))
     
          }
  })
  
  output$artist_details = renderUI({
    artist_bio = get_artist_bio(as.character(filtered_nodes[filtered_nodes$id == input$network_selected, ][['name']]))
    HTML(artist_bio)
  })
}

ui <- fluidPage(
  fluidRow(
    column(8, 
           visNetworkOutput("network")
    ),
    column(4,
           #verbatimTextOutput("shiny_return")
           #uiOutput("artist_details")
           htmlOutput("artist_details")
    )
    )
)

shinyApp(ui = ui, server = server)

