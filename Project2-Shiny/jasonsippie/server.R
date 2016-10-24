library(ggplot2)
library(plotly)

load("busData")



# give state boundaries a white border
l <- list(color = toRGB("white"), width = 2)
# specify some map projection/options
g <- list(
  scope = 'usa',
  projection = list(type = 'albers usa'),
  showlakes = TRUE,
  lakecolor = toRGB('white')
)

function(input, output) {
  
# master plot
  output$distPlot <- renderPlotly( {

    busDataF = subset(busData, yr==input$yr & indLevel == 0)
    busDataDisp = data.frame(
      busDataF[,"stateAbbr"],
      busDataF[,input$metric],
      busDataF[,paste0(input$metric, "_chg")],
      busDataF[,paste0("prev_",input$metric)]
    )
    
    colnames(busDataDisp)<- c("stateAbbr", "zcurr","zchg","zprev")
    
    busDataDisp$hover <- with(busDataDisp,
                           paste(stateAbbr, '<br>', "Current", dollar(zcurr),'<br>', "Previous", dollar(zprev)))
    busDataDisp <- arrange(busDataDisp, stateAbbr, zcurr,zchg,zprev)
    
    busDataDisp <<- busDataDisp
    
    plot_geo(busDataDisp, locationmode = 'USA-states', source="cmap") %>%
      add_trace(
        z = ~zchg, locations = ~stateAbbr, text = ~hover,
        color = ~zchg, zmax=20, zmin=-20, reversescale=TRUE, colorscale="Portland"
      ) %>%
      colorbar(title = "Percent") %>%
      layout(
        title = 'YoY % Change',
        geo = g
      )
    
  }
  )
  ## detail plot
  
  output$detPlot <- renderPlotly( {
    
    event.data <- event_data("plotly_click", source="cmap")
    if(is.null(event.data) == T) return(NULL)
    idx = event.data[[2]]
    st = levels(busDataDisp$stateAbbr)[idx+1]
    
    
    busDataF = subset(busData, yr==input$yr & indLevel == 1 & stateAbbr==st)
    busDataDispDet = data.frame(
      busDataF[,"industName"],
      busDataF[,input$metric],
      busDataF[,paste0(input$metric, "_chg")],
      busDataF[,paste0("prev_",input$metric)]
    )
    
    colnames(busDataDispDet)<- c("industName", "zcurr","zchg","zprev")
    busDataDispDet <- busDataDispDet %>% top_n(20, zcurr) %>% arrange(-zcurr)
    
    t = paste0(0,rownames(busDataDispDet))
    t = substr(t, nchar(t)-2+1, nchar(t))
    busDataDispDet$industName <- paste(t, busDataDispDet$industName )

    plot_ly(
      y = busDataDispDet$zprev,
      x = busDataDispDet$industName,
      type = "bar",
      name = 'Prev', marker = list(color = 'rgb(204,204,204)')) %>%
      add_trace(y = ~busDataDispDet$zcurr, name = 'Curr', marker = list(color = 'rgb(49,130,189)')) %>% 
      layout(autosize = F, width = 600, height = 250, margin=list(b=70),
             title=paste("Industry breakout for ",st), 
             yaxis = list(title = input$metric))
  
    
  }
  )
  ## detail plot
  
  output$trendPlot <- renderPlotly( {
    
    event.data <- event_data("plotly_click", source="cmap")
    if(is.null(event.data) == T) return(NULL)
    idx = event.data[[2]]
    st = levels(busDataDisp$stateAbbr)[idx+1]
    
    
    busDataF = subset(busData, indLevel == 0 & stateAbbr==st)
    
    ay <- list(
      overlaying = "y",
      side = "right",
      title = "second y axis"
    )
    
    plot_ly(
      y = busDataF$num_emp,
      x = busDataF$yr,
      type = "scatter", mode="line",
      name = '# Employees') %>%
      add_trace(y=busDataF$tot_payroll, name="Payroll", yaxis="y2") %>% 
      layout(autosize = F, width = 600, height = 250, margin=list(b=70),
             title=paste("Trend for ",st), 
             yaxis = list(title = "Employees"),
             yaxis2 = ay)
  
    
  }
  )

}

