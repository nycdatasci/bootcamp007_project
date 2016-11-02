library(shiny)
library(leaflet)

fluidPage(
  
  titlePanel("Go,Pokemon!"),
  
  fluidRow(column(width = 4,
                  br(),br(),br(),
                  img(src="pokemon_go_2.png", height = 170.6, width = 290),
                  br(),br(),br(),
                  ## select continuous column
                  selectizeInput(inputId = "ct", 
                                 label = "Select The City:", 
                                 choices = city_choice,
                                 selected = 'New_York'),
                  ## select categorical column
                  selectizeInput(inputId = "mon", 
                                 label = "Select The Pokemon", 
                                 choices = pokemon_choice,
                                 selected = 'Pidgey'),
                  ## select point size 
                  sliderInput(inputId = "size",
                              label = "zoom the map",
                              min = 3, max = 18, value = 11),
                  img(src="pokemon_go_1.jpg", height = 162, width = 288)
                  ),
           column(width = 8,
                  br(),br(),br(),
                  selectizeInput(inputId = "map", 
                                 label = "Select your favorate map provider", 
                                 choices = map,
                                 selected = "CartoDB.Positron"),
                  dataTableOutput('mytable'),
#                 checkboxGroupInput("checkGroup",
#                                     label = h3("Choose the your favorate map provider"),
#                                     choices = list("Google Earth Map" = 1,"Leaflet Map" = 2),
#                                     selected = 1),
                  leafletOutput("mymap")
#                  plotOutput(outputId = "plot",
#                             width="500%", height="500px")
                  
#                  p("Go"),
#                  actionButton("recalc", "New points")
                   
                  ))
           )
  