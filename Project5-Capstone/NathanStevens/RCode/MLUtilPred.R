#
# Script for connecting to the desktop java application to
# make prediction base on size of tree
#
library(dplyr)
library(caret)
library(xgboost)
library(ModelMetrics)
library(Rserve)

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
    if(cn != '.outcome') {
      indexes = append(indexes, getColIndex(cn, df))
    }
  }
  
  return(indexes)
}

# load of the model and data
loadTreeData = function() {
  trees_2015 <<- read.csv("../raw_data/trees_2015.csv")
  
  # load the dead trees data
  trees_dead <<- read.csv("../raw_data/trees_2015_dead.csv")
  
  # load the min and max values
  species_info <<- groupBySpecies(trees_2015)
  
  # load leafsnag species information data
  leafsnap_info <<- read.csv("../raw_data/leafsnap.csv")
  
  info = paste("Loaded tree data", nrow(trees_2015), nrow(trees_dead))
  return(info)
}

# create the test data matrix
createPredictionDM = function(df) {
  df <- select(df, -tree_id, -year, -spc_common, -address, -zipcode, -block_code)
  dm <- model.matrix(sidewalk ~ ., data = df)
  #preProc <- preProcess(dm, method = "zv")
  #dm <- predict(preProc, dm)
  dm = dm[, getColIndexes(modelCN, dm)]
  return(dm)
}

# plot a particular feature. this needs debuging
plotPrediction = function(df) {
  # let draw this plot to a file so it can be read by the client app
  png(file='predictionPlot.png',width=800,height=600,res=72)
  
  print(ggplot(data = df, aes(x = spc_common, y= tree_dbh, fill = factor(year), color = sidewalk)) + 
    geom_bar(stat = "identity", position = position_dodge()) + scale_fill_brewer())
  
  dev.off()
}

# return a filtered data frame with trees from around 
# a given location
filterByLocation = function(lng, lat) {
  prec = 0.0015
  df <- filter(trees_2015, abs(longitude - lng) <= prec & abs(latitude - lat) <= prec)
  return(df)
}
#df = filterByLocation(-73.844, 40.723)

# filter dead trees by zip codes
filterByZipCode = function(zc) {
  df <- filter(trees_dead, zipcode == zc)
  df <- select(df, -block_code, -sidewalk)
  df <- df[order(df$tree_id), ]
  return(df)  
}

# filter live trees by zipcode
filterTreesByZipCode = function(zc) {
  df <- filter(trees_2015, zipcode == zc)
  return(df)  
}

# filter by boro
filterByBoro = function(boro) {
  df <- filter(trees_dead, boro_name == boro)
  return(df)
}

# get the zip codes in a boro
getZipCodes = function(boro) {
  df = filter(trees_dead, boro_name == boro)
  zipcodes = unique(df$zipcode)
  return(zipcodes)
}

# group data frame by species and gather the statics
groupBySpecies = function(df) {
  df = group_by(df, spc_latin, spc_common)
  sdf = dplyr::summarise(df, total = n(), 
                         min_dbh = min(tree_dbh),
                         mean_dbh = mean(tree_dbh),
                         median_dbh = median(tree_dbh),
                         max_dbh = max(tree_dbh))
  sdf = sdf[order(-sdf$total), ]
  sdf$spc_latin = as.character(sdf$spc_latin)
  sdf$spc_common = as.character(sdf$spc_common)
  return(sdf)
}

# function to return the species in a particular zipcode
getSpeciesByZipCode = function(zc) {
  df <- filter(trees_2015, zipcode == zc)
  return(groupBySpecies(df))
}

# get the tree diameter by using a function based on the
# species
getTreeDiameter = function(species, year) {
  dbh = 1
  
  # based on the species compute the dbh based year
  if (species == 'PLATANUS X ACERIFOLIA') {
    dbh = 2.40322 + (1.2942*year) + -0.00705*(year^2)
  } else if (species == 'GLEDITSIA TRIACANTHOS') {
    dbh = exp(1.68387 + 1.59967 * log(log(year + 1) + (0.06782/2)))
  } else if (species == 'PYRUS CALLERYANA') {
    dbh = 4.13514 + 1.2698*year
  } else if (species == 'QUERCUS PALUSTRIS') {
    dbh = 2.85629 + 1.29969*year
  } else if (species == 'ACER PLATANOIDES') {
    dbh = 5.61705 + 0.91636*year
  } else if (species == 'TILIA CORDATA') {
    dbh = 2.70741 + 1.43292*year + -0.01191*year^2 + 0.00006*year^3
  } else if (species == 'PRUNUS') {
    dbh = 3.606 + 1.53283*year
  } else if (species == 'ZELKOVA SERRATA') {
    dbh = 2.17317 + 1.32424*year
  } else if (species == 'GINKGO BILOBA') {
    dbh = 1.91918 + (1.0947*year) + -0.00307*(year^2)
  } else if (species == 'ACER RUBRUM') {
    dbh = 2.64166 + 1.27076*year + -0.01758*year^2 + 0.00012*year^3
  } else if (species == 'FRAXINUS PENNSYLVANICA') {
    dbh = 2.41764 + 1.4626*year + -0.02052*year^2 + 0.00016*year^3
  } else {
    # use a linear model that averages all the linear models
    dbh = 3.575651 + 1.131603*year
  }
  
  #df = filter(species_info, spc_latin == species)
  #med_dbh = df$median_dbh[1]
  
  # just return the median * year
  dbh = ceiling(dbh*0.4)
  return(dbh)
}
#getTreeDiameter('TILIA CO', 300)

# make different prediction based on different species and years
generatePredictions = function(dt.df, species.df, years, blocks) {
  # create dataframe with structure of trees_2015 with same factor
  # levels so when we dummy we get the same results
  pred.df <<- trees_2015[1,]
  
  # use two for loops even though using apply might be faster
  # but we only doing less than ten iterations
  for (i in 1:nrow(species.df)) {
    species = species.df[i,1][[1]]
    species.common = species.df[i,2][[1]]
    
    for(year in years) {
      dt.df$health = as.factor('Good')
      dt.df$year = year
      dt.df$root_stone = blocks
      dt.df$tree_dbh = getTreeDiameter(species, year)
      dt.df$spc_latin = as.factor(species)
      dt.df$spc_common = as.factor(species.common)
      pred.df = rbind(pred.df, dt.df)
    }
  }
  
  # get the data matrix gets generated
  pred.dm <<- createPredictionDM(pred.df)
  
  # now try making prediction
  predicted <- predict(modelFit, pred.dm)
  pred.df$sidewalk = as.character(predicted)
  
  pred.df = pred.df[-1, ] # drop the first column and return df
  return(pred.df)
}

# given a tree id make prediction based aroud
makePrediction = function(tree.id, zc, species.count, blocks) {
  dt.df = filter(trees_dead, tree_id == tree.id)
  
  # get the species which are either neaby the current
  # dead tree or in the same zipcode
  if(zc == -1) {
    nbt.df = filterByLocation(dt.df$longitude, dt.df$latitude)
  } else {
    nbt.df = filterTreesByZipCode(zc)  
  }
  
  # for the found trees get df with species and take the top
  # n species
  species.df = head(groupBySpecies(nbt.df), n = species.count)
  
  # make predictions for 10, 20, 30, 50, 75 years
  years = c(10,20,30,50,75)
  
  cat("Prediction for dead tree#", dt.df$tree_id, ', @"', 
      as.character(dt.df$address), '",# NBT = ', nrow(nbt.df), '\n')
  
  pred.df = generatePredictions(dt.df, species.df, years, blocks)
  pred.df = select(pred.df, -block_code)
  pred.df$sidewalk = as.factor(pred.df$sidewalk)
  
  cat("Done ...\n\n")
  
  return(pred.df)
}

# given a dataframe see howmany damage results are
getDamageCount = function(df) {
  sr = summary(df$sidewalk)
  return(nrow(df) - sr['NoDamage'][[1]])
}

# get information about sidwalk damage
getSidewalkDamage = function() {
  df = filter(trees_2015, sidewalk == 'Damage')
  gdf1 = group_by(df, zipcode)
  sdf1 = dplyr::summarise(gdf1, boro_name = head(boro_name, 1), mean_dbh = mean(tree_dbh), total_damage = n())
  
  gdf2 = group_by(trees_2015, zipcode)
  sdf2 = dplyr::summarise(gdf2, total_mean_dbh = mean(tree_dbh), total_trees = n())
  
  mdf = inner_join(sdf1, sdf2)
  mdf = mutate(mdf, 
               percent_damage = as.integer((total_damage/total_trees)*100), 
               percent_diff = as.integer((total_damage/total_trees)*100 - 40))

  mdf = mdf[order(-mdf$percent_damage), ]
  
  return(mdf)
}

# load the data if needed
if(!exists('trees_2015')) {
  loadTreeData()
}

# load our trained model
if(!exists('modelFit')) {
  load('C:/temp/rdata/glmnetFit.RData')
  modelFit = glmnetFit
  modelCN = colnames(modelFit$trainingData)
  rm(glmnetFit)
}

# make a precition here
# sindex = sample(nrow(trees_dead), 10)
# sample_dead = trees_dead[1:10, ]
# pred.list = list()
# 
# i = 1
# for(id in sample_dead$tree_id) {
#   cat('loop #', i, '\n')
#   pred.list[[i]] = makePrediction(id, 3)
#   i = i + 1
# }

#df01 = makePrediction(453889, 11691, 5, 'Yes')
df01 = makePrediction(453889, -1, 4, 'No')
