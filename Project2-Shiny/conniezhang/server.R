library(DT)
library(shiny)
library(googleVis)

shinyServer(function(input, output) {
    # show map using googleVis
  plot_df = reactive({
    
    ChosedDataframe = data.frame()
    ChosedDataframe = switch (input$ConditionChoice,
                              "Colonoscopy Care" = ColonoscopyCare,
                              "Children's Asthma Care" = ChildrenAsthma,
                              "Heart Failure Care" =  HeartFailure, 
                              "Pneumonia Care" = Pneumonia,
                              "Preventive Care" = PreventCare,
                              "Pregnancy and Delivery Care" = PegDelCare
    )
  })  # for plot_df
  

ReturnForPlot = data.frame()
    
  finalplot = reactive({
    
    if(input$RegionChoice =="NationWide") {
    
      NationOnly = plot_df() %>% 
      group_by(State) %>% 
      summarise(TotalScore = sum(TScore), TotalSample = sum(Sample))
      
      NationOnly = NationOnly %>% filter(!is.na(abbr2state(State)))
    
    NationOnly$AvgScore = round(NationOnly$TotalScore/
                                   NationOnly$TotalSample,2)
    
    ReturnForPlot = NationOnly
    return (ReturnForPlot)
    
    }  # for NationWide
    
    else {
      
      RegionData = filter(plot_df(), State == input$RegionChoice)
      RegionData = RegionData %>% filter(!is.na(abbr2state(State)))
      if (length(RegionData) > 0) {
        ReturnForPlot = RegionData
        return (ReturnForPlot)  
          } # for if on length(RegionData)
      else {
        ReturnForPlot = data.frame()
        return (ReturnForPlot)}
      
    }
    
})  ## for finalPlot
  

  observe({
    
     if(input$RegionChoice =="NationWide") {
      output$map <- renderGvis({
      gvisGeoChart(finalplot(), "State", "AvgScore",
                        options=list(region="US", displayMode="regions", 
                                     resolution="provinces",
                                     width="auto", height="auto",
                                     colorAxis="{minValue: 0, maxValue: 100,colors: ['green', 'white', 'red']}"))
       })  ## for output$map
      
    # show histogram using googleVis
     output$hist <- renderGvis({  
       gvisHistogram(finalplot()[,"AvgScore", drop=FALSE],
                     options = list(legend="{ position: 'top'}" , hAxis = "{ticks: [0,20,40,60,100]}"))
     })  ## for output$hist
     # show statistics using infoBox
       output$maxBox <- renderInfoBox({
           max_value <- max(finalplot()[,"AvgScore"])
           max_state <- 
               finalplot()$State[finalplot()[,"AvgScore"] == max_value]
           infoBox(abbr2state(max_state), max_value, icon = icon("hand-o-up"))
       })
       output$minBox <- renderInfoBox({
           min_value <- min(finalplot()[,"AvgScore"])
           min_state <- 
              finalplot()$State[finalplot()[,"AvgScore"] == min_value]
           infoBox(abbr2state(min_state), min_value, icon = icon("hand-o-down"))
      })
      output$avgBox <- renderInfoBox ({
           infoBox(paste( "Average"),
                  round(mean(finalplot()$AvgScore),2), 
                 icon = icon("calculator"), fill = TRUE 
                 )
               })
      # show data using DataTable
        output$table <- DT::renderDataTable ({
            datatable(finalplot() %>% arrange(desc(AvgScore)),rownames=FALSE) 
    
        })  
     
    
  } # for finalplot() national


    else if(input$RegionChoice !="NationWide" & length(finalplot()) != 0 ) {
      ForStateMap = finalplot() %>% group_by(State) %>% summarise(STD = sd(Score))
      output$map <- renderGvis({

               gvisGeoChart(ForStateMap, "State", "STD",
                                options=list(region="US", displayMode="regions", 
                                             resolution="provinces",
                                             width="auto", height="auto",
                                             colorAxis="{minValue: 10, maxValue: 40,colors: ['green', 'white', 'red']}"))
               })  ## for output$map      
      
      output$hist <- renderGvis({
        gvisHistogram(finalplot()[,"Score", drop=FALSE],
                      options = list(legend="{ position: 'top'}" , hAxis = "{ticks: [0,20,40,60,100]}"))
     })  # for output$hist
      
      # show statistics using infoBox
        output$maxBox <- renderInfoBox ({
            max_value <- max(finalplot()[,"Score"])
            max_Hospital <- 
                finalplot()$Hospital.Name[finalplot()[,"Score"] == max_value]
            infoBox(max_Hospital, max_value, icon = icon("hand-o-up"))
      })
        output$minBox <- renderInfoBox({
            min_value <- min(finalplot()[,"Score"])
            min_Hospital <- 
               finalplot()$Hospital.Name[finalplot()[,"Score"] == min_value]
            infoBox(min_Hospital, min_value, icon = icon("hand-o-down"))
        })
       output$avgBox <- renderInfoBox ({
            infoBox(paste("Average", "Score"),
                   round(mean(finalplot()$Score),2), 
                  icon = icon("calculator"), fill = TRUE)
         })
    
       # show data using DataTable
       output$table <- DT::renderDataTable ({
         sortfinalplot = finalplot() %>% arrange(desc(Score))
         sortfinalplot = data.frame("HospitalName"=sortfinalplot$Hospital.Name,"Address" = sortfinalplot$Address,
                           "City" = sortfinalplot$City,"State"=sortfinalplot$State,
                           "Zip Code" =sortfinalplot$ZIP.Code,"Phone Number" =sortfinalplot$Phone.Number,"Score" =sortfinalplot$Score)
         datatable(sortfinalplot,rownames=FALSE) 
         
       })        
       
       }   # for if on else if
    else {
      output$text  <- renderText({
        paste("This state does not have the data for ", input$ConditionChoice, "!!!")  
      })  # for output$text
    } # for the else just above output$text

  })   # testing observe again
  }) # for the very top




 


