shinyUI(
  navbarPage(
    title = 'Meetup Group Sorting',
    id = 'nav',
    theme = shinytheme('united'),
    
    tabPanel('Statistics', 
             fluidRow(
               column(12, 
                      h3('Number of groups by location in each category'),
                      plotlyOutput("locp"),
                      
                      fluidRow(
                        column(6, 
                               h3('Number of meetup in each category'),
                               plotlyOutput('catp')),
                        column(6, 
                               h3('Average member in each category'),
                               plotlyOutput('avgcp')))
                      ))
               
             ),
    tabPanel("Scatter Plot", 
             mainPanel(
               tabsetPanel(
                 tabPanel('Past Meetup v.s. Member', plotlyOutput('scatplm')),
                 tabPanel('Upcoming Meetup v.s. Member',plotlyOutput('scatplu')),
                 tabPanel('3D scatter plot', plotlyOutput("scat3d"))
               ))),
    
    tabPanel('Heat Map',
             fluidRow(
               column(3,
                     selectInput("types",
                                     h4("Select on Type:"),
                                     choices =  Types,
                                     selected = 'Members')),
               column(9,plotlyOutput('heatm_poptime'))
                      )),
    tabPanel('Select Your Group',
             fluidRow(
               column(2,
                      h4('Make Selection Below:'),
                      br(),
                      selectInput("location",
                                  "Select Location:",
                                  choices = unique(meetup_up_event$Location),
                                  selected = NULL

                      ),
                      br(),
                      selectInput("weekday",
                                  'Select Weekday:',
                                  choices = unique(meetup_up_event$U_e_wd),
                                  selected = NULL

                      ),
                      br(),
                      sliderInput("member",
                                  h4('Select the Range of Members'),
                                  min= 1,
                                  max = 51252,
                                  value = c(1,51252)
                      ),
                      br(),
                      sliderInput("pm",
                                  h4('Select the Range of Past Meetup'),
                                  min = 0,
                                  max = 7537,
                                  value = c(0,7537)
                      ),
                      br(),

                      sliderInput("um",
                                  h4('Select the Range of Upcoming Meetup'),
                                  min = 0,
                                  max = 452,
                                  value = c(0,452)
                      ),
                      br()
),
               column(10, DT::dataTableOutput('tableouput'))
             ))


  ))
  