library(shiny)
library(ggplot2)
library(plotly)

load("busData")

min_y = min(busData$yr)
max_y = max(busData$yr)


fluidPage(
  #titlePanel("Employment Analysis"),
  fluidRow(column(width = 4,
                  selectizeInput(inputId = "metric",
                                 label = "Choose Metric:",
                                 choices = list("Num Employees"="num_emp",
                                                "Total Payroll"="tot_payroll",
                                                "Num establishments"="num_est"),
                                 selected="tot_payroll")
          ),
          column(width=2,
          radioButtons("radio_lvlpct", label = "",
                       choices = list("Level per capita" = "lpc", "% Change" = "pctChg"), 
                       selected = "pctChg")
          ),
           column(width=4,
                  sliderInput("yr",
                              "Year",
                              min = min_y,
                              max= max_y,
                              value= min_y,
                              sep="",
                              animate =TRUE
                              )
           ),
          column(width=2,
                 checkboxInput("notesOnly", label = "Notes Only", value = FALSE)
                 
          )
  ),
  fluidRow(
    column(width = 6,
         plotlyOutput("distPlot")
    ),
    column(width=4, 
         plotlyOutput("detPlot")
    )
  ),
  fluidRow(
    column(width=6, 
           plotlyOutput("trendPlot")
    )
    ,
    column(width=6,
           plotlyOutput("countyPlot")
    )
    
  )
  
)