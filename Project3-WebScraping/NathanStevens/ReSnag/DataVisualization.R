# R scriot for doing some sample 
# visualization on the data collected
library(mongolite)
library(dplyr)
library(ggplot2)

# firt load the mongo database
nsfa <- mongo(collection = 'nsfawards', db="grants")
nsfa$count()

# this function performs a keyword search on the mongoDB
# then apply some basic transformation on data
getDocs <- function(keyword) {
  searchTerm = paste0('{"$text": {"$search": "', keyword, '"}}')
  df = nsfa$find(searchTerm)

  # extract the year from the data to make grouping better
  df$Amount = as.integer(df$Amount)
  df$Year = substring(df$Date, 7)
  
  return(df)
}

#define the font size
font.size = 20
font.size.axis = 18

# get data for use case 1. Acme AFM #
df = getDocs('AFM')
gbdf = group_by(df, Year)
sdf = summarise(gbdf, Total.Amount = sum(Amount), Grant.Count = n())

# plot dollar amounts per year
ggplot(data=sdf, aes(x=Year, y=Total.Amount, fill=Year)) +
  geom_bar(stat="identity")

# plot amount of grants
ggplot(data=sdf, aes(x=Year, y=Grant.Count, fill=Year)) +
  geom_bar(stat="identity")

# plot the top grant institutions for last 
df1 = filter(df, Year > 2010)
gbdf1 = group_by(df, Institution)
sdf1 = summarise(gbdf1, Total.Amount = sum(Amount), Grant.Count = n())
ggplot(data = sdf1, aes(x = reorder(Institution, -Grant.Count), y = Grant.Count)) + 
  geom_jitter(colour = "green", size = 3) + 
  xlab("Institutions (2011 - 2017)") + 
  ylab("Number Of Grants") +
  theme(axis.text.x = element_blank(), text=element_text(size=font.size, face="bold"),
        axis.text.y=element_text(size=font.size.axis, face="bold"))

#
# get the example for tissue engeneering
#
df2 = getDocs('\\"tissue engineering\\"')
gbdf2 = group_by(df2, Year)
sdf2 = summarise(gbdf2, Total.Amount = sum(Amount), Grant.Count = n())

# plot dollar amounts per year
ggplot(data=sdf2, aes(x=Year, y=Total.Amount, fill=Year)) +
  geom_bar(stat="identity")

# plot amount of grants
ggplot(data=sdf2, aes(x=Year, y=Grant.Count, fill=Year)) +
  geom_bar(stat="identity")

# get the money by institution
df3 = filter(df2, Year == 2016)
gbdf3 = group_by(df3, Institution)
sdf3 = summarise(gbdf3, Total.Amount = sum(Amount), Grant.Count = n())

df4 = filter(df2, Year == 2015)
gbdf4 = group_by(df4, Institution)
sdf4 = summarise(gbdf4, Total.Amount = sum(Amount), Grant.Count = n())
