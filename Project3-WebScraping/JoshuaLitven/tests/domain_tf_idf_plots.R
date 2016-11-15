library(dplyr)
library(janeaustenr)
library(tidytext)

setwd('~/Courses/nyc_data_science_academy/projects/web_scraping/data')
quotes = read.csv('cleaned_data/quotes.csv', stringsAsFactors = FALSE)
quotes = quotes  %>% filter(author != "Lot", author !="Job", author!= "Hide")

# Merge with pantheon
pantheon = read.csv('cleaned_data/pantheon.csv', stringsAsFactors=FALSE)
quotes = merge(pantheon, quotes, by.x="name", by.y="author")

quote_words = quotes %>% 
  unnest_tokens(word, body) %>% 
  count(domain, word, sort=TRUE) %>% 
  ungroup()

total_words = quote_words %>% group_by(domain) %>% summarise(total = sum(n))
quote_words = left_join(quote_words, total_words)
quote_words

library(ggplot2)
library(viridis)
ggplot(quote_words, aes(n/total, fill = domain)) +
  geom_histogram(alpha = 0.8, show.legend = FALSE) +
  xlim(NA, 0.0009) +
  labs(title = "Term Frequency Distribution in Jane Austen's Novels",
       y = "Count") +
  facet_wrap(~domain, ncol = 2, scales = "free_y") +
  theme_minimal(base_size = 13) +
  scale_fill_viridis(end = 0.85, discrete=TRUE) +
  theme(strip.text=element_text(hjust=0)) +
  theme(strip.text = element_text(face = "italic"))

quote_words = quote_words %>% bind_tf_idf(word, domain, n)
quote_words

quote_words %>% 
  select(-total) %>% 
  arrange(desc(tf_idf))

library(ggstance)
library(ggthemes)
plot_domains <- quote_words %>%
  arrange(desc(tf_idf)) %>%
  mutate(word = factor(word, levels = rev(unique(word))))

ggplot(plot_domains[1:20,], aes(tf_idf, word, fill = domain, alpha = tf_idf)) +
  geom_barh(stat = "identity") +
  labs(title = "Highest tf-idf words in Domains",
       y = NULL, x = "tf-idf") +
  theme_tufte(base_family = "Arial", base_size = 13, ticks = FALSE) +
  scale_alpha_continuous(range = c(0.6, 1), guide = FALSE) +
  scale_x_continuous(expand=c(0,0)) +
  scale_fill_viridis(end = 0.85, discrete=TRUE) +
  theme(legend.title=element_blank()) +
  theme(legend.justification=c(1,0), legend.position=c(1,0))

plot_domains <- plot_domains %>% group_by(domain) %>% top_n(15) %>% ungroup
ggplot(plot_domains, aes(tf_idf, word, fill = domain, alpha = tf_idf)) +
  geom_barh(stat = "identity", show.legend = FALSE) +
  labs(title = "Highest tf-idf words in Known People's Domains",
       y = NULL, x = "tf-idf") +
  facet_wrap(~domain, ncol = 2, scales = "free") +
  theme_tufte(base_family = "Arial", base_size = 13, ticks = FALSE) +
  scale_alpha_continuous(range = c(0.6, 1)) +
  scale_x_continuous(expand=c(0,0)) +
  scale_fill_viridis(end = 0.85, discrete=TRUE) +
  theme(strip.text=element_text(hjust=0)) +
  theme(strip.text = element_text(face = "italic"))
