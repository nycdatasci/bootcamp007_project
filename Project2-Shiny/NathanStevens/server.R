#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
source('helpers.R')

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  # set the min and max values for the value boxes
  output$minAvgRatingBox <- renderValueBox({
    # need to load the data here
    avgRatingDF <<- getAvgRatingByState(input$infection)
    
    value = avgRatingDF$Avg.Rating[1]
    stateName = paste("Best :", abb2state(avgRatingDF$State[1]))
    valueBox(value, stateName, color = "green")
  })
  
  output$maxAvgRatingBox <- renderValueBox({
    input$infection # need to have this here for proper updating
    
    lastRow = nrow(avgRatingDF)
    value = avgRatingDF$Avg.Rating[lastRow]
    stateName = paste("Worst :", abb2state(avgRatingDF$State[lastRow]))
    
    valueBox(value, stateName, color = "maroon")
  })
  
  # plot the aveverage infection rate on a map of the US
  # using google maps
  output$gvisMap <- renderGvis({
    input$infection # need to have this here for proper updating
    
    gvisGeoChart(avgRatingDF,
                 locationvar = "State", colorvar="Avg.Rating",
                 options = list(region="US", displayMode="regions",
                                resolution="provinces",
                                colors = "['white', 'red']",
                                width=800, height=500)
    )
  })
  
  # display information in the information boxes that are on the
  # chart view tab
  output$minAvgRatingBox2 <- renderValueBox({
    # need to load the data here
    avgRatingDF <<- getAvgRatingByState(input$infection)
    
    value = avgRatingDF$Avg.Rating[1]
    stateName = paste("Best :", abb2state(avgRatingDF$State[1]))
    valueBox(value, stateName, color = "green")
  })
  
  output$maxAvgRatingBox2 <- renderValueBox({
    input$infection # need to have this here for proper updating
    
    lastRow = nrow(avgRatingDF)
    value = avgRatingDF$Avg.Rating[lastRow]
    stateName = paste("Worst :", abb2state(avgRatingDF$State[lastRow]))
    
    valueBox(value, stateName, color = "maroon")
  })
  
  # now let plot plot the same results in bar plots
  output$gvisBarChart <- renderGvis({
    input$infection # need to have this here for proper updating
    
    plotTitle = "Hospital Rating -- Lower is Better"
    
    gvisBarChart(avgRatingDF, options = list(height = 600,
                                             title = plotTitle,
                                             colors = "['red']"))      
  })
  
  # handle events on the first state slider from the bubble chats view
  observe({
    val <- input$stateSlider1
    infection = input$infection
    
    # get the state name based on it's number
    stateAbbr = stateAbbrs[val]
    stateName = abb2state(stateAbbr)
    
    # now load the data filtered by the selected state
    # territory and infection type
    df = getHospitalRatingByState(stateAbbr, infection)
    
    # if we have any data render the bubble plot here
    if(nrow(df) != 0) {
      output$gvisScatterChart <- renderGvis({
        
        # set the title
        plotTitle = paste("Rating for", nrow(df), "Hospital(s) in ", 
                          stateName, '-- ( Associated Infection:', infection , ')')
        
        # need to set the y axis range
        vaxisOption = paste0("{title:'rating',viewWindow:{max:",
                             df$Rating[nrow(df)] + 5,
                             ",min:", df$Rating[1] - 5, "}}")
        
        gvisBubbleChart(df,
                        colorvar = "Standing",
                        #sizevar = "Relative.Rating",
                        options=list(
                          #legend="none",
                          title= plotTitle,
                          #colorAxis = "{colors: ['green', 'yellow', 'red']}",
                          sizeAxis = "{maxSize:10,minSize:5}",
                          vAxis = vaxisOption,
                          hAxis="{title:'hospital #'}",
                          height=500))  
        
      })
    }
    
    # now update the slider label to reflect the selected location    
    label = paste("Selected:", stateName)
    updateSliderInput(session, "stateSlider1", label = label)
    
    # test code
    #output$hospitalview.text = renderText({ 
    #  paste("State Selected:", infection)
    #})
  })
  
  # observe block to see what state or territory was selected
  # display the data for this state
  observe({
    location = input$location
    df = getDataByState(location)
    
    output$mytable = renderDataTable({
      df
    })
  })
})
