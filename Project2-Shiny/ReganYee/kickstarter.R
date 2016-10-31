library(dplyr)
library(googleVis)
library(ggplot2)
library(bubbles)

## Load csv into R
setwd("~/Documents/Project/2-KickStarter/kickstarter/data")
ks = read.csv("uber_kickstarter.csv", stringsAsFactors = FALSE)
colnames(ks)
head(ks)

## Extract the friendly end-user category name (after the slug section)
## clean_categories has format of category1/subcategory
delimited_list = strsplit(ks$category, 'slug\":')
categories = sapply(delimited_list,function(x) x[2])
clean_categories = sapply(strsplit(categories, '\\"'),function(x) x[2])
ks$category = clean_categories
cat_split = strsplit(ks$category, '/')
cat1 = sapply(cat_split,function(x) x[1])
cat2 = sapply(cat_split,function(x) x[2])
ks$cat1 = cat1
ks$cat2 = cat2
# Garbage Cleanup
rm(clean_categories)
rm(delimited_list)
rm(categories)
rm(cat_split)
rm(cat1)
rm(cat2)

## Extract the short_name of the location
delimited_list = strsplit(ks$location, 'short_name\":\"')
location_name = sapply(delimited_list,function(x) x[2])
location_name
clean_location_name = sapply(strsplit(location_name, '\"'), function(x) x[1])
ks$location = clean_location_name
# Garbage Cleanup
rm(clean_location_name)
rm(delimited_list)
rm(location_name)

## Extract City,State
delimited_list = strsplit(ks$location, ", ")
loc1 = sapply(delimited_list,function(x) x[1])
loc2 = sapply(delimited_list,function(x) x[2])
ks$loc1 = loc1
ks$loc2 = loc2
# Cleanup
rm(loc1)
rm(loc2)

## Extract the URL to the kickstarter idea
delimited_list = strsplit(ks$urls, '\"')
idea_url = sapply(delimited_list,function(x) x[6])
ks$urls = idea_url
#Garbage Cleanup
rm(delimited_list)
rm(idea_url)

## Convert UNIX time -> datetime character for the created timestamp
times = sapply(ks$created_at,function(x) 
  as.character(
    as.POSIXct(
      as.numeric(x),origin="1970-01-01")))
ks$created_at = times
#Garbage Cleanup
rm(times)

#Confirm that categories has been mutated
ks %>% distinct(category) %>% arrange(category)
ks %>% distinct(location) %>% arrange(location)


#Clean up dirty columns from catting the CSV files together (remove headers)
clean_ks = ks %>% filter(state != 'state')

#Select the columns that you want
colnames(ks)
df = clean_ks %>% 
  select(id,name,backers_count,goal,pledged,state,cat1,cat2,country,loc1,loc2,created_at,urls) %>% 
  transmute(ID=id,Name=name,Backers=backers_count,Goal=goal,Pledged=pledged,Status=state,Category=cat1,Subcategory=cat2,Country=country,City=loc1,State=loc2,Created_Time=created_at,URL=urls)
head(df,10)
df$Goal = as.numeric(df$Goal)
df$Pledged = as.numeric(df$Pledged)
df$Backers = as.numeric(df$Backers)

## Only look at kickstarters who have money pledged into them
pledged = df %>% filter(Pledged != 0)
head(pledged)
pledged$Goal = as.numeric(pledged$Goal)
pledged$Pledged = as.numeric(pledged$Pledged)
pledged$Backers = as.numeric(pledged$Backers)

pledged %>% filter(State=='NY') %>% distinct(State)
ny = pledged %>% filter(State == 'NY' & City == 'New York') %>% arrange(Category)
ny %>% distinct(Category)
head(ny)

saveRDS(pledged,'pledged.RDS')



############################ Analysis
g = ggplot(ny, aes(x=Backers, y = Pledged, size=Backers, color = Category))
g+geom_point()
ny$Backers
ny$Pledged
US_KS %>% distinct(Status)

colnames(pledged)


############################# Bubble Chart
ny$Category = as.factor(ny$Category)
r=rainbow(15,alpha=NULL)
pie(rep(1,15), col=r)
mycolors = sapply(ny$Category, function(x) r[match(x,levels(ny$Category))])

b = bubbles(value = ny$Backers, label="", tooltip = ny$Name, color = mycolors)
renderBubbles(b, env="map")
?bubbles
test = as.character(c(1:6080))

bubbles(runif(10), LETTERS[1:10], color = rainbow(10, alpha = NULL), tooltip = as.character(c(1:10)))


pledged %>% group_by(cat1) %>% summarize(count=n()) %>% arrange(count)
ny %>% group_by(cat1) %>% summarize(count=n()) %>% arrange(count)

pledged %>% filter(country=='US') %>% group_by(loc2) %>% summarize(count=n()) %>% arrange(desc(count))

colnames(ny)
Table <- gvisTable(summary_of_cat)
plot(Table)
#Create a custom color scale
#library(RColorBrewer)
#myColors <- brewer.pal(9,"Set1")
#myColors

## sizevar is my pledged
## colorvar is my category
## points (idvar is my project names -- name)

##GOOGLE VIS BUBBLE
ny %>% distinct(Status)

nyunder50 = ny %>% filter(Status=='live')
Bubble <- gvisBubbleChart(nyunder50, idvar="Name", 
                          xvar="Pledged", yvar="Goal",
                          colorvar="Category", sizevar="Backers",
                          options=list(
                            width=800, height=600,
                            bubble="{textStyle:{color: 'none'}}",
                            explorer.actions='dragToZoom',
                            animation.duration=1))
plot(Bubble)
?gvisBubbleChart

  ## Look by count backers
pledged %>% filter(backers_count > 90000) %>% arrange(desc(backers_count))

head(pledged %>% arrange(desc(goal)))

## Look by total pledged
pledged %>% filter(pledged$pledged > 8000000) %>% arrange(desc(pledged))

## Count pledged by state(status)
pledged %>% group_by(state) %>% summarize(count = n())

## Count pledged by location
pledged %>% filter(country == 'US') %>% distinct(loc2)
us = pledged %>% filter(country == 'US')
us %>% group_by(loc2) %>% summarise(count=n()) %>% arrange(desc(count))
us %>% filter(loc2=='Hong Kong')

## Salad kickstarters
ks %>% filter(grepl('[s,S]alad',name)) %>% select(name,state,goal,pledged)



summary_of_Loc = pledged %>% filter(loc1=='New York') %>% summarize(count=n())

summary_of_cat = pledged %>% filter(loc1=='New York') %>% 
  group_by(cat1) %>% summarize(count=n()) %>% 
  mutate(percentage = percent(count/summary_of_Loc$count)) %>% 
  mutate(Location = ny$loc1[1]) %>% 
  arrange(desc(count/summary_of_Loc$count))


library(rpivotTable)
## One line to create pivot table
US_KS = pledged %>% filter(Country=='US')
US_KS = US_KS %>% filter(nchar(State) == 2)
ny = US_KS %>% filter(State=='NY')
exp = rpivotTable(ny, rows="State", col="Category", aggregatorName="Count as Fraction of Rows", 
            vals="name", rendererName="Table Barchart")

rpivotTableOutput("pivotSum", width = "100%", height = "500px")

