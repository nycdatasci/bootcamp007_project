library(shiny)
library(googleVis)
temp = read.csv(file="./data/temp2009.csv")
temp1994 = read.csv(file="./data/temp1994.csv")
oil = read.csv(file="./data/oil.2009.csv")
# Use a fluid Bootstrap layout
fluidPage(    
  
  # Give the page a title
  titlePanel("Energy Index by Region"),
  
  # Generate a row with a sidebar
  sidebarLayout(      
    
    # Define the sidebar with one input
    sidebarPanel(
#      checkboxGroupInput('show_vars', 'Energy index to show:',
#                         names(temp),
#                         selected = names(temp)),
      selectInput('show_vars', '2009',
                  names(temp)[3:6]),
      selectInput('show_vars2', '1994',
                  names(temp)[3:5]),
      selectInput('show_vars3', 'top 20 oil consumers 2009',
                  names(oil)[2]),
#                  names(temp)),
#      selectInput("region", "Index:", 
#                  choices=colnames(temp)),
#      hr(),
      helpText("Pick an energy index."),
      helpText("population (million)"),
      helpText("natural.gas.consumption (quadrillion Btu)"),
      helpText("coal.consumption (quadrillion Btu)"),
      helpText("CO2.emission (million metric tons)"),
      helpText("oil.consumption (million barrels per day)")
    
    ),

    # Create a spot for the plots
    mainPanel(
      helpText("2009"),
      htmlOutput("firstPlot"),
      
      helpText("1994"),
      htmlOutput("secondPlot"),
      
      helpText("top 20 oil consumers 2009"),
      htmlOutput("thirdPlot")
      
    )
    
  )
)
