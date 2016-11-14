shinyUI(
  navbarPage(
    title = 'Meetup Group Sorting',
    id = 'nav',
    theme = shinytheme('flatly'),
    
    tabPanel('Statistics',
             fluidRow(
               column(3,
                      h3('Statistics of Meetup'),
                      br(),
                      br(),
                      br(),
                      selectInput("category",
                                     h4("Select Category:"),
                                     choices = unique(meetup$Category),
                                     selected = 'Outdoors & Adventure',
                                     
                      ),
                      br(),
                      selectInput("location",
                                  h4("Select Location:"),
                                  choices = unique(meetup$Location),
                                  selected = 'New York, NY'
                                  
                      ),
                      selectInput("weekday",
                                  h4('Select Weekday:'),
                                  choices = unique(meetup$u_e_wd),
                                  selected = 'Sat'
                                  
                      ),
                      sliderInput("member", 
                                  h4('Select the Range of Members'),
                                  min= 0,
                                  max = ,
                                  value = ,
                                   ),
                      sliderInput("pastmeeup",
                                  h4('Select the Range of Past Meetup'),
                                  min = 0,
                                  max = ,
                                  value = ,
                                   )
                      
               ),
               column(9, dataTableOutput('tableouput'))
             )),
    

    
    ########################################################### Correlation   
    tabPanel('Map',
             fluidRow(
               column(3,
                      h3('Bed Occupancy Rate by Region'),
                      br(),
                      selectInput("ratio",
                                  h4("Bed Type"),
                                  choices = ratio,
                                  selected = 'General Bed'),
                      selectInput("year2",
                                  h4('By Year:'),
                                  choices = unique(hp$Year),
                                  selected = '2006')),
               
               column(9, leafletOutput('statc'))
               
             )),
    
    #############################################################About 
    
                               
                               
                               
                      ))
               
