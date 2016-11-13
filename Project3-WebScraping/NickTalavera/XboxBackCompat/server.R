# shinyHome
# Real Estate Analytics and Forecasting
# Nick Talavera
# Date: October 25, 2016

# server.R

#===============================================================================
#                               SHINYSERVER                                    #
#===============================================================================
str_Currency <- function(value, currency.sym="$", digits=2, sep=",", decimal=".") {
  paste(
    currency.sym,
    formatC(value, format = "f", big.mark = sep, digits=digits, decimal.mark=decimal),
    sep=""
  )
}

reorder_size <- function(x) {
  factor(x, levels = names(sort(table(x))))
}

shinyServer(function(input, output, session) {
  
  
  #===============================================================================
  #                        DASHBOARD SERVER FUNCTIONS                            #
  #===============================================================================
  # Render National Home Value Index Box
  output$usViBox <- renderValueBox({
    # current <- currentState[ which(currentState$State == "United States"), ]
    valueBox(
      paste0(nrow(xboxData)), paste("Drug Postings"), 
      icon = icon("bar-chart"), color = "red"
    )
  })
  
  
  # Highest Home Value Index by City Box
  output$highestViBox <- renderValueBox({
    dataSet = select(xboxData,Market_Name,Drug_Type,Price_Per_Gram_BTC)
    dataSet$Market_Name = as.character(dataSet$Market_Name)
    dataSetTemp = summarise(group_by(dataSet, Drug_Type), mnCount = length(unique(Market_Name)))
    dataSetTemp = filter(dataSetTemp, mnCount >=2)
    
    drugRandom = sample(unique(dataSetTemp$Drug_Type),1)
    dataSet = dataSet[dataSet$Drug_Type == drugRandom,]
    marketRandom = sample(unique(dataSet$Market_Name),1)
    averagePriceNotMarket = mean(dataSet$Price_Per_Gram_BTC[dataSet$Drug_Type == drugRandom & dataSet$Market_Name != marketRandom], na.rm = TRUE)
    averagePriceMarket = mean(dataSet$Price_Per_Gram_BTC[dataSet$Drug_Type == drugRandom & dataSet$Market_Name == marketRandom], na.rm = TRUE)
    percentDiff = (averagePriceMarket - averagePriceNotMarket) / abs(averagePriceNotMarket)
    if (percentDiff > 0) {
      hl = "Higher"
    }
    else {
      hl = "Lower"
    }
    percentDiff = abs(percentDiff)
    percentDiff = signif(percentDiff, digits = 3)
    valueBox(
      paste0(percentDiff,"%"), str_title_case(paste(hl, "Than Average Prices For", drugRandom, "At", marketRandom)), 
      icon = icon("money"), color = "blue"
    )
  })
  
  # Render Annual Price Growth  Box
  output$usAnnualBox <- renderValueBox({
    price = 0
    dataSet = select(xboxData,Sheet_Date,Shipped_From,Market_Name,Drug_Type,Price_Per_Gram_BTC)
    dataSetTemp = summarise(group_by(dataSet, Drug_Type), mnCount= length(unique(Market_Name)))
    print(dataSetTemp)
    dataSetTemp = filter(dataSetTemp, mnCount >=2)
    drugRandom = sample(unique(dataSetTemp$Drug_Type),1)
    dataSet = dataSet[dataSet$Drug_Type == drugRandom,]
    countryRandom = sample(unique(dataSet$Shipped_From[!is.na(dataSet$Shipped_From)]),1)
    dataSet = dataSet[dataSet$Shipped_From == countryRandom,]
    dateRandom = sample(unique(dataSet$Sheet_Date[!is.na(dataSet$Sheet_Date)]),1)
    dataSet = dataSet[dataSet$Sheet_Date == dateRandom,]
    dataSet = dataSet[!is.na(dataSet$Price_Per_Gram_BTC),]
    price = mean(dataSet$Price_Per_Gram_BTC, rm.na = TRUE)*28.345
    valueBox(
      paste0(str_Currency(price)), paste("Average Price Per Ounce For",drugRandom,"In",str_title_case(countryRandom), "on", dateRandom), icon = icon("dollar"), color = "green"
    )
  })
  
  # Render Highest Annual Price Growth  Box
  output$highestAnnualBox <- renderValueBox({
    price = 0
    dataSet = select(xboxData,Sheet_Date,Shipped_From,Market_Name,Drug_Type,Price_Per_Gram_BTC)
    dataSetTemp = summarise(group_by(dataSet, Drug_Type), mnCount= length(unique(Market_Name)))
    dataSetTemp = filter(dataSetTemp, mnCount >=2)
    drugRandom = sample(unique(dataSetTemp$Drug_Type),1)
    dataSet = dataSet[dataSet$Drug_Type == drugRandom,]
    marketRandom = sample(unique(dataSet$Market_Name[!is.na(dataSet$Market_Name)]),1)
    dataSet = dataSet[dataSet$Market_Name == marketRandom,]
    mostPostedDay = names(sort(summary(as.factor(xboxData$Time_Added[xboxData$Market_Name == marketRandom])), decreasing=T))
    for (i in 1:length(mostPostedDay)) {
      if (mostPostedDay[i] != "NA's" & mostPostedDay[i] != "(Other)") {
        mostPostedDay = mostPostedDay[i]  
        break
      }
    }
    price = mean(dataSet$Price_Per_Gram_BTC, rm.na = TRUE)
    valueBox(
      paste0(mostPostedDay), paste("Day Of The Most",drugRandom,"Posts On",marketRandom), icon = icon("line-chart"), color = "purple"
    )
  })
  
  # Render number of states box
  output$numStatesBox <- renderValueBox({
    dataSet = select(xboxData,Shipped_From)
    mostPostedInCountry = names(sort(summary(as.factor(xboxData$Shipped_From), decreasing=T)))[1]
    valueBox(
      paste0(str_title_case(mostPostedInCountry)), paste("Most Active Country"), 
      icon = icon("map-marker"), color = "green"
    )
  })
  
  # Render number of counties box
  output$mostPostedDruginXCountry <- renderValueBox({
    dataSet = select(xboxData,Drug_Type,Shipped_From)
    countryRandom = sample(unique(xboxData$Shipped_From[!is.na(dataSet$Shipped_From) & xboxData$Shipped_From != "unknown"]),1)
    mostPostedDrug = names(sort(summary(as.factor(xboxData$Drug_Type[xboxData$Shipped_From == countryRandom])), decreasing=T))
    for (i in 1:length(mostPostedDrug)) {
      if (mostPostedDrug[i] != "NA's") {
        mostPostedDrug = mostPostedDrug[i]  
        break
      }
    }
    valueBox(
      paste0(str_title_case(as.character(mostPostedDrug))), paste("Most Posted Drug in",as.character(str_title_case(as.character(countryRandom)))), 
      icon = icon("map"), color = "yellow"
    )
  })
  
  # Render number of cities box
  output$bitcoinHighLow <- renderValueBox({
    dataSet = select(xboxData,BitcoinPriceUSD)
    #dataSet = dataSet[!is.infinite(abs(dataSet$BitcoinPriceUSD)),]
    choice = sample(c(1:3),1)
    if (choice == 1) {
      value = min(dataSet$BitcoinPriceUSD, na.rm = TRUE)
      text = "Low"
    }
    else if (choice == 2) {
      value = mean(dataSet$BitcoinPriceUSD, na.rm = TRUE)
      text = "Average"
    }
    else {
      value = max(dataSet$BitcoinPriceUSD, na.rm = TRUE)
      text = "High"
    }
    valueBox(
      printCurrency(value), paste(text,"Bitcoin Price"), 
      icon = icon("map-pin"), color = "red"
    )
  })
  
  # Render number of cities box
  output$mostPopularMarketForDrugX <- renderValueBox({
    dataSet = summarise(group_by(xboxData, Drug_Type, Market_Name), mnPrice = mean(Price_Per_Gram_BTC))
    drugRandom = sample(unique(dataSet$Drug_Type),1)
    dataSet = filter(dataSet, Drug_Type == drugRandom)
    dataSet = arrange(dataSet, desc(mnPrice))
    print(dataSet)
    lowestCost = min(dataSet$mnPrice, na.rm = TRUE)
    lowestMarket = dataSet$Market_Name[dataSet$mnPrice == lowestCost]
    valueBox(
      paste0(lowestMarket), str_title_case(paste("Market With Lowest Average Price For",drugRandom)), icon = icon("line-chart"), color = "black"
    )
  })
  
  
  
  #===============================================================================
  #                         MARKET EXPLORER FUNCTIONS                            #
  #===============================================================================
  
  
  output$mostCommonDrugsHist <- renderPlot({
    withProgress(message = "Rendering Most Common Drug Listing by Count Bar Graph", {
      # Get Data
      dataSet <- getDataSetToUse()
      dataSet = dataSet[!is.na(dataSet$Drug_Type),]
      temp <- row.names(as.data.frame(summary(dataSet$Drug_Type, max=8))) # create a df or something else with the summary output.
      dataSet$Drug_Type <- as.character(dataSet$Drug_Type)
      dataSet$top <- ifelse(
        dataSet$Drug_Type %in% temp, ## condition: match aDDs$answer with row.names in summary df
        dataSet$Drug_Type, ## then it should be named as aDDs$answer
        "Other" ## else it should be named "Other"
      )
      dataSet$top <- as.factor(dataSet$top)
      
      
      colourCount = length(unique(dataSet$Price_Per_Gram_BTC))
      getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      platteNew = getPalette(colourCount)
      g = ggplot(data = dataSet, aes(x = reorder_size(top)))
      g + geom_bar(stat="count") + ylab('Number of Postings') + xlab('Drug Type') + guides(color = "colorbar") + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Typical Game Type"))
    })
  })
  
  output$mostPopularMarkets <- renderPlot({
    withProgress(message = "Rendering Most Popular Market For Selected Drugs Bar Graph", {
      # Get Data
      dataSet <- getDataSetToUse()
      dataSet = dataSet[!is.na(dataSet$Market_Name),]
      temp <- row.names(as.data.frame(summary(dataSet$Market_Name, max=8))) # create a df or something else with the summary output.
      dataSet$Market_Name <- as.character(dataSet$Market_Name)
      dataSet$top <- ifelse(
        dataSet$Market_Name %in% temp, ## condition: match aDDs$answer with row.names in summary df
        dataSet$Market_Name, ## then it should be named as aDDs$answer
        "Other" ## else it should be named "Other"
      )
      dataSet$top <- as.factor(dataSet$top)
      
      colourCount = length(unique(dataSet$Price_Per_Gram_BTC))
      getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      platteNew = getPalette(colourCount)
      g = ggplot(data = dataSet, aes(x = reorder_size(top))) #+ ggtitle(title)
      g + geom_bar(stat="count") + ylab('Number of Postings') + xlab('Market Name') + guides(color = "colorbar") + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Typical Game Type"))
    })
  })
  
  
  
  
  
  #Render Top Markets by Home Value Growth TimeSeries
  output$topMarketsTS <- renderChart({
    
    withProgress(message = "Rendering Top Market Time Series", {
      
      # Get Data
      d <- getDataSetToUse()
      
      # Set number of markets to plot.  Markets are sorted by Growth (desc)
      numMarkets <- 10
      
      # Merge current with historical data for number of markets
      d <- mergeMarketData(d, numMarkets)
      
      # Format for Plotting
      d <- subset(d, select = c(location, X2000.01:X2015.12))
      d <- t(d)
      colnames(d) <- d[1,]
      d <- d[-1,]
      timePeriod  <- seq.Date(as.Date('2000/1/1'), by = "month", length.out = 192)
      d <- data.frame("Time" = timePeriod, d)
      ts <- melt(d, id = "Time")
      names(ts) <- c("Time", "Market", "Value")
      
      #Plot Data
      p <- nPlot(Value ~ Time, group = "Market", type = "lineChart", data = ts, width = 1100, height = 600, dom = "topMarketsTS")
      p$xAxis(
        tickFormat = 
          "#!
        function(d){
        f =  d3.time.format.utc('%Y-%m-%d');
        return f(new Date( d*24*60*60*1000 ));
        }
        !#"
      )
      p$yAxis(tickFormat = "#! function(d) {return d3.format(',.0f')(d)} !#")
      return(p)
    })
  })
  
  # Render Top 10 States bar chart
  output$top10StatesBar <- renderPlot({
    withProgress(message = "Rendering Most Common Drug Listing by Count Bar Graph", {
      # Get Data
      dataSet <- xboxData
      dataSet = dataSet[!is.na(dataSet$Drug_Type),]
      dataSet = dataSet[dataSet$Price_Per_Gram_BTC <= 3000,]
      dataSet = summarise(group_by(dataSet, Sheet_Date, Drug_Type), meanPrice_Per_Gram_BTC=mean(Price_Per_Gram_BTC)/max(Price_Per_Gram_BTC))
      temp <- row.names(as.data.frame(summary(dataSet$Drug_Type, max=11))) # create a df or something else with the summary output.
      dataSet$Drug_Type <- as.character(dataSet$Drug_Type)
      dataSet$top <- ifelse(
        dataSet$Drug_Type %in% temp, ## condition: match aDDs$answer with row.names in summary df
        dataSet$Drug_Type, ## then it should be named as aDDs$answer
        "Other" ## else it should be named "Other"
      )
      dataSet$top <- as.factor(dataSet$top)
      dataSet = dataSet[as.character(dataSet$top) != "Other",]
      colourCount = length(unique(dataSet$meanPrice_Per_Gram_BTC))
      getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      platteNew = getPalette(colourCount)
      g = ggplot(data = dataSet, aes(x = Sheet_Date, y=meanPrice_Per_Gram_BTC, colour=Drug_Type))
      g + geom_line(na.rm = TRUE, size=1) + ylab('Average Price Per Gram (Normalized)') + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug Type")) 
    })
  })
  
  # Render Top 10 Cities bar chart
  output$top10CitiesBar <- renderPlot({
    withProgress(message = "Rendering Most Common Drug Listing by Count Bar Graph", {
      # Get Data
      dataSet <- xboxData
      dataSet = dataSet[!is.na(dataSet$Market_Name),]
      dataSet = dataSet[!is.na(dataSet$Price_Per_Gram_BTC),]
      dataSet = dataSet[dataSet$Price_Per_Gram_BTC <= 3000,]
      dataSet = summarise(group_by(dataSet, Sheet_Date, Market_Name), meanPrice_Per_Gram_BTC=mean(Price_Per_Gram_BTC, na.rm = TRUE)/max(Price_Per_Gram_BTC, na.rm = TRUE), lenMN = length(Price_Per_Gram_BTC))
      dataSet= dataSet[dataSet$lenMN >=3,]
      temp <- row.names(as.data.frame(summary(dataSet$Market_Name, max=5))) # create a df or something else with the summary output.
      dataSet$Market_Name <- as.character(dataSet$Market_Name)
      dataSet$top <- ifelse(
        dataSet$Market_Name %in% temp, ## condition: match aDDs$answer with row.names in summary df
        dataSet$Market_Name, ## then it should be named as aDDs$answer
        "Other" ## else it should be named "Other"
      )
      dataSet$top <- as.factor(dataSet$top)
      dataSet = dataSet[as.character(dataSet$top) != "Other",]
      colourCount = length(unique(dataSet$meanPrice_Per_Gram_BTC))
      getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      platteNew = getPalette(colourCount)
      g = ggplot(data = dataSet, aes(x = Sheet_Date, y=meanPrice_Per_Gram_BTC, colour=Market_Name))
      g + geom_line(na.rm = TRUE, size=1) + ylab('Average Price Per Gram (Normalized)') + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug Type")) + scale_y_continuous(labels = dollar_format(prefix = "$"))
    })
  })
  
  
  output$topTenDrugPriceChangeTimeSeries <- renderPlot({
    withProgress(message = "Rendering Most Common Drug Listing by Count Bar Graph", {
      # Get Data
      dataSet <- xboxData
      dataSet = dataSet[!is.na(dataSet$Drug_Type),]
      dataSet = dataSet[dataSet$Price_Per_Gram_BTC <= 3000,]
      dataSet = summarise(group_by(dataSet, Sheet_Date, Drug_Type), meanPrice_Per_Gram_BTC=mean(Price_Per_Gram_BTC)/max(Price_Per_Gram_BTC))
      temp <- row.names(as.data.frame(summary(dataSet$Drug_Type, max=7, na.rm = TRUE))) # create a df or something else with the summary output.
      dataSet$Drug_Type <- as.character(dataSet$Drug_Type)
      dataSet$top <- ifelse(
        dataSet$Drug_Type %in% temp, ## condition: match aDDs$answer with row.names in summary df
        dataSet$Drug_Type, ## then it should be named as aDDs$answer
        "Other" ## else it should be named "Other"
      )
      dataSet$top <- as.factor(dataSet$top)
      dataSet = dataSet[as.character(dataSet$top) != "Other",]
      colourCount = length(unique(dataSet$meanPrice_Per_Gram_BTC))
      getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      platteNew = getPalette(colourCount)
      g = ggplot(data = dataSet, aes(x = Sheet_Date, y=meanPrice_Per_Gram_BTC, colour=Drug_Type))
      g + geom_line(na.rm = TRUE, size=1) + ylab('Average Price Per 10 Grams (Normalized)') + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug Type")) + theme(axis.text.y=element_blank(), axis.ticks.y=element_blank())
    })
  })
  
  
  output$drugPricesVSBitcoinVSPharma <- renderPlot({
    withProgress(message = "Number of Posts in Each Darknet Market Time Series Compared to Bitcoin Prices (USD)", {
      # Get Data
      # gramMult = 28
      dataSet <- xboxData
      dataSet = dataSet[!is.na(dataSet$Drug_Type),]
      dataSet = dataSet[dataSet$Price_Per_Gram_BTC <= 3000,]
      # dataSet = dataSet[as.character(dataSet$Drug_Type) == "Marijuana",]
      dataSet = summarise(group_by(dataSet, Sheet_Date), meanPrice_Per_Gram_BTC=mean(Price_Per_Gram_BTC), meanBTC = mean(BitcoinPriceUSD))
      dataSet = dataSet[dataSet$meanPrice_Per_Gram_BTC <= 1000,]
      colourCount = length(unique(dataSet$meanPrice_Per_Gram_BTC))
      getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      platteNew = getPalette(colourCount)
      g = ggplot(data = dataSet, aes(Sheet_Date))
      g + geom_line(aes(y=meanPrice_Per_Gram_BTC), na.rm = TRUE, size=1) + geom_line(aes(y=meanBTC), na.rm = TRUE, size=1, color = "red") + ylab(paste('Average Price Per','Gram', '(Normalized)')) + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug Type")) + scale_y_continuous(labels = dollar_format(prefix = "$"))
    })
  })
  
  
  
  output$topTenDrugPriceChangeTimeSeries <- renderPlot({
    withProgress(message = "Rendering Most Common Drug Listing by Count Bar Graph", {
      # Get Data
      dataSet <- xboxData
      dataSet = dataSet[!is.na(dataSet$Drug_Type),]
      dataSet = dataSet[dataSet$Price_Per_Gram_BTC <= 3000,]
      dataSet = summarise(group_by(dataSet, Sheet_Date, Drug_Type), meanPrice_Per_Gram_BTC=mean(Price_Per_Gram_BTC)/max(Price_Per_Gram_BTC))
      temp <- row.names(as.data.frame(summary(dataSet$Drug_Type, max=7, na.rm = TRUE))) # create a df or something else with the summary output.
      dataSet$Drug_Type <- as.character(dataSet$Drug_Type)
      dataSet$top <- ifelse(
        dataSet$Drug_Type %in% temp, ## condition: match aDDs$answer with row.names in summary df
        dataSet$Drug_Type, ## then it should be named as aDDs$answer
        "Other" ## else it should be named "Other"
      )
      dataSet$top <- as.factor(dataSet$top)
      dataSet = dataSet[as.character(dataSet$top) != "Other",]
      colourCount = length(unique(dataSet$meanPrice_Per_Gram_BTC))
      getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      platteNew = getPalette(colourCount)
      g = ggplot(data = dataSet, aes(x = Sheet_Date, y=meanPrice_Per_Gram_BTC, colour=Drug_Type))
      g + geom_line(na.rm = TRUE, size=1) + ylab('Average Price Per 10 Grams (Normalized)') + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug Type")) + theme(axis.text.y=element_blank(), axis.ticks.y=element_blank())
    })
  })
  
  
  output$postsPerDayWithDrugColor <- renderPlot({
    withProgress(message = "Number of postings per day over time for each darknet", {
      # Get Data
      dataSet <- getDataSetToUse()
      dataSet = dataSet[!is.na(dataSet$Drug_Type),]
      dataSet = dataSet[dataSet$Price_Per_Gram_BTC <= 3000,]
      # dataSet = summarise(group_by(dataSet, Time_Added, Market_Name))
      colourCount = length(unique(dataSet$meanPrice_Per_Gram_BTC))
      getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      platteNew = getPalette(colourCount)
      g = ggplot(data = dataSet, aes(x = Time_Added, colour = Market_Name))
      g + geom_density(na.rm = TRUE, size=1) + ylab('Number of Posts Made') + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug Type"))
    })
  })
  
  
  
  output$numberOfDrugsAvailablePerMarket <- renderPlot({
    withProgress(message = "Number of postings per day over time for each darknet", {
      # Get Data
      dataSet <- getDataSetToUse()
      dataSet$Market_Name = as.character(dataSet$Market_Name)
      dataSet = dataSet[!is.na(dataSet$Drug_Type),]
      dataSet = summarise(group_by(dataSet, Market_Name), drugCount = length(unique(Drug_Type)))
      colourCount = length(unique(dataSet$Market_Name))
      getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      platteNew = getPalette(colourCount)
      g = ggplot(data = dataSet, aes(x = Market_Name, y = drugCount))
      g + geom_bar(stat="identity") + ylab('Number of Drugs') + xlab('Market')
    })
  })
  
  
  output$pricePerDrug <- renderPlot({
    withProgress(message = "Rendering Most Common Drug Listing by Count Bar Graph", {
      # Get Data
      dataSet <- getDataSetToUse()
      dataSet = dataSet[!is.na(dataSet$Drug_Type),]
      dataSet = dataSet[!is.na(dataSet$Price_Per_Gram_BTC),]
      dataSet = dataSet[dataSet$Price_Per_Gram_BTC <= 3000,]
      dataSet = summarise(group_by(dataSet, Sheet_Date, Drug_Type), meanPrice_Per_Gram_BTC=mean(Price_Per_Gram_BTC, na.rm = TRUE)/max(Price_Per_Gram_BTC, na.rm = TRUE), lenMN = length(Price_Per_Gram_BTC))
      dataSet= dataSet[dataSet$lenMN >=3,]
      temp <- row.names(as.data.frame(summary(dataSet$Drug_Type))) # create a df or something else with the summary output.
      dataSet$Drug_Type <- as.character(dataSet$Drug_Type)
      dataSet$top <- ifelse(
        dataSet$Drug_Type %in% temp, ## condition: match aDDs$answer with row.names in summary df
        dataSet$Drug_Type, ## then it should be named as aDDs$answer
        "Other" ## else it should be named "Other"
      )
      dataSet$top <- as.factor(dataSet$top)
      dataSet = dataSet[as.character(dataSet$top) != "Other",]
      colourCount = length(unique(dataSet$meanPrice_Per_Gram_BTC))
      getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      platteNew = getPalette(colourCount)
      g = ggplot(data = dataSet, aes(x = Sheet_Date, y=meanPrice_Per_Gram_BTC, colour=Drug_Type))
      g + geom_line(na.rm = TRUE, size=1) + ylab('Average Price Per Gram') + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug Type")) + scale_y_continuous(labels = dollar_format(prefix = "$"))
    })
  })
  output$mostActiveCountryDaily <- renderPlot({
    withProgress(message = "Rendering Most Common Drug Listing by Count Bar Graph", {
      # Get Data
      dataSet <- getDataSetToUse()
      mostPostedInCountry = names(sort(summary(as.factor(xboxData$Shipped_From), decreasing=T)))[1]
      #       dataSet = dataSet[!is.na(dataSet$Drug_Type),]
      #       dataSet = dataSet[dataSet$Price_Per_Gram_BTC <= 3000,]
      #       dataSet = summarise(group_by(dataSet, Sheet_Date, Drug_Type), meanPrice_Per_Gram_BTC=mean(Price_Per_Gram_BTC)/max(Price_Per_Gram_BTC))
      #       temp <- row.names(as.data.frame(summary(dataSet$Drug_Type, max=7, na.rm = TRUE))) # create a df or something else with the summary output.
      #       dataSet$Drug_Type <- as.character(dataSet$Drug_Type)
      #       dataSet$top <- ifelse(
      #         dataSet$Drug_Type %in% temp, ## condition: match aDDs$answer with row.names in summary df
      #         dataSet$Drug_Type, ## then it should be named as aDDs$answer
      #         "Other" ## else it should be named "Other"
      #       )
      #       mostPostedInCountry = names(sort(summary(as.factor(xboxData$Shipped_From), decreasing=T)))[1]
      #       dataSet$top <- as.factor(dataSet$top)
      #       dataSet = dataSet[as.character(dataSet$top) != "Other",]
      #       colourCount = length(unique(dataSet$meanPrice_Per_Gram_BTC))
      #       getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      #       platteNew = getPalette(colourCount)
      # g = ggplot(data = dataSet, aes(x = Sheet_Date, y=meanPrice_Per_Gram_BTC, colour=Drug_Type))
      # g + geom_line(na.rm = TRUE, size=1) + ylab('Average Price Per 10 Grams (Normalized)') + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug Type")) + theme(axis.text.y=element_blank(), axis.ticks.y=element_blank())
    })
  })
  output$drugPrices <- renderPlot({
    withProgress(message = "Rendering Most Common Drug Listing by Count Bar Graph", {
      # Get Data
      dataSet <- getDataSetToUse()
      dataSet = dataSet[!is.na(dataSet$Market_Name),]
      dataSet = dataSet[!is.na(dataSet$Price_Per_Gram_BTC),]
      dataSet = dataSet[dataSet$Price_Per_Gram_BTC <= 3000,]
      dataSet = summarise(group_by(dataSet, Sheet_Date, Market_Name), meanPrice_Per_Gram_BTC=mean(Price_Per_Gram_BTC, na.rm = TRUE)/max(Price_Per_Gram_BTC, na.rm = TRUE), lenMN = length(Price_Per_Gram_BTC))
      dataSet= dataSet[dataSet$lenMN >=3,]
      temp <- row.names(as.data.frame(summary(dataSet$Market_Name))) # create a df or something else with the summary output.
      dataSet$Market_Name <- as.character(dataSet$Market_Name)
      dataSet$top <- ifelse(
        dataSet$Market_Name %in% temp, ## condition: match aDDs$answer with row.names in summary df
        dataSet$Market_Name, ## then it should be named as aDDs$answer
        "Other" ## else it should be named "Other"
      )
      dataSet$top <- as.factor(dataSet$top)
      dataSet = dataSet[as.character(dataSet$top) != "Other",]
      colourCount = length(unique(dataSet$meanPrice_Per_Gram_BTC))
      getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      platteNew = getPalette(colourCount)
      g = ggplot(data = dataSet, aes(x = Sheet_Date, y=meanPrice_Per_Gram_BTC, colour=Market_Name))
      g + geom_line(na.rm = TRUE, size=1) + ylab('Average Price Per Gram') + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug Type")) + scale_y_continuous(labels = dollar_format(prefix = "$"))
    })
  })
  output$pricesComparedToBicoinPrice <- renderPlot({
    withProgress(message = "Average prices of drugs against price of bitcoins", {
      # Get Data
      dataSet <- getDataSetToUse()
      dataSet = dataSet[!is.na(dataSet$Drug_Type),]
      dataSet = dataSet[dataSet$Price_Per_Gram_BTC <= 3000,]
      dataSet = summarise(group_by(dataSet, Sheet_Date, Drug_Type), meanPrice_Per_Gram_BTC=mean(Price_Per_Gram_BTC)/max(Price_Per_Gram_BTC), meanBTC = mean(BitcoinPriceUSD, na.rm = TRUE))
      temp <- row.names(as.data.frame(summary(dataSet$Drug_Type, max=7, na.rm = TRUE))) # create a df or something else with the summary output.
      dataSet$Drug_Type <- as.character(dataSet$Drug_Type)
      dataSet$top <- ifelse(
        dataSet$Drug_Type %in% temp, ## condition: match aDDs$answer with row.names in summary df
        dataSet$Drug_Type, ## then it should be named as aDDs$answer
        "Other" ## else it should be named "Other"
      )
      dataSet$top <- as.factor(dataSet$top)
      dataSet = dataSet[as.character(dataSet$top) != "Other",]
      colourCount = length(unique(dataSet$meanPrice_Per_Gram_BTC))
      getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      platteNew = getPalette(colourCount)
      g = ggplot(data = dataSet, aes(x = Sheet_Date, y=meanPrice_Per_Gram_BTC, colour=Drug_Type))
      g + geom_line(na.rm = TRUE, size=1) + geom_line(aes(y=meanBTC), size = 3, color="red") + ylab("Average prices of drugs against price of bitcoins") + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug Type"))
    })
  })
  output$postsComparedToBicoinPrice <- renderPlot({
    withProgress(message = "Number of posts compared to bitcoin price (colored by country)", {
      dataSet <- getDataSetToUse()
      dataSet = dataSet[!is.na(dataSet$Shipped_From),]
      dataSet = dataSet[dataSet$Price_Per_Gram_BTC <= 3000,]
      dataSet$Time_Added = as.character(dataSet$Time_Added)
      dataSet = summarise(group_by(dataSet, Time_Added), counter = count(Shipped_From, na.rm = TRUE))
      colourCount = length(unique(dataSet$Shipped_From))
      getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      platteNew = getPalette(colourCount)
      g = ggplot(data = dataSet, aes(x = Time_Added, y=count(Shipped_From), colour=Shipped_From))
      g + geom_line(na.rm = TRUE, size=1) + geom_line(aes(y=BitcoinPriceUSD), size = 3, color="red") + ylab("Number of Posts") + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Shipping Location")) 
    })
  })
  
  output$drugPricesVSBitcoinVSPharmaMarketExplorer <- renderPlot({
    withProgress(message = "Number of Posts in Each Darknet Market Time Series Compared to Bitcoin Prices (USD)", {
      # Get Data
      dataSet <- getDataSetToUse()
      dataSet = dataSet[!is.na(dataSet$Drug_Type),]
      dataSet = dataSet[dataSet$Price_Per_Gram_BTC <= 3000,]
      # dataSet = dataSet[as.character(dataSet$Drug_Type) == "Marijuana",]
      dataSet = summarise(group_by(dataSet, Sheet_Date), meanPrice_Per_Gram_BTC=mean(Price_Per_Gram_BTC), meanBTC = mean(BitcoinPriceUSD))
      
      colourCount = length(unique(dataSet$meanPrice_Per_Gram_BTC))
      getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      platteNew = getPalette(colourCount)
      g = ggplot(data = dataSet, aes(Sheet_Date))
      g + geom_line(aes(y=meanPrice_Per_Gram_BTC), na.rm = TRUE, size=1) + geom_line(aes(y=meanBTC), na.rm = TRUE, size=1, color = "red") + ylab(paste('Average Price Per','Gram (Normalized)')) + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug Type")) + scale_y_continuous(labels = dollar_format(prefix = "$"))
    })
  })
  
  ######################
  #Data sets
  ######################
  
  # Return the requested dataset
  getDataSetToUse <- eventReactive(input$query, {
    dataToDisplay = xboxData
    if (!is.null(input$marketName)) {
      dataToDisplay = dataToDisplay[which((dataToDisplay$Market_Name%in%input$marketName)),]
    }
    
    if (!is.null(input$drugName)) {
      dataToDisplay = dataToDisplay[which((dataToDisplay$Drug_Type%in%input$drugName)),]
    }
    if (!is.null(input$shippedFrom)) {
      dataToDisplay = dataToDisplay[which((dataToDisplay$Shipped_From%in%input$shippedFrom)),]
    }
    # switch(input$weightUnits)
    if (!is.null(input$weightUnits)) {
      drugUnitMutiplier = c(1000,1e+6,1,0.001,NA,0.035274,0.0022046249999752, 0.00000110231131)
      names(drugUnitMutiplier) = c("milligrams","ug","grams","kilograms","ml","ounces","pounds","tons")
      dataToDisplay$Price_Per_Gram_BTC = dataToDisplay$Price_Per_Gram_BTC*drugUnitMutiplier[input$weightUnits]
    }
    if (!is.null(input$weightValue)) {
      dataToDisplay$Price_Per_Gram_BTC = dataToDisplay$Price_Per_Gram_BTC*as.numeric(input$weightValue)
    }
    # dataToDisplay = dataToDisplay[is.finite(dataToDisplay$Price_Per_Gram_BTC),]
    if (!is.null(input$pricePerWeight)) {
      dataToDisplay = dataToDisplay[dataToDisplay$Price_Per_Gram_BTC >= input$pricePerWeight[1] & dataToDisplay$Price_Per_Gram_BTC <= input$pricePerWeight[2],]
    }
    if (!is.null(input$dataAccessedDate)) {
      dataToDisplay = dataToDisplay[dataToDisplay$Sheet_Date >= input$dataAccessedDate[1] & dataToDisplay$Sheet_Date <= input$dataAccessedDate[2],]
    }
    if (!is.null(input$dataPostedDate)) {
      dataToDisplay = dataToDisplay[dataToDisplay$Time_Added >= input$dataPostedDate[1] & dataToDisplay$Time_Added <= input$dataPostedDate[2],]
    }
    dataToDisplay = dataToDisplay[!is.na(dataToDisplay$Market_Name),]
    return(dataToDisplay)
  }, ignoreNULL = FALSE)
  
  
  output$dataTableViewOfDrugs <- DT::renderDataTable({
    dataSet = getDataSetToUse()
    dataSet$Shipped_From = str_title_case(dataSet$Shipped_From)
    dataSet$Drug_Type = str_title_case(dataSet$Drug_Type)
    dataSet$Market_Name = str_title_case(dataSet$Market_Name)
    DT::datatable(dataSet, options = list(autoWidth = TRUE, orderClasses = TRUE, lengthMenu = c(5, 10, 30, 50), pageLength = 10))
  })
  
  getDataPresentable = function(){
    dataToPresent = xboxData
    dataToPresent = dataToPresent[dataToPresent$gameName != "TRUE",]
    # dataToPresent$percentProb[dataToPresent$isBCCompatible == TRUE] = 100
    dataToPresent$bcGuess = as.logical(dataToPresent$bcGuess)
    # dataToPresent[dataToPresent == TRUE] = TRUE
    # dataToPresent[dataToPresent == FALSE] = FALSE
    return(dataToPresent)
  }
  
  output$List_BackwardsCompatibleGames <- DT::renderDataTable(
    DT::datatable(
      {
        dataToPresent = getDataPresentable()
        dataToPresent = dataToPresent[dataToPresent$isBCCompatible == TRUE,]
        dataToPresent = dplyr::select(dataToPresent, Name = gameName, "Available for Digital Download" = isAvailableToPurchaseDigitally, 
                               "On Microsoft's Site" = isListedOnMSSite, "Kinect Supported" = isKinectSupported,
                               "Kinect Required" = isKinectRequired, "Exclusive" = isExclusive, "Is Console Exclusive" = isConsoleExclusive, "Metacritic Rating" = reviewScorePro, 
                               "Metacritic User Rating" = reviewScoreUser, "Xbox User Rating" = xbox360Rating, 'Price' = price, 'Game Addons' = DLgameAddons, "Genre" = genre,
                               'Publisher'= publisher, 'Developer' = developer, "Xbox One Version Available" = isOnXboxOne)
        dataToPresent
      }, selection = "none",
  options = list(
        lengthMenu = list(c(15, 30, -1), c('15', '30', 'All')),
        pageLength = 15
      )
    )
  )
  
  output$List_AllGames <- DT::renderDataTable(
    DT::datatable(
      {
        dataToPresent = getDataPresentable()
        dataToPresent = dplyr::select(dataToPresent, Name = gameName, 'Predicted Backwards Compatible' = bcGuess, "Percent Probability" = percentProb, "Uservoice Votes" = as.numeric(votes), "Available for Digital Download" = isAvailableToPurchaseDigitally, 
                               "On Microsoft's Site" = isListedOnMSSite, "Kinect Supported" = isKinectSupported,
                               "Kinect Required" = isKinectRequired, "Exclusive" = isExclusive, "Is Console Exclusive" = isConsoleExclusive, "Metacritic Rating" = reviewScorePro, 
                               "Metacritic User Rating" = reviewScoreUser, "Xbox User Rating" = xbox360Rating, 'Price' = price, 'Game Addons' = DLgameAddons, "Genre" = genre,
                               'Publisher'= publisher, 'Developer' = developer, "Xbox One Version Available" = isOnXboxOne)
        dataToPresent
      }, selection = "none",
      options = list(
        lengthMenu = list(c(15, 30, -1), c('15', '30', 'All')),
        pageLength = 15
      )
    )
  )
  
  output$List_PredictedBackwardsCompatible <- DT::renderDataTable(
    DT::datatable(
      {
        dataToPresent = getDataPresentable()
        dataToPresent = dataToPresent[dataToPresent$bcGuess == TRUE & dataToPresent$isBCCompatible == FALSE,]
        dataToPresent = dplyr::select(dataToPresent, Name = gameName, "Percent Probability" = percentProb, "Uservoice Votes" = as.numeric(votes), "Available for Digital Download" = isAvailableToPurchaseDigitally, 
                               "On Microsoft's Site" = isListedOnMSSite, "Kinect Supported" = isKinectSupported,
                               "Kinect Required" = isKinectRequired, "Exclusive" = isExclusive, "Is Console Exclusive" = isConsoleExclusive, "Metacritic Rating" = reviewScorePro, 
                               "Metacritic User Rating" = reviewScoreUser, "Xbox User Rating" = xbox360Rating, 'Price' = as.numeric(price), 'Game Addons' = DLgameAddons, "Genre" = genre,
                               'Publisher'= publisher, 'Developer' = developer, "Xbox One Version Available" = isOnXboxOne)
      dataToPresent
        }, selection = "none",
      options = list(
        lengthMenu = list(c(15, 30, -1), c('15', '30', 'All')),
        pageLength = 15
      )
    )
  )
  
  # # you can also use paging = FALSE to disable pagination
  # output$ex3 <- DT::renderDataTable(
  #   DT::datatable(iris, options = list(paging = FALSE))
  # )
  
  output$List_KinectGames <- DT::renderDataTable(
    DT::datatable(
      {
        dataToPresent = getDataPresentable()
        dataToPresent = dataToPresent[dataToPresent$isKinectSupported == TRUE | dataToPresent$isKinectRequired == TRUE,]
        dataToPresent = dplyr::select(dataToPresent, Name = gameName, "Kinect Required" = isKinectRequired, "Percent Probability" = percentProb, "Uservoice Votes" = votes, 
                               "Available for Digital Download" = isAvailableToPurchaseDigitally, "On Microsoft's Site" = isListedOnMSSite, 
                               "Exclusive" = isExclusive, "Is Console Exclusive" = isConsoleExclusive, "Metacritic Rating" = reviewScorePro, 
                               "Metacritic User Rating" = reviewScoreUser, "Xbox User Rating" = xbox360Rating, 'Price' = price, 'Game Addons' = DLgameAddons, "Genre" = genre,
                               'Publisher'= publisher, 'Developer' = developer, "Xbox One Version Available" = isOnXboxOne)
        dataToPresent
      }, selection = "none",
      options = list(
        lengthMenu = list(c(15, 30, -1), c('15', '30', 'All')),
        pageLength = 15
      )
    )
  )
  
  output$List_HasXboxOneVersion <- DT::renderDataTable(
    DT::datatable(
      {
        dataToPresent = getDataPresentable()
        dataToPresent = dataToPresent[dataToPresent$isOnXboxOne == TRUE | dataToPresent$isKinectRequired == TRUE,]
        dataToPresent = dplyr::select(dataToPresent, Name = gameName, "Uservoice Votes" = votes, "Available for Digital Download" = isAvailableToPurchaseDigitally, 
                               "On Microsoft's Site" = isListedOnMSSite, "Kinect Supported" = isKinectSupported,
                               "Kinect Required" = isKinectRequired, "Exclusive" = isExclusive, "Is Console Exclusive" = isConsoleExclusive, "Metacritic Rating" = reviewScorePro, 
                               "Metacritic User Rating" = reviewScoreUser, "Xbox User Rating" = xbox360Rating, 'Price' = price, 'Game Addons' = DLgameAddons, "Genre" = genre,
                               'Publisher'= publisher, 'Developer' = developer)
        dataToPresent
      }, selection = "none",
      options = list(
        lengthMenu = list(c(15, 30, -1), c('15', '30', 'All')),
        pageLength = 15
      )
    )
  )
  output$List_Exclusives <- DT::renderDataTable(
    DT::datatable(
      {
        dataToPresent = getDataPresentable()        
        dataToPresent = dataToPresent[dataToPresent$isExclusive == TRUE,]
        dataToPresent = dplyr::select(dataToPresent, Name = gameName, "Is Console Exclusive" = isConsoleExclusive, "Uservoice Votes" = votes, "Available for Digital Download" = isAvailableToPurchaseDigitally, 
                               "On Microsoft's Site" = isListedOnMSSite, "Kinect Supported" = isKinectSupported,
                               "Kinect Required" = isKinectRequired, "Metacritic Rating" = reviewScorePro, 
                               "Metacritic User Rating" = reviewScoreUser, "Xbox User Rating" = xbox360Rating, 'Price' = price, 'Game Addons' = DLgameAddons, "Genre" = genre,
                               'Publisher'= publisher, 'Developer' = developer, "Xbox One Version Available" = isOnXboxOne)
        dataToPresent
      }, selection = "none",
      height = NULL,
      options = list(
        lengthMenu = list(c(15, 30, -1), c('15', '30', 'All')),
        pageLength = 15
      )
    )
  )
  
  
  output$PublisherTop <- shiny::renderTable(
    head(getDataPresentable(), n = input$obs)
  )


  output$PublisherBottom <- shiny::renderTable(
    head({
      dataToPresent = getDataPresentable()
      dataToPresent = summarise(group_by(dataToPresent, publisher), gamesMadeBackwardsCompatible = length(isBCCompatible[isBCCompatible==TRUE]), gamesPublished = length(gameName), ratio = gamesMadeBackwardsCompatible/gamesPublished)
      dataToPresent = arrange(dataToPresent, desc(ratio))
      dataToPresent
      }, 
      n = 20)
    # DT::datatable(
    #   {
        # dataToPresent = getDataPresentable()
    #     dataToPresent = dataToPresent[dataToPresent$isExclusive == TRUE,]
    #     dataToPresent = select(dataToPresent, Name = gameName, "Is Console Exclusive" = isConsoleExclusive, "Uservoice Votes" = votes, "Available for Digital Download" = isAvailableToPurchaseDigitally,
    #                            "On Microsoft's Site" = isListedOnMSSite, "Kinect Supported" = isKinectSupported,
    #                            "Kinect Required" = isKinectRequired, "Metacritic Rating" = reviewScorePro,
    #                            "Metacritic User Rating" = reviewScoreUser, "Xbox User Rating" = xbox360Rating, 'Price' = price, 'Game Addons' = DLgameAddons, "Genre" = genre,
    #                            'Publisher'= publisher, 'Developer' = developer, "Xbox One Version Available" = isOnXboxOne)
    #     dataToPresent
    #   }, selection = "none",
    #   options = list(
    #     lengthMenu = list(c(15, 30, -1), c('15', '30', 'All')),
    #     pageLength = 15
    #   )
    # )
  )
  
  output$Explanation <- renderUI({
    # shiny::includeMarkdown(rmarkdown::render("../Explanation.Rmd"))
    shiny::includeMarkdown(rmarkdown::render("../Explanation.Rmd"))
  })
})