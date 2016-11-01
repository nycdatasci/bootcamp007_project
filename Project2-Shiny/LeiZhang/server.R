library(ggplot2)
library(dplyr)
library(leaflet)
library(sp)
library(rgdal)
library(ggmap)
library(maps)
function(input, output) {
#  filteredData <- reactive({
#    df_select<-df[df$city==input$ct & df$pokemonName==input$mon,]
#    df_select<-df_select%>%group_by(pokemonId,pokemonName,latitude,longitude,appearedTimeOfDay)%>%
#      summarise(num=sum(pokemonId))})
##  NY_data<- reactive({
#    df_select<-df[df$city==input$ct & df$pokemonName==input$mon,]
#    df_select<-df_select%>%group_by(pokemonId,pokemonName,latitude,longitude,appearedTimeOfDay)%>%
#      summarise(num=sum(pokemonId))
#    df_select<-df_select%>%filter(latitude < 41.5 & latitude > 40 & longitude< -73 & longitude>-74)})
#  mapselect <- reactive({
 #   if (input$checkGroup==1){
 #     output$plot<-renderPlot({ggmap(get_map(location = input$ct, zoom = input$size,maptype = "roadmap",scale = 2),extent = "device",maprange = FALSE)+
#          geom_point(data=filteredData(), aes(x=longitude, y=latitude, size= num*100), color="blue",alpha = 0.8)+ scale_size(range = c(3, 20))
        
      output$mymap <- renderLeaflet({
        df_select<-df[df$city==input$ct & df$pokemonName==input$mon,]
        df_select<-df_select%>%group_by(pokemonId,pokemonName,latitude,longitude,appearedTimeOfDay)%>%
          summarise(num=sum(pokemonId))
        if (input$ct =="New_York"){
          df_select<-df_select%>%filter(latitude < 41.5 & latitude > 40 & longitude< -73 & longitude>-74)
          leaflet(data=df_select)%>%addCircles(lat = ~latitude, lng = ~longitude, radius=~num)%>%
            setView(lng = -73.965242, lat = 40.780610, zoom = input$size)%>% addProviderTiles(input$map)#%>%addMarkers(~longitude, ~latitude)
        }
        else {
          leaflet(data=df_select) %>%
            addCircles(lat = ~latitude, lng = ~longitude, radius=~(num*1000))%>%
            addProviderTiles(input$map,options = providerTileOptions(noWrap = FALSE))%>%
            addMarkers(~longitude, ~latitude, popup = ~as.character(pokemonName))
          }
        
        })
      
      output$mytable = renderDataTable({pkmStatus[pkmStatus$Name==input$mon,][,2:12]}, options = list(bSortClasses = FALSE))
    }
#  # points <- eventReactive(input$recalc, {
# #    cbind(rnorm(40) * 2 + 13, rnorm(40) + 48)
# #  }, ignoreNULL = FALSE)
#   
#  output$mymap <- renderLeaflet({
#        filter(latitude < (mean(latitude)+0.5) & latitude > (mean(latitude)-0.5) & longitude< (mean(longitude)+0.5)&longitude>(mean(longitude)-0.5))%>%
        
#      for (i in length(df_select$latitude)){
#        if (df_select$latitude[i] > median(df_select$latitude)+1 | df_select$latitude[i] < median(df_select$latitude)-1|
#            df_select$longitude[i] > median(df_select$longitude)+1 | df_select$longitude[i] < median(df_select$longitude)-1){
#          df_select<-df_select[-i,]
#        }
#      }
 #     print (df_select)
#        if (input$ct =="New_York"){
#        leaflet(data=NY_data())%>%addCircles(lat = ~latitude, lng = ~longitude, radius=~num)%>%
#        setView(lng = -73.965242, lat = 40.780610, zoom = input$size)%>% addProviderTiles(input$map)#%>%addMarkers(~longitude, ~latitude)
#        }
#      else {
#      leaflet(data=filteredData()) %>%
#          addCircles(lat = ~latitude, lng = ~longitude, radius=~(num*1000))%>%
#          addProviderTiles(input$map,options = providerTileOptions(noWrap = FALSE))%>%
#          addMarkers(~longitude, ~latitude, popup = ~as.character(pokemonName))
#      }})
#   output$plot<-renderPlot({ggmap(get_map(location = input$ct, zoom = input$size,maptype = "roadmap",scale = 2),extent = "device",maprange = FALSE)+
#       geom_point(data=filteredData(), aes(x=longitude, y=latitude, size= num*100), color="blue",alpha = 0.8)+ scale_size(range = c(3, 20))
#   })
#}
