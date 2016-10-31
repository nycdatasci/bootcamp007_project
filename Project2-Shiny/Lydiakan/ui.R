shinyUI(
  navbarPage(
    title = 'Hospital Resources in Taiwan',
    id = 'nav',
    theme = shinytheme('flatly'),
   
     tabPanel('Statistics',
             fluidRow(
               column(3,
                      h3('Hospital Resources Allocation'),
                      br(),
                      br(),
                      br(),
                      selectizeInput("city",
                                         h4("Select on City:"),
                                         choices = unique(hp$City),
                                         selected = c('Taipei City','Taichung City','Tainan City'),
                                     multiple = TRUE
                                         ),
                      br(),
                      selectInput("category",
                                  h4("By Category"),
                                  choices = Category,
                                  selected = 'Bed Types'
                        
                      ),
                      selectInput("year",
                                  h4('By Year:'),
                                  choices = unique(hp$Year),
                                  selected = '2006'
                        
                      )
                 
               ),
               column(9, htmlOutput('stata'))
             )),
    
 ###########################################################Motionchart   
    tabPanel('Correlation',
      fluidRow(
        column(3,
             h3('Hospital Resources Correlation'),
             br(),
             selectInput("type",
                         h4("Showing data by type"),
                         choices = type,
                         selected = 'Number'),
             br(),
             h4('Note: This graph is interactive.'),
             br('You can select different plots to visualized data'),
             br('As your mouse moves over the number of data are displayed.'),
             br('To identify the trend, you can drag or play the timeline button'),
             br('To see the trails of specific city, click the city in the Select box')
            
             
      ),
        column(9, htmlOutput('statb')
               )
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
                     selectInput("year",
                                  h4('By Year:'),
                                  choices = unique(hp$Year),
                                  selected = '2006')),

               column(9, leafletOutput('statc'))

            )),
 
#############################################################About 
    tabPanel('Data Info',
            fluidRow(
              column(12,
                     h2('Data Info'),
                     tags$div(class = 'header', checked = NA,
                              tags$a(href = 'http://iiqsw.mohw.gov.tw/InteractiveIntro.aspx?TID=9BBD9FD042347C1F#',
                                     'Data Definition' )),
                     br('Unit Explaination:'),
                     br('Number = Number of Counts'),
                     br('per Capita = Number / Total Population of the Region'),
                     h2('Data Source:'),
                     tags$div(class = 'header', checked = NA,
                              tags$a(href = 'http://iiqs.mohw.gov.tw/','Ministry of Health and Welfare' )),
                     tags$div(class = 'header', checked = NA,
                              tags$a(href = 'https://github.com/g0v/twgeojson','g0v' )),
                     h2('Contact Author'), 
                     tags$div(class = "header", checked = NA,
                           tags$p("If there is any questions or suggestions, please contact the author through following email:"),
                           tags$a(href = "lydiakan310@gmail.com", "lydiakan310@gmail.com"),
                    tags$div(class = "header", checked = NA,
                           tags$a(href= "http://blog.nycdatascience.com/author/lydiakan310/","Blog"))
                    
                     
                    
                
                        ))
           
            )

)))