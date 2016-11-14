library(dplyr)
library(janeaustenr)
library(tidytext)
book_words <- austen_books() %>%
  unnest_tokens(word, text) %>%
  count(book, word, sort = TRUE) %>%
  ungroup()

total_words <- book_words %>% group_by(book) %>% summarize(total = sum(n))
book_words <- left_join(book_words, total_words)
book_words

library(ggplot2)
library(viridis)
ggplot(book_words, aes(n/total, fill = book)) +
  geom_histogram(alpha = 0.8, show.legend = FALSE) +
  xlim(NA, 0.0009) +
  labs(title = "Term Frequency Distribution in Jane Austen's Novels",
       y = "Count") +
  facet_wrap(~book, ncol = 2, scales = "free_y") +
  theme_minimal(base_size = 13) +
  scale_fill_viridis(end = 0.85, discrete=TRUE) +
  theme(strip.text=element_text(hjust=0)) +
  theme(strip.text = element_text(face = "italic"))

book_words <- book_words %>%
  bind_tf_idf(word, book, n)
book_words


library(ggstance)
library(ggthemes)
plot_austen <- book_words %>%
  arrange(desc(tf_idf)) %>%
  mutate(word = factor(word, levels = rev(unique(word))))
ggplot(plot_austen[1:20,], aes(tf_idf, word, fill = book, alpha = tf_idf)) +
  geom_barh(stat = "identity") +
  labs(title = "Highest tf-idf words in Jane Austen's Novels",
       y = NULL, x = "tf-idf") +
  theme_tufte(base_family = "Arial", base_size = 13, ticks = FALSE) +
  scale_alpha_continuous(range = c(0.6, 1), guide = FALSE) +
  scale_x_continuous(expand=c(0,0)) +
  scale_fill_viridis(end = 0.85, discrete=TRUE) +
  theme(legend.title=element_blank()) +
  theme(legend.justification=c(1,0), legend.position=c(1,0))


plot_austen <- plot_austen %>% group_by(book) %>% top_n(15) %>% ungroup
ggplot(plot_austen, aes(tf_idf, word, fill = book, alpha = tf_idf)) +
  geom_barh(stat = "identity", show.legend = FALSE) +
  labs(title = "Highest tf-idf words in Jane Austen's Novels",
       y = NULL, x = "tf-idf") +
  facet_wrap(~book, ncol = 2, scales = "free") +
  theme_tufte(base_family = "Arial", base_size = 13, ticks = FALSE) +
  scale_alpha_continuous(range = c(0.6, 1)) +
  scale_x_continuous(expand=c(0,0)) +
  scale_fill_viridis(end = 0.85, discrete=TRUE) +
  theme(strip.text=element_text(hjust=0)) +
  theme(strip.text = element_text(face = "italic"))

library(gutenbergr)
physics <- gutenberg_download(c(37729, 14725, 13476, 5001), 
                              meta_fields = "author")
physics_words <- physics %>%
  unnest_tokens(word, text) %>%
  count(author, word, sort = TRUE) %>%
  ungroup()
physics_words

physics_words <- physics_words %>%
  bind_tf_idf(word, author, n) 
plot_physics <- physics_words %>%
  arrange(desc(tf_idf)) %>%
  mutate(word = factor(word, levels = rev(unique(word)))) %>%
  mutate(author = factor(author, levels = c("Galilei, Galileo",
                                            "Huygens, Christiaan",
                                            "Tesla, Nikola",
                                            "Einstein, Albert")))

ggplot(plot_physics[1:20,], aes(tf_idf, word, fill = author, alpha = tf_idf)) +
  geom_barh(stat = "identity") +
  labs(title = "Highest tf-idf words in Classic Physics Texts",
       y = NULL, x = "tf-idf") +
  theme_tufte(base_family = "Arial", base_size = 13, ticks = FALSE) +
  scale_alpha_continuous(range = c(0.6, 1), guide = FALSE) +
  scale_x_continuous(expand=c(0,0)) +
  scale_fill_viridis(end = 0.6, discrete=TRUE) +
  theme(legend.title=element_blank()) +
  theme(legend.justification=c(1,0), legend.position=c(1,0))

plot_physics <- plot_physics %>% group_by(author) %>% 
  top_n(15, tf_idf) %>% 
  mutate(word = reorder(word, tf_idf))
ggplot(plot_physics, aes(tf_idf, word, fill = author, alpha = tf_idf)) +
  geom_barh(stat = "identity", show.legend = FALSE) +
  labs(title = "Highest tf-idf words in Classic Physics Texts",
       y = NULL, x = "tf-idf") +
  facet_wrap(~author, ncol = 2, scales = "free") +
  theme_tufte(base_family = "Arial", base_size = 13, ticks = FALSE) +
  scale_alpha_continuous(range = c(0.6, 1)) +
  scale_x_continuous(expand=c(0,0)) +
  scale_fill_viridis(end = 0.6, discrete=TRUE) +
  theme(strip.text=element_text(hjust=0))


mystopwords <- data_frame(word = c("gif", "eq", "co", "rc", "ac", "ak", "bn", 
                                   "fig", "file", "cg", "cb"))
physics_words <- anti_join(physics_words, mystopwords, by = "word")
plot_physics <- physics_words %>%
  arrange(desc(tf_idf)) %>%
  mutate(word = factor(word, levels = rev(unique(word)))) %>%
  group_by(author) %>% 
  top_n(15, tf_idf) %>%
  ungroup %>%
  mutate(author = factor(author, levels = c("Galilei, Galileo",
                                            "Huygens, Christiaan",
                                            "Tesla, Nikola",
                                            "Einstein, Albert")))

ggplot(plot_physics, aes(tf_idf, word, fill = author, alpha = tf_idf)) +
  geom_barh(stat = "identity", show.legend = FALSE) +
  labs(title = "Highest tf-idf words in Classic Physics Texts",
       y = NULL, x = "tf-idf") +
  facet_wrap(~author, ncol = 2, scales = "free") +
  theme_tufte(base_family = "Arial", base_size = 13, ticks = FALSE) +
  scale_alpha_continuous(range = c(0.6, 1)) +
  scale_x_continuous(expand=c(0,0)) +
  scale_fill_viridis(end = 0.6, discrete=TRUE) +
  theme(strip.text=element_text(hjust=0))