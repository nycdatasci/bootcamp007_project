#
# Utility script for doing cluster analysis on NYC tree data
#
library(dplyr)
library(cluster)
library(fpc)
library(ggplot2)
#library(ggfortify)

# load the train data to get the clusters on
loadTreeData = function() {
  df = read.csv("../raw_data/trees_2015_train.csv")
  trees_2015 <<- select(df, -tree_id, -year, -spc_common)
  trees_2015r <<- select(df, -tree_id, -year, -spc_common, -boro_name, -address, -zipcode, -block_code)
  sidewalk.r2 <<- data.frame(trees_2015r$sidewalk)
  trees_2015r2 <<- select(trees_2015r, -sidewalk)
}

# function to get gowers distance matrix
createGDM = function(trees.df) {
  trees_gdm <<- daisy(trees.df, metric = "gower")
}

# attempt to find the number of clusters
findPAMClusters = function() {
  asw <<- numeric(10)
  
  ## Note that "k=1" won't work!
  for (k in 2:length(asw)) {
    cat("Testing with ", k, "clusters ...\n")
    asw[k] <- pam(trees_gdm, k)$silinfo$avg.width
    cat("Average width: ", asw[k], "\n\n")
  }
  
  k.best <<- which.max(asw)
  cat("\nsilhouette-optimal number of clusters:", k.best, "\n")
  
  plot(1:length(asw), asw, type= "h", main = "pam() clustering assessment",
       xlab= "k  (# clusters)", ylab = "average silhouette width")
  axis(1, k.best, paste("best",k.best,sep="\n"), col = "red", col.axis = "red")
}

# just generate many plots from sample and see how the clusters
# change
sampleClusters = function(nruns, df) {
  set.seed(123)
  best.ks <<- numeric(nruns)
  
  for (i in 1:nruns) {
    cat("@ Loop #", i, "\n\n")
    
    createGDM(df)
  
    # get the pam clusters
    findPAMClusters()
    
    best.ks[i] = k.best
    
    #pamx = pam(trees_gdm, k.best)
    #clusplot(pamx, color = TRUE, main = paste("K = ", k.best))
  }
  avg.best.ks <<- as.integer(mean(best.ks))
  cat("Average of best ks:", avg.best.ks)
}

# function to create merge data fram containing clustering
# feature from pam function
mergeClusterInfo = function(clustering) {
  dfc = data.frame(clustering)
  
  # switch the clustering so the odering matches up with 
  # with the Damage and No Damage factor levels
  #dfc$clustering = ifelse(dfc$clustering == 1, 2, 1)
  
  dfc$clustering = as.factor(dfc$clustering)
  
  # merge and check to see if to add the sidewalk column
  sdf <- merge(sampleTrees, dfc, by=0, all=TRUE)
  if (!("sidewalk" %in% colnames(sdf))) {
    sdf$sidewalk = sidewalk.r2[sindex, 1]
  }
  
  merged.df <<- select(sdf, -Row.names)  
}

# do chi squared test to check for independence of between
# clusters found by pam and the sidewalk classifcation 
checkIndependence = function() {
  tbl = table(merged.df$sidewalk, merged.df$clustering)
  chisq.test(tbl)  
}

# plot how the data clustered vs the sidewalk damage
# classification
plotClusterVsSidewalk = function() {
  plot1 <<- ggplot(merged.df, aes(x=longitude, y=latitude, color=clustering)) + geom_point()
  plot2 <<- ggplot(merged.df, aes(x=longitude, y=latitude, color=sidewalk)) + geom_point()
}

# generate dendrograms based on clustering. 
# We assume only two clusters
createDendrograms = function() {
  # split data base on clustering
  cls = levels(merged.df$clustering)
  for (k in cls) {
    cat("Create dendrogram for cluster", k, "\n")
    
    df = filter(merged.df, clustering == k)
    createGDM(df)
    
    hc.c = hclust(trees_gdm, method="complete")
    hcd = as.dendrogram(hc.c)
    plot(hcd, main = paste("Dendrogram Cluster # ", k))
    
    cat("plotting done ...")
  }
}
createDendrograms()

# run the script now
loadTreeData()

start.time <- Sys.time()
sindex = sample(nrow(trees_2015), 200)
sampleTrees <- trees_2015r[sindex, ]
sampleClusters(2, sampleTrees)

end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken

# # do some plotting
pamx = pam(trees_gdm, avg.best.ks)
mergeClusterInfo(pamx$clustering)
#clusplot(pamx, color = TRUE, labels = 4, lines = 0)
#plotClusterVsClass(pamx$clustering)



#jpeg('rplot.jpg', width = 6, height = 6, units = 'in', res = 200)
#plot(silhouette(pamx),  col = c(4,2)) 
#plot(pamx)
#dev.off()

#hc.trees <- trees_2015r[sample(nrow(trees_2015), 100), ]
#createGDM(hc.trees)
#hc.m = hclust(trees_gdm, method="median")
#hc.s = hclust(trees_gdm, method="single")
#hc.c = hclust(trees_gdm, method="complete")
#plot(hc.c, hang = -1)

#hcd = as.dendrogram(hc.c)
#plot(hcd)
#cut.hcd = cut(hcd, h = 0.525)