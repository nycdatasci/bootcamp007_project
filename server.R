library(shiny)
library(googleVis)
setwd("~/shiny_proj/data/shiny_files")
temp = read.csv(file="~/shiny_proj/data/shiny_files/data/temp2009.csv")
temp1994 = read.csv(file="~/shiny_proj/data/shiny_files/data/temp1994.csv")
oil = read.csv(file="~/shiny_proj/data/shiny_files/data/oil.2009.csv")
# Define a server for the Shiny app
function(input, output) {
  
  # Fill in the spot we created for a plot
  output$firstPlot <- renderGvis({
    state_em <- gvisGeoChart(temp, "country", input$show_vars, 
                             options=list( 
                               colorAxis="{colors: ['blue', 'green', 'red']}"
                             )
    )
    })
  output$secondPlot <- renderGvis({
    state_em <- gvisGeoChart(temp1994, "country", input$show_vars2, 
                             options=list( 
                               colorAxis="{colors: ['blue', 'green', 'red']}"
                             )
    )
  })
  output$thirdPlot <- renderGvis({
    state_em <- gvisGeoChart(oil, "Country", input$show_vars3, 
                             options=list( 
                               colorAxis="{colors: ['blue', 'green', 'red']}"
                             )
    )
  })
  
}
