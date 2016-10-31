library(dplyr)
library(leaflet)
pkmgo<-read.csv("300k.csv")
pkmgoName<-read.csv("PokmonName.csv",header=FALSE)
names(pkmgoName)=c("pokemonId","pokemonName")
pkmgo<-left_join(pkmgo,pkmgoName,by="pokemonId")
variable<-names(pkmgo)
list<-c("pokemonId","pokemonName","latitude",'longitude','appearedTimeOfDay','city','continent','population_density')
df<-select(pkmgo,match(list,names(pkmgo)))
df_NY<- df[df$city=='New_York',]
df_NY_Id<-df_NY%>% filter(pokemonId==1)%>%
  group_by(pokemonId,pokemonName,latitude,longitude)%>%summarise(num=sum(pokemonId))
#draw map by leaflet
m<-leaflet(data=df_NY_Id)%>%addCircles(lat = ~latitude, lng = ~longitude, radius=~num)%>%
  setView(lng = -97.42, lat = 20.50, zoom = 12)%>% addProviderTiles("CartoDB.Positron")%>%
  addMarkers(~longitude, ~latitude, popup = ~as.character(pokemonName))
for (i in length(df$X)){
  lon<-df[i,5]
  lat<-df[i,4]
#  res<-revgeocode(c(lon,lat),output="more")
  output[i]<-levels(revgeocode(c(lon,lat),output="more")$locality)
} 
#####ggmap
df_NY<-df[df$city==input$New_York & df$pokemonName==input$mon,]
ggmap(get_map(location = 'New_York', zoom = 11,maptype = "toner-2010",scale = 2))+
  geom_point(data=df_NY_Id, aes(x=longitude, y=latitude, size=num), color="blue",alpha = 0.8)
