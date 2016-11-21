# Darknet Market Analyzer
# Darknet Market Analysis
# Nick Talavera
# Date: October 25, 2016

# server.R

#===============================================================================
#                               GENERAL FUNCTIONS                              #
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

#===============================================================================
#                                  SHINY SERVER                                #
#===============================================================================
shinyServer(function(input, output, session) {
  #=============================================================================
  #                               DASHBOARD BOXES                              #
  #=============================================================================
  output$usViBox <- renderValueBox({
    valueBox(
      paste0(nrow(dnmData)), paste("Drug Postings"), 
      icon = icon("bar-chart"), color = "red"
    )
  })
  
  output$XThanAveragePricesForXAtXBox <- renderValueBox({
    dataSet = dplyr::select(dnmData,Market_Name,Drug_Type,Price_Per_Gram_BTC)
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
  
  output$averagePricePerOunceForXInXonXBox <- renderValueBox({
    price = 0
    dataSet = dplyr::select(dnmData,Sheet_Date,Shipped_From,Market_Name,Drug_Type,Price_Per_Gram_BTC)
    dataSetTemp = summarise(group_by(dataSet, Drug_Type), mnCount= length(unique(Market_Name)))
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
      paste0(str_Currency(price)), paste("Average Price Per Ounce For", drugRandom, "In", str_title_case(countryRandom), "on", dateRandom), icon = icon("dollar"), color = "green"
    )
  })
  
  output$DayOfTheMostXPostsOnXBox <- renderValueBox({
    price = 0
    dataSet = dplyr::select(dnmData,Sheet_Date,Shipped_From,Market_Name,Drug_Type,Price_Per_Gram_BTC)
    dataSetTemp = summarise(group_by(dataSet, Drug_Type), mnCount= length(unique(Market_Name)))
    dataSetTemp = filter(dataSetTemp, mnCount >=2)
    drugRandom = sample(unique(dataSetTemp$Drug_Type),1)
    dataSet = dataSet[dataSet$Drug_Type == drugRandom,]
    marketRandom = sample(unique(dataSet$Market_Name[!is.na(dataSet$Market_Name)]),1)
    dataSet = dataSet[dataSet$Market_Name == marketRandom,]
    mostPostedDay = names(sort(summary(as.factor(dnmData$Time_Added[dnmData$Market_Name == marketRandom])), decreasing=T))
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
  
  output$MostActiveCountryBox <- renderValueBox({
    dataSet = dplyr::select(dnmData,Shipped_From)
    mostPostedInCountry = names(sort(summary(as.factor(dnmData$Shipped_From), decreasing=T)))[1]
    valueBox(
      paste0(str_title_case(mostPostedInCountry)), paste("Most Active Country"), 
      icon = icon("map-marker"), color = "green"
    )
  })
  
  output$mostPostedDruginXCountryBox <- renderValueBox({
    dataSet = dplyr::select(dnmData,Drug_Type,Shipped_From)
    countryRandom = sample(unique(dnmData$Shipped_From[!is.na(dataSet$Shipped_From) & dnmData$Shipped_From != "unknown"]),1)
    mostPostedDrug = names(sort(summary(as.factor(dnmData$Drug_Type[dnmData$Shipped_From == countryRandom])), decreasing=T))
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
  
  output$bitcoinHighLowBox <- renderValueBox({
    dataSet = dplyr::select(dnmData,BitcoinPriceUSD)
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
  
  output$mostPopularMarketForDrugXBox <- renderValueBox({
    dataSet = summarise(group_by(dnmData, Drug_Type, Market_Name), mnPrice = mean(Price_Per_Gram_BTC))
    drugRandom = sample(unique(dataSet$Drug_Type),1)
    dataSet = filter(dataSet, Drug_Type == drugRandom)
    dataSet = arrange(dataSet, desc(mnPrice))
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
      dataSet <- getDataSetFromSearch()
      dataSet = dataSet[!is.na(dataSet$Drug_Type),]
      if (length(dataSet$Drug_Type) <= 10) {
        topValues = length(dataSet$Drug_Type)
      } else {
        topValues = 6
      }
      temp <- row.names(as.data.frame(summary(dataSet$Drug_Type, max=topValues))) # create a df or something else with the summary output.
      print(temp)
      dataSet$Drug_Type <- as.character(dataSet$Drug_Type)
      dataSet$top <- ifelse(
        dataSet$Drug_Type %in% temp, ## condition: match aDDs$answer with row.names in summary df
        dataSet$Drug_Type, ## then it should be named as aDDs$answer
        "Other" ## else it should be named "Other"
      )
      dataSet$top <- as.factor(dataSet$top)
      dataSet = dataSet[dataSet$top != "Other",]
      colourCount = length(unique(dataSet$top))
      getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      platteNew = getPalette(colourCount)
      g = ggplot(data = dataSet, aes(x = reorder_size(top), fill=reorder_size(top)))
      g + geom_bar(stat="count") + ylab('Number of Postings') + xlab('Drug') + guides(color = "colorbar") + scale_fill_manual(values = platteNew) + theme(legend.position="none")
      
    })
  })
  
  output$mostPopularMarkets <- renderPlot({
    withProgress(message = "Rendering Active For Selected Drugs Bar Graph", {
      # Get Data
      choice = "Market_Name"
      if (input$radialMostActive == "Most Active Market") {
        choice = "Market_Name"
        xlabel ="Market Name"
      } else {
        choice = "Shipped_From"
        xlabel ="Country Shipped From"
      }
      dataSet <- getDataSetFromSearch()
      dataSet = dataSet[!is.na(dataSet[,choice]),]
      if (length(dataSet[,choice]) <= 10) {
        topValues = length(dataSet[,choice])
      } else {
        topValues = 6
      }
      temp <- row.names(as.data.frame(summary(dataSet[,choice], max=topValues))) # create a df or something else with the summary output.
      print(temp)
      dataSet[,choice] <- as.character(dataSet[,choice])
      dataSet$top <- ifelse(
        dataSet[,choice] %in% temp, ## condition: match aDDs$answer with row.names in summary df
        dataSet[,choice], ## then it should be named as aDDs$answer
        "Other" ## else it should be named "Other"
      )
      dataSet$top <- as.factor(dataSet$top)
      dataSet = dataSet[dataSet$top != "Other",]
      colourCount = length(unique(dataSet$top))
      getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      platteNew = getPalette(colourCount)
      g = ggplot(data = dataSet, aes(x = reorder_size(top), fill = reorder_size(top))) #+ ggtitle(title)
      g = g + geom_bar(stat="count") + ylab('Number of Postings') + xlab(xlabel) + guides(color = "colorbar") + scale_fill_manual(values = platteNew) + theme(legend.position="none")
      if (colourCount >= 10) {
        g = g + theme(legend.position="bottom")
      }
      g
    })
  }, bg="transparent")
  
  output$mostCommonCountryAndMarketForEachDrug <- DT::renderDataTable({
    dataSet <- getDataSetFromSearch()
    dataSet = summarise(group_by(dataSet,Drug_Type), "Country" = names(which.max(table(Shipped_From))), "Market" = names(which.max(table(Market_Name))))
    DT::datatable(dataSet, 
                  options = list(autoWidth = TRUE, orderClasses = TRUE, lengthMenu = c(5, 10, 30, 50), pageLength = 5, 
                                 scrollY = TRUE, scrollX = TRUE), selection = "none", style = "bootstrap")
  }
  )
  
  #=============================================================================
  #                        DASHBOARD SERVER FUNCTIONS                          #
  #=============================================================================
  
  output$topMarketsTS <- renderChart({
    
    withProgress(message = "Rendering Top Market Time Series", {
      
      # Get Data
      d <- getDataSetFromSearch()
      
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
  
  output$top10StatesBar <- renderPlot({
    withProgress(message = "Rendering Most Common Drug Listing by Count Bar Graph", {
      dataSet <- dnmData
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
      g + geom_line(na.rm = TRUE, size=1) + ylab('Average Price Per Gram (Normalized)') + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug")) 
    })
  })
  
  output$top10CitiesBar <- renderPlot({
    withProgress(message = "Rendering Most Common Drug Listing by Count Bar Graph", {
      dataSet <- dnmData
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
      g + geom_line(na.rm = TRUE, size=1) + ylab('Average Price Per Gram (Normalized)') + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug")) + scale_y_continuous(labels = dollar_format(prefix = "$"))
    })
  })
  
  
  output$topTenDrugPriceChangeTimeSeries <- renderPlot({
    withProgress(message = "Rendering Most Common Drug Listing by Count Bar Graph", {
      # Get Data
      dataSet <- dnmData
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
      g + geom_line(na.rm = TRUE, size=1) + ylab('Average Price Per 10 Grams (Normalized)') + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug")) + theme(axis.text.y=element_blank(), axis.ticks.y=element_blank())
    })
  })
  
  
  output$drugPricesVSBitcoinVSPharma <- renderPlot({
    withProgress(message = "Number of Posts in Each Darknet Market Time Series Compared to Bitcoin Prices (USD)", {
      dataSet <- dnmData
      dataSet = dataSet[!is.na(dataSet$Drug_Type),]
      dataSet = dataSet[dataSet$Price_Per_Gram_BTC <= 3000,]
      dataSet = summarise(group_by(dataSet, Sheet_Date), meanPrice_Per_Gram_BTC=mean(Price_Per_Gram_BTC), meanBTC = mean(BitcoinPriceUSD))
      dataSet = dataSet[dataSet$meanPrice_Per_Gram_BTC <= 1000,]
      colourCount = length(unique(dataSet$meanPrice_Per_Gram_BTC))
      getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      platteNew = getPalette(colourCount)
      g = ggplot(data = dataSet, aes(Sheet_Date))
      g + geom_line(aes(y=meanPrice_Per_Gram_BTC), na.rm = TRUE, size=1) + geom_line(aes(y=meanBTC), na.rm = TRUE, size=1, color = "red") + ylab(paste('Average Price Per','Gram', '(Normalized)')) + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug")) + scale_y_continuous(labels = dollar_format(prefix = "$"))
    })
  })
  
  output$mymap <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("Stamen.TonerLite",
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addMarkers(data = points())
  })
  
  output$topTenDrugPriceChangeTimeSeries <- renderPlot({
    withProgress(message = "Rendering Most Common Drug Listing by Count Bar Graph", {
      # Get Data
      dataSet <- dnmData
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
      g + geom_line(na.rm = TRUE, size=1) + ylab('Average Price Per 10 Grams (Normalized)') + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug")) + theme(axis.text.y=element_blank(), axis.ticks.y=element_blank())
    })
  })
  
  
  output$postsPerDayWithDrugColor <- renderPlot({
    withProgress(message = "Number of postings per day over time for each darknet", {
      # Get Data
      dataSet <- getDataSetFromSearch()
      dataSet = dataSet[!is.na(dataSet$Drug_Type),]
      dataSet = dataSet[dataSet$Price_Per_Gram_BTC <= 3000,]
      # dataSet = summarise(group_by(dataSet, Time_Added, Market_Name))
      colourCount = length(unique(dataSet$meanPrice_Per_Gram_BTC))
      getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      platteNew = getPalette(colourCount)
      g = ggplot(data = dataSet, aes(x = Time_Added, colour = Market_Name))
      g = g + geom_density(na.rm = TRUE, size=1) + ylab('Number of Posts Made') + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug")) 
      if (colourCount >= 10) {
        g = g + theme(legend.position="bottom")
      }
      g
    })
  })
  
  
  rquery.wordcloud <- function(x, type=c("text", "url", "file"), 
                               lang="english", excludeWords=NULL, 
                               textStemming=FALSE,  colorPalette="Dark2",
                               min.freq=3, max.words=200)
  { 
    
    if(type[1]=="file") text <- readLines(x)
    else if(type[1]=="url") text <- html_to_text(x)
    else if(type[1]=="text") text <- x
    # Load the text as a corpus
    docs <- Corpus(VectorSource(text))
    # Convert the text to lower case
    docs <- tm_map(docs, content_transformer(tolower))
    # Remove numbers
    docs <- tm_map(docs, removeNumbers)
    # Remove stopwords for the language 
    docs <- tm_map(docs, removeWords, stopwords(lang))
    # Remove punctuations
    docs <- tm_map(docs, removePunctuation)
    # Eliminate extra white spaces
    docs <- tm_map(docs, stripWhitespace)
    # Remove your own stopwords
    if(!is.null(excludeWords)) 
      docs <- tm_map(docs, removeWords, excludeWords) 
    # Text stemming
    if(textStemming) docs <- tm_map(docs, stemDocument)
    # Create term-document matrix
    tdm <- TermDocumentMatrix(docs)
    m <- as.matrix(tdm)
    v <- sort(rowSums(m),decreasing=TRUE)
    d <- data.frame(word = names(v),freq=v)
    # check the color palette name 
    if(!colorPalette %in% rownames(brewer.pal.info)) colors = colorPalette
    else colors = brewer.pal(8, colorPalette) 
    # Plot the word cloud
    set.seed(1234)
    par(bg= "transparent")
    wordcloud(d$word,d$freq, min.freq=min.freq, max.words=max.words,
              random.order=FALSE, rot.per=0.35, 
              use.r.layout=FALSE, colors=colors)
    
    invisible(list(tdm=tdm, freqTable = d))
  }
  wordcloud_rep <- repeatable(wordcloud)
  output$wordCloud <- renderPlot({
    isolate({
      withProgress({
        setProgress(message = "Processing word cloud...")
        dataWords = read.csv(paste0(dataLocale,"DNMdataDescriptionsOnly.csv"))
        dataWords$X = NULL
        repeatable(rquery.wordcloud(dataWords, type= "text", min.freq = 50, max.words= 60, 
                                    excludeWords = c("get","will","can","like","one","say","items","see","read","src","non",
                                                     "com",'links',"www","http","note","case","theres","good","listing",
                                                     "via","yet","full","usd","may","user","even","watches","watch","little","additional",
                                                     "around","just",
                                                     "item","don","much","many","way","first","also","per","sphotobuckcom","back")))
      })
    })
  })
  
  output$numberOfDrugsAvailablePerMarket <- renderPlot({
    withProgress(message = "Rendering Number of Drugs Available Per Market", {
      # Get Data
      choice = "Market_Name"
      if (input$numberOfDrugsRadial == "Per Market") {
        choice = "Market_Name"
        xlabel = "Market Name"
      } else {
        choice = "Shipped_From"
        xlabel = "Country Shipped From"
      }
      dataSet <- getDataSetFromSearch()
      dataSet[,choice] = as.character(dataSet[,choice])
      dataSet = dataSet[!is.na(dataSet$Drug_Type),]
      dataSet = summarise(group_by_(dataSet, choice), drugCount = length(unique(Drug_Type)))
      colourCount = nrow(unique(dataSet[,choice]))
      getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      platteNew = getPalette(colourCount)
      g = ggplot(data = dataSet, aes_string(x = choice, y = "drugCount", fill = choice))
      g = g + geom_bar(stat="identity") + ylab('Number of Drugs') + xlab(xlabel) + scale_fill_manual(values = platteNew, guide = guide_legend(title = xlabel))
      if (colourCount >= 10) {
        g = g + theme(legend.position="bottom") +
          theme(axis.title.x=element_blank(),
                axis.text.x=element_blank(),
                axis.ticks.x=element_blank())
      } else {
        g = g + theme(legend.position="none")
      }
      g
    })
  })
  
  output$pricePerDrug <- renderPlot({
    withProgress(message = "Rendering Most Common Drug Listing by Count Bar Graph", {
      # Get Data
      dataSet <- getDataSetFromSearch()
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
      LegendTitle = 'Drug'
      g = ggplot(data = dataSet, aes(x = Sheet_Date, y=meanPrice_Per_Gram_BTC, colour=Drug_Type))
      g= g + geom_line(na.rm = TRUE, size=1) + ylab('Average Price Per Gram') + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = LegendTitle)) + scale_y_continuous(labels = dollar_format(prefix = "$"))
      if (colourCount >= 10) {
        g = g + theme(legend.position="bottom")
      }
      g
    })
  })
  output$mostActiveCountryDaily <- renderPlot({
    withProgress(message = "Rendering Most Active Country Daily", {
      # Get Data
      dataSet <- getDataSetFromSearch()
      mostPostedInCountry = names(sort(summary(as.factor(dnmData$Shipped_From), decreasing=T)))[1]
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
      #       mostPostedInCountry = names(sort(summary(as.factor(dnmData$Shipped_From), decreasing=T)))[1]
      #       dataSet$top <- as.factor(dataSet$top)
      #       dataSet = dataSet[as.character(dataSet$top) != "Other",]
      #       colourCount = length(unique(dataSet$meanPrice_Per_Gram_BTC))
      #       getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      #       platteNew = getPalette(colourCount)
      # g = ggplot(data = dataSet, aes(x = Sheet_Date, y=meanPrice_Per_Gram_BTC, colour=Drug_Type))
      # g + geom_line(na.rm = TRUE, size=1) + ylab('Average Price Per 10 Grams (Normalized)') + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug")) + theme(axis.text.y=element_blank(), axis.ticks.y=element_blank())
    })
  })
  output$drugPrices <- renderPlot({
    withProgress(message = "Rendering Drug Price Line Graph", {
      # Get Data
      dataSet <- getDataSetFromSearch()
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
      g + geom_line(na.rm = TRUE, size=1) + ylab('Average Price Per Gram') + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug")) + scale_y_continuous(labels = dollar_format(prefix = "$"))
    })
  })
  output$pricesComparedToBicoinPrice <- renderPlot({
    withProgress(message = "Average prices of drugs against price of bitcoins", {
      # Get Data
      dataSet <- getDataSetFromSearch()
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
      g + geom_line(na.rm = TRUE, size=1) + geom_line(aes(y=meanBTC), size = 3, color="red") + ylab("Average prices of drugs against price of bitcoins") + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug"))
    })
  })
  output$postsComparedToBicoinPrice <- renderPlot({
    withProgress(message = "Number of posts compared to bitcoin price (colored by country)", {
      dataSet <- getDataSetFromSearch()
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
      dataSet <- getDataSetFromSearch()
      dataSet = dataSet[!is.na(dataSet$Drug_Type),]
      dataSet = dataSet[dataSet$Price_Per_Gram_BTC <= 3000,]
      # dataSet = dataSet[as.character(dataSet$Drug_Type) == "Marijuana",]
      dataSet = summarise(group_by(dataSet, Sheet_Date), meanPrice_Per_Gram_BTC=mean(Price_Per_Gram_BTC), meanBTC = mean(BitcoinPriceUSD))
      
      colourCount = length(unique(dataSet$meanPrice_Per_Gram_BTC))
      getPalette = colorRampPalette(brewer.pal(11, "Spectral"))
      platteNew = getPalette(colourCount)
      g = ggplot(data = dataSet, aes(Sheet_Date))
      g + geom_line(aes(y=meanPrice_Per_Gram_BTC), na.rm = TRUE, size=1) + geom_line(aes(y=meanBTC), na.rm = TRUE, size=1, color = "red") + ylab(paste('Average Price Per','Gram (Normalized)')) + xlab('Date') + scale_fill_manual(values = platteNew, guide = guide_legend(title = "Drug")) + scale_y_continuous(labels = dollar_format(prefix = "$"))
    })
  })
  
  output$dataTableViewOfDrugs <- DT::renderDataTable({
    dataSet = getDataSetFromSearch()
    dataSet$Shipped_From = str_title_case(dataSet$Shipped_From)
    dataSet$Drug_Type = str_title_case(dataSet$Drug_Type)
    dataSet$Market_Name = str_title_case(dataSet$Market_Name)
    dataSet = select(dataSet,"Market" = Market_Name, "Country of Origin" = Shipped_From, "Drug" = Drug_Type, "Price/Gram (Bitcoin)" = Price_Per_Gram_BTC, "Date Posted" = Time_Added, "Date Scraped" = Sheet_Date)
    names(dataSet) = str_title_case(names(dataSet))
    DT::datatable(dataSet, 
                  options = list(autoWidth = TRUE, orderClasses = TRUE, lengthMenu = c(5, 10, 30, 50), pageLength = 10, 
                                 scrollY = TRUE, scrollX = TRUE), selection = "none", style = "bootstrap")
  })
  
  #=============================================================================
  #                               SEARCH RESULTS                              #
  #=============================================================================
  getDataSetFromSearch <- eventReactive(input$query, {
    dataToDisplay = dnmData
    if (!is.null(input$marketName)) {
      dataToDisplay = dataToDisplay[which((dataToDisplay$Market_Name%in%input$marketName)),]
    }
    
    if (!is.null(input$drugName)) {
      dataToDisplay = dataToDisplay[which((dataToDisplay$Drug_Type%in%input$drugName)),]
    }
    if (!is.null(input$shippedFrom)) {
      dataToDisplay = dataToDisplay[which((dataToDisplay$Shipped_From%in%input$shippedFrom)),]
    }
    if (!is.null(input$weightUnits)) {
      drugUnitMutiplier = c(1000,1e+6,1,0.001,NA,0.035274,0.0022046249999752, 0.00000110231131)
      names(drugUnitMutiplier) = c("milligrams","ug","grams","kilograms","ml","ounces","pounds","tons")
      dataToDisplay$Price_Per_Gram_BTC = dataToDisplay$Price_Per_Gram_BTC*drugUnitMutiplier[input$weightUnits]
    }
    if (!is.null(input$weightValue)) {
      dataToDisplay$Price_Per_Gram_BTC = dataToDisplay$Price_Per_Gram_BTC*as.numeric(input$weightValue)
    }
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
})