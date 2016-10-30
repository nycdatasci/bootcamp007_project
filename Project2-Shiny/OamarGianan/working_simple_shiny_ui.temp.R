shinyUI(fluidPage(
       titlePanel("Financial Aid Merry-Go-Round"), # main title
       sidebarLayout(
              sidebarPanel(
                     helpText("Select the following attributes."), ## subtitle
                     sliderInput("select_year", "Select year data:", 2008, 2013, 1, step = 1, 
                                 timeFormat = "%Y",
                                 sep = "",
                                 animate=animationOptions(interval=2000, loop=F)),
                     sliderInput("select_percentile", "Cutoff by percentile:", 70, 99, 1, step = 1),

                     # selectInput("donors", # choose the donors
                     #             label = "Choose donor countries to display",
                     #             choices = donors_list, #c('Australia', 'United States', 'United Kingdom'),
                     #             multiple = TRUE,
                     #             selectize = TRUE,
                     #             selected = c('Australia', 'Canada', 'France', 'China')),
                     selectInput("select_country", # choose the recievers
                                        label = "Choose recieving countries to display",
                                        choices = c('Australia', 'Canada', 'France', 'China'),
                                        multiple = TRUE,
                                        selectize = TRUE,
                                        selected = c('Australia', 'Canada', 'France', 'China'))
              ),
              mainPanel(plotOutput("chord", width = '600px', height = '600px'))
#              mainPanel(htmlOutput("plot"))
)
))