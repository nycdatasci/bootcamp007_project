# library packages
library(shiny)
library(shinythemes)
library(ggplot2)
library(ggthemes)
library(dplyr)
library(xts)
library(dygraphs)
library(leaflet)
library(RColorBrewer)
library(zoo)
library(reshape2)
library(wordcloud)


# load data
# storm events data
load("data/LatLngTime.RData")
# fatality data
load("data/FatalLoc.RData")
# word cloud data
load("data/desc_txt.RData")


# data for shiny
LatLngTime = LatLngTime %>% 
  mutate(., EVENT_DATE = as.Date(BEGIN_DATE_TIME, format = '%d-%b-%y %H:%M:%S'))
LatLngTime$DATE_YM = as.yearmon(as.character(LatLngTime$YEARMONTH), format = '%Y%m')
# dygraph: time vs. event type
fata = LatLngTime %>% 
  select(., DEATHS_DIRECT, DEATHS_INDIRECT, DATE_YM) %>%
  group_by(., DATE_YM) %>% 
  summarise(., Direct = sum(DEATHS_DIRECT), Indirect = sum(DEATHS_INDIRECT))
fata_xt = xts(fata[, -1], order.by = fata$DATE_YM)
# dygraph: time vs. fatality
types = LatLngTime %>% group_by(., DATE_YM, EVENT_TYPE) %>% 
  summarise(., TYPE_NUM = n())
types_tran = dcast(types, DATE_YM ~ EVENT_TYPE, value.var = 'TYPE_NUM')
types_xt = xts(types_tran, types_tran$DATE_YM)

# tab/panel choices variable
top6 = c('Flash Flood' = 'Flash Flood',
         'Flood' = 'Flood',
         'Hail' = 'Hail',
         'Marine Thunderstorm Wind' = 'Marine Thunderstorm Wind',
         'Thunderstorm Wind' = 'Thunderstorm Wind',
         'Tornado' = 'Tornado')
loss = c('Deaths - Direct' = 'DEATHS_DIRECT',
         'Deaths - Indirect' = 'DEATHS_INDIRECT',
         'Injuries - Direct' = 'INJURIES_DIRECT',
         'Injuries - Indirect' = 'INJURIES_INDIRECT',
         'Damage Property' = 'DAMAGE_PROPERTY',
         'Damage Crops' = 'DAMAGE_CROPS')


# color pal
colpal = colorFactor(RColorBrewer::brewer.pal(6, 'Set1'),
                     domain = c('Flash Flood', 'Flood', 'Hail', 'Marine Thunderstorm Wind',
                                'Thunderstorm Wind', 'Tornado'))
