#
# Script for conducting eda on data and sending them to Java front end program
#
library(dplyr)
library(caret)
library(utils)

# set the working directory
fn <- function(x) {
  x + 1 # A comment, kept as part of the source
}
wd = getSrcDirectory(fn)
setwd(wd[1])

# given a name get an index
getColIndex = function(cn, df) {
  return (which(colnames(df) == cn))
}

# function to return a vector column index
getColIndexes = function(cns, df) {
  indexes = c()
  
  for(cn in cns) {
    indexes = append(indexes, getColIndex(cn, df))
  }
  
  return(indexes)
}
#getColIndexes(c('cat1', 'cat15'), alls.trainSDF)

# function to sort by a particular column and plot
sortAndPlot = function(cn, skip) {
  index = getColIndex(cn, dm_trees)
  df = dm_trees[order(dm_trees[index]), ]
  plotdf = df[seq(1, nrow(df), skip), ]
  plot(x = 1:nrow(plotdf), y = plotdf$sidewalk)
}
#sortAndPlot('cat112', 100)

# plot a particular feature. this needs debuging
plotFeature = function(cn, skip) {
  plotdf = dm_trees[seq(1, nrow(dm_trees), skip), ]
  
  # let draw this plot to a file now
  png(file='featurePlot.png',width=600,height=500,res=72)
  
  #index = getColIndex(cn, alls.trainSDF)
  #print(boxplot(loss ~ plotdf[,index], data=plotdf, main="Feature vs. Loss", 
  #        xlab=paste("Feature", cn,"Values"), ylab="Log Loss + 1"))
  
  if(grepl('cat', cn)) {
    print(ggplot(data = plotdf, aes_string(x = cn, y = 'loss', fill = cn)) + geom_boxplot())
  } else {
    print(ggplot(data = plotdf, aes_string(x = cn, y = 'loss')) + geom_point() + geom_smooth(method=lm))
  }
  
  dev.off()
}
#plotFeature('cat57', 10)

# load the tree data now
loadTreeData = function() {
  df = read.csv("../raw_data/trees_2015_small.csv")
  trees_2015 <<- select(df, -year, -spc_common, -address, -boro_name, -block_code)
  merge_data <<- select(df, boro_name, sidewalk)
  
  return(paste("Loaded Tree Data, ", nrow(trees_2015), "obs"))
}

# create the dummified data matrix now
createDM = function(test.df) {
  dm <- model.matrix(sidewalk ~ ., data = test.df)
  preProc <- preProcess(dm, method = "zv")
  dm <- predict(preProc, dm)
  dm <- data.frame(dm)
  dm <- merge(dm, merge_data, by=0, all=TRUE)
  dm <- select(dm, -Row.names)
  dm_trees <<- dm[order(dm$sidewalk), ]
}

# plot the tree species using ggplot
plotSpecies = function() {
  df <- data.frame(table(trees_2015$spc_common))
  
  # do bar plot
  ggplot(df, aes(x=reorder(Var1, Freq), y = Freq)) +
  geom_bar(stat="identity") + coord_flip() +
  labs(x = 'Tree Species',y = 'Count') +
  theme(#axis.title.y=element_text(), 
        axis.text.y=element_blank(), 
        axis.ticks.y=element_blank())
  
  # get top 10 trees
  species.df <<- df[order(df$Freq, decreasing = T), ]
}

## load the trees and create the very large data matrix
loadTreeData()
createDM(trees_2015)

## plot the speciest
#plotSpecies()
#head(species.df, 10)