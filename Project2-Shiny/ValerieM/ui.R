
library(shinydashboard)

shinyUI(dashboardPage(
  dashboardHeader(title = "Are Rich People Different?",
                  titleWidth = 450),
  
  dashboardSidebar(
    selectInput(inputId = "n_state",
      label = "State:",
      choices = list("All",
                     "Alaska",
                     "Arizona",
                     "Arkansas",
                     "California",
                     "Colorado",
                     "Connecticut",
                     "Delaware",
                     "Florida",
                     "Georgia",
                     "Hawaii",
                     "Idaho",
                     "Illinois",
                     "Indiana",
                     "Iowa",
                     "Kansas",
                     "Kentucky",
                     "Louisiana",
                     "Maine",
                     "Maryland",
                     "Massachusetts",
                     "Michigan",
                     "Minnesota",
                     "Mississippi",
                     "Missouri",
                     "Montana",
                     "Nebraska",
                     "Nevada",
                     "New Hampshire",
                     "New Jersey",
                     "New Mexico",
                     "New York",
                     "North Carolina",
                     "North Dakota",
                     "Ohio",
                     "Oklahoma",
                     "Oregon",
                     "Pennsylvania",
                     "Rhode Island",
                     "South Carolina",
                     "South Dakota",
                     "Tennessee",
                     "Texas",
                     "Utah",
                     "Vermont",
                     "Virginia",
                     "Washington",
                     "West Virginia",
                     "Wisconsin",
                     "Wyoming"),
      selected = "All"),
    
      selectInput(inputId = "n_gender",
            label = "Gender:",
            choices = list("All", "Male", "Female"), 
      selected = "All"),
    
      # make a slider range 
      sliderInput("Age", label = h3("Age Range"), min = 18, 
                max = 90, value = c(40, 60)),
    
      selectInput(inputId = "n_race",
                label = "Race:",
                choices = list("All", "White", "Black","Native Amer",
                               "Hispanic",
                               "Asian",
                               "Don't Know",
                               "Other",
                               "Pacific-Islander",
                               "Refused"),
                selected = "All"),
  
  selectInput(inputId = "Income",
              label = "Income:",
              choices = list("All", "Analyze", "$150,000 or more", "100 to under $150,000",
                             "75 to under $100,000",
                             "50 to under $75,000",
                             "40 to under $50,000",
                             "30 to under $40,000",
                             "20 to under $30,000",
                             "10 to under $20,000",
                             "Less than $10,000",
                             "Don't know/Refused"),
              selected = "All")), 
  
  dashboardBody(
       tabsetPanel(type = "tabs",
       tabPanel("Honest", h4("Honest")),
       tabPanel("Intelligent", h4("Intelligent")),
       tabPanel("Greedy", htmlOutput("plot4"))
       )
  )
))
dashboardSidebar(
  sidebarUserPanel("Your Name"),
  sidebarMenu(
    menuItem("Map", tabName = "map", icon = icon("map")),
    menuItem("Data", tabName = "data", icon = icon("database")))
)