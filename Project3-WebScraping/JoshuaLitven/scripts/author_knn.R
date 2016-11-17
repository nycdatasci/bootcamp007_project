# Script to run K-nn algorithm on the domains of the authors
# using the similarity matrix.
# The assumption is that similar authors are often in the same domain.
# If the similarity matrix reflects true similarity, the model should perform well.

# Load the data
pantheon = read.csv('../shiny/data/cleaned_data/pantheon.csv', stringsAsFactors = FALSE)
load('../shiny/data/cleaned_data/similarity_matrix.RData')

# Get the domain of all authors in the similarity matrix
domains = pantheon %>% filter(name %in% colnames(similarity_matrix)) %>% select(name, domain)

# KNN algorithm using the similarity matrix
perform_author_knn  = function(author, k){
  domain = domains$domain[domains$name==author]
  sim_authors = get_similar_authors(author, k)
  sim_domains = domains$domain[domains$name %in% sim_authors]
  sim_domain = max(sim_domains)
  return(domain==sim_domain)
}

# Perform KNN for varying values of k
authors = domains$name
k_values = 1:10
accuracies = numeric(length(k_values))
for(k in k_values){
  accuracy = sum(unlist(lapply(authors, perform_author_knn, k=k))) / length(authors)
  accuracies[k] = accuracy
  cat("Perform KNN on authors with k=", k, "\n")
}

# Plot the results
library(ggplot2)
ggplot(data = data.frame(k_values, accuracies)) +
  geom_line(aes(x=k_values, y=accuracies)) +
  labs(title="Accuracy of KNN Predicting Author Domains", x="k", y="Accuracy") +
  theme_tufte(base_family = "Arial", base_size = 16, ticks = FALSE)
