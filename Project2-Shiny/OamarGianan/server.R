library(DT)
library(shiny)
library(googleVis)
library(igraph)
library(data.table)

getExportTable <- function(select_year, select_country){
       whoisTopEx <- getExport(select_year, select_country)
       print(whoisTopEx)
       print(select_year)
       table <- all_categorized %>% 
              filter(Year == select_year & Reporter == whoisTopEx[[1]] & `Indicator Type` == "Export") %>%
              select(`Product categories`, `US$ million` = `Indicator Value`)
       table <- arrange(table, desc(`US$ million`))
       return(table)
}

getImportTable <- function(select_year, select_country){
       whoisTopIm <- getImport(select_year, select_country)
       print(whoisTopIm)
       print(select_year)
       table <- all_categorized %>% 
              filter(Year == select_year & Reporter == whoisTopIm[[1]] & `Indicator Type` == "Import") %>%
              select(`Product categories`, `US$ million` = `Indicator Value`)
       table <- arrange(table, desc(`US$ million`))
       return(table)
}

getExport <- function(select_year, select_country){
       ##Get Top Exporter
       Exports <- all_data %>% filter(Year == select_year) %>% 
              filter(From %in% select_country | To %in% select_country) %>%
              select(From, amount)
       Exports <- arrange(Exports, desc(amount))
       Exports <- aggregate(Exports$amount, by = list(Exports$From), FUN=sum)
       Exports <- filter(Exports, x == max(Exports$x))
       names(Exports) <- c("Top Exporter", "Amount in $mil")
       return(Exports)
}

getImport <- function(select_year, select_country){
       ##Get Top Importer
       Imports <- all_data %>% filter(Year == select_year) %>% 
              filter(From %in% select_country | To %in% select_country) %>%
              select(To, amount)
       Imports <- arrange(Imports, desc(amount))
       Imports <- aggregate(Imports$amount, by = list(Imports$To), FUN=sum)
       Imports <- filter(Imports, x == max(Imports$x))
       names(Imports) <- c("Top Importer", "Amount in $mil")
       return(Imports)
}

##FUNCTION FOR DISPLAYING SECTOR LABEL BETTER
rounders <- function(x){
       if (x > 1e3) {
              x <- paste(format(round(x / 1e3, 0), trim = TRUE), "T")
       }
       return(x)
}

##FUNCTION FOR DISPLAYING SECTOR LABEL BETTER
stepper <- function(x){
       val <- ifelse(x > 5e5, 2e5, ifelse(x>2e5, 1e5, 1e3))
       return(val)
}

###Chord Diagram Function to avoid using numerous reactive statements
getChordDiagram <- function(select_year, select_percentile, select_country){
       
       ##filter database based on input
       df_plot <- all_data %>% filter(Year == select_year) %>% 
              filter(amount > quantile(amount, as.numeric(select_percentile)*.01))  %>% 
              select(From, To, amount) %>%
              filter(From %in% select_country | To %in% select_country)				 
       df_plot <- arrange(df_plot, desc(amount))
       
       ##get the adjacency matrix
       df_mat <- as_adjacency_matrix(graph.data.frame(df_plot,directed=TRUE), names=TRUE,sparse=FALSE,attr="amount")
       
       ##Sort order of df and matrix for plotting in circos
       df_plot_countries <- as.data.frame(sort(unique(c(df_plot$From, df_plot$To)))) 
       df_plot_countries <-  setnames(df_plot_countries, "Country")  
       df_plot_countries <- arrange(df_plot_countries, Country)
       df_plot_countries$Country <-  factor(df_plot_countries$Country, levels = df_plot_countries$Country) 
       
       #was used in reactive   Country_f <- factor(df_plot_countries$Country) })
       #was used in reactive   df_plot_countries <-   cbind(df_plot_countries, Country_f) %>% select(-Country) %>% select( Country = Country_f)  
       
       df_mat <- df_mat[levels(df_plot_countries$Country),levels(df_plot_countries$Country)]  
       
       ### Define ranges of circos sectors and their colors (both of the sectors and the links)
       df_plot_countries$xmin <- 0
       #was used in reactive   df_plot_countries <- reactive({ cbind(df_plot_countries, xmin = 0)   })
       df_plot_countries$xmax <- rowSums(df_mat) + colSums(df_mat)
       #was used in reactive   df_plot_countries <- reactive({  cbind(df_plot_countries, xmax = rowSums(df_mat) + colSums(df_mat))  })
       n_n <- nrow(df_plot_countries) 
       
       #was used in reactive    df_plot_countries <- reactive({   cbind(df_plot_countries, sum1 = colSums(df_mat))   })
       #was used in reactive    df_plot_countries <- reactive({   cbind(df_plot_countries, sum2 = numeric(n_n))  })
       #############FIX COLOR HERE LATER
       test_col <- Colored[match(df_plot_countries$Country, Colored$`unique(Countries)`), 2] 
       
       ### Plot sectors (outer part)
       par(mar=rep(0,4))
       circos.clear()

       ### Basic circos graphic parameters
       circos.par(cell.padding=c(0,0,0,0), track.margin=c(0,0.15), start.degree = 90, gap.degree =4)
       
       ### Sector details
       circos.initialize(factors = df_plot_countries$Country,
                         xlim = cbind(df_plot_countries$xmin,
                                      df_plot_countries$xmax))
       
       ### Plot sectors
       circos.trackPlotRegion(ylim = c(0, 1), factors = df_plot_countries$Country, track.height=0.1,
                              #panel.fun for each sector
                              panel.fun = function(x, y) {
                                     #select details of current sector
                                     name = get.cell.meta.data("sector.index")
                                     i = get.cell.meta.data("sector.numeric.index")
                                     xlim = get.cell.meta.data("xlim")
                                     ylim = get.cell.meta.data("ylim")
                                     
                                     #text direction (dd) and adjusmtents (aa)
                                     theta = circlize(mean(xlim), 1.3)[1, 1] %% 360
                                     dd <- ifelse(theta < 90 || theta > 270, "clockwise", "reverse.clockwise")
                                     aa = c(1, 0.5)
                                     if(theta < 90 || theta > 270)  aa = c(0, 0.5)
                                     
                                     #plot country labels
                                     circos.text(x=mean(xlim), y=1.7, labels=name, facing = dd, cex=0.6,  adj = aa)
                                     
                                     #plot main sector
                                     circos.rect(xleft=xlim[1], ybottom=ylim[1], xright=xlim[2], ytop=ylim[2],
                                                 col = test_col[i], border="black" )
                                     
                                     #blank in part of main sector
                                     circos.rect(xleft=xlim[1], ybottom=ylim[1], xright=xlim[2]-rowSums(df_mat)[i], ytop=ylim[1]+0.3,
                                                 col = "white", border = "white")
                                     
                                     #white line all the way around
                                     circos.rect(xleft=xlim[1], ybottom=0.3, xright=xlim[2], ytop=0.32, col = "white", border = "white")
                                     
                                     #plot axis
                                     circos.axis(labels.cex=0.6, direction = "outside", major.at=seq(from=0,to=floor(df_plot_countries$xmax)[i],by=stepper(df_plot_countries$xmax)[i]),
                                                 major.tick = TRUE, minor.ticks=1, labels.away.percentage = 0.15, labels = sapply(seq(from=0,to=floor(df_plot_countries$xmax)[i],stepper(df_plot_countries$xmax)[i]), FUN = rounders)  )
                              })

       ### Plot links (inner part)
       df_plot_countries$sum1 <- colSums(df_mat)
       df_plot_countries$sum2 <- numeric(n_n)
       
       ### Plot links
       for(k in 1:nrow(df_plot)){
              #i,j reference of flow matrix
              i<-match(df_plot$From[k],df_plot_countries$Country)
              j<-match(df_plot$To[k],df_plot_countries$Country)
              #plot link
              circos.link(sector.index1=df_plot_countries$Country[i], point1=c(df_plot_countries$sum1[i], df_plot_countries$sum1[i] + abs(df_mat[i, j])),
                          sector.index2=df_plot_countries$Country[j], point2=c(df_plot_countries$sum2[j], df_plot_countries$sum2[j] + abs(df_mat[i, j])),
                          col = test_col[i])
              
              #update sum1 and sum2 for use when plotting the next link
              df_plot_countries$sum1[i] = df_plot_countries$sum1[i] + abs(df_mat[i, j])
              df_plot_countries$sum2[j] = df_plot_countries$sum2[j] + abs(df_mat[i, j])
       }
}




shinyServer(function(input, output){
       getYear <-  reactive({return(input$select_year)})
       getPercentile <-  reactive({return(input$select_percentile)})
       getCountries <-  reactive({return(input$select_country)})

       #PLOT valueboxes
       output$TopImporter <- renderValueBox({
              dfTopImporter <- getImport(getYear(), getCountries())
           infoBox(dfTopImporter[[1]], paste(paste("$",format(round(dfTopImporter[[2]]), big.mark=","),sep=""), "M"), icon = icon("download"))
       })
       output$TopExporter <- renderValueBox({
              dfTopExporter <- getExport(getYear(), getCountries())
           infoBox(dfTopExporter[[1]], paste(paste("$",format(round(dfTopExporter[[2]]), big.mark=","),sep=""), "M"), icon = icon("upload"))
       })
       # output$avgBox <- renderInfoBox(
       #     infoBox(paste("AVG.", input$selected),
       #             mean(state_stat[,input$selected]), 
       #             icon = icon("calculator"), fill = TRUE))
       
       #PLOT chord diagram
       output$chord <- renderPlot({ 
              print(getChordDiagram(getYear(), getPercentile(), getCountries()))  
       })
       
       #PLOT table of product categories
       output$CategoryExTable <- renderTable({
              print(head(getExportTable(getYear(), getCountries()), n = 10L))
       }, digits = 1)

       output$CategoryImTable <- renderTable({
              print(head(getImportTable(getYear(), getCountries()), n = 10L))
       }, digits = 1)       
       
       
})
    
    

