healthdf2 <- healthdf[,c(1,62:63,5:61)]

healthreshape <- as.data.frame(t(healthdf2))

gsub('X', '', healthreshape[, "49"])
years = gsub('X', '', names(healthreshape[, "49"]))


