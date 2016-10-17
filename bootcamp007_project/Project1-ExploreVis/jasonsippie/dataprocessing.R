
wd = '~/R files/lendingClub'

allFiles = c("Loans2012-2013.csv","loans40k.csv")

setwd(wd)

for (f in allFiles) {
  print(paste("Working on file", f))
  
  # load source file
  l<-read.table(f, sep=";", quote="\"", header=T, comment.char="", encoding="UTF-8", fill=F)
  
  # create new derived columns
  
  # clean up percentages
  l$Trm.int_rate <- as.numeric(sub("%","",l$Trm.int_rate))/100
  
  l$Rev.revol_util <- as.numeric(sub("%","",l$Rev.revol_util))/100
  
  # make loan term numeric
  l$Trm.term <- as.numeric(sub("months","",l$Trm.term))
  
  # make bank card percent utilization a decimal
  l$BC.bc_util<-l$BC.bc_util/100
  
  # calculate utilization of bank cards and credit cards
  l$Tot.avgRevBCUtil = 
    (ifelse(is.na(l$BC.bc_util),0, l$BC.bc_util) + ifelse(is.na(l$Rev.revol_util),0,l$Rev.revol_util))/2
  
  # cast issue date into a date from text
  l$Trm.issue_d <- as.Date(paste(l$Trm.issue_d,"-01",sep=""),"%b-%Y-%d")
  
  # get issue year
  l$Trm.issue_Y <- as.numeric(format(l$Trm.issue_d,"%Y"))
  
  # get year of earliest credit line
  l$Prof.earliest_cr_line_Y <- as.numeric(format(as.Date(paste(l$Prof.earliest_cr_line,"-01",sep=""),"%b-%Y-%d"),"%Y"))
  
  # measure FICO average
  l$Prof.fico_avg <- (as.numeric(l$Prof.fico_range_high) + as.numeric(l$Prof.fico_range_low))/2
  
  # categorize FICO score
  l$Prof.fico_group <- cut(l$Prof.fico_avg, 
                           c(600, 650, 700, 750, 800,850),right=F, 
                           labels=c("Poor","Fair","Good","Very Good","Excellent"))
  
  # set charge off flag
  l$Stat.ChargeOffFlg <- l$Stat.loan_status=="Charged Off"
  
  # loan amount to annual income ratio
  l$Prof.LCLoanIncRatio <- l$Stat.loan_amnt/l$Prof.annual_inc
  
  # total debt to annual income ratio
  l$Prof.TLCLoanIncRatio <- (l$Tot.tot_cur_bal + l$Stat.loan_amnt)/l$Prof.annual_inc
  
  # find FICO outliers
  a<- l %>% group_by(Trm.issue_Y, Trm.grade) %>% mutate(pct_rank = percent_rank(Prof.fico_avg)) %>%ungroup
  
  # get IQR
  aa<- a %>% group_by(Trm.issue_Y, Trm.grade) %>% summarize(iqRange=IQR(Prof.fico_avg, na.rm=T), pct75=quantile(Prof.fico_avg, na.rm=T)[4]) %>% ungroup
  
  # add in IQR to original file
  l<-join(l, aa, by=c("Trm.issue_Y", "Trm.grade"))
  
  # set FICO outlier flag
  l$outlierFlg<-l$Prof.fico_avg > l$iqRange *1.5 + l$pct75
  
  # create hypothetical grade
  
  l$x = factor(l$Trm.grade)
  

  levels(l$x) <- list(
    A = "A",
    A = "B",
    B = "C",
    C = "D",
    D = "E",
    E = "F",
    F = "G")
  
  
  l <- l %>% mutate(hypGrade=ifelse(l$outlierFlg==T, as.character(l$x[]), as.character(l$Trm.grade[])))
  
  
  l$x<-NULL
  
  # peel off only 2013 loans
  if (f=="Loans2012-2013.csv") { l<-subset(l, Trm.issue_Y==2013)}
  
  # generate percentiles
  l <- l %>% group_by(Trm.issue_Y, 
                         hypGrade) %>% mutate(
                           Stat.loan_amntpctRank = percent_rank(Stat.loan_amnt),
                           Stat.delinq_amntpctRank = percent_rank(Stat.delinq_amnt),
                           Prof.mths_since_last_delinqpctRank = percent_rank(Prof.mths_since_last_delinq),
                           Prof.pub_rec_bankruptciespctRank = percent_rank(Prof.pub_rec_bankruptcies),
                           Prof.annual_incpctRank = percent_rank(Prof.annual_inc),
                           Prof.dtipctRank = percent_rank(Prof.dti),
                           Cnt.open_accpctRank = percent_rank(Cnt.open_acc),
                           inq_last_6mthspctRank = percent_rank(inq_last_6mths),
                           Tot.total_bal_ex_mortpctRank = percent_rank(Tot.total_bal_ex_mort),
                           Tot.tot_hi_cred_limpctRank = percent_rank(Tot.tot_hi_cred_lim),
                           Tot.tot_cur_balpctRank = percent_rank(Tot.tot_cur_bal),
                           Tot.avgRevBCUtilpctRank = percent_rank(Tot.avgRevBCUtil),
                           Rev.revol_utilpctRank = percent_rank(Rev.revol_util),
                           Rev.num_rev_acctspctRank = percent_rank(Rev.num_rev_accts),
                           Prof.earliest_cr_line_YpctRank = percent_rank(Prof.earliest_cr_line_Y),
                           Cnt.pct_tl_nvr_dlqpctRank = percent_rank(Cnt.pct_tl_nvr_dlq), #
                           Cnt.num_satspctRank = percent_rank(Cnt.num_sats), #
                           Cnt.acc_now_delinqpctRank = percent_rank(Cnt.acc_now_delinq), #
                           Cnt.delinq_2yrspctRank = percent_rank(Cnt.delinq_2yrs), #
                           Cnt.num_tl_30dpdpctRank = percent_rank(Cnt.num_tl_30dpd), #
                           Cnt.num_tl_90g_dpd_24mpctRank = percent_rank(Cnt.num_tl_90g_dpd_24m),
                           Prof.mo_sin_old_il_acctpctRank=percent_rank(Prof.mo_sin_old_il_acct),
                           Prof.mo_sin_old_rev_tl_oppctRank=percent_rank(Prof.mo_sin_old_rev_tl_op),
                           Prof.mo_sin_rcnt_rev_tl_oppctRank=percent_rank(Prof.mo_sin_rcnt_rev_tl_op),
                           Prof.mo_sin_rcnt_tlpctRank=percent_rank(Prof.mo_sin_rcnt_tl),
                           Prof.mort_accpctRank=percent_rank(Prof.mort_acc),
                           Prof.mths_since_last_major_derogpctRank=percent_rank(Prof.mths_since_last_major_derog),
                           Prof.mths_since_last_recordpctRank=percent_rank(Prof.mths_since_last_record),
                           Prof.mths_since_rcnt_ilpctRank=percent_rank(Prof.mths_since_rcnt_il),
                           Prof.mths_since_recent_bcpctRank=percent_rank(Prof.mths_since_recent_bc),
                           Prof.mths_since_recent_bc_dlqpctRank=percent_rank(Prof.mths_since_recent_bc_dlq),
                           Prof.mths_since_recent_inqpctRank=percent_rank(Prof.mths_since_recent_inq),
                           Prof.mths_since_recent_revol_delinqpctRank=percent_rank(Prof.mths_since_recent_revol_delinq),
                           Prof.LCLoanIncRatiopctRank = percent_rank(Prof.LCLoanIncRatio),
                           Prof.TLCLoanIncRatiopctRank = percent_rank(Prof.TLCLoanIncRatio)
                         ) %>% ungroup
  
  
  
  write.table(l, paste0("proc_", f), qmethod="double", row.names=F, append=F, sep=";")
  
  rm(l,a, aa)

}

