#
# Shiny app for visualizing infection rates at hospital 
# the US for which this information is available
#

library(shinydashboard)

dashboardPage(skin = "green",
              
  dashboardHeader(title = "HospiView"),
  
  dashboardSidebar(
    
    # this is a fix for bug which prevents tabs from being selected
    # more than once. This is a rediculous bug that should have never
    # made it into the code !!!!!
    tags$head(
      tags$script(
        HTML(
          "
          $(document).ready(function(){
          // Bind classes to menu items, easiest to fill in manually
          var ids = ['mapview','chatview','hospitalview','dataview'];
          for(i=0; i<ids.length; i++){
            $('a[data-value='+ids[i]+']').addClass('my_subitem_class');
          }

          // Register click handeler
          $('.my_subitem_class').on('click',function(){
            // Unactive menuSubItems
            $('.my_subitem_class').parent().removeClass('active');
          })
        })
        "
        )
      )
    ), # end bug fix
    
    # menu items added here
    selectInput("infection", label = "Select Associated Infection", 
                choices = infectionChoices),
    
    menuItem("Map View", tabName = "mapview", icon = icon("map-o")),
    
    menuItem("Chat View", tabName = "chatview", icon = icon("bar-chart")),
    
    menuItem("Hospital View", tabName = "hospitalview", icon = icon("hospital-o")),
    
    menuItem("Data View", tabName = "dataview", icon = icon("table"))
  ),
  
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    
    # add the tab panel
    tabItems(
      # map show infections by state
      tabItem(tabName = "mapview",
              # add the dynamic value boxes for minimum and maximum
              fluidRow(
                # value box to hold the min
                valueBoxOutput("minAvgRatingBox"),
                
                valueBoxOutput("maxAvgRatingBox")
              ),
              
              htmlOutput("gvisMap"),
              
              br(),
              h4("Visualize the infections with map ...")
      ),
      
      tabItem(tabName = "chatview",
              # add the dynamic value boxes for minimum and maximum
              fluidRow(
                # value box to hold the min
                valueBoxOutput("minAvgRatingBox2"),
                
                valueBoxOutput("maxAvgRatingBox2")
              ),
              
              htmlOutput("gvisBarChart")
      ),
      
      tabItem(tabName = "hospitalview",
              box(width = 700, 
                  height = 520,
                  #background = "white",
                  
                # this holds the scatter plot for the state
                htmlOutput("gvisScatterChart")
              ),
              
              sliderInput("stateSlider1", "Location:", min=1, max=stateCount, value=1,
                          step=1, pre = "##", animate = animationOptions(interval = 1500)),
              
              # TEST CODE
              br(),
              textOutput("hospitalview.text")
      ),
      
      tabItem(tabName = "dataview",
              selectInput("location", "Choose a State Or Territory:", 
                          choices = stateChoices),
              
              # add the data table below
              dataTableOutput('mytable')
      )
    )
  )
)