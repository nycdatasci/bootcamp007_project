Needed <- c("tm", "SnowballCC", "RColorBrewer", "ggplot2", "wordcloud", "biclust", "cluster", "igraph", "fpc")   
install.packages(Needed, dependencies=TRUE)   

doc1 <- "Stray cats are running all over the place. I see 10 a day!"
doc2 <- "Cats are killers. They kill billions of animals a year."
doc3 <- "The best food in Columbus, OH is   the North Market."
doc4 <- "Brand A is the best tasting cat food around. Your cat will love it."
doc5 <- "Buy Brand C cat food for your cat. Brand C makes healthy and happy cats."
doc6 <- "The Arnold Classic came to town this weekend. It reminds us to be healthy."
doc7 <- "I have nothing to say. In summary, I have told you nothing."

doc.list <- list(doc1, doc2, doc3, doc4, doc5, doc6, doc7)
N.docs <- length(doc.list)
names(doc.list) <- paste0("doc", c(1:N.docs))

query <- "Healthy cat food"

library(tm)

my.docs <- VectorSource(c(doc.list, query))
my.docs$Names <- c(names(doc.list), "query")

my.corpus <- Corpus(my.docs)
my.corpus

my.corpus <- tm_map(my.corpus, removePunctuation)
my.corpus[[1]]$content

library(SnowballC)

my.corpus <- tm_map(my.corpus, stemDocument)
my.corpus[[1]]

my.corpus <- tm_map(my.corpus, removeNumbers)
my.corpus <- tm_map(my.corpus, content_transformer(tolower))
my.corpus <- tm_map(my.corpus, stripWhitespace)
my.corpus <- tm_map(my.corpus, function(x) removeWords(x, stopwords("english")))
my.corpus[[5]]$content

terms <-DocumentTermMatrix(my.corpus,control = list(weighting = function(x) weightTfIdf(x, normalize = TRUE)))
inspect(terms)

dist

