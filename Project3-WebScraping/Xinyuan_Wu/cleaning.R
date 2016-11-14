setwd("D:/Dropbox/NYC DS Academy/Project 3/Xinyuan_Wu")
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(ggthemes))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(corrplot))
suppressPackageStartupMessages(library(car))

# read datasets
cpu <- read.csv("cpu.csv")
gpu <- read.csv("gpu.csv")

# clean cpu core variable
core <- cpu$core
productname <- cpu$productname
productname <- tolower(productname)
sum(is.na(core))
summary(core)
core <- as.character(core)
core[core == 'Single'] <- '1'
core[core == 'Six'] <- '6'

## extract number of cores from productname
index <- which(grepl("-core", productname) & core == 'None')
namelist <- strsplit(productname[index], ' ')

findcore <- function(x) {
    for (i in x) {
        if (grepl('-core', i)) {
            return(i)
        }
    }
}

imputecore <- sapply(namelist, findcore)
imputecore <- sub('-core', '', imputecore)
imputecore <- c('10', '8', '2', '2', '4', '4', '4', '2', '4', '4', '4', '8','4', '4', '2', 
                '2', '8', '8', '4', '4', '6', '4', '4', '4', '4', '8')
core[index] <- imputecore
cpu$core <- core
cpusub1 <- cpu[!(cpu$core == 'None'), ]
###View(cpusub1)

# clean cpu brand variable
summary(cpusub1$brand)
brand <- tolower(as.character(factor(cpusub1$brand)))
productname <- tolower(cpusub1$productname)
index <- which(brand == '')
namelist <- strsplit(productname[index], ' ')
brand[index] <- sapply(namelist, function(x) x[1])
cpusub1$brand <- brand

# clean cpu freq variable
summary(cpusub1$freq)
freq <- as.character(cpusub1$freq)
index <- which(freq == '')
productname <- cpusub1$productname
list <- productname[index]
missingname <- productname[index]
freq[index] <- c('3.5', '2.0', '2.7', '3.7', '2.9', '3.3', '3.7',
                 '3.1', '3.6', '3.7', '3.6', '3.5', '3.5', '3.8',
                 '3.2', '3.6', '3.2', '3.2', '3.5', '3.1', '3.5', 
                 '3.5', '3.5', '3.2', '4.0', '3.4', '3.5', '4.0')
freq <- gsub(' ', '', gsub('GHz', '', freq))

findfreq <- function(x) {
    if (substr(x, 4, 4) %in% 1:9) {
        return(substr(x, 1, 4))
    }
    return(substr(x, 1, 3))
}

freq <- sapply(as.list(freq), findfreq)
cpusub1$freq <- freq
###View(cpusub1)

# clean cpu price variable
price <- as.numeric(as.character(gsub(',', '', cpusub1$price)))
cpusub1$price <- price

# clean cpu rating variable
rating <- as.character(cpusub1$rating)
index <- which(rating == 'no rating')
noratingurl <- as.character(cpusub1$url)[index]
rating[index] <- c('4', '4', '4', '5', '4', '4', '4', '4', '4', '4',
                   '4', '4', '4', '4', '4', '4', '4', '4', '4', '5',
                   '5', '4', '4', '5', '4', '4', '4', '5', '4', NA, 
                   '4', '4', '4', '4', '4', '5', '5', '4', '4', '4',
                   '4', '4', '4', '5', '4', '4', '5', '5', '4', '4',
                   NA, '4', '5', '5', '4', '4', '4', '4', '5')
rating <- as.numeric(gsub('Rating \\+ ', '', rating))
rating[which(is.na(rating))] <- 4
cpusub1$rating <- rating
###View(cpusub1) 

# clean cpu power variable
power <- as.character(cpusub1$power)
index <- which(power == '')
nopowerurl <- as.character(cpusub1$url)[index]
power[index] <- c('130W', NA, NA, NA, NA, '65W', NA, NA, '37W', NA,
                  NA, '115W', NA, '65W', '65W', NA, NA, '65W', '91W', '125W',
                  '95W', '65W', '54W', '53W', '95W', NA, '65W', '65W', '95W', '88W',
                  '65W', NA, NA, '125W', NA, '84W', '77W', '125W', NA, NA)
index2 <- which(is.na(power))
productname[index2]
cpusub1$rank[index2]
power[index2] <- c(NA, NA, NA, NA, NA, NA, NA, NA, '95W', '53W',
                   '95W', '125W', '53W', '105W', '88W', '65W', '84W')
power <- as.numeric(gsub('W', '', power))
cpusub1$power <- power
cpusub2 <- cpusub1[!is.na(cpusub1$power), ]   # remove obs that are still NA
cpusub2 <- cpusub2[!(cpusub2$brand == 'hp' | cpusub2$brand == 'lenovo'), ]

###View(cpusub2)

# clean cpu productname variable
cpusub2$productname <- as.character(cpusub2$productname)
# clean cpu series variable
series <- as.character(cpusub2$series)
productname <- cpusub2$productname
series[series == 'Core i7 Extreme Edition'] <- 'Core i7'
series[series == 'Dual-Core'] <- 'Pentium Dual-Core'
series[series == 'Pentium Dual-Core'] <- 'Pentium'
series[series == 'Celeron Dual-Core'] <- 'Celeron'
index <- which(series == '')
series[index] <- c('Pentium', 'A6-Series', 'A4-Series', 'Athlon X4', 'A6-Series',
                   'Athlon X4', 'A10-Series', 'Core i5', 'FX-Series', 'FX-Series',
                   'Core i5', 'Core i3', 'Pentium', 'FX-Series', 'FX-Series',
                   'A8-Series', 'A10-Series', 'FX-Series', 'Core i5', 'Core i5',
                   'FX-Series', 'Core i5', 'FX-Series')
cpusub2$series <- series
###View(cpusub2)

# clean cpu corename variable
corename <- as.character(cpusub2$corename)
index <- which(corename == '')
corename[index] <- c('', 'Richland', '', 'Ivy Bridge', 'Trinity', 
                     '', '', 'Godavari', 'Skylake', 'Vishera',
                     'Vishera', 'Skylake', '', '', 'Vishera',
                     'Vishera', 'Kaveri', 'Kaveri', 'Vishera', '',
                     'Skylake', '', '', '', 'Ivy Bridge', 'Vishera', '')
index2 <- which(corename == '')
corename[index2] <- c('Skylake', 'Kaveri', 'Allendale', 'Kaveri', 'Skylake',
                     'Haswell', 'Devil\'s Canyon', 'Vishera', 'Devil\'s Canyon',
                     'Haswell', 'Carrizo')
cpusub2$corename <- corename
###View(cpusub2)

# clean cpu name variable
name <- as.character(cpusub2$name)
index <- which(name == '')
name[index] <- c('A6-7400', 'A4-6300', 'Athlon X4', 'A6-5400', 'Athlon X4',
                 'A10-7860K', 'Core i5-6600k', 'FX-8320', 'FX-4300', 'Core i5-6500',
                 'Core i3-6098p', 'Pentium G3258', 'FX-8320E', 'FX-8320', 'A8-7600',
                 'A10-7800', 'FX-6300', 'Core i5-4690k', 'Core i5-6500', 'FX-8350',
                 'Core i5-4670k', 'FX-8350')
cpusub2$name <- name
###View(cpusub2)

# formatting cpu data
cpusub2$core <- as.numeric(cpusub2$core)
cpusub2$url <- as.character(cpusub2$url)
cpusub2$l3cache <- as.character(cpusub2$l3cache)
cpusub2$l2cache <- as.character(cpusub2$l2cache)
cpusub2$freq <- as.numeric(cpusub2$freq)
cpusub2$socket <- as.character(cpusub2$socket)
cpu <- cpusub2[-which(grepl('hp', tolower(cpusub2$productname))), ]
###View(cpu)


# clean gpu rating variable
###View(gpu)
rating <- as.character(gpu$rating)
rating <- as.numeric(gsub('Rating \\+ ', '', rating))
gpu$rating <- rating

# clean gpu chipmake variable
chipmake <- tolower(as.character(gpu$chipmake))
productname <- as.character(gpu$productname)
index <- which(chipmake == '')
chipmake[index] <- c('nvidia', 'nvidia', NA, 'nvidia', 'nvidia', 'nvidia', 'nvidia',
                     'nvidia', 'nvidia', 'nvidia', 'nvidia', 'amd', 'nvidia', 'nvidia',
                     'amd', 'amd', 'nvidia', 'nvidia', 'amd', 'nvidia', 'nvidia',
                     'nvidia', 'amd', 'nvidia', 'amd', 'amd', 'amd', 'nvidia',
                     'nvidia', 'nvidia', 'nvidia', 'nvidia', 'nvidia', 'nvidia', 'nvidia',
                     'nvidia', 'amd', 'nvidia', 'amd')
gpu$chipmake <- chipmake
gpu1 <- gpu[!is.na(chipmake), ]

# clean gpu brand variable
brand <- tolower(as.character(gpu1$brand))
productname <- as.character(gpu1$productname)
url <- as.character(gpu1$url)
index <- which(brand == '')
brand[index] <- c('NA', 'inno3d', 'NA', 'evga', 'inno3d', 'NA', 'inno3d', 'msi', 'inno3d', 'inno3d',
                  'NA', 'inno3d', 'evga', 'evga', 'inno3d', 'NA', 'sapphire', 'gigabyte', 'sapphire', 'NA',
                  'NA', 'NA', 'pny', 'inno3d', 'inno3d', 'msi')
brand[brand == 'amd'] <- c('NA', 'NA')   # dell graphic card, fuck off.
brand[brand == 'colorful'] <- c('NA')   # shen me ji ba wan yi
brand[brand == 'hp'] <- c('NA', 'NA')   # hp graphic card? cao ni ma
brand[brand == 'jaton'] <- c('NA', 'NA', 'NA')
brand[brand == 'laintek'] <- c('inno3d', 'asus', 'NA', 'NA')
brand[brand == 'pny technology'] <- 'pny'
brand[brand == 'unbranded/generic'] <- 'NA'
brand[brand == 'vamery gtx650ti'] <- 'NA'
brand[brand == 'wintek technology int\'l limited'] <- 'NA'
gpu1$brand <- brand
gpu2 <- gpu1[!(gpu1$brand == 'NA'), ]
###View(gpu2)

# clean gpu memorysize variable
memory <- as.character(gpu2$memorysize)
productname <- as.character(gpu2$productname)
index <- which(memory == '')
memory[index] <- c('4GB', '8GB', '4GB', '8GB', '8GB', '4GB', '4GB', '4GB', '8GB', '4GB',
                   '8GB', '8GB', '8GB', '4GB', '4GB', '8GB', '2GB', '4GB', '12GB', '8GB', '6GB')
gpu2$memorysize <- memory
gpu3 <- gpu2[!(memory == '64MB' | memory == '512MB'), ]

findmemory <- function(x) {
    if (substr(x, 2, 2) %in% 1:9) {
        return(substr(x, 1, 2))
    }
    return(substr(x, 1, 1))
}

memory <- sapply(as.list(gpu3$memorysize), findmemory)
gpu3$memorysize <- as.numeric(memory)
###View(gpu3)

# clean gpu boostclock variable
boostclock <- as.character(gpu3[, 6])
gpu3 <- gpu3[, -6]   ### this variable is highly correlated with coreclock

# clean gpu coreclock variable
coreclock <- as.character(gpu3$coreclock)
url <- as.character(gpu3$url)
coreclock2 <- ifelse(coreclock == '', boostclock, coreclock)
index <- which(coreclock2 == '')
coreclock2[index] <- c(rep('NA', 37), '730 MHZ')
gpu3$coreclock <- coreclock2
gpu4 <- gpu3[!(coreclock2 == 'NA'), ]
coreclock3 <- gpu4$coreclock
coreclock3[23] <- '1710 MHZ'
clocklist <- str_extract_all(coreclock3, '[0-9][0-9][0-9][0-9]?')

findclock <- function(x) {
    return(max(as.numeric(x)))
}

gpu4$coreclock <- sapply(clocklist, findclock)
### View(gpu4)

# clean gpu url variable
gpu4$url <- as.character(gpu4$url)

# clean gpu memorytype variable
mtype <- as.character(gpu4$memorytype)
url <- gpu4$url
index <- which(mtype == '')
mtype[index] <- c('DDR5', 'GDDR5', 'GDDR5', 'DDR3')
gpu4$memorytype <- mtype

# clean gpu memoryclock variable
gpu5 <- gpu4[, -9] ### not important
###View(gpu5)

# clean gpu model variable
gpu6 <- gpu5[, -11] ### does not tell more information
###View(gpu6)

# clean gpu memoryinterface variable
minterface <- as.character(gpu6$memoryinterface)
minterface[minterface == 'GDDR5'] <- '128-Bit'
minterface[minterface == ''] <- c('256-Bit', '256-Bit', 'NA', '4096-Bit', '256-Bit', 'NA', '128-Bit')
gpu6$memoryinterface <- minterface
gpu7 <- gpu6[!(gpu6$memoryinterface == 'NA'), ]
###View(gpu7)

# clean gpu gpu variable
gpucol <- as.character(gpu7$gpu)
gpucol[gpucol == 'GeForce GTX 980 Ti Hybrid'] <- 'GeForce GTX 980 Ti'
gpucol[gpucol == 'GTX 1080'] <- 'GeForce GTX 1080'
gpucol[gpucol == 'GeForce GTX 1080 FE'] <- 'GeForce GTX 1080'
gpucol[gpucol == 'GeForce GTX 1060 FTW+ Gaming'] <- 'GeForce GTX 1060'
gpucol[gpucol == 'GeForce GTX 1070 GAMING ACX 3.0 Black Edition'] <- 'GeForce GTX 1070'
gpucol[gpucol == 'GeForce GTX 1070 Hybrid Gaming'] <- 'GeForce GTX 1070'
gpucol[gpucol == 'GeForce GTX 1070 FE'] <- 'GeForce GTX 1070'
gpucol[gpucol == 'GeForce GTX 1070 GAMING'] <- 'GeForce GTX 1070'
gpucol[gpucol == 'GeForce GTX 1060 SC Gaming'] <- 'GeForce GTX 1060'
gpucol[gpucol == 'GeForce GT 740 Superclocked'] <- 'GeForce GT 740'
gpucol[gpucol == 'GeForce GTX 750 Ti Superclocked'] <- 'GeForce GTX 750 Ti'
gpucol[gpucol == 'GeForce GTX 750Ti GAMING'] <- 'GeForce GTX 750 Ti'
gpucol[grep('1060', gpucol)] <- 'GeForce GTX 1060'
gpucol[gpucol == ''] <- c('GeForce GTX 960', 'GeForce GTX 960', 'GeForce GTX 960', 
                          'GeForce GTX 960', 'GeForce GTX 970')
gpu7$gpu <- gpucol

# clean gpu productname variable
pname <- as.character(gpu7$productname)
pname[57] <- 'MSI GTX1060 3GT OC 3GDR5, DUAL FAN, DP,HDMI, DL-DVI-D, PCIE\n(GTX1060 3GT OC 3GDR5)'
gpu7$productname <- pname

# clean gpu price variable
price <- as.character(gpu7$price)
price <- as.numeric(gsub(',', '', price))
price[192] <- 246.99
gpu7$price <- price

# formatting gpu data
gpu <- gpu7[!(gpu7$chipmake == 'ati'), ]
###View(gpu)

# multiplot function
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
    library(grid)
    
    # Make a list from the ... arguments and plotlist
    plots <- c(list(...), plotlist)
    
    numPlots = length(plots)
    
    # If layout is NULL, then use 'cols' to determine layout
    if (is.null(layout)) {
        # Make the panel
        # ncol: Number of columns of plots
        # nrow: Number of rows needed, calculated from # of cols
        layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                         ncol = cols, nrow = ceiling(numPlots/cols))
    }
    
    if (numPlots==1) {
        print(plots[[1]])
        
    } else {
        # Set up the page
        grid.newpage()
        pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
        
        # Make each plot, in the correct location
        for (i in 1:numPlots) {
            # Get the i,j matrix positions of the regions that contain this subplot
            matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
            
            print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                            layout.pos.col = matchidx$col))
        }
    }
}















