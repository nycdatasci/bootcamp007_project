#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
setwd("C:/Users/James/Desktop/RSHINY")
library(shinydashboard)

dashboardPage(
  dashboardHeader(title= "American Time Use"),
  dashboardSidebar(
    sidebarUserPanel("James Lee" , image = 'mypic.jpg'),
    sidebarMenu(
      menuItem("Introduction", tabName = "intro", icon = icon("fa fa-info-circle")),
      menuItem("Hobbies Over Time", tabName = "bar", icon = icon("fa fa-bar-chart")),
      menuItem("Data Frame", tabName = "DF", icon = icon("fa fa-database"))
      
    ),
    selectInput("race", label = h4("Race"),
                choices= list("White"= 1, 
                              "Black" = 2, 
                              "American Indian" = 3, 
                              "Asian" = 4, 
                              "Hawaiian/Pacific Islander" = 5, 
                              "White Mixed" = 6,
                              "Black Mixed" = 7,
                              "Other Mixed" = 8,
                              "All" = 9), 
                selected = 9),
    selectInput("region", label = h4("Region"),
                choices = list("Metropolitan" = 1,
                               "Non-Metropolitan" = 2,
                               "All" =3), 
                selected = 3),
    
    selectInput("sex", label = h4("Sex"),
                choices = list("Male" = 1,
                               "Female" = 2,
                               "All" = 3),
                selected = 3),
    selectInput("incomeg", label = h4("Income Group"),
                choices = list("0" = 1,
                               "Under 30K" = 2,
                               "30K ~ 60K" = 3,
                               "60K ~ 100K" = 4,
                               "Over 100K" = 5,
                               "All" = 6),
                selected = 6),
    radioButtons("gen", label = h3("Generation"), 
                       choices = list("Millenial" = 1, "Generation X" = 2, "Baby Boomers" = 3, "Silent Generation" =4),
                       selected = 1)
    
  ),
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "intro", h2("Pictures Maybe Data Frame, Sources, etc."),
              column(12,
                     tabsetPanel(
                       tabPanel("Motivations & Objectives",
                                fluidRow(
                                  column(7,
                                         h3('Motivation'),
                                         p("This Shiny app was created by James Lee as the second project in his time at the NYC Data Science Bootcamp Cohort #7"),
                                         p("Modern Development has produced technology that allows us to save time by automation.  From the computers that can handle large data sets to even the simple forms of advancement in transportation,
                                           Various tools have been refined and developed so that we may gain more time.  Even now, our goal is to research new methods in shrinking time use, refine techniques and procedures to waste as little time as possible."),
                                         p("However, while the tools that we use have grown more advanced and efficient, we constantly greed for shorter and shorter time use, to the point that we still feel pressed for time.  Time management is as necessary today
                                           as it was over a decade ago.  If there is such a development in our constant struggle for time, How do the use of time differ today than in the past?"),
                                         h3("Objectives"),
                                         tags$ul(
                                           tags$li("Analyze how the use of time has changed from 2003 to 2015"),
                                           tags$li("Analyze trends among different categories such as region of residence, race, income group and gender"),
                                           tags$li("Visualize the changes that occur and identify possible reasons for such change")
                                           )
                                         )
                                         )
                                         ),
                       tabPanel("About the data",
                                fluidRow(
                                  column(7,
                                         h3("Data Source"),
                                         p("All data has been sourced from the Bureau of Labor Statistics' American Time Use Survey.  Data was collected in a survey running from 2003 to the past year in 2015 and 170,000 people were interviewed in total"),
                                         h3("Origins of Data Collection"),
                                         p("The survey included multiple information such as the labor status of individuals, the number of children, marrital status, etc.  The survey was conducted in random and provides representative estimates on how, where, and with whom Americans spend their time. "),
                                         p("The information is crucial in that it examines the national changes in the time Americans spend working, doing household chores and enjoying leisure at different points of time."),
                                         p("The collected data can estimate worker productivity, and trends in Leisure."),
                                         p(strong( "The Activies have been categorized into groups of similar activities.")),
                                         p("For further information please check the American Time Use Survey from the Bureau of Labor Statistics at"),
                                         (href='https://www.bls.gov/tus')
                                  )
                                )
                       )
                     )
              )
      ),
    
  
      
      # Second tab content
      tabItem(tabName = "bar", h2("Americans Spend the Most Time Doing..."),
              tabsetPanel(
                tabPanel("Bar Chart",
                         fluidRow(
                           box(htmlOutput("barPlot", height = "100%",width = "100%"))
                           
                         ),
                         fluidRow(
                           box(
                             title = "Time",
                             sliderInput("slider1", label = h3("Year"), 
                                         min = 2003, 
                                         max = 2015, 
                                         value = 2015)
                           )
                         )
                ),
                tabPanel("Bar Chart ln(Minutes)",
                         fluidRow(
                           box(htmlOutput("barPlot2", height = "100%",width = "100%"))
                           
                         ),
                         fluidRow(
                           box(
                             title = "Time",
                             sliderInput("slider2", label = h3("Year"), 
                                         min = 2003, 
                                         max = 2015, 
                                         value = 2015)
                           )
                         )
                )
              )),
      #Third Tab
      tabItem(tabName = "DF", h2("Chart"),
              fluidPage(
                titlePanel("Data Table"),
                
                # Create a new row for the table.
                fluidRow(
                  DT::dataTableOutput("DataFrame")
                        )
                      )
      )

    )
    
  )
)

