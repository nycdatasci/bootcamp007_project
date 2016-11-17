# This script computes the similarity matrix of authors based on their quotes.
# We will use the quanteda library to parse and tokenize the quotes.
# Similarities are then used from the Vector Space Model, where authors
# represent "documents".
library(quanteda)
library(dplyr)

# Load in the quotes data
setwd('~/Courses/nyc_data_science_academy/projects/web_scraping/data/cleaned_data/')
quotes = read.csv('quotes.csv', stringsAsFactors = FALSE)

# Create the corpus of quotes
quotes_by_author = quotes %>% group_by(author) %>% summarise(text=paste(body, collapse=" "))
quotes_text = quotes_by_author$text
names(quotes_text) = quotes_by_author$author
quotes_corpus = corpus(quotes_text)

# Get a summary of the corpus
tokenInfo <- summary(quotes_corpus)

# make a document feature matrix, removing stopwords and applying stemming
quotes_dfm <- dfm(quotes_corpus, ignoredFeatures = stopwords("english"), stem = TRUE)

# Let's see the top 20 words
topfeatures(quotes_dfm, 20)

# Compute the tf-idf matrix
quotes_tfidf <- tfidf(quotes_dfm, normalize=TRUE)

# Compute the norms
tfidf_norms = apply(quotes_tfidf, 1, norm, type="2")

# Compute the similarity matrix
similarity_matrix <- similarity(quotes_tfidf, margin="documents", method = "cosine") 
similarity_matrix = as.matrix(similarity_matrix)

# Get most similar authors
author = "Aristotle"

most_similar = sort(similarity_matrix[author, ], decreasing=TRUE)
most_similar = most_similar[-1] # exclude top element
most_similar[1:10]

# Create a random user
document_names = rownames(quotes_tfidf)
sample_docs = sample(document_names, 5, replace = FALSE)
sample_docs = c("Charles Darwin")
user = ifelse(document_names %in% sample_docs, 1, 0)

# Get the corresponding vector in word space
# I think I need to normalized before summing
user_doc2 = colSums(quotes_tfidf[user==1, ])
user.quotes = quotes_tfidf[user==1, ]
user.norms = apply(user.quotes, 1, norm, type = "2")
user.quotes.normalized = user.quotes / user.norms
user_doc = colSums(user.quotes.normalized)

# Calculate the user preference
user_prefs = quotes_tfidf %*% user_doc
user_prefs_normalized = user_prefs / tfidf_norms

# Filter out documents user has already selected
#user_prefs_normalized = user_prefs_normalized[!rownames(user_prefs_normalized) %in% sample_docs, ,drop=FALSE]
n_recommendations = 25
top_recommendations = user_prefs_normalized[order(user_prefs_normalized, decreasing = TRUE), ][1:n_recommendations]
top_recommendations

OUTPUT_DATA = FALSE

# Output to file
if(OUTPUT_DATA){
  save(similarity_matrix, file="similarity_matrix.RData")
  save(tfidf_norms, file="tfidf_norms.RData")
  save(quotes_tfidf, file="quotes_tfidf.RData")
}

# Plato Ralph Waldo Emerson      Samuel Johnson       Francis Bacon George Bernard Shaw 
# 0.3762767           0.3170570           0.3099014           0.2928849           0.2922911 
# Blaise Pascal Friedrich Nietzsche         John Ruskin    Thomas Jefferson      Joseph Addison 
# 0.2901397           0.2817879           0.2796148           0.2792864           0.2756363 
