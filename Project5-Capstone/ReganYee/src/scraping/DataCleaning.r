library(dplyr)
library(stringr)
library(DT)

###########################################################################
# FlightClub --------------------------------------------------------------
###########################################################################
setwd("~/Documents/Project/What Are Those?/scraping_data")
data = read.csv("flightclub.csv", stringsAsFactors = FALSE)

image_list = print(data$image, quote=FALSE)

## Data Cleanup ------------------------------------------------------------
## Remove leading and trailing white spaces from the product name.
data$product_name = str_trim(data$product_name)

###########################################################################
# Footlocker --------------------------------------------------------------
###########################################################################
footlocker = read.csv("footlocker.csv", stringsAsFactors = FALSE)

## Data Cleanup
footlocker$price = sapply(strsplit(footlocker$price, "<b>\\$"), function(x){x[2]})
footlocker$price = sapply(strsplit(footlocker$price, "</b>"), function(x){x[1]})

footlocker$image = paste0("https:", footlocker$image)

footlocker$brand = sapply(strsplit(footlocker$product_name, " "), function(x){x[1]})

footlocker$brand[which(footlocker$brand == "New")] = "New Balance"
footlocker$brand[which(footlocker$brand == "Under")] = "Under Armor"

###########################################################################
# Merge Data --------------------------------------------------------------
###########################################################################

df = rbind(data,footlocker)

## Primary key to join image file and R record.
image_list = print(df$image, quote=FALSE)
df$photo_index = seq(1:length(image_list))
df$photo_name = paste0(as.character(df$photo_index),".jpg")
df$brand = toupper(df$brand)

saveRDS(df, file="final_df.RDS")


traincsv = df %>% 
           mutate(subject = as.character(sample(1:10,nrow(df), replace=TRUE))) %>% 
           select(subject, brand, photo_name) %>% 
           filter(brand %in% c('NIKE', 'JORDAN', 'ADIDAS', 'NEW BALANCE'))
write.csv(traincsv, "driver_imgs_list.csv", row.names=FALSE, quote = FALSE)

###########################################################################
# EDA ---------------------------------------------------------------------
###########################################################################

## Show the count of brands sorted descending.
datatable(df %>% group_by(brand) %>% summarize(count=n()) %>% arrange(desc(count)), width="400px")
?datatable

## Give me all the Jordans in my dataset.
jordans = df %>% filter(brand=="JORDAN")
jordans_images = jordans %>% select(image, photo_name)

# ## Code to Download Jordans Images
# setwd("~/Documents/Project/What\ Are\ Those?/classes/jordans")
# 
# for(i in seq(1:nrow(jordans_images))){
#   print(paste0(paste0(i,"/"),as.character(nrow(jordans_images))))
#   download.file(jordans_images$image[i], jordans_images$photo_name[i])
# }

## Give me all the Nikes in my dataset.
nike = df %>% filter(brand=="NIKE")
nike_images = nike %>% select(image, photo_index, photo_name)

# ## Code to Download Nike Images
# setwd("~/Documents/Project/What\ Are\ Those?/classes/nike")
# 
# for(i in seq(1:nrow(nike_images))){
#   print(paste0(paste0(i,"/"),as.character(nrow(nike_images))))
#   download.file(nike_images$image[i], nike_images$photo_name[i])
# }

## Give me all the Adidas Shoes in my dataset.
adidas = df %>% filter(brand=="ADIDAS")
adidas_images = adidas %>% select(image, photo_index, photo_name)

# ## Code to Download Adidas Images
# setwd("~/Documents/Project/What\ Are\ Those?/classes/adidas")
# 
# for(i in seq(330,nrow(adidas_images))){
#   print(paste0(paste0(i,"/"),as.character(nrow(adidas_images))))
#   download.file(adidas_images$image[i], adidas_images$photo_name[i])
# }

## Give me all the New Balance Shoes in my dataset.
nb = df %>% filter(brand=="NEW BALANCE")
nb_images = nb %>% select(image, photo_index, photo_name)

# ## Code to Download New Balance Images
# setwd("~/Documents/Project/What\ Are\ Those?/classes/newbalance")
# 
# for(i in seq(1,nrow(nb_images))){
#   print(paste0(paste0(i,"/"),as.character(nrow(nb_images))))
#   download.file(nb_images$image[i], nb_images$photo_name[i])
# }

# Eigenshoe ---------------------------------------------------------------------
pixels = read.csv("../pixels.csv")

jordan0 = pixels %>% filter(brand == 'Nike')
jordans = jordan0[-22501]
meanjordan = rowMeans(t(jordans))
j0 = jordans - meanjordan
pc = prcomp(j0, center=FALSE, scale. = FALSE)
u_unscaled <- as.matrix(j0) %*% pc$rotation

# singular value decomposition of data
sv <- svd(j0)
# left eigenvalues are stored in matrix "u"
u <- sv$u

# display first 6 eigenfaces
pc$x
show_image(pc$x[, 1])


# create grey scale color map
greys <- gray.colors(256, start = 0, end = 1)
# convenience function to plot pets
show_image <- function(v, n = 150, col = greys) {
  # transform image vector back to matrix
  m <- matrix(v, ncol = n, byrow = TRUE)
  # invert columns to obtain right orientation
  # plot using "image"
  image(m[, nrow(m):1], col = col, axes = FALSE)
}
# plot average shoe
for (i in list(meanjordan)) {
  show_image(i)
}


