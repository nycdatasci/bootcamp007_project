library(shiny)
library(shinydashboard)

dashboardPage(
       dashboardHeader(title = "Global Trade"),
       dashboardSidebar(
 
              sliderInput("select_year", 
                          "Select year data:", 2010, 2015, 1, step = 1, timeFormat = "%Y", sep = "", ticks = F
              ),
              
              sliderInput("select_percentile", "Cutoff by percentile:", 80, 95, 1, step = 1
              ),
              
              selectInput("select_country", 
                          label = "Choose countries to display",
                          choices = Countries,
                          multiple = TRUE,
                          selectize = TRUE,
                          selected = c('Singapore', 'Indonesia')
              )
#              ,
              
              
#              sidebarMenu(
#                     menuItem("Dashboard", tabName = "dashboard"),
#                     menuItem("Raw data", tabName = "rawdata")
#              )
       ),
       dashboardBody(
#              tabItems(
#                     tabItem("dashboard",
                             fluidRow(
                                    valueBoxOutput("TopExporter"),
                                    valueBoxOutput("TopImporter")
                             ),
                             fluidRow(
                                    box(
                                           width = 8, status = "info", solidHeader = TRUE,
                                           title = "Global Trade Flow",
                                           plotOutput("chord", width = "100%", height = '550px')
                                    ),
                                    tabBox( width = 4,
                                           title = "Showing top 10 categories",
                                           # The id lets us use input$tabset1 on the server to find the current tab
                                           id = "tabset1",
                                           tabPanel("Top Exporter", tableOutput("CategoryExTable")),
                                           tabPanel("Top Importer", tableOutput("CategoryImTable"))
                                    )

                             )
                     )
#,
#                     tabItem("rawdata",
#                             numericInput("maxrows", "Rows to show", 25),
#                             verbatimTextOutput("rawtable"),
#                             downloadButton("downloadCsv", "Download as CSV")
#                     )
#              )
#       )
)