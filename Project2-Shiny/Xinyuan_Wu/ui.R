library(googleVis)
library(shiny)

fluidPage(theme = shinytheme("yeti"),
          tags$div(tags$style('#about { background-image: url("ForRaccoon.png");
                                        opacity: 1; height: 100%; width: 100%; 
                                        color:black; position: absolute; top: 0; left: 0;}')),
          navbarPage("MPG for 2012-2017 Vehicle (beta)", id = 'nav', 
                     tabPanel("About This App",
                              div(id = 'about',
                                fluidRow(
                                    column(width = 7, offset = 1,
                                           br(),
                                           br(),
                                           br(),
                                           br(),
                                           br(),
                                           h2(strong("Motivation")),
                                           br(),
                                           h3('This app is designed to explore the parameters of 2012-2017 vehicles,
                                              with the emphasis on fuel consumption.'),
                                           br(),
                                           h2(strong('Using this app, you can:')),
                                           br(),
                                           h3('1. Explore the factors that affact the fuel consumption'),
                                           br(),
                                           h3('2. Visualize manufactuers effort on saving fuels'),
                                           br(),
                                           h3('3. Get a recommendation on your next car')
                                           )

                                           
                                  # tags$img(src = "background.png", height = 1080, width = 1920)
                                ))
                     ),
                     tabPanel("Understand MPG",
                              fluidRow(
                                  column(
                                      width = 2,
                                      style = "background-color: #F8F8F8",
                                      h4('Factor that impact MPG'),
                                      br(),
                                      selectInput('type',
                                                  'Select a vehicle type you want to explore',
                                                  choices = select_type),
                                      br(),
                                      selectInput('mpgtype',
                                                  'Select a fuel consumption measurement',
                                                  choices = select_mpg),
                                      submitButton("Submit"),
                                      br(),
                                      br()

                                  ),
                                  column(5, plotOutput(outputId = "plot1", width = "500px", height = "320px"),
                                         br(),
                                         br(),
                                         br(),
                                         plotOutput(outputId = "plot4", width = "500px", height = "320px")),
                                  column(5, plotOutput(outputId = "plot2", width = "500px", height = "320px"),
                                         br(),
                                         br(),
                                         br(),
                                         plotOutput(outputId = "plot3", width = "500px", height = "320px"))
                                  )
                     ),
                     tabPanel("Explore by Manufacturer",
                              fluidRow(
                                  column(
                                         width = 2,
                                         style = "background-color:#F8F8F8",
                                         h4('Select a manufacturer'),
                                         br(),
                                         selectInput('manuf',
                                                     'Select manufacturer',
                                                     choices = select_manuf),
                                         submitButton("Submit"),
                                         br(),
                                         br()
                                  ),
                                  column(width = 10,
                                         htmlOutput("plot5"),
                                         br(),
                                         br()
                                         # htmlOutput("plot6")
                                  )
                             )
                     ),
                     tabPanel("Select Your Next Vehicle",
                              fluidRow(
                                  column(
                                      width = 2,
                                      style = "background-color:#F8F8F8",
                                      h4('Make selections below'),
                                      br(),
                                      selectInput('condition',
                                                  'Select vehicle condition',
                                                  choices = c('', select_condition),
                                                  selected = NULL),
                                      br(),
                                      selectInput('carline',
                                                  'Select vehicle type',
                                                  choices = c('', select_type),
                                                  selected = NULL),
                                      br(),
                                      selectInput('lux',
                                                  'Select vehicle class',
                                                  choices = c('', select_lux),
                                                  selected = NULL),
                                      br(),
                                      selectInput('trans',
                                                  'Select transmission type',
                                                  choices = c('', select_trans),
                                                  selected = NULL),
                                      br(),
                                      # actionButton("button1", "Get Range"),
                                      submitButton("Limit Annual Fuel Cost"),
                                      br(),
                                      uiOutput('ui'),
                                      br(),
                                      submitButton("Get results"),
                                      br(),
                                      br()
                                  ),
                                  column(width = 10,
                                         DT::dataTableOutput("table_output")
                                  )
                              )
                     )
         )

)