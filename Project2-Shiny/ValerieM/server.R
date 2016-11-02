## server.R ##
library(googleVis)
library(dplyr)

shinyServer(function(input, output){
  
# You can access the values of the second widget with input$slider2, e.g.
#  output$range <- renderPrint({ input$sliderAge })
output$plot4 <- renderGvis({
  if (input$n_state == "All"){
    
    aa = df %>% group_by(state) %>% filter(q29c == "More likely") %>% count()
    bb = df %>% group_by(state) %>% count()
    cc = inner_join(aa, bb, by = "state")
    dd =  mutate(cc, Greedy = n.x/n.y)
    ee = transmute(dd, state, Greedy)
    ee = add_row(ee, state = "South Dakota", Greedy = "0.1")
    ee = add_row(ee, state = "Hawaii", Greedy = "0.1")
    ee = add_row(ee, state = "Vermont", Greedy = "0.1")
    ee <- ee[-c(9),]
    ff = ee[order(array(ee$state)),] 
    states <- data.frame(state.name, ff)
#    Sys.sleep(0.3)
    GeoStates <- gvisGeoChart(states, "state.name", "Greedy",
                              options=list(region="US", 
                                           displayMode="regions", 
                                           resolution="provinces",
                                           width=600, height=400))
   return(GeoStates)
  }
##else if (input$Income == "Analyze" & input$n_state == "All"){
##    kk =df %>% group_by(q29c, income) %>% select(q29c, income)
##    tt = group_by(kk, state) %>% count(., income)
##    Column <- gvisColumnChart(tt, options = list(width=700, height=400))
##    return(Column)
##  }
  else{
      kk =df %>% group_by(state, q29c) %>% select(state,q29c)
      tt = group_by(kk, state) %>% count(., q29c)
      sname = input$n_state
      dfBar = filter(tt, state == sname) %>% arrange(.,desc(n))
      ee=data_frame(dfBar$q29c, Number=dfBar$n)
      Bar <- gvisBarChart(ee, 
                   options = list(hAxis=paste0("{title:'","Number of People", "'}"),
                                  vAxis=paste0("{title:'","Greedy in ", input$n_state,"'}"),
                                  width=700, height=400))
      return(Bar)
    }
#  output$main_plot <- renderPlot({
    
#    hist(faithful$eruptions,
#         probability = TRUE,
#         breaks = as.numeric(input$n_breaks),
#         xlab = "Duration (minutes)",
#         main = "Geyser eruption duration")
    
#   if (input$individual_obs) {
#     rug(faithful$eruptions)
#    }
    
#   if (input$density) {
#      dens <- density(faithful$eruptions,
#                      adjust = input$bw_adjust)
#      lines(dens, col = "blue")
#    }
    
  #  })
})
})