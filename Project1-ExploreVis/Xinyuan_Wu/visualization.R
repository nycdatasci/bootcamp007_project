setwd("G:/Dropbox/Dropbox/NYC DS Academy/Project 1")
source("Xinyuan_Wu/data cleaning.R")




## graph 1. density plot with respect to shot distance (Home, Away)
data1 <- data
data1$dist_cut <- cut(data1$shot_dist, 42)
levels(data1$dist_cut) <- 0.6:41.6
data1$dist_cut <- as.numeric(as.character(data1$dist_cut))

g <- ggplot(data = data1, aes(x = dist_cut))
g <- g + geom_density(aes(fill = player_name))
g <- g + facet_grid(player_name ~ .)
g <- g + theme_gdocs() + theme(axis.text.y = element_blank())
g <- g + xlab("Shot Distance") + ylab("Shot Density") + ggtitle("Shot Distribution")
g <- g + scale_fill_manual("Players", values = c("#FFCC33", "#FF3300", "#990000", "#0066FF"))
ggsave("1.png", width = 6, height = 4)







# graph 2. shot made per game vs. distance (Won, Lost) (boring)
data2 <- data
data2$dist_cut <- cut(data2$shot_dist, 42)
levels(data2$dist_cut) <- 0.6:41.6
data2.1 <- data2 %>%
           group_by(player_name, match_result, dist_cut) %>%
           summarize(shot_made = sum(result))
data2.2 <- data2 %>%
           group_by(player_name, date, match_result) %>%
           summarize()
data2.2$match_result2 <- ifelse(as.character(data2.2$match_result) == "Won", 1, 0)
data2.3 <- data2.2 %>%
           group_by(player_name, match_result) %>%
           summarize(num_match = n())
data2.4 <- data2.1 %>%
           left_join(data2.3, by = c("player_name", "match_result")) %>%
           mutate(shot_made_per_game = shot_made/num_match) %>%
           mutate(dist_cut = as.numeric(as.character(dist_cut)))

g <- ggplot(data = data2.4, aes(x = dist_cut, y = shot_made_per_game))
g <- g + geom_point(aes(color = player_name), alpha = 0.2) + geom_line(aes(color = player_name))
g <- g + facet_grid(player_name ~ .)
g <- g + xlim(-1, 30)
g <- g + theme_gdocs()
g <- g + xlab("Shot Distance") + ylab("Number of Shots Made Per Game") + ggtitle("Shot Distribution")
g <- g + scale_color_manual("Players", values = c("#FFCC33", "#FF3300", "#990000", "#0066FF"))
ggsave("2.png", width = 6, height = 6)









# graph 3. boxplot that summarize shot accuracy (Home, Away) (boring)
data3 <- data
data3list <- split(data3, data3$player_name)
graph3list <- list()
name <- c("Curry", "Harden", "LBJ", "Westbrook")
for (i in 1:4) {graph3list[[i]] <- data3list[[i]] %>%
    group_by(date, location) %>% 
    summarize(accuracy = sum(result)/n()) %>%
    mutate(player = name[i])
}
graph3data <- rbind(graph3list[[1]], graph3list[[2]], graph3list[[3]], graph3list[[4]])

g <- ggplot(graph3data, aes(x = player, y = accuracy))
g <- g + geom_boxplot(aes(color = location), position = "dodge")
g <- g + xlab("Player") + ylab("Shot Accuracy") + ggtitle("Summary of Shot Accuracy")
g <- g + theme_gdocs()
g <- g + scale_colour_manual("Location", values = c("#FF3333", "#0099CC"))
ggsave("3.png", width = 6, height = 4)
















## graph 4. boxplot that summarize shot accuracy 2 (Won, Lost)
data3 <- data
data3list <- split(data3, data3$player_name)
graph4list <- list()
name <- c("Curry", "Harden", "LBJ", "Westbrook")
for (i in 1:4) {graph4list[[i]] <- data3list[[i]] %>%
    group_by(date, match_result) %>% 
    summarize(accuracy = sum(result)/n()) %>%
    mutate(player = name[i])
}
graph4data <- rbind(graph4list[[1]], graph4list[[2]], graph4list[[3]], graph4list[[4]])

g <- ggplot(graph4data, aes(x = player, y = accuracy))
g <- g + geom_boxplot(aes(color = match_result), position = "dodge")
g <- g + xlab("Player") + ylab("Shot Accuracy") + ggtitle("Shot Accuracy vs. Match Result")
g <- g + theme_gdocs()
g <- g + scale_colour_manual("Match Result", values = c("#FF3333", "#0099CC"))
ggsave("4.png", width = 6, height = 4)





















## graph 5. violin plot that summarisze the shot accuracy
data5 <- data %>%
         group_by(player_name, date, pts_type) %>%
         summarize(accuracy = sum(result)/n())

g <- ggplot(data5, aes(x = player_name, y = accuracy))
g <- g + geom_violin(aes(fill = player_name), alpha = 0.8)
#g <- g + geom_dotplot(aes(fill = player_name), binaxis = "y", stackdir = "center")
g <- g + xlab("Player") + ylab("Shot Accuracy") + ggtitle("Summary of Shot Accuracy")
g <- g + theme_gdocs()
g <- g + scale_fill_manual("Players", values = c("#FFCC33", "#FF3300", "#990000", "#0066FF"))
ggsave("5.png", width = 6, height = 4)






















## graph 6. shot accuracy vs. date
data6 <- data
data6 <- data6 %>%
         group_by(player_name, date) %>%
         summarize(accuracy = sum(result)/n())

g <- ggplot(data6, aes(x = date, y = accuracy))
g <- g + geom_point(aes(color = player_name), alpha = 0.3)
g <- g + geom_smooth(aes(color = player_name), se = FALSE, size = 2)
#g <- g + facet_grid(player_name ~ .)
g <- g + theme_gdocs()
g <- g + xlab("Date") + ylab("Shot Accuracy") + ggtitle("Shot Accuracy vs. Date")
g <- g + scale_colour_manual("Players", values = c("#FFCC33", "#FF3300", "#990000", "#0066FF"))
ggsave("6.png", width = 6, height = 4)














## graph 7. shot attempt vs. date (based on data3) 
data7 <- data %>%
         group_by(player_name, date) %>%
         summarize(num_shots = n())

g <- ggplot(data7, aes(x = date, y = num_shots))
g <- g + geom_point(aes(color = player_name), alpha = 0.3)
g <- g + geom_smooth(aes(color = player_name), se = FALSE, size = 2)
#g <- g + facet_grid(player_name ~ .)
g <- g + theme_gdocs()
g <- g + xlab("Date") + ylab("Number of Shots") + ggtitle("Number of Shots vs. Date")
g <- g + scale_colour_manual("Players", values = c("#FFCC33", "#FF3300", "#990000", "#0066FF"))
ggsave("7.png", width = 6, height = 4)























# graph 8. shot attempt and made vs. date (based on data3) (boring)
data8 <- data %>%
         group_by(player_name, date) %>%
         summarize(num_shots = n(), num_made = sum(result))

g <- ggplot(data8, aes(x = date, y = num_shots))
g <- g + geom_point(color = "#CCCCCC") + geom_smooth(aes(color = player_name))
g <- g + geom_point(aes(x = date, y = num_made), color = "#FFCC99")
g <- g + geom_smooth(aes(x = date, y = num_made, color = player_name))
g <- g + facet_grid(player_name ~ .)
g <- g + theme_gdocs()
g <- g + xlab("Date") + ylab("Number of Shots") + ggtitle("Number of Shots vs. Date")
g <- g + scale_colour_manual("Players", values = c("#FFCC33", "#FF3300", "#990000", "#0066FF"))
ggsave("8.png", width = 6, height = 6)     



















# graph 9. shot accuracy vs. dribbles
data9 <- data %>%
         group_by(player_name, dribbles) %>%
         summarize(accuracy = sum(result)/n())

g <- ggplot(data9, aes(x = dribbles, y = accuracy))
g <- g + geom_bar(aes(fill = player_name), stat = "identity")
g <- g + facet_grid(player_name ~ .)
g <- g + theme_gdocs() + xlim(0, 10)
g <- g + xlab("Number of Dribbles") + ylab("Shot Accuracy") + ggtitle("Shot Accuracy vs. Number of Dribbles")
g <- g + scale_fill_manual("Players", values = c("#FFCC33", "#FF3300", "#990000", "#0066FF"))
ggsave("9.png", width = 6, height = 6)

















# graph 10. shot attempt vs. dribbles
data10 <- data %>%
          group_by(player_name, dribbles) %>%
          summarize(num_shots = n())
g <- ggplot(data10, aes(x = dribbles, y = num_shots))
g <- g + geom_point(color = "#333333") + geom_line(aes(color = player_name))
g <- g + facet_grid(player_name ~ .)
g <- g + theme_gdocs() + xlim(0, 10)
g <- g + xlab("Number of Dribbles") + ylab("Number of Shots") + ggtitle("Number of Shots vs. Number of Dribbles")
g <- g + scale_colour_manual("Players", values = c("#FFCC33", "#FF3300", "#990000", "#0066FF"))
ggsave("10.png", width = 6, height = 6)



















## graph 11. shot attempt vs. touch time
data$touch_cut <- cut(data$touch_time, 47, include.lowest = TRUE)
levels(data$touch_cut) <- seq(0.25, 23.25, by = 0.5)
data11 <- data %>%
          group_by(player_name, touch_cut) %>%
          summarize(num_shots = n()) %>%
          mutate(touch_time = as.numeric(as.character(touch_cut)))
g <- ggplot(data11, aes(x = touch_time, y = num_shots))
g <- g + geom_point(aes(color = player_name), size = 4, alpha = 0.2)
g <- g + geom_line(aes(color = player_name), size = 2)
#g <- g + facet_grid(player_name ~ .)
g <- g + theme_gdocs() + xlim(0, 15)
g <- g + xlab("Touch Time (s)") + ylab("Number of Shots") + ggtitle("Number of Shots vs. Touch Time")
g <- g + scale_color_manual("Players", values = c("#FFCC33", "#FF3300", "#990000", "#0066FF"))
ggsave("11.png", width = 6, height = 4)















# graph 12. accuracy vs. touch time
data12 <- data %>%
          group_by(player_name, touch_cut) %>%
          summarize(accuracy = sum(result)/n()) %>%
          mutate(touch_cut = as.numeric(as.character(touch_cut)))
g <- ggplot(data12, aes(x = touch_cut, y = accuracy))
g <- g + geom_point(color = "#333333") + geom_smooth(aes(color = player_name))
g <- g + facet_grid(player_name ~ .)
g <- g + theme_gdocs()
g <- g + xlab("Touch Time (s)") + ylab("Accuracy") + ggtitle("Accuracy vs. Touch Time")
g <- g + scale_color_manual("Players", values = c("#FFCC33", "#FF3300", "#990000", "#0066FF"))
g <- g + xlim(0, 10)
ggsave("12.png", width = 6, height = 6)













          
# graph 13. shot accuracy vs. game clock (boring)
data13 <- data
data13$game_cut <- cut(data13$game_clock, 12)
levels(data13$game_cut) <- 1:12
data13$period <- as.factor(as.character(data13$period))
levels(data13$period) = c("First", "Second", "Third", "Fourth", "Extra")
data13 <- data13 %>%
          group_by(player_name, period, game_cut) %>%
          summarize(accuracy = sum(result)/n()) %>%
          mutate(game_cut = as.numeric(as.character(game_cut)))

g <- ggplot(data13, aes(x = game_cut, y = accuracy))
g <- g + geom_point() + geom_smooth()
g <- g + facet_grid(player_name ~ .)
g <- g + theme_gdocs()
g <- g + xlab("Game Clock (s)") + ylab("Accuracy") + ggtitle("Accuracy vs. Game Clock")
ggsave("13.png", width = 6, height = 6)
















## graph 14. shot accuracy vs. shot distance
data14 <- data
data14$dist_cut <- cut(data$shot_dist, 42)
levels(data14$dist_cut) <- 0.6:41.6
data14$dist_cut <- as.numeric(as.character(data14$dist_cut))
data14 <- data14 %>%
          group_by(player_name, dist_cut) %>%
          summarize(accuracy = sum(result)/n())
g <- ggplot(data14, aes(x = dist_cut, y = accuracy))
g <- g + geom_point(aes(color = player_name), alpha = 0.2)
g <- g + geom_smooth(aes(color = player_name), size = 2, se = FALSE)
g <- g + xlim(-1, 30)
g <- g + theme_gdocs()
g <- g + scale_color_manual("Players", values = c("#FFCC33", "#FF3300", "#990000", "#0066FF"))
g <- g + xlab("Shot Distance") + ylab("Accuracy") + ggtitle("Accuracy vs. Shot Distance")
ggsave("14.png", width = 6, height = 4)

















# graph 15. shot accuracy vs. close def dist
quan <- quantile(data$close_def_dist, seq(0, 1, by = 0.04))
data$close_def_dist_cut <- cut(data$close_def_dist, quan, include.lowest = TRUE)
data15 <- data %>% 
          group_by(player_name, close_def_dist_cut) %>%
          summarize(accuracy = sum(result)/n())

g <- ggplot(data15, aes(x = close_def_dist_cut, y = accuracy))
g <- g + geom_bar(aes(fill = player_name), stat = "identity")
g <- g + facet_grid(player_name ~ .)
g <- g + theme_gdocs() + theme(axis.text.x = element_text(angle = 90, hjust = 1))
g <- g + scale_fill_manual("Players", values = c("#FFCC33", "#FF3300", "#990000", "#0066FF"))
g <- g + xlab("Closest Defender Distance") + ylab("Accuracy") + ggtitle("Accuracy vs. Shot Distance")
ggsave("15.png", width = 6, height = 6)
















# graph 16. shot numbers vs. close def dist
data16 <- data
quan <- quantile(data16$close_def_dist, seq(0, 1, by = 0.04))
data16$close_def_dist_cut <- cut(data16$close_def_dist, quan, include.lowest = TRUE)
data16 <- data16 %>% 
    group_by(player_name, close_def_dist_cut) %>%
    summarize(shot_number = n())

g <- ggplot(data16, aes(x = close_def_dist_cut, y = shot_number))
g <- g + geom_bar(aes(fill = player_name), stat = "identity")
g <- g + facet_grid(player_name ~ .)
g <- g + theme_gdocs() + theme(axis.text.x = element_text(angle = 90, hjust = 1))
g <- g + scale_fill_manual("Players", values = c("#FFCC33", "#FF3300", "#990000", "#0066FF"))
g <- g + xlab("Closest Defender Distance") + ylab("Number of Shots") + ggtitle("Number of Shot vs. Shot Distance")
ggsave("16.png", width = 6, height = 6)


















## graph 17. 2d density, shot attempt vs. shot_dist + close_def_dist
data17.1 <- data[data$player_name == "Curry", ]
data17.2 <- data %>% filter(player_name == "Westbrook")
data17.3 <- data %>% filter(player_name == "Harden")
data17.4 <- data %>% filter(player_name == "LBJ")


g <- ggplot(rbind(data17.2, data17.1), aes(x = shot_dist, y = close_def_dist))
g <- g + stat_density2d(geom = "density2d", aes(color = player_name, alpha = ..level..), size = 2, contour = TRUE)
g <- g + scale_color_manual("Players", values = c("#FF3300", "#0099CC"))
g <- g + coord_cartesian(xlim = c(0, 30), ylim = c(0, 12))
g <- g + xlab("Shot Distance") + ylab("Defender Distance") + ggtitle("2D Shot Density Plot")
g <- g + theme_gdocs()
ggsave("17.png", width = 6, height = 4)


g <- ggplot(rbind(data17.2, data17.4), aes(x = shot_dist, y = close_def_dist))
g <- g + stat_density2d(geom = "density2d", aes(color = player_name, alpha = ..level..), size = 2, contour = TRUE)
g <- g + scale_color_manual("Players", values = c("#FF3300", "#0099CC"))
g <- g + coord_cartesian(xlim = c(0, 30), ylim = c(0, 10))
g <- g + xlab("Shot Distance") + ylab("Defender Distance") + ggtitle("2D Shot Density Plot")
g <- g + theme_gdocs()
ggsave("17_1.png", width = 6, height = 4)














## graph 18. Heat map, shot attemp vs. opponent
data18 <- data
data18$opp <- ifelse(data18$location == "Away", data18$home_team, data18$away_team)
data18$opp <- as.factor(data18$opp)
#summary(data18[data18$player_name == "Curry", ]$opp)
#summary(data18[data18$player_name == "Harden", ]$opp)
#summary(data18[data18$player_name == "LBJ", ]$opp)
#summary(data18[data18$player_name == "Westbrook", ]$opp)

data18.1 <- data18 %>%
            group_by(player_name, opp) %>%
            summarize(shot_number = n())

g1 <- ggplot(data18.1, aes(x = player_name, y = opp))
g1 <- g1 + geom_tile(aes(fill = shot_number), color = "white")
g1 <- g1 + scale_fill_gradient(name = "Shot Numbers", low = "#66CCFF", high = "#FF3300")
g1 <- g1 + xlab("Players") + ylab("Opponent") + ggtitle("Shot Attempt Heat Map")
g1 <- g1 + theme_gdocs() + theme(axis.text.x = element_text(angle = 30, hjust = 1))
ggsave("18.png", width = 6, height = 6)

## graph 19. Heat map, shot accuracy vs. opponent

data19 <- data18 %>%
          group_by(player_name, opp) %>%
          summarize(accuracy = sum(result)/n())

g2 <- ggplot(data19, aes(x = player_name, y = opp))
g2 <- g2 + geom_tile(aes(fill = accuracy), color = "white")
g2 <- g2 + scale_fill_gradient(name = "Shot Accuracy", low = "#3366CC", high = "#FF3300")
g2 <- g2 + xlab("Players") + ylab("Opponent") + ggtitle("Shot Accuracy Heat Map")
g2 <- g2 + theme_gdocs() + theme(axis.text.x = element_text(angle = 30, hjust = 1))
ggsave("19.png", width = 6, height = 6)

# graph 20. combine 18 and 19
#grid.arrange(g1, g2, ncol=2, nrow =1)
#ggsave("20.png", width = 6, height = 6)














## graph 21. hot hand hypothesis (all shots)

data21.0 <- find_hot_hand_0()
data21.1 <- find_hot_hand_1()
data21.2 <- find_hot_hand_2()
data21.3 <- find_hot_hand_3()

data21.01 <- data21.0 %>% group_by(player_name) %>% summarize(accuracy = sum(result)/n()) %>% mutate(hothand = "(after missed a shot)")
data21.11 <- data21.1 %>% group_by(player_name) %>% summarize(accuracy = sum(result)/n()) %>% mutate(hothand = "after 1 shot made")
data21.21 <- data21.2 %>% group_by(player_name) %>% summarize(accuracy = sum(result)/n()) %>% mutate(hothand = "after 2 shot made")
data21.31 <- data21.3 %>% group_by(player_name) %>% summarize(accuracy = sum(result)/n()) %>% mutate(hothand = "after 3 shot made")

data21 <- rbind(data21.01, data21.11, data21.21, data21.31)

g <- ggplot(data21, aes(x = player_name, y = accuracy))
g <- g + geom_bar(aes(fill = hothand), stat = "identity", position = "dodge")
g <- g + xlab("Players") + ylab("Accuracy") + ggtitle("Exploring Hot Hand Phenomenon (1)")
g <- g + theme_gdocs()
g <- g + scale_fill_hue(name = "Situation")
ggsave("21.png", width = 6, height = 2)



## graph 22. hot hand hypothesis (three points)

data22.0 <- find_hot_hand_three0()
data22.1 <- find_hot_hand_three1()
data22.2 <- find_hot_hand_three2()

data22.01 <- data22.0 %>% group_by(player_name) %>% summarize(accuracy = sum(result)/n()) %>% mutate(hothand = "(after missed a three)")
data22.11 <- data22.1 %>% group_by(player_name) %>% summarize(accuracy = sum(result)/n()) %>% mutate(hothand = "after 1 three made")
data22.21 <- data22.2 %>% group_by(player_name) %>% summarize(accuracy = sum(result)/n()) %>% mutate(hothand = "after 2 three made")

data22 <- rbind(data22.01, data22.11, data22.21)

g <- ggplot(data22, aes(x = player_name, y = accuracy))
g <- g + geom_bar(aes(fill = hothand), stat = "identity", position = "dodge")
g <- g + xlab("Players") + ylab("Accuracy") + ggtitle("Exploring Hot Hand Phenomenon (2)")
g <- g + theme_gdocs()
g <- g + scale_fill_hue(name = "Situation")
ggsave("22.png", width = 6, height = 2)






















