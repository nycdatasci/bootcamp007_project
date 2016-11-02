library(dplyr)
library(scales)

# convert matrix to dataframe
pledged = readRDS("./data/pledged.RDS")

# select certain fields to display
data = pledged %>% select(Name, Goal, Pledged, Backers, Category, City, State, Status)

# total of US
summary_of_Loc = pledged %>% filter(Country=='US', nchar(State) == 2) %>% summarize(count=n())

# summarize by category (for percentage by category)
summary_of_cat = pledged %>% filter(Country=='US', nchar(State) == 2) %>% 
  group_by(Category) %>%
  summarize(Count=n()) %>% 
  mutate(Percentage = percent(Count/summary_of_Loc$count)) %>% 
  arrange(desc(Count/summary_of_Loc$count))

