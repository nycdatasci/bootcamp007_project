library(googleVis)
library(shiny)
library(shinythemes)

fluidPage(  
          navbarPage("Chord Progression in Modern Music", id = 'nav', 
                     tabPanel("Presentation",
                              div(id = 'about',
                                fluidRow(
                                    column(width = 12, offset = 1,
                                           br(),
                                            includeHTML("EDA.html")
                                           )
                                ))
                     ),
                     #####
                     tabPanel("Artist Signature Explorer",
                              fluidRow(
                                  column(
                                      width = 2,
                                      style = "background-color: #F8F8F8",
                                      h4('Explore chord progressions by...'),
                                      br(),
                                      selectInput("select_artist",
                                                  label = "Choose artist to explore",
                                                  choices = artists,
                                                  multiple = TRUE,
                                                  selectize = TRUE,
                                                  selected = "U2"
                                      ),
                                      submitButton("Get Signature")
                                  ),
                                  column(width = 10,
                                         htmlOutput("sankey_a"))
                                  )
                     ),
                     ####
                     tabPanel("Genre Signature Explorer",
                              fluidRow(
                                  column(
                                      width = 2,
                                      style = "background-color:#F8F8F8",
                                      h4('Explore chord progressions by...'),
                                      br(),
                                      textInput("select_genre",
                                                  label = "Choose genre to explore",
                                                  value = "pop"
                                      ),
                                      submitButton("Get Signature")
                                  ),
                                  column(width = 10,
                                         htmlOutput("sankey_g")
                                  )
                      
                              )
                     ),
                     tabPanel("Insights",
                              div(id = 'about',
                                  fluidRow(
                                    column(width = 12, offset = 1,
                                           br(),
                                           p("I-V-vi-IV stands out in the dataset as the most commonly used progression."),
                                           br(),
                                           p("Starting with a vi conveys a sadder tone than using I.")
                                    )
                                  ))
                     )
                     #####
         )

)
