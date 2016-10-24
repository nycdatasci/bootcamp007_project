library(shiny)
library(ggplot2)

load("busData")

min_y = as.numeric(min(levels(busData$yr)))
max_y = as.numeric(max(levels(busData$yr)))

fluidPage(
  titlePanel("Employment Analysis"),
  fluidRow(column(width = 4,
                  # selectizeInput(inputId = "metric",
                  #                label = "Select Metric",
                  #                choices = as.list(setNames(as.character(unique(busData$yr)), as.character(unique(busData$yr))))),
                  selectizeInput(inputId = "metric",
                                 label = "% Change in:",
                                 choices = list("Num Employees"="num_emp",
                                                "Total Payroll"="tot_payroll",
                                                "Num establishments"="num_est"),
                                 selected="tot_payroll"),
                  sliderInput("yr",
                              "Year",
                              min = min_y,
                              max= max_y,
                              value= min_y,
                              sep="",
                              animate =TRUE
                              )
  ),
    column(width = 8,
         plotlyOutput("distPlot")
  )),
  fluidRow(
    column(width=6, 
         plotlyOutput("detPlot")
    ),
    column(width=6, 
           plotlyOutput("trendPlot")
    )
  )
  
)