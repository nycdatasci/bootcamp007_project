library(shiny)
library(shinydashboard)
# dashboardPage(
#        dashboardHeader(title = "Global Trade"),
#        dashboardSidebar(
#               sliderInput("select_year", "Select year data:", 2005, 2015, 1, step = 1, 
#                           timeFormat = "%Y",
#                           sep = "",
#                           animate=animationOptions(interval=2000, loop=F)
#                           ),
#               sliderInput("select_percentile", "Cutoff by percentile:", 10, 99, 1, step = 1),
#               
#               selectInput("countries", # choose the donors
#                           label = "Choose countries to display",
#                           choices = c('Australia', 'United States', 'United Kingdom'), #Countries,
#                           multiple = TRUE,
#                           selectize = TRUE,
#                           selected = c('Australia', 'United States'))
#               sidebarMenu(
#                      menuItem("Dashboard", tabName = "dashboard"),
#                      menuItem("Raw data", tabName = "rawdata")
#               )
#        ),
#        dashboardBody(
#               tabItems(
#                      tabItem("dashboard",
#                              fluidRow(
#                                     valueBoxOutput("rate"),
#                                     valueBoxOutput("count"),
#                                     valueBoxOutput("users")
#                              ),
#                              fluidRow(
#                                     box(
#                                            width = 8, status = "info", solidHeader = TRUE,
#                                            title = "Popularity by package (last 5 min)",
#                                            bubblesOutput("packagePlot", width = "100%", height = 600)
#                                     ),
#                                     box(
#                                            width = 4, status = "info",
#                                            title = "Top packages (last 5 min)",
#                                            tableOutput("packageTable")
#                                     )
#                              )
#                      ),
#                      tabItem("rawdata",
#                              numericInput("maxrows", "Rows to show", 25),
#                              verbatimTextOutput("rawtable"),
#                              downloadButton("downloadCsv", "Download as CSV")
#                      )
#               )
#        )
# )
# 
# 
# 
# ###########
shinyUI(dashboardPage(
    dashboardHeader(title = "My Dashboard"),
    dashboardSidebar(
        
        sidebarUserPanel("NYC DSA",
                         image = "https://yt3.ggpht.com/-04uuTMHfDz4/AAAAAAAAAAI/AAAAAAAAAAA/Kjeupp-eNNg/s100-c-k-no-rj-c0xffffff/photo.jpg"),
        # sidebarMenu(
        #     menuItem("Map", tabName = "map", icon = icon("map")),
        #     menuItem("Data", tabName = "data", icon = icon("database"))
        # ),
        helpText("Select the following attributes."), ## subtitle
        sliderInput("select_year", "Select year data:", 2010, 2015, 1, step = 1, 
                    timeFormat = "%Y",
                    sep = "",
                    animate=animationOptions(interval=2000, loop=F)),
        sliderInput("select_percentile", "Cutoff by percentile:", 10, 99, 1, step = 1),
        
        selectInput("select_country", # choose the donors
                    label = "Choose countries to display",
                    choices = c('Australia', 'United States', 'United Kingdom'), #Countries,
                    multiple = TRUE,
                    selectize = TRUE,
                    selected = c('Australia', 'United States'))
        # ,        
        # selectizeInput("selected",
        #                "Select Item to Display",
        #                choice)
    ),
    dashboardBody(
        tags$head(
            tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
        ),
        tabItems(
            tabItem(tabName = "map",
                    fluidRow(infoBoxOutput("maxBox"),
                             infoBoxOutput("minBox"),
                             infoBoxOutput("avgBox")),
                    fluidRow(box(plotOutput("chord"), height = 300),
                             box(htmlOutput("sankey"), height = 300))),
            tabItem(tabName = "data",
                    fluidRow(box(DT::dataTableOutput("table"), width = 12)))
        )
    )
))