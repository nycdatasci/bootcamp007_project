library(dplyr)
library(ggplot2)
library(ggthemes)
library(xts)
library(leaflet)
library(RColorBrewer)
library(tidyr)
library(shinythemes)
library(googleVis)
library(reshape2)
library(jsonlite)

#data for stat
hospital1 = read.csv('hospital_1.csv', header = T)
hospital2 = read.csv('hospital_2.csv', header = T)
hp = merge(hospital1, hospital2, by= c('City','Year')) %>% 
  rename(Number_patient = Number_Patient)


#data for motion
newhp = read.csv('newhp.csv',header = T)
pop = read.csv('pop.csv',header = T)

newpop = gather(pop, Year, Population, -X) %>% 
  rename(City = X) %>% 
  mutate( Year= sub("X", "", Year))

newhppop = merge(newhp, newpop, by=c('City','Year'))


#data for map
trans = newhppop %>% filter(Year==2006) %>% select(City)
trans$COUNTYNAME = c('彰化縣','嘉義市','嘉義縣','新竹市','新竹縣','花蓮縣','高雄市','基隆市','金門縣','連江縣','苗栗縣','南投縣','新北市','澎湖縣','屏東縣','台中市','台南市','台北市','台東縣','桃園縣','宜蘭縣','雲林縣')
row.names(trans) = trans$City
geo.json.url = 'https://raw.githubusercontent.com/g0v/twgeojson/master/json/twCounty2010.geo.json'

#list for input select

Category = c('beds','patient','staff')
type = c('Number' = "num", 'per Capita' = "perCap")
ratio = c('General Bed' = "Gb_ratio", 'Special Bed' = "Sb_ratio")