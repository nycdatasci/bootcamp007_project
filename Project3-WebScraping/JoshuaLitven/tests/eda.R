# Investigate the quotes from historical figures
setwd('~/Courses/nyc_data_science_academy/projects/web_scraping/data')
quotes = read.csv('quotes.csv', stringsAsFactors = FALSE)

# Numerical EDA
dim(quotes)
# [1] 278240      3
summary(quotes)
# All categorical variables
head(quotes)

# Load dplyr for easy manipulation
library(dplyr)

# Get the most prolific authors
author_counts = 
  quotes %>% 
  group_by(author) %>% 
  tally() %>% 
  arrange(desc(n))
# TODO: Remove Job and Lot
# 1              Job  1000
# 2              Lot  1000
# 3             Hide   525
# 4     Noam Chomsky   453
# 5       Bill Gates   376
# 6     Taylor Swift   341
# 7    Rush Limbaugh   300
# 8  Richard Dawkins   292
# 9   Salman Rushdie   287
# 10    Dolly Parton   286

author_counts %>% filter(author=='Aristotle')

# Merge with pantheon
pantheon = read.csv('pantheon.tsv', sep='\t', stringsAsFactors=FALSE)
quotes.full$birthyear = as.integer(quotes.full$birthyear)
head(pantheon)
quotes.full = merge(pantheon, quotes, by.x="name", by.y="author")
quotes.full$birthyear = as.numeric(quotes.full$birthyear)

# Plot the histogram of years
library(ggplot2)
ggplot(quotes.full) + geom_histogram(aes(x=birthyear))

# Get a list of all tags
get_top_tags = function(df){
  tags = as.list(strsplit(df$tags, ','))
  tags = unlist(sapply(tags, function(tag) as.character(tag)))
  df = data.frame(tags=tags)
  df %>% 
    group_by(tags) %>% 
    tally() %>% 
    arrange(desc(n))
}
# Find the most popular tags
tags = get_tags(quotes)
tags %>% 
  group_by(tags) %>% 
  tally() %>% 
  arrange(desc(n))
# 1  People 12044
# 2      Me  9906
# 3    Life  9345
# 4    Time  7790
# 5    Love  7278
# 6    Good  6624
# 7    Work  5531
# 8   World  5100
# 9    Know  4757
# 10  Great  4370

# Most popular tags of philosophers?
philosophers = quotes.full %>% filter(occupation == "PHILOSOPHER")
dim(philosophers)
# [1] 4392   25
get_top_tags(philosophers)
# 1     Man   426
# 2    Life   284
# 3     God   217
# 4     Men   214
# 5    Good   196
# 6   World   183
# 7    Love   150
# 8   Great   138
# 9  Nature   132
# 10  Truth   127

# Most popular tags of mathematicians?
mathematicians = quotes.full %>% filter(occupation == "MATHEMATICIAN")
dim(mathematicians)
# [1] 497  25
get_top_tags(mathematicians)
# 1  Mathematics    38
# 2          Man    35
# 3          Men    28
# 4         Time    27
# 5         Life    24
# 6        World    23
# 7         Love    21
# 8      Science    18
# 9          God    17
# 10        Know    16

# Most popular USA tags
america = quotes.full %>% filter(countryCode=="US")
dim(america)
# [1] 72518    25
get_top_tags(america)
# 1  People  6693
# 2      Me  5585
# 3    Life  4685
# 4    Time  4109
# 5    Love  3859
# 6    Good  3306
# 7    Work  2865
# 8    Know  2651
# 9   World  2292
# 10    You  2268

# Most popular Chinese tags
china = quotes.full %>%  filter(countryCode=="CN")
dim(china)
get_top_tags(china)
# 1  People    62
# 2    Time    59
# 3   World    50
# 4    Life    49
# 5      Me    45
# 6    Good    37
# 7    Work    37
# 8     Man    30
# 9   Enemy    27
# 10    Art    26

# Most popular artist tags
artists = quotes.full %>% filter(occupation=="ARTIST")
dim(artists)
get_top_tags(artists)
# 1       Art   161
# 2      Life    85
# 3        Me    79
# 4    People    78
# 5      Work    68
# 6       Man    47
# 7      Time    45
# 8  Painting    43
# 9     World    41
# 10     Good    37

# Old
old = quotes.full %>% filter(birthyear < 1800)
get_top_tags(old)

# Let's focus on Eastern thought vs. Western thought
east = old %>% filter(continentName=="Asia")
east_top_tags = get_top_tags(east)
east_top_100 = east_top_tags[1:100, ]

west = old %>% filter(continentName=="Europe")
west_top_tags = get_top_tags(west)
west_top_100 = west_top_tags[1:100, ]

# intersection
intersection = intersect(west_top_100$tags, east_top_100$tags)

west_only = setdiff(west_top_100$tags,east_top_100$tags)
west_only
# [1] "True"        "Happy"       "Age"         "Reason"      "Religion"    "Justice"     "Law"        
# [8] "Light"       "Long"        "Myself"      "Hope"        "Women"       "Music"       "Money"      
# [15] "Free"        "Education"   "Science"     "History"     "Government"  "Own"         "Die"        
# [22] "First"       "Imagination" "Think"       "Thoughts"    "Most"        "Always"      "Friends"    
# [29] "Speak"       "Way"         "Wish"        "Without"     "He"          "Person"      "Philosophy" 
# [36] "Body"        "Love Is"     "Learn"    

east_only = setdiff(east_top_100$tags, west_top_100$tags)
east_only
# [1] "Yourself"   "Victory"    "Together"   "Fight"      "Peace"      "Win"        "Anger"     
# [8] "Everything" "Excellence" "Father"     "Success"    "Want"       "Wealth"     "Army"      
# [15] "Brainy"     "Difficult"  "Fire"       "Ignorance"  "Need"       "Patience"   "Practice"  
# [22] "Remember"   "Rich"       "Right"      "Sun"        "Things"     "Trees"      "Battle"    
# [29] "Beginning"  "Born"       "Business"   "Chance"     "Doing"      "Down"       "Everyone"  
# [36] "Experience" "Eye"        "Family"  

# Can we see a difference in sentiments about war before and after world war 1?
get_tags_vec = function(tags_string){
  tags = unlist(strsplit(tags_string, ','))
  return(tags)
}

filter_by_tag = function(df, tag){
  bools = sapply(df$tag_string, function(str) tag %in% get_tags_vec(str))
  return(df[bools, ])
}

war = filter_by_tag(quotes.full, "War")

word = "Technology"
century_16 = quotes.full %>% filter(birthyear > 1500, birthyear < 1600)
nrow(filter_by_tag(century_16, word)) / nrow(century_16)

century_17 = quotes.full %>% filter(birthyear > 1600, birthyear < 1700)
nrow(filter_by_tag(century_17, word)) / nrow(century_17)

century_18 = quotes.full %>% filter(birthyear > 1700, birthyear < 1800)
nrow(filter_by_tag(century_18, word)) / nrow(century_18)

century_19 = quotes.full %>% filter(birthyear > 1800, birthyear < 1900)
nrow(filter_by_tag(century_19, word)) / nrow(century_19)

century_20 = quotes.full %>% filter(birthyear > 1900, birthyear < 2000)
nrow(filter_by_tag(century_20, word)) / nrow(century_20)

