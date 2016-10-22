install.packages("ggplot2")
library(ggplot2)
install.packages("ggthemes")
library(ggthemes)
setwd("~/Desktop/")

q1 <- read.csv("Q1 Overall, are you satisfied or dissatisfied with the way things are going in our country today_.csv")
q2 <- read.csv("Q3 Advanced Economies Pessimistic In the next 12 months, the economy will….csv")
q3 <- read.csv("Q4 Personal Economic Situation.csv")
q4 <- read.csv("Q8 Emerging Markets- More Hopeful for Children.csv")

p1 <- ggplot(data = q1,aes(x = X,y = Satisfied))
p1 + geom_bar(stat = "identity") + facet_wrap( ~ Categorization) + ggtitle("Most Dissatisfied with Country Direction") + coord_flip() +  theme(axis.title.x = element_text(colour = "darkgreen"),axis.title.y = element_text(color = "darkgreen")) + theme_bw()

# p1 + geom_bar(stat = "identity") + facet_wrap( ~ Categorization) + ggtitle("Most Dissatisfied with Country Direction") + coord_flip() + theme_economist() + scale_fill_economist()

p2 <- ggplot(data = q2,aes(x = X,y = Improve))
p2 + geom_bar(stat = "identity") + facet_grid( ~ Categorization) + ggtitle("In the next 12 months, the economy will...")  + theme_economist() + scale_fill_economist() + coord_flip()

p3 <- ggplot(data = q3,aes(x = X,y = Good))
p3 + geom_bar(stat = "identity") + facet_wrap( ~ Categorization) + ggtitle("Personal Economic Situation")  + coord_flip() + theme_wsj() + scale_fill_wsj((palette = "black_green"))

p4 <- ggplot(data = q4,aes(x = X,y = Worse))
p4 + geom_bar(stat = "identity") + facet_wrap( ~ Categorization) + ggtitle("Hope for children") + coord_flip() +  theme(axis.title.x = element_text(colour = "darkgreen"),axis.title.y = element_text(color = "darkgreen")) + theme_bw()
