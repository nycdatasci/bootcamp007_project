setwd("/Users/apple/Desktop")
CCM = read.csv("Chemicals_in_Cosmetics.csv", header = TRUE)
library("dplyr")
library("ggplot2")
library("tm")
library("wordcloud")

###################     Primtype_Bar chart    ###########################
CCMprim=count(CCM,PrimaryCategory) %>% arrange(desc(n))

CCMprim$PrimaryCategory=factor(CCMprim$PrimaryCategory, levels = reorder(CCMprim$PrimaryCategory, -CCMprim$n))


primcountplot= ggplot(data= CCMprim, aes(x=reorder(PrimaryCategory,-n), y=n))+
  geom_bar(aes(fill=PrimaryCategory), stat="identity")+ 
  ggtitle("Number of Cosmetic Product being Reported by Category")+ 
  ylab("Number of Products") +
  xlab("Primary Category")+
  theme_hc(bgcolor = "darkunica") +
  scale_colour_hc("darkunica")+
  theme(legend.position = "right")+
  theme(text = element_text(size=10, color="#e6ffff"),
        axis.text.x = element_text(angle=45, hjust=1, color = "#e6ffff"),
        axis.text.y = element_text(color = "#e6ffff"),
        plot.title= element_text(face="bold")) +
        scale_x_discrete( labels=c("Non-permenant Makeup","Nail",
                                      "Skin Care","Sun-Related","Bath",
                                       "Hair Coloring","Hair Care",
                                      "Tattoos and Perm. Makeup","Personal Care",
                                       "Fragrances","Oral Hygiene","Shaving","Baby"))+
       scale_fill_discrete( labels=c("Non-permenant Makeup","Nail",
                             "Skin Care","Sun-Related","Bath",
                             "Hair Coloring","Hair Care",
                             "Tattoos and Perm. Makeup","Personal Care",
                             "Fragrances","Oral Hygiene","Shaving","Baby"))

primcountplot

##################    Subtype_bar char    ######################
subn_makeup=select (CCM, PrimaryCategory, SubCategory) %>% 
  filter (PrimaryCategory == "Makeup Products (non-permanent)") %>%
  count(SubCategory) %>% arrange(desc(n))

subn_makeup$SubCategory=factor(subn_makeup$SubCategory, levels = reorder(subn_makeup$SubCategory, -subn_makeup$n))

subcountplot=ggplot(data= subn_makeup, aes(x=reorder(SubCategory,-n), y=n))+
  geom_bar(aes(fill=SubCategory), stat="identity")+ 
  theme_hc(bgcolor = "darkunica") +
  scale_colour_hc("darkunica")+
  theme(legend.position = "right")+
  theme(text = element_text(size=10, color="#e6ffff"),
        axis.text.x = element_text(angle=45, hjust=1, color = "#e6ffff"),
        axis.text.y = element_text(color = "#e6ffff"),
        plot.title= element_text(face="bold")) +
  ggtitle("Number of Makeup Product being Reported by Types ")+ 
  ylab("Number of Products") +
  xlab("Makeup Product Typs")+
  scale_x_discrete( labels=c("Lipsticks,Pencils","Eye Shadow",
                             "Foundations & Bases","Lip Gloss","Eyeliner/Eyebrow Pencils",
                             "Face Powders",
                             "Blushes","Eyelash Products",
                             "Lip Balm","Others","Rouges","Makeup Fixatives",
                             "Makeup Preparations","Paints"))+
  scale_fill_discrete( labels=c("Lipsticks,Pencils","Eye Shadow",
                                "Foundations & Bases","Lip Gloss","Eyeliner/Eyebrow Pencils",
                                "Face Powders",
                                "Blushes","Eyelash Products",
                                "Lip Balm","Others","Rouges","Makeup Fixatives",
                                "Makeup Preparations","Paints"))



subcountplot
#################### Company_bar chart   ########################/////wordcloud?
ccm1=count(CCM, CompanyName) %>% arrange(desc(n)) %>% top_n(10,n)

ccm1$CompanyName=factor(ccm1$CompanyName, levels = reorder(ccm1$CompanyName, -ccm1$n))

compcountplot= ggplot(data= ccm1, aes(x=reorder(CompanyName, -n), y= n))+ 
              geom_bar(aes(fill=CompanyName), stat="identity")+ 
  theme_hc(bgcolor = "darkunica") +
  scale_colour_hc("darkunica")+
  theme(legend.position = "right")+
  theme(text = element_text(size=10, color="#e6ffff"),
        axis.text.x = element_text(angle=45, hjust=1, color = "#e6ffff"),
        axis.text.y = element_text(color = "#e6ffff"),
        plot.title= element_text(face="bold")) +
              ggtitle("Number of Cosmetic Product being Reported by Company")+ 
              ylab("Number of Products")+
              xlab("Name of Company")
compcountplot
#####################  Brand_bar chart #########################
brandname = data.frame(lapply(CCM["BrandName"], as.character )) %>% mutate_each(funs(toupper)) 
CCM2 =select(CCM, -BrandName) %>%  bind_cols(brandname)  #change to all upper case
CCM2=data.frame(sapply(CCM2["BrandName"],as.factor)) #change back to factor

subc_brand_l=select (CCM2, CompanyName, BrandName) %>% filter (CompanyName == "L'Oreal USA") %>%
  count(BrandName) %>% arrange(desc(n)) %>% top_n(10,n)

subc_brand_l$BrandName=factor(subc_brand_l$BrandName, levels = reorder(subc_brand_l$BrandName, -subc_brand_l$n))

brandcountplot= ggplot(data= subc_brand_l, aes(x=reorder(BrandName, -n), y=n))+ 
  geom_bar(aes(fill=BrandName),stat="identity")+ 
  theme(text = element_text(size=10),
        axis.text.x = element_text(angle=45, hjust=1))+
  ggtitle("Number of L'Oreal Product being Reported by Brand")+ 
  ylab("Number of Products") 

brandcountplot

###########################################
wcbrand= select (CCM2, CompanyName, BrandName) %>% filter (CompanyName == "L'Oreal USA") %>%
  count(BrandName) %>% arrange(desc(n))


pal <- c("#ffc266","#00b3b3","#aa80ff","#993333","#334d99",
         "#669999","#cc0044","#8533ff","#3973ac")
set.seed(18)
wordcloud(wcbrand$BrandName, 
          wcbrand$n, 
          scale=c(2,.4), 
          color=pal, rot.per = .2,random.order = F, random.color=T
         )
#orange Tgreen purple gray red tgreend darkblue 12 18
#################     Chemtype_stack bar chart    #########################
chemical_type=select(CCM, PrimaryCategory, ChemicalName) %>% group_by(PrimaryCategory, ChemicalName)%>%
  count(ChemicalName) %>% arrange(PrimaryCategory, desc(n)) %>% top_n(3,n) 

chem_typeplot= ggplot(data= chemical_type, aes(x=PrimaryCategory, y= n,fill=ChemicalName))+ 
  geom_bar(stat="identity",position="fill")+ 
  ggtitle("Chemical types within Primary Category")+ 
  ylab("Chemical Count") +
  xlab("Chemical Types")+
  theme_hc(bgcolor = "darkunica") +
  scale_colour_hc("darkunica")+
  theme(legend.position = "right")+
  theme(text = element_text(size=10, color="#e6ffff"),
        axis.text.x = element_text(angle=45, hjust=1, color = "#e6ffff"),
        axis.text.y = element_text(color = "#e6ffff"),
        plot.title= element_text(face="bold")) +
  scale_fill_discrete(labels=c("Butylated Hydroxyanisole","Carbon Black",
                                "Carbon Black (airborne)",
                                "Cocamide DEA","Cocamide Diethanolamine",
                                "Coffee",
                                "Estragole","Phenacetin",
                                "Propylene Glycol Mono-t-butyl Ether",
                                "Retinol/Retinyl Esters","Retinyl Palmitate","Silica, Crystalline",
                                "Titanium Dioxide","Trade Secret", "Vitamin A Palmitate"))
  
  
  
chem_typeplot
##########################  Violin   ###############################
chemical_chem= select(CCM, PrimaryCategory, ChemicalCount) %>% 
  group_by(PrimaryCategory)%>%
  count(ChemicalCount)

mulchem=ggplot(data= CCM, aes(x=PrimaryCategory,y=ChemicalCount))+ 
  geom_violin(aes(fill=PrimaryCategory),color="white", scale = 'area', trim=T) +
  theme_hc(bgcolor = "darkunica") +
  scale_colour_hc("darkunica")+
  ggtitle("Number of Chemical Count in Each Category")+ 
  ylab("Chemical Count") +
  xlab("Primary Category")+
  theme(legend.position = "right")+
  theme(text = element_text(size=10, color="#e6ffff"),
        axis.text.x = element_text(angle=45, hjust=1, color = "#e6ffff"),
        axis.text.y = element_text(color = "#e6ffff"),
        plot.title= element_text(face="bold"))+
  

mulchem

########################   Time series   ###########################
CCMtem = CCM
CCMtem$ChemicalDateRemoved=as.character(CCM$ChemicalDateRemoved)

CCMtem$ChemicalDateRemoved = gsub("2103", "2013",CCMtem$ChemicalDateRemoved)
CCMtem$ChemicalDateRemoved = gsub("2104", "2014",CCMtem$ChemicalDateRemoved)

CCMtem$InitialDateReported= as.Date(CCMtem$InitialDateReported, "%m/%d/%Y")
CCMtem$MostRecentDateReported= as.Date(CCMtem$MostRecentDateReported, "%m/%d/%Y")
CCMtem$DiscontinuedDate= as.Date(CCMtem$DiscontinuedDate, "%m/%d/%Y")
CCMtem$ChemicalDateRemoved= as.Date(CCMtem$ChemicalDateRemoved, "%m/%d/%Y")

CCMtem1=filter(CCMtem, DiscontinuedDate > "2009/01/01")  #738  77725
CCMtem2= filter(CCMtem, is.na(DiscontinuedDate))
CCMtem3= bind_rows(CCMtem1,CCMtem2)


timechart= ggplot(data=CCMtem3)+
  geom_line(aes(x= InitialDateReported,colour = "Initial Date Reported"), stat="density") +
  geom_line(aes(x= MostRecentDateReported,colour = "Most Recent Date Reported"), stat="density")+
  geom_line(aes(x= ChemicalDateRemoved,colour = "Chemical Date Removed"), stat="density")+
  geom_line(aes(x= DiscontinuedDate,colour = "Discontinued Date"), stat="density")+
  scale_colour_manual("", 
                      breaks = c("Initial Date Reported", "Most Recent Date Reported", "Chemical Date Removed","Discontinued Date"),
                      values = c("#fc8d62","#e78ac3","#66c2a5", "#8da0cb"))+
  theme_hc(bgcolor = "darkunica") +
  xlab("Year")+ ylab("Number of Times Reported")+ 
  ggtitle("Timeline of Reported Cosmetics")


timechart
################################################################################################
cbPalette <- c("#999999", "#E69F00")