
# This script does the following:
# 1. Read all t_ files of lending club data
# 2. Do some basic filtering
# 3. Select a sample of the data
# 4. Write sampled data to one file


library("dplyr", lib.loc="/Library/Frameworks/R.framework/Versions/3.2/Resources/library")

# "t_" files have had last two rows stripped out with awk code (control rows)

allFiles = c('t_LoanStats 2012-2013.csv')
             
# allFiles = c('t_LoanStats 2007-2011.csv',
# 't_LoanStats 2012-2013.csv',
# 't_LoanStats 2014.csv',
# 't_LoanStats 2015.csv',
# 't_LoanStats 2016Q1.csv',
# 't_LoanStats 2016Q2.csv'
# )

wd = '~/R files/lendingClub'
imptrows = 40000
# tfile = "loans40k.csv"
tfile = "Loans2012-2013.csv"
writeHeaderFlg = T

setwd(wd)
# list of columns to extract from data files
r2x = read.table("rows2Extract.csv",sep=",",quote="'", stringsAsFactors = FALSE)
# first row contains source columns
sel1 = as.character(r2x[1,])
# second row contains new names
tgtnames = as.character(r2x[2,])


#columns to be appended for files that don't have fico scores
fico = c('fico_range_high', 'fico_range_low','last_fico_range_high', 'last_fico_range_low')


# this loops through all files and appends them to the "tfile". 
# It also adjusts the number of columns to be the superset of all the source files' columns

for (f in allFiles) {
  print(paste("Working on file", f))
  
  l  <- read.csv(f, skip=1, quote="\"") # one control row about the column headers
  
  # if not the first file, then don't write headers
  if (f != allFiles[1]) {
    writeHeaderFlg = F
  }

  # if the fico scores are missing from the source file, drop them from the select clause
  if (ncol(l)< 115) {
    sel = sel1[!(sel1 %in% fico)]
  } else {
    sel = sel1
  }
  
  # remove large unverified incomes
  lsub <- subset(l, 
                 application_type=='INDIVIDUAL'
                 & !(annual_inc>250000 & verification_status=='Not Verified'),
                 select = sel)
 # lsub <- sample_n(lsub, imptrows)
  
  # now that we've got a smaller set of data, if the fico scores are missing then 
  # initialize a dummy matrix of scores with NAs and append to the source data
  if (ncol(l) < 115) {
    m = matrix(rep(0,4*nrow(lsub)), nrow = nrow(lsub), ncol=4)
    m[] = NA
    colnames(m) = fico
    lsub = cbind(lsub, as.data.frame(m))
  }
  
  # rename headers
  colnames(lsub)<-tgtcnames
  
  # write data to consolidated file
  # append = !writeHeaderflg b/c if we're not writing headers, 
  # we are writing something other than the first file
  write.table(lsub, tfile, col.names = writeHeaderFlg, qmethod="double", row.names=F, append=!writeHeaderFlg,sep=";")
}

remove (l)
remove(lsub)
remove(allFiles)