library(leaflet)
library(ggplot2)
library(plotly)

# Choices for school district drop-down
vars <- sort(unique(hs_info_disp$School_District))
##

navbarPage("NYC Public High Schools", id="nav",

  tabPanel("Interactive map",
    div(class="outer",

      tags$head(
        # Include our custom CSS
        includeCSS("styles.css"),
        includeScript("gomap.js")
      ),

      leafletOutput("map", width="100%", height="100%"),

      # Shiny versions prior to 0.11 should use class="modal" instead.
      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
        draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
        width = 330, height = "auto",
        plotOutput("SAT_2012_hist", height = 150),
        plotOutput("survey_2011_hist", height = 150),
        plotOutput("student_number", height = 150),
        htmlOutput("School_Info")
      ),

      tags$div(id="cite",
        'Data from ', tags$em('NYC Dept. of Education'), '2016'
      )
    )
  ),

  tabPanel("School Info",
    fluidRow(
      column(3,
        selectInput("boroughs", "Borough", c("NYC"="", "Manhattan", "Brooklyn", "Bronx", "Queens", "Staten Island"), multiple=TRUE)
      ),
      column(3,
        conditionalPanel("input.boroughs",
          selectInput("neighborhoods", "Neighborhood", c("All Neighborhoods"=""), multiple=TRUE)
        )
      )
    ),
    tags$li("Click a school name in the table will go to the school's location on map."),
    hr(),
    DT::dataTableOutput("hs_info"),
    htmlOutput("School_Info_dt")
    
  ),
  tabPanel("School District Comparison",
           fluidRow(
               column(3,
                      selectInput("selection1", 
                                  "School District Selection 1", 
                                  c("NYC"="", vars), 
                                  multiple=TRUE)
               ),
               column(3,
                      conditionalPanel("input.selection1",
                                       selectInput("selection2", 
                                                   "School District Selection 2", 
                                                   c("School District"=""), 
                                                   multiple=TRUE)
                      )
               ),
               column(4, 
                      selectInput("variable",
                                  "Variables",
                                  c("2012 SAT Score",
                                    "2010 SAT Score",
                                    "2011 High School Survey"),
                                  selected = "2012 SAT Score"))
           ),
           hr(),
           htmlOutput("selection_info"),
           hr(),
           fluidRow(
               column(6, 
                      plotlyOutput("sd_comp_1", width = "100%")),
               column(6, 
                      plotlyOutput("sd_comp_2", width = "100%"))
           ),
           fluidRow(
               column(6, 
                      plotlyOutput("sd_comp_3", width = "100%")),
               column(6, 
                      plotlyOutput("sd_comp_4", width = "100%"))
           ),
           hr(),
           htmlOutput("note")

  ),
  tabPanel("About",
           fluidRow(
               column(8, 
                      tags$div(align = "right",
                   "This shiny app is completed for the second project of NYC Data Science Academy bootcamp #7.",
                   tags$br(),tags$br(),
                   "All data sets are downloaded from NYC OpenData.",
                   tags$br(),
                   tags$br(),
                   HTML(paste0("The app is hosted on <a href='https://yisongtao.shinyapps.io/NYC_HS/'>Shinyapps.io. </a>")),
                   tags$br(),tags$br(),
                   "Yisong Tao",
                   tags$br(),
                   "10-30-2016"
                   )  
               )
           )
  )

  
)
