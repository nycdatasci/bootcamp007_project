library(shiny)
library(plotly)
library(shinythemes)
library(googleCharts)

indicator_names_b <-
  c(
    "Sanitation.Facilities",
    "Health.Expenditure",
    "Physicians",
    "Tuberculosis.Success",
    "Tuberculosis.Detection",
    "Tuberculosis.Incidence",
    "Population"
  )

indicator_names_t <- c(indicator_names_b, "Life.Span")

select_yr <- unique(data_long$Year)

shinyUI(
  navbarPage(
    "World Development Health Indicators",
    theme = shinytheme("flatly"),
    id = "nav",
    tabPanel("By Year",
             sidebarLayout(
               sidebarPanel(
                 sliderInput(
                   "year",
                   "Year",
                   min = min(data$Year),
                   max = max(data$Year),
                   value = min(data$Year),
                   animate = FALSE,
                   step = 1
                 ),
                 selectInput("indicator", "Pick one indicator:",
                             indicator_names_b)
               ),
               # End of sidebarLayout
               mainPanel(
                 # loads the Google Charts JS library
                 googleChartsInit(),
                 
                 # Use the Google webfont "Source Sans Pro"
                 tags$link(
                   href = paste0(
                     "http://fonts.googleapis.com/css?",
                     "family=Source+Sans+Pro:300,600,300italic"
                   ),
                   rel = "stylesheet",
                   type = "text/css"
                 ),
                 tags$style(type = "text/css",
                            "body {font-family: 'Source Sans Pro'}"),
                 
                 h2(""),
                 
                 googleBubbleChart("chart",
                                   width = "100%",
                                   height = "475px"),
                 br(),
                 hr(),
                 helpText("Author: Ziqiao Cheryl Liu")
                 
               )# End of mainPanel
             )) # End of tabPanel "By years"
    ,
    ###plot trend over years for individual country
    
    tabPanel("By Country",
             sidebarLayout(
               sidebarPanel( width =3,
                 selectInput("country", "Choose a Country:",
                             choices = sort(trend_cn)),
                 selectInput("indicator1", "Choose an Indicator:",
                             choices = indicator_names_t),
                 selectInput("year1", "Choose a Year:",
                             choices = sort(select_yr))
               ),
               #end of sidebar
               mainPanel(
                 plotlyOutput(outputId = "trend_plot", width = "500px", height = "400px"),
                 hr(),
                 plotlyOutput(outputId = "hist", width = "500px", height = "400px")
                 )# end of mainpanel
             )),
    #End of tabPanel
    
    ###reference
    navbarMenu("Reference",
               tabPanel("Table",
                        DT::dataTableOutput("table")
               ),
               tabPanel("About",
                        fluidRow(
                          includeMarkdown("about.md")
                          )
                          )
    
                           
             )
    )
    )# End of shinyUI
    