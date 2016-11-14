
server = function(input,output){
##########################Statistics  
  output$locp = renderPlotly({
    plot_ly(n_loc, x= ~Category, y= ~n, color= ~Location)
  })
  
  output$catp = renderPlotly({
    plot_ly(n_cat, x= ~Category, y= ~n, type='bar', marker = list(color = c('rgba(185,66,64,0.9)', 'rgba(177, 78, 42, 0.9)',
                                                                          'rgba(201, 147, 38, 0.9)', 'rgba(136, 214, 72, 0.9)',
                                                                          'rgba(136, 214, 146, 0.9)','rgba(136, 214, 193, 0.9)',
                                                                          'rgba(152, 119, 237, 0.9)','rgba(104, 119, 237, 0.9)',
                                                                          'rgba(191, 106, 211, 0.9)','rgba(177, 106, 228, 0.9))',
                                                                          'rgba(177, 163, 228, 0.9)', 'rgba(217, 129, 228, 0.9)',
                                                                          'rgba(168, 146, 228, 0.9)', 'rgba(130, 146, 228, 0.9)',
                                                                          'rgba(130, 177, 228, 0.9)','rgba(130, 177, 179, 0.9)',
                                                                          'rgba(130, 177, 131, 0.9)','rgba(181, 165, 96, 0.9)',
                                                                          'rgba(217, 177, 73, 0.9)','rgba(217, 137, 73, 0.9)',
                                                                          'rgba(217, 108, 73, 0.9)','rgba(217, 85, 123, 0.9)',
                                                                          'rgba(217, 85, 180, 0.9)','rgba(168, 85, 180, 0.9)'
  )))
  })
  
  output$avgcp = renderPlotly({
    avgcp = plot_ly(n_mem, x= ~Category, y= ~avg, type='bar', marker = list(color = c('rgba(185,66,64,0.9)', 'rgba(177, 78, 42, 0.9)',
                                                                                      'rgba(201, 147, 38, 0.9)', 'rgba(136, 214, 72, 0.9)',
                                                                                      'rgba(136, 214, 146, 0.9)','rgba(136, 214, 193, 0.9)',
                                                                                      'rgba(152, 119, 237, 0.9)','rgba(104, 119, 237, 0.9)',
                                                                                      'rgba(191, 106, 211, 0.9)','rgba(177, 106, 228, 0.9))',
                                                                                      'rgba(177, 163, 228, 0.9)', 'rgba(217, 129, 228, 0.9)',
                                                                                      'rgba(168, 146, 228, 0.9)', 'rgba(130, 146, 228, 0.9)',
                                                                                      'rgba(130, 177, 228, 0.9)','rgba(130, 177, 179, 0.9)',
                                                                                      'rgba(130, 177, 131, 0.9)','rgba(181, 165, 96, 0.9)',
                                                                                      'rgba(217, 177, 73, 0.9)','rgba(217, 137, 73, 0.9)',
                                                                                      'rgba(217, 108, 73, 0.9)','rgba(217, 85, 123, 0.9)',
                                                                                      'rgba(217, 85, 180, 0.9)','rgba(168, 85, 180, 0.9)'
    )))
  })
################################################ scatterplot 
  output$scatplm = renderPlotly({
    plot_ly(meetup_no_m, x= ~Past.Meetups, y= ~member, color= ~Category)
  })
  
  output$scatplu = renderPlotly({
    plot_ly(meetup_no_m, x= ~Upcoming.Meetups, y= ~member, color= ~Category)
  })
  
  output$scat3d = renderPlotly({
    plot_ly(meetup_no_m, x= ~Past.Meetups, y= ~Upcoming.Meetups, 
            z= ~member, color = ~Category, text= ~paste("Past:", Past.Meetups, '<br>Upcoming:', Upcoming.Meetups, '<br>Members:',member)) %>% 
      add_markers() %>% layout(scene = list(xaxis= list(title ='Past.Meetups'),
                                            yaxis = list(title = 'Upcoming.Meetups'),
                                            zaxis = list(title = 'member')))
  })
  ###################################################### heatmap
    
    output$heatm_poptime = renderPlotly({
    plot_ly(x= heatm_df$Timeslot, y=heatm_df$U_e_wd, z=heatm_df[[input$types]] , type = "heatmap")
  })

########################################################### table 
    output$tableouput = DT::renderDataTable({
      df = meetup_up_event %>% 
        filter(Location == input$location, U_e_wd == input$weekday)%>%
        
        filter(member>=input$member[1], member<=input$member[2])%>%
        filter(Past.Meetups>=input$pm[1], Past.Meetups<=input$pm[2]) %>%
        filter(Upcoming.Meetups>=input$um[1], Upcoming.Meetups<=input$um[2])%>%
        select(Category, name, member, Location, FoundedDate, Past.Meetups, Upcoming.Meetups, url)

    })

}