library(dplyr)
library(janeaustenr)
library(tidytext)

setwd('~/Courses/nyc_data_science_academy/projects/web_scraping/data')
quotes = read.csv('quotes.csv', stringsAsFactors = FALSE)
quotes = quotes  %>% filter(author != "Lot", author !="Job", author!= "Hide")

# Merge with pantheon
pantheon = read.csv('pantheon.tsv', sep='\t', stringsAsFactors=FALSE)
quotes = merge(pantheon, quotes, by.x="name", by.y="author")

quote_words = quotes %>% 
  unnest_tokens(word, body, drop=FALSE) %>% 
  count(name, word, sort=TRUE) %>% 
  ungroup()

total_words = quote_words %>% group_by(name) %>% summarise(total = sum(n))
quote_words = left_join(quote_words, total_words)
quote_words

quote_words = quote_words %>% bind_tf_idf(word, name, n)
View(quote_words)

# Normalize author vectors
author_vector_lengths = 
  quote_words %>% 
  group_by(name) %>% 
  summarise(mag = sqrt(sum(tf_idf^2)))
author_vector_lengths
quote_words = left_join(quote_words, author_vector_lengths, by="name")
quote_words = 
  quote_words %>% 
  mutate(normalized = tf_idf / mag)

# Get author similarity
get_author_similarity = function(author_1, author_2){
  author_1_words = quote_words %>% filter(name==author_1) %>% select(word, normalized)
  author_2_words = quote_words %>% filter(name==author_2) %>% select(word, normalized)
  
  # Get common words
  common_words = inner_join(author_1_words, author_2_words, by="word")
 # print(common_words %>% arrange(desc(normalized.x)))
  dot_product = sum(common_words$normalized.x * common_words$normalized.y)
  return(dot_product)
}

get_most_similar_author = function(author){
  
}

author_1 = "Voltaire"
author_2 = "Brian Greene"
get_author_similarity(author_1, author_2)

author = "Voltaire"
philosophers = unique(quotes$name[quotes$occupation=="PHILOSOPHER"])
distances = sapply(philosophers[philosophers!=author], get_author_similarity, author_1)
which.max(distances)
