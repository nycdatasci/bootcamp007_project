function(input, output){
  
  # tab-1 'TEDx Events 2017'
  output$map = renderLeaflet(mymap)

    
  # tab-2 'Graphic EDA of Views'
  # tab-2.1
  output$scatterplot = renderPlot({
    myplot = ggplot(tedtalk, aes(x = input$factors, y = total_views/1e6)) +
      geom_jitter(aes_string(color = input$topics1), stat = 'identity') +
      theme_economist_white(gray_bg = F) +
      scale_fill_brewer(palette = 'Set2', name = input$topics1) +
      ggtitle('Topics vs. Views') +
      ylab('Views(million)') +
      theme(legend.position = 'right', axis.title.x = element_blank(),
            axis.text.x = element_blank())
    if(input$log10y){
      myplot = myplot + scale_y_log10()
    }
    myplot
  })
  # tab-2.2
  tedbar = reactive({
    df = tedtalk %>% select_(.dots = c('total_views', topic1 = input$topics1))
    df %>% group_by(., topic1) %>%
      summarise(., views = sum(total_views/1e6, na.rm = T)/n())
  })
  output$barchart = renderPlot({
    ggplot(tedbar(), aes_string(x = 'topic1', y = 'views')) +
      geom_bar(aes_string(fill = 'topic1'), stat = 'identity', width = 0.2, position = 'dodge') +
      theme_economist_white(gray_bg = F) +
      scale_fill_brewer(palette = 'Set2', name = input$topics1, labels = c('No', 'Yes')) +
      ggtitle('Topics vs. Views') +
      ylab('Views(million)') +
      theme(legend.position = 'right', axis.title.x = element_blank(),
            axis.text.x = element_blank())
  })
  # tab-2.3
  output$barchart2 = renderPlot({
    ggplot(topic_num, aes(x = reorder(topic, -topic_counts), y = topic_counts)) +
      geom_bar(aes(fill = topic), stat = 'identity', width = 0.4, alpha = 0.6) +
      theme_economist_white(gray_bg = F) +
      scale_fill_brewer(palette = 'Set2') +
      ggtitle('Topics vs. Video Numbers') +
      ylab('Counts') +
      theme(legend.position = 'right', axis.title.x = element_blank())
  })
  
  
  # tab-3 'Topic Perspective'
  # tab-3.1
  # dygraph: time vs. topic_type
  output$dygraphs = renderDygraph({
    dygraph(topic_xt, main = 'Topic Views Changes on Time Series') %>%
      dyOptions(colors = RColorBrewer::brewer.pal(7, 'Paired'), fillGraph = T, fillAlpha = 0.2,
                includeZero = T, axisLineColor = '#386cb0') %>%
      dyHighlight(highlightCircleSize = 2, 
                  highlightSeriesBackgroundAlpha = 1,
                  hideOnMouseOut = F,
                  highlightSeriesOpts = list(strokeWidth = 1)) %>%
      dyAxis('x', drawGrid = F,
             axisLabelFormatter = "function(y){return y.getFullYear()}") %>%
      dyAxis('y', label = 'Views(million)', gridLineWidth = 0.1) %>%
      dyLegend(width = 215, show = 'onmouseover', labelsSeparateLines = T) %>% 
      dyRangeSelector(height = 20, fillColor = '#bdc9e1', strokeColor = '') %>% 
      dyRoller(rollPeriod = 6)
  })
  # tab-3.2  
  output$force = renderForceNetwork({
    forceNetwork(Links = networklinks, Nodes = nodes, 
                 Source = 'src', Target = 'target', Value = 'value',
                 NodeID = 'name', Nodesize = 'nodesize', Group = 'group',
                 fontSize = 40, linkColour = '#bdc9e1',
                 linkDistance = JS("function(d){return (d.value ^ 10) * 10}"),
                 zoom = T, legend = T, opacity = 0.8)
  })
  
  
}