library(ggplot2)
library(plotly)
library(scales)
library(dplyr)
library(maps)

# color range for charts
hColor = "#77A5CA"
lColor = "#973231"
mColor = "#E3E3E3"
# plotly needs it in an array
cscale = array(dim=c(3, 2),data = c(0,0.5, 1,lColor, mColor,hColor))

# load data
load("busData") # state level econ data w/ industry level
load("byCountyData") # county level econ data
load("countiesGeo") # lat/longitude info for county plot
load("byCountyUnempData") # County-level enemployment data

# join geographic info for polygon plot to the economic data
countiesGeo = inner_join(byCountyData, countiesGeo, by=c("stateAbbr","County.Name"="subregion"))

# build dummy notes for hover event in top left map
notes = data.frame(c(2009, 2011,2002, 2008), 
                   c("NV","ND","CO", "DE"), 
                   c("Largest drop in employment. 2.8 million <br>
                     properties with a mortgage got a foreclosure notice.<br>
                     Large drops in construction employment",
                    "Jump in fracking employment. Gas industry <br>
                     providing 12% of state's employment",
                    "Drop in IT employment after dot com bubble.",
                    "Large drop in financial services sector<br>
                     in northern DE."), stringsAsFactors = FALSE)
colnames(notes) = c("yr","stateAbbr","Note")

# Join notes to main state-level data table
# Set Note to empty string to prevent "NA" from showing up in the popup box
busData <-left_join(busData, notes, by=c("yr","stateAbbr"))
busData[is.na(busData$Note),"Note"] = ""

# get max and mins for each data element
t = c("num_emp_chg",
              "tot_payroll_chg",
              "num_est_chg",
              "num_emp_pcap",
              "tot_payroll_pcap",
              "num_est_pcap")

busDataF = subset(busData, yr!=2007 & indLevel == 0 & fipstate!=11) # not D.C.

maxMinCols <-  as.data.frame(list(colName = t, maxVal=rep(0, length(t))))
# add max and min to a DF. This is used to
# make the range consistent in the colorbars
# Scale it down by 20% to increase the granularity
# of the color range
for (i in maxMinCols$colName) {
  temp = 0.8* max(c(abs(min(busDataF[,i], na.rm=T)), abs(max(busDataF[,i], na.rm=T))))
  maxMinCols[maxMinCols$colName==i,2]=temp
}
rm(busDataF)

# need to do this so the point number that shows up 
# in the click event matches the ID of the factor.
# This way we can retrieve which state was clicked on.
busData$stateAbbr <- factor(busData$stateAbbr)
busData <- arrange(busData, yr, indLevel,stateAbbr)


# give state boundaries a white border
l <- list(color = toRGB("white"), width = 1)

# specify some map projection/options
g <- list(
  scope = 'usa',
  projection = list(type = 'albers usa'),
  showlakes = TRUE,
  lakecolor = toRGB('white')
)


# ---------------------------------------------------------------
#
#  Main plot
#
# ---------------------------------------------------------------
function(input, output) {
  
# County Plot
  output$distPlot <- renderPlotly( {
    
    # set a bunch of parameters depending on the the selections
    # in the widgets
    
    if (input$radio_lvlpct=="pctChg") {
      chosenMetric = paste0(input$metric, "_chg")
      maxval = maxMinCols[maxMinCols$colName == chosenMetric,2]
      minval = -maxMinCols[maxMinCols$colName == chosenMetric,2]
      legendLabel = "Percent\nChange"
      revScale = FALSE
      currCol = input$metric
      prevCol = paste0("prev_",input$metric)
      changeCol = chosenMetric
    } else {
      chosenMetric = paste0(input$metric, "_pcap")
      currCol = chosenMetric
      prevCol = chosenMetric
      changeCol=chosenMetric
      maxval = maxMinCols[maxMinCols$colName == chosenMetric,2]
      minval = 0
      legendLabel = "Per\nCapita"
      revScale = FALSE
    }
    

    
    # create convenience data frame filtered by ui widget. Rename cols to accommodate plotly. 
    if (input$notesOnly==TRUE) {
      busDataF = subset(busData, yr==input$yr & indLevel == 0 & Note!="")
    } else {
      busDataF = subset(busData, yr==input$yr & indLevel == 0)
    }
    
    busDataDisp = data.frame(
      busDataF[,"stateAbbr"],
      busDataF[,"Note"],
      busDataF[,currCol],
      busDataF[,changeCol],
      busDataF[,prevCol],
      busDataF[,chosenMetric]
    )

    colnames(busDataDisp)<- c("stateAbbr", "Note", "zcurr","zchg","zprev","zdisp")
    
    # set up hover text
    
    if (currCol == "tot_payroll") {
      currData = dollar(busDataDisp$zcurr)
      prevData = dollar(busDataDisp$zprev)
    } else if (currCol == "tot_payroll_pcap") {
      currData = paste0(dollar(busDataDisp$zcurr),"k")
      prevData = paste0(dollar(busDataDisp$zprev),"k")
    } else {
      currData = busDataDisp$zcurr
      prevData = busDataDisp$zprev
    }
      
    
    hov = paste0(busDataDisp$stateAbbr, '<br>')
    hov = paste0(hov, "Current: ",currData,'<br>')
    if (input$radio_lvlpct=="pctChg") {
      hov = paste0(hov, "Prev: ",prevData)
    } 
      
    busDataDisp$hover = paste0(hov, ifelse(busDataDisp$Note!="",paste0("<br>",busDataDisp$Note),""))
    
    
    

    # place in parent frame so detail plots can access
    busDataDisp <<- busDataDisp

    # plot map
    plot_geo(busDataDisp, locationmode = 'USA-states', source="cmap") %>% 
      add_trace(
        z = ~zdisp, locations = ~stateAbbr, text = ~hover,
        color = ~zchg, zmax=maxval, zmin=minval, reversescale=revScale, colorscale=cscale,  marker = list(line = l)
      ) %>%
      colorbar(title = legendLabel) %>%
      layout(
        geo = g
      )


  }
  )
  # Industry Plot
  
  output$detPlot <- renderPlotly( {
    
    # If we got a click event, get the point number from the event
    event.data <- event_data("plotly_click", source="cmap")
    if(is.null(event.data) == T) return(NULL)
    idx = event.data[[2]] # corresponds to point number
    
    
    
    # Point number is one less than the corresponding level
    # in the choropleth's data frame (not sure why --- this is a hack)
    st = levels(busDataDisp$stateAbbr)[idx+1]
    print(st)
    
    # now that we know what state was clicked on, filter a dataframe accordingly
    busDataF = subset(busData, yr==input$yr & indLevel == 1 & stateAbbr==st)
    busDataDispDet = data.frame(
      busDataF[,"industName"],
      busDataF[,input$metric],
      busDataF[,paste0(input$metric, "_chg")],
      busDataF[,paste0("prev_",input$metric)]
    )
    
    # rename cols to generic names for plotly and then sort and peel off the top 20
    colnames(busDataDispDet)<- c("industName", "zcurr","zchg","zprev")
    busDataDispDet <- busDataDispDet %>% top_n(20, zcurr) %>% arrange(-zcurr)
    
    # prefix the group names with a number so plotly displays them in the correct order
    t = paste0(0,rownames(busDataDispDet))
    t = substr(t, nchar(t)-2+1, nchar(t))
    t = paste(t, busDataDispDet$industName )
    t = ifelse(nchar(t) > 25, paste0(substr(t, 0, 25), "..."), t)
    
    
    busDataDispDet$industName = t
    ttl = paste(input$metric,"000's")
    
    # plot graph
    plot_ly(
      x = busDataDispDet$zcurr,
      y = busDataDispDet$industName,
      type = "bar",
      name = 'Curr', marker = list(color = 'rgb(49,130,189)')) %>%
      add_trace(x = ~busDataDispDet$zprev, name = 'Prev', marker = list(color = 'rgb(204,204,204)')) %>% 
      layout(autosize = F, width = 700, height = 400, margin=list(l=200),
             title=paste("Industry breakout for ",st), 
             xaxis = list(title = ttl))
  
    
  }
  )
  # Unemployment Plot
  
  output$trendPlot <- renderPlotly( {
    
    # find state (see other detail plot for explanation of why I do this)
    event.data <- event_data("plotly_click", source="cmap")
    if(is.null(event.data) == T) return(NULL)
    idx = event.data[[2]]
    st = levels(busDataDisp$stateAbbr)[idx+1]
    
    # subset based on state
    busDataF = subset(busData, indLevel == 0 & stateAbbr==st)
    byCountyUnempDataF = subset(byCountyUnempData, stateAbbr==st)
    
    
    ggplot() + 
      geom_point(data = byCountyUnempDataF, aes(y = unempRate, x = Year, color=County.Name)) +
      geom_line(data=busDataF, aes(y = busDataF$unempRate, x = busDataF$yr), color="gray20") +
      theme_minimal() +
      ggtitle(paste("Unemployment Trend for", st)) +
      theme(legend.position="none") +
      theme(axis.title.x=element_blank()) +
      ylab("Unemployment Rate") + 
      scale_color_brewer(palette="Spectral") +
      ylim(0,20)

  }
  )

  # countyPlot

  output$countyPlot <- renderPlotly( {

    # find state (see other detail plot for explanation of why I do this)

    event.data <- event_data("plotly_click", source="cmap")
    if(is.null(event.data) == T) return(NULL)
    idx = event.data[[2]]
    st = (levels(busDataDisp$stateAbbr)[idx+1])
    
    if (input$radio_lvlpct=="pctChg") {
      chosenMetric = paste0(input$metric, "_chg")
      maxval = maxMinCols[maxMinCols$colName == chosenMetric,2]
      minval = -maxMinCols[maxMinCols$colName == chosenMetric,2]
      legendLabel = "% Change"
      revScale = FALSE
    } else {
      chosenMetric = paste0(input$metric, "_pcap")
      maxval = maxMinCols[maxMinCols$colName == chosenMetric,2]
      minval = 0
      legendLabel = "Per\nCapita"
      revScale = FALSE
    }
    

    # plot graph

    countiesF = countiesGeo[countiesGeo$stateAbbr==st & countiesGeo$yr==input$yr,]
    
    countiesF = data.frame(
      countiesF[,"group"],
      countiesF[,"order"],
      countiesF[,"long"],
      countiesF[,"lat"],
      countiesF[,input$metric],
      countiesF[,paste0(input$metric, "_chg")],
      countiesF[,paste0("prev_",input$metric)],
      countiesF[,chosenMetric]
    )
    
    colnames(countiesF) = c("group","order","long","lat","zcurr","zchg","zprev","zdisp")
    
    # removed this from scale_fillgradient: limits=c(minval*1.2, maxval*1.2)
    ggplot(data = countiesF, aes(x = long, y = lat)) +
      geom_polygon(aes(group = group, fill = zdisp)) + coord_fixed(ratio=1) +
      theme_minimal() + scale_fill_gradient2( high=hColor, mid=mColor, low=lColor, name = legendLabel) +
      scale_x_continuous(breaks = NULL) +
      scale_y_continuous(breaks = NULL) +
      theme(axis.title.x=element_blank(), axis.title.y=element_blank(), legend.key=element_blank())
   
  }
  )
}

