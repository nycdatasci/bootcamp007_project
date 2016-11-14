# library packages
library(shiny)
library(shinythemes)
library(knitr)
library(dplyr)
library(leaflet)
library(ggplot2)
library(ggthemes)
library(RColorBrewer)
library(xts)
library(dygraphs)
library(reshape2)
library(networkD3)



# load data
# map data
load("data/leaf.RData")
# tedtalk data
load("data/tedtalk.RData")
# networkD3 links data
load("data/networklinks.RData")
# networkD3 nodes data
load("data/nodes.RData")
# dygraph data
load("data/topic.RData")


# data for shiny
# to convert the numeric variable to factor
topic_count = data.frame(Business = as.numeric(tedtalk$Business) - 1 ,
                         Entertainment = as.numeric(tedtalk$Entertainment) - 1,
                         Health = as.numeric(tedtalk$Health) - 1,
                         Psychology = as.numeric(tedtalk$Psychology) - 1,
                         Science = as.numeric(tedtalk$Science) - 1,
                         Technology = as.numeric(tedtalk$Technology) - 1,
                         Global = as.numeric(tedtalk$Global) - 1)
topic_counts = colSums(topic_count)
topic_counts = as.data.frame(topic_counts)
topic_num = data.frame(topic = row.names(topic_counts), topic_counts = topic_counts$topic_counts)

# to convert the date variable
tedtalk$upload_date = as.Date(tedtalk$upload_date)

# map data
mymap = leaflet() %>% setView(lat = 14.93305, lng =  -23.51333, 2) %>%
  addProviderTiles('CartoDB.Positron') %>%
  addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
           attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
  addCircleMarkers(data = leaf, lat = ~ latitude, lng = ~ longitude, 
             radius = 5, stroke = F, fillOpacity = 0.3, 
             color = 'red', popup = ~ address)

# dygraph data
# convert date data
# topic$yrmon = as.yearmon(as.character(topic$yrmon), format = '%Y%m')
topic_tran = dcast(topic, yrmon ~ group, value.var = 'views')
# convert to xts data
topic_xt = xts(topic_tran[, -1], order.by = topic_tran$yrmon)



# vectors needed in the process
continuous_var = c('total_views', 'upload_months', 'seconds', 'comment_num', 'subtitle', 'topic_num')
discrete_var = c('Business', 'Entertainment', 'Health', 'Psychology', 'Science', 'Technology', 'Global')



# tab/panel choices variable
factors = c('Months Since Uploaded' = 'upload_months',
            'Subtitle Numbers' = 'subtitles',
            'Video Duration' = 'seconds',
            'Comment Number' = 'comment_num',
            'Topic Variety' = 'topic_num')
topics = c('Technology' = 'Technology',
           'Business' = 'Business',
           'Global Issues' = 'Global',
           'Health' = 'Health',
           'Business' = 'Business',
           'Psychology' = 'Psychology',
           'Entertainment' = 'Entertainment')



# render rMarkdown in Shiny
rmdfiles = c("RMarkdownFile.rmd")
sapply(rmdfiles, knit, quiet = T)