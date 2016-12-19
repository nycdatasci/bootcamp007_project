# for(p in glmnet.CN) {
#   if (p %in% dm.CN) {
#     cat(p, "in data to predict\n")
#   } else {
#     cat('\n', p, 'not found')
#   }
# }

#ggplot(data = df01, aes(x = spc_common, y= tree_dbh, fill = factor(year), color = sidewalk)) + 
#  geom_bar(stat = "identity", position = position_dodge()) + scale_fill_brewer()

cv.test = function(x,y) {
  CV = sqrt(chisq.test(x, y, correct=FALSE)$statistic /
              (length(x) * (min(length(unique(x)),length(unique(y))) - 1)))
  print.noquote("Cramér V / Phi:")
  return(as.numeric(CV))
}

cv.test(trees_2015$sidewalk, trees_2015$tree_dbh)
cv.test(trees_2015$sidewalk, trees_2015$health)
cv.test(trees_2015$sidewalk, trees_2015$spc_latin)
cv.test(trees_2015$sidewalk, trees_2015$root_stone)
cv.test(trees_2015$sidewalk, trees_2015$trunk_wire)
cv.test(trees_2015$sidewalk, trees_2015$zipcode)
cv.test(trees_2015$sidewalk, trees_2015$boro_name)

library(ICC)
effort(est.type = "p", x = sidewalk, y = tree_dbh, data = trees_2015)
effort(est.type = "p", x = sidewalk, y = longitude, data = trees_2015)
