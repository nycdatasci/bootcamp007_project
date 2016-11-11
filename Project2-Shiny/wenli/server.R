function(input, output) {
  
  # user selected input from tab-1 absolutePanel
  points = reactive({
    LatLngTime %>% filter(., EVENT_TYPE %in% input$top6, YEAR %in% input$year)
  })
  
  bar = reactive({
    df = LatLngTime %>% filter(., EVENT_TYPE %in% input$top6, YEAR %in% input$year) %>%
      select_(.dots = c('EVENT_TYPE', yloss = input$loss))
    df %>% group_by(., EVENT_TYPE) %>% summarise(., counts = sum(yloss, na.rm = T))
  })
  
  # tab-1 output
  mymap = leaflet() %>% setView(lat = 39.82, lng = -98.58, 4) %>%
    addProviderTiles('CartoDB.Positron') %>%
    addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
             attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
    addLegend("topright", pal = colpal, values =c('Flash Flood', 'Flood', 'Hail', 
              'Marine Thunderstorm Wind', 'Thunderstorm Wind', 'Tornado'), title = "Storm Type",
              opacity = 0.5)
  output$map = renderLeaflet(mymap)
  
  observe({
    if (nrow(points()) == 0) {leafletProxy('map') %>% clearShapes()} 
    else {
      leafletProxy('map', data = points()) %>% clearShapes() %>%
        addCircles(lat = ~ LATITUDE, lng = ~ LONGITUDE,
                   radius = 500, stroke = F, fillOpacity = 0.5, 
                   color = ~ colpal(EVENT_TYPE), 
                   popup = ~ paste(sep = '<br/>','Event Type:', EVENT_TYPE))}
  })
  
  output$bar = renderPlot({
    ggplot(bar(), aes_string(x = 'EVENT_TYPE', y = 'counts')) +
      geom_bar(aes_string(fill = 'EVENT_TYPE'), stat = 'identity', width = 0.1, alpha = 0.6) + 
      theme_economist() +
      scale_fill_economist() +
      ggtitle('Loss vs. Storm Events') +
      ylab('Counts or Damage (million $)') +
      theme(legend.position = 'none', axis.title.x=element_blank(),
            axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1))
  })

  
  
  
  
  # tab-2 output
  output$dygraph1 = renderDygraph({
    dygraph(types_xt, main = 'Storm Events in U.S. 2007 - 2016', group = 'SE') %>%
      dyOptions(colors = RColorBrewer::brewer.pal(6, 'Paired'), fillGraph = T, fillAlpha = 0.2,
                includeZero = T, axisLineColor = '#386cb0') %>%
      dyHighlight(highlightCircleSize = 2, 
                  highlightSeriesBackgroundAlpha = 1,
                  hideOnMouseOut = F,
                  highlightSeriesOpts = list(strokeWidth = 1)) %>%
      dyAxis('x', drawGrid = F, axisLabelColor = 'white',
             axisLabelFormatter = "function(y){return y.getFullYear()}") %>%
      dyAxis('y', label = 'Event Counts', gridLineWidth = 0.1, axisLabelColor = 'white') %>%
      dyLegend(width = 215, show = 'onmouseover', labelsSeparateLines = T) %>% 
      dyRangeSelector(height = 20, fillColor = '#bdc9e1', strokeColor = '') %>% 
      dyRoller(rollPeriod = 1)
  })
  
  output$dygraph2 = renderDygraph({
    dygraph(fata_xt, main = 'Fatality in Storm Events', group = 'SE') %>%
      dyOptions(colors = RColorBrewer::brewer.pal(2, 'Set2'), fillGraph = T, fillAlpha = 0.4,
                includeZero = T, axisLineColor = '#386cb0') %>%
      dyHighlight(highlightCircleSize = 2, 
                  highlightSeriesBackgroundAlpha = 1,
                  hideOnMouseOut = F,
                  highlightSeriesOpts = list(strokeWidth = 1)) %>%
      dyAxis('x', drawGrid = F, axisLabelColor = 'white',
             axisLabelFormatter = "function(y){return y.getFullYear()}") %>%
      dyAxis('y', label = 'Deaths', gridLineWidth = 0.1, axisLabelColor = 'white') %>%
      dyLegend(width = 80, show = 'onmouseover', labelsSeparateLines = T) %>% 
      dyRangeSelector(height = 20, fillColor = '#bdc9e1', strokeColor = '') %>% 
      dyRoller(rollPeriod = 1)
  })

  
  
  
  # tab-3 output
  output$barplt1 = renderPlot({
    ggplot(FatalLoc,
           aes(x = reorder(FATALITY_LOCATION, FATALITY_LOCATION, function(x)-length(x)))) +
      geom_bar(aes(fill = FATALITY_SEX), alpha = 0.7) +
      theme_economist() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
            legend.position = 'top') +
      scale_fill_economist(name = '', label = c('Female', 'Male', 'Unknown')) +
      guides(color = 'legend') +
      ggtitle('Fatality Location') +
      xlab('') +
      ylab('Deaths')
  })
  
  output$barplt2 = renderPlot({
    ggplot(dths, aes(x = reorder(EVENT_TYPE, -DEATHS), y = DEATHS)) +
      geom_bar(aes(fill = EVENT_TYPE), stat = 'identity', alpha = 0.7, width = 0.6) +
      theme_economist() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
            legend.position = 'none') +
      theme_economist() +
      scale_fill_economist() +
      ggtitle('Storm Types vs. Fatality') +
      xlab('') +
      ylab('Deaths')
  })
  
  output$boxplt = renderPlot({
    ggplot(FatalLoc, aes(x = FATALITY_SEX, y = FATALITY_AGE)) +
      geom_boxplot(aes_string(fill = 'FATALITY_SEX'), color = 'lightgray', alpha = 0.7, width = 0.3) +                 
<<<<<<< HEAD
      theme_economist() +
      scale_fill_economist(guide = 'none') +
=======
      # theme_economist() +
      theme_economist() +
>>>>>>> 376e535380b47a3cc3808ecbde4a96752621474d
      theme(axis.title.x=element_blank()) +
      scale_fill_economist() +
      ylab('Age') +
      scale_x_discrete(labels = c('Female', 'Male', 'Unknown'))
  })
  
  
  # tab-4 wordcloud data
  descr = reactive({desc_txt})
  
  # tab-4 wordcloud output
  output$wordcloud = renderPlot({
    par(bg = "#2B3E4F") 
    wordcloud(words = descr()$word, freq = descr()$freq, min.freq = input$min_freq,
              max.words = input$max_wds, random.order = FALSE, rot.per = 0.35, 
              colors = brewer.pal(8, 'Pastel1'))
  })
  
}