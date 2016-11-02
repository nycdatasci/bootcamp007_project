library(shiny)
library(leaflet)
library(RColorBrewer)
library(datasets)


navbarPage(
  title = "Nursing Home Explorer",
  id = "nav",
  
  tabPanel("Interactive map",
           div(class = "outer", 
      
      tags$head(
        includeCSS("styles.css")
    #   includeScript("gomap.js")),
     ),
    
      
    leafletOutput("map", width = "100%", height = "100%"),

      absolutePanel(
        id = "controls",
        class = "panel panel-default",
        fixed = TRUE,
        draggable = TRUE,
        top = 60,
        left = "auto",
        right = 20,
        bottom = "auto",
        width = 330,
        height = "auto",
        h2("Nursing Homes Explorer"),
        
        tags$div(
          class = "header3",
          "This interactive map shows data on nursing homes in the Unites States"
        ),
        
        plotOutput("histCentile", height = 200),
        
        tags$div(
        #id = "cite",
        "Data compiled by Joseph van Bemmelen"
      )
    )
)),


tabPanel(
  "By State",
  fluidRow(
#    sidebarPanel(
#      selectInput("nursing", "Choose a characteristic", 
 #                 choices = c("rock", "pressure"))
#    ),
    selectizeInput("selected",
                   "Select Item to Display",
                   choice),
    column(9,
           htmlOutput("gmap", height="50%")
           ),
    column(3,
           htmlOutput("hist",width=700,height=400)
           ),
    column(9,
           htmlOutput("view",width=700,height=400)
    )
    
)),

tabPanel(
  "By County",
  fluidRow(
    #    sidebarPanel(
    #      selectInput("nursing", "Choose a characteristic", 
    #                 choices = c("rock", "pressure"))
    #    ),
    selectizeInput("selected",
                   "Select Item to Display",
                   choice2),
    
           htmlOutput("bubble", height="200%")
    )
  ),

tabPanel(
  "Homes",
  fluidRow(
    checkboxInput(inputId = "pageable", label = "Change number of results per page"),
    conditionalPanel("input.pageable==true",
                     numericInput(inputId = "pagesize",
                                  label = "Homes per page",20)),
    htmlOutput("myTable")
  )
),

tabPanel(
  "About the Data",
  fluidRow(
    mainPanel(
      mainPanel(
        h2("About the Data"),
        p("The data for this project is a combination of the
          Ownership (https://data.medicare.gov/Nursing-Home-Compare/Ownership/y2hd-n93e)
          and Provider Info (https://data.medicare.gov/Nursing-Home-Compare/Provider-Info/4pq5-n9py) datasets
          from https://data.medicare.gov."),
        p("As per the Medicare website:"),
        p("The Provider info dataset contains quality of care and staffing information for all 15,000 plus
          Medicare- and Medicaid-participating nursing homes. Note: Nursing homes aren't included on Nursing Home
          Compare if they aren't Medicare- or Medicaid-certified. These Nursing Homes can be licensed by the state.
          For information about nursing homes not on Nursing Home Compare, contact your State Survey Agency."),
        p("5-star quality ratings come from:"),
        p("- Health inspections"),
        p("- Staffing"),
        p("- Quality measures"),
        p("A star rating is provided for each of these 3 sources, in case some areas are more important to you 
than others. Then, these 3 ratings are combined to calculate an overall rating.")
      )
    )
)))
