# Do statistical test

# Get the top n most similar authors
# author_name - string
# n - number of similar authors
# returns - names of authors
get_similar_authors = function(author_name, n=10){
  most_similar = sort(similarity_matrix[author_name, ], decreasing=TRUE)
  most_similar = most_similar[-1] # exclude top element
  return(names(most_similar[1:n]))
}

occ = pantheon$occupation[1]
for(occ in unique(pantheon$occupation)){
  print(occ)
  # Get similarity submatrix
  authors = pantheon %>% filter(occupation==occ) %>% select(name)
  authors = authors %>% filter(name %in% quotes$author)
  submatrix = similarity_matrix[authors$name, authors$name]
  # compute mean similarity
  mean_similarity = mean(submatrix)
  mean_similarity
  # Get rest of matrix
  others = pantheon %>% filter(occupation!=occ) %>% select(name)
  others = others %>% filter(name %in% quotes$author)
  other_submatrix = similarity_matrix[others$name, others$name]
  mean(other_submatrix)
  print(t.test(submatrix, other_submatrix, "greater"))
}

# Better idea: Perform KNN using similarity metric
# See how well the model performs

# Load the data
setwd('~/Courses/nyc_data_science_academy/projects/web_scraping/data/cleaned_data')
pantheon = read.csv('pantheon.csv', stringsAsFactors = FALSE)
industries = pantheon %>% filter(name %in% colnames(similarity_matrix)) %>% select(name, industry)
load('similarity_matrix.RData')

# Perform 1-NN using the industry
perform_industry_nn  = function(author, k){
  industry = industries$industry[industries$name==author]
  sim_authors = get_similar_authors(author, k)
  sim_industries = industries$industry[industries$name %in% sim_authors]
  sim_industry = max(sim_industries)
  return(industry==sim_industry)
}

authors = industries$name
sum(unlist(lapply(authors, perform_industry_nn, 1))) / length(authors)
View(industries %>% group_by(industry)  %>% tally()) # baseline is choosing 'FILM AND THEATRE'
# WE get ~ 60% accuracy, which isn't great, but considering the baseline is 30%, 
# we have some confidence it works well. Also note that it shouldn't be 100% because
# Similar thinkers are not necessarily in the same industry e.g. philosophers and scientists



