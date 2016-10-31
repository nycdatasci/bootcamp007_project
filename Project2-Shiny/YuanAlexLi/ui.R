library(shiny)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(caret)
library(RSQLite)
library(sp)

dashboardPage(
  skin="green",
  
  dashboardHeader(
    title = "Pokemon Go Observer"
    ),
  dashboardSidebar(
    sidebarMenu(id="menu",
      menuItem("Information", tabName="info", icon=icon("book")),
      menuItem("Map", tabName="map", icon=icon("map")),
      menuItem("Density Contour", tabName="contour", icon=icon("circle"))
    ),  
    
    conditionalPanel(
      condition = "input.menu == 'map'",
      
      selectizeInput("id", "Pokemon", choices=pokeID$Pokemon, selected="All", multiple=TRUE),
      sliderInput("freq", "Number", min=1, max=10000, value=1000),
      selectizeInput("region", "Region", choices=c("Australia", "Asia", "Africa", "North America",
                                                   "South America", "Europe"), selected="North America"),
      actionButton("go", "Go!")
    ),

    conditionalPanel(
      condition = "input.menu == 'contour'",
      
      selectizeInput("city", "Region", choices=cities, selected="Edmonton"),
      actionButton("gen", "Generate")
    )

  ),
  dashboardBody(
    tags$head(
      tags$link(rel="stylesheet", type="text/css", href="custom.css")
    ),
    tabItems(
      tabItem(
        tabName="info",
        h1("Pokemon Go Observer/Predictor", align="center"),
        # h3("Motivation:"),
        # p("This project originally started as an e"),
        h3("Functionality:"),
        p("Visualization: Displays all pokemon and their previous spawn location."),
        p("Prediction: Predicts the rarity of a pokemon spawning at a specific location using a k-nearest neighbor algorithm."),
        p("Regional Density and Distribution: Generates the contour plot of major regions based on the pokemon density, and 
          provides the rarity distribution of that region."),
        h4("K-Nearest Neighbor Algorithm"),
        # p("The k-NN classifier "),
        p(img(src="KnnClassification.png")),
        p("The reason k-NN model was chosen as the prediction model due to:"),
        p("k-NN is a non-parametric algorithm that is based on distance metrics, which is perfect for this data (Euclidean distance)."),
        p('k-NN is better at multiclass classification, while other non-parametric models such as Support Vector Machine will
          not be as accurate.'),
        h3("Data Source: "),
        p("The dataset is obtained from Kaggle")
        ),
      tabItem(
        tabName="map",
        fluidRow(
          infoBoxOutput("position", width=6),
          infoBoxOutput("prediction", width=6)
        ),
        fluidRow(
          leafletOutput("map"))

      ),
      tabItem(
        tabName="contour",
        fluidRow(
          tabBox(
            width="250px",
            tabPanel("Contour Map", 
                     leafletOutput("kdeMap")),
            tabPanel("Distribution",
                     plotOutput("rareDist"))
          )
        )
          
      )


    )
    
  )
)
