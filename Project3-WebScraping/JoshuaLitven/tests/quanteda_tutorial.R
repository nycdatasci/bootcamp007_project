library(quanteda)

str(inaugTexts)

# Create a corpus from documents
myCorpus <- corpus(inaugTexts)

# Get summary of first 5 documents
summary(myCorpus, n = 5)

# Extract 2nd document from the corpus
texts(inaugCorpus)[2]

# Get a summary of the corpus
tokenInfo <- summary(inaugCorpus)

if (require(ggplot2))
  ggplot(data=tokenInfo, aes(x=Year, y=Tokens, group=1)) + geom_line() + geom_point() +
  scale_x_discrete(labels=c(seq(1789,2012,12)), breaks=seq(1789,2012,12) ) 

myCorpus <- subset(inaugCorpus, Year > 1950)

# make a dfm
myDfm <- dfm(myCorpus)

myDfm[, 1:5]

# make a dfm, removing stopwords and applying stemming
myStemMat <- dfm(myCorpus, ignoredFeatures = stopwords("english"), stem = TRUE)

head(stopwords("english"), 20)

topfeatures(myStemMat, 20) # 20 top words

if (require(RColorBrewer))
  plot(myStemMat, max.words = 100, colors = brewer.pal(6, "Dark2"), scale = c(8, .5))

# Group
byPartyDfm <- dfm(ie2010Corpus, groups = "party", ignoredFeatures = stopwords("english"))

sort(byPartyDfm)[, 1:10]

# Weight by tf-idf
tfidf_matrix <- tfidf(myStemMat, normalize=TRUE)

# Compute the similarity matrix
similarity_matrix <- similarity(tfidf_matrix, margin="documents", method = "cosine") 
similarity_matrix = as.matrix(similarity_matrix)

# Get most similar documents of a given document
document = "1973-Nixon"

most_similar = sort(similarity_matrix[document, ], decreasing=TRUE)
most_similar = most_similar[-1] # exclude top element
most_similar

# What if I have user's preferences?

# Create a random user
document_names = rownames(similarity_matrix)
sample_docs = sample(document_names, 5, replace = FALSE)
user = ifelse(document_names %in% sample_docs, 1, 0)

# Normalize the rows for computing cosine similarities
tfidf_normalized = apply(tfidf_matrix, 1, function(row) row / norm(row, type="2"))
tfidf_normalized = t(tfidf_normalized)

# Get the corresponding vector in word space
user_doc = as.numeric(t(tfidf_normalized) %*% user)
user_doc = user_doc / norm(user_doc, type="2")

# Calculate the user preference
user_prefs = normalized_matrix %*% user_doc
user_prefs

# Filter out documents user has already selected
user_prefs = user_prefs[!rownames(user_prefs) %in% sample_docs, ]
n_recommendations = 5
top_recommendations = sort(user_prefs, decreasing = TRUE)[1:n_recommendations]
top_recommendations = names(top_recommendations)
top_recommendations