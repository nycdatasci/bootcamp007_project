################################################
# Nelson Chen
# nchen9191@gmail.com
# NYC Data Science Academy
# Webscraping Project - Data Analysis
################################################

library(dplyr)
library(ggplot2)

# read in csv
instagram_df = read.csv('data/instagram/instagram_clarifai.csv')

# split dfs
df1  = instragram_df %>% select(numLikes,numComments,Class.1,score.1)
df2  = instragram_df %>% select(numLikes,numComments,Class.2,score.2)
df3  = instragram_df %>% select(numLikes,numComments,Class.3,score.3)
df4  = instragram_df %>% select(numLikes,numComments,Class.4,score.4)
df5  = instragram_df %>% select(numLikes,numComments,Class.5,score.5)
df6  = instragram_df %>% select(numLikes,numComments,Object.1,Prob.1)
df7  = instragram_df %>% select(numLikes,numComments,Object.2,Prob.2)
df8  = instragram_df %>% select(numLikes,numComments,Object.3,Prob.3)
df9  = instragram_df %>% select(numLikes,numComments,Object.4,Prob.4)
df10 = instragram_df %>% select(numLikes,numComments,Object.5,Prob.5)

# Change column names
colnames(df1)[3:4] =  c('Class', 'score')
colnames(df2)[3:4] =  c('Class', 'score')
colnames(df3)[3:4] =  c('Class', 'score')
colnames(df4)[3:4] =  c('Class', 'score')
colnames(df5)[3:4] =  c('Class', 'score')
colnames(df6)[3:4] =  c('Object', 'Prob')
colnames(df7)[3:4] =  c('Object', 'Prob')
colnames(df8)[3:4] =  c('Object', 'Prob')
colnames(df9)[3:4] =  c('Object', 'Prob')
colnames(df10)[3:4] =  c('Object', 'Prob')

# Merge dfs
instagram_df_class = rbind(df1,df2,df3,df4,df5)
instagram_df_obj = rbind(df6,df7,df8,df9,df10)

# Plot likes vs. comments
g = ggplot(instagram_df, aes(x = log(numComments), y = log(numLikes))) + geom_point(alpha = 0.3) #+
    #xlim(c(4,log(20000)))

model = lm(log(numLikes)~log(numComments), data = filter(instagram_df, numComments < 20000))
bc = boxcox(model)

g + geom_abline(slope = 1.043,intercept = 4.422)

# Classes and Likes
top_classes_likes = instagram_df_class %>% group_by(Class) %>% 
  summarise(weighted_avg = sum(numLikes*score)/n()) %>% 
  arrange(desc(weighted_avg))

# Classes and number of photos
top_classes_counts = instagram_df_class %>% group_by(Class) %>% 
  summarise(count = n()) %>% 
  arrange(desc(count))

# Objects and likes
top_object_likes = instagram_df_obj %>% group_by(Object) %>% 
  summarise(weighted_avg = sum(numLikes*Prob)/n()) %>% 
  arrange(desc(weighted_avg))

# Objects and counts
top_object_counts = instagram_df_obj %>% group_by(Object) %>% 
  summarise(count = n()) %>% 
  arrange(desc(count))

# Classes and Likes
top_classes_comments = instagram_df_class %>% group_by(Class) %>% 
  summarise(weighted_avg = sum(numComments*score)/n()) %>% 
  arrange(desc(weighted_avg))

# Objects and likes
top_object_comments = instagram_df_obj %>% group_by(Object) %>% 
  summarise(weighted_avg = sum(numComments*Prob)/n()) %>% 
  arrange(desc(weighted_avg))

## Plots
class_likes = ggplot(data = top_classes_likes[1:10,], aes(x = Class, y = weighted_avg, fill = Class)) + 
                geom_bar(stat = 'identity') + ggtitle('Top 10 Classes by Likes') + ylab('Weighted Average of Likes')+
                theme(axis.text.x=element_blank(),
                      axis.title.x=element_text(size=18),
                      title=element_text(size=20,face="bold"),
                      legend.text=element_text(size=10),
                      legend.title=element_text(size=18),
                      axis.text.y = element_text(size=16))
class_likes

object_likes = ggplot(data = top_object_likes[1:10,], aes(x = Object, y = weighted_avg, fill = Object)) + 
  geom_bar(stat = 'identity') + ggtitle('Top 10 Regional Desciptors by Likes') + ylab('Weighted Average of Likes')+
  theme(axis.text.x=element_blank(),
        axis.title.x=element_text(size=18),
        title=element_text(size=20,face="bold"),
        legend.text=element_text(size=16),
        legend.title=element_text(size=18),
        axis.text.y = element_text(size=16)) + xlab('Regional Descriptor')
object_likes

class_comments = ggplot(data = top_classes_comments[1:10,], aes(x = Class, y = weighted_avg, fill = Class)) + 
  geom_bar(stat = 'identity') + ggtitle('Top 10 Classes by Comments') + ylab('Weighted Average of Comments')+
  theme(axis.text.x=element_blank(),
        axis.title.x=element_text(size=18),
        title=element_text(size=20,face="bold"),
        legend.text=element_text(size=10),
        legend.title=element_text(size=18),
        axis.text.y = element_text(size=16))
class_comments

object_comments = ggplot(data = top_object_comments[1:10,], aes(x = Object, y = weighted_avg, fill = Object)) + 
  geom_bar(stat = 'identity') + ggtitle('Top 10 Regional Desciptors by Comments') + ylab('Weighted Average of Comments')+
  theme(axis.text.x=element_blank(),
        axis.title.x=element_text(size=18),
        title=element_text(size=20,face="bold"),
        legend.text=element_text(size=16),
        legend.title=element_text(size=18),
        axis.text.y = element_text(size=16)) + xlab('Regional Descriptor')
object_comments

class_count = ggplot(data = top_classes_counts[1:10,], aes(x = Class, y = count, fill = Class)) + 
  geom_bar(stat = 'identity') + ggtitle('Top 10 Classes by Likes') + ylab('Count')+
  theme(axis.text.x=element_blank(),
        axis.title.x=element_text(size=18),
        title=element_text(size=20,face="bold"),
        legend.text=element_text(size=10),
        legend.title=element_text(size=18),
        axis.text.y = element_text(size=16))
class_count

object_count = ggplot(data = top_object_counts[1:10,], aes(x = Object, y = count, fill = Object)) + 
  geom_bar(stat = 'identity') + ggtitle('Top 10 Regional Desciptors by Likes') + ylab('Count')+
  theme(axis.text.x=element_blank(),
        axis.title.x=element_text(size=18),
        title=element_text(size=20,face="bold"),
        legend.text=element_text(size=16),
        legend.title=element_text(size=18),
        axis.text.y = element_text(size=16)) + xlab('Regional Descriptor')
object_count

