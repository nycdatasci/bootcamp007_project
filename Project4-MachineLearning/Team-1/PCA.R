t = read.csv("train.csv")
summary(t)
library(psych) 
install.packages("caret")
library(caret)
binary_cat = model.matrix(loss ~ ., data = t)
binary_cat_df = as.data.frame(binary_cat)
str(binary_cat_df, list.len = 1050)
binary_cat_df$loss = t$loss
summary(binary_cat_df)

covmat = cov(binary_cat_df)

covmatnum = as.numeric(covmat)

fa.parallel(covmatnum, #The data in question.
            n.obs = 188318, #Since we supplied a covaraince matrix, need to know n.
            fa = "pc", #Display the eigenvalues for PCA.
            n.iter = 10) #Number of simulated analyses to perform.
### I get this error Error in if (dim(x)[1] != dim(x)[2]) { : argument is of length zero so 
## I don't know how to find the right value for k. I'm just going to assume 4 and come back to this

pc_covmat = principal(covmatnum, #The data in question.
                      nfactors = 4, #The number of PCs to extract.
                      rotate = "none")
pc_covmat

factor.plot(pc_covmat, labels = colnames(covmat)) 

#trying it on the raw dataset
t = read.csv("train.csv")
t1 = t

summary(t)
library(psych) 
install.packages("caret")
library(caret)
binary_cat = model.matrix(loss ~ ., data = t)
binary_cat_df = as.data.frame(binary_cat)
str(binary_cat_df, list.len = 1050)
binary_cat_df$loss = t$loss
summary(binary_cat_df)

covmat = cov(binary_cat_df)

covmatnum = as.numeric(covmat)

fa.parallel(covmatnum, #The data in question.
            n.obs = 188318, #Since we supplied a covaraince matrix, need to know n.
            fa = "pc", #Display the eigenvalues for PCA.
            n.iter = 10) #Number of simulated analyses to perform.
### I get this error Error in if (dim(x)[1] != dim(x)[2]) { : argument is of length zero so 
## I don't know how to find the right value for k. I'm just going to assume 4 and come back to this

pc_covmat = principal(covmatnum, #The data in question.
                      nfactors = 4, #The number of PCs to extract.
                      rotate = "none")
pc_covmat

factor.plot(pc_covmat, labels = colnames(covmat)) 
