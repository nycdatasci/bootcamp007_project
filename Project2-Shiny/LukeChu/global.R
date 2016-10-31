library(stattleshipR)
library(dplyr)
library(googleVis)

options(stringsAsFactors = FALSE)

set_token("673a35612348d867c09bc3cb3d3ceb30")

team.name.list <- c("Arizona Cardinals", "Atlanta Falcons", "Baltimore Ravens",
                    "Buffalo Bills", "Carolina Panthers", "Chicago Bears",
                    "Cincinnati Bengals", "Cleveland Browns", "Dallas Cowboys",
                    "Denver Broncos", "Detroit Lions", "Green Bay Packers",
                    "Houston Texans", "Indianapolis Colts", "Jacksonville Jaguars",
                    "Kansas City Chiefs", "Miami Dolphins", "Minnesota Vikings",
                    "New England Patriots", "New Orleans Saints", "NY Giants",
                    "NY Jets", "Oakland Raiders", "Philadelphia Eagles",
                    "Pittsburgh Steelers", "San Diego Chargers", "San Francisco 49ers",
                    "Seattle Seahawks", "St. Louis Rams", "Tampa Bay Buccaneers",
                    "Tennessee Titans", "Washington Redskins")

years.available<- c('2016-2017', '2015-2016', '2013-2014', '2012-2013', '2011-2012')

offensive.positions <- c("QB", "RB", "WR", "K", "TE")

# removed Week and Home Away for now
stat.list <- c('RushingYards', 'ReceivingYards', 'PassingYards',
               'TotalTouchdowns', 'ReceivingTouchdowns', 'RushingTouchdowns',
               'PassingTouchdowns')

# make stat.list for comparing two players to use in a single data frame / plot
compare.stat.list <- paste(rep(stat.list, each ='2'), c('.p1','.p2'), sep='')
names(compare.stat.list) <- rep(stat.list, each='2')
compare.stat.list <- split(compare.stat.list, 1:2)

title.bar <- "DEFAULT"

queryAPI <- function(player.name, year){
  
  # format name for query
  name <- gsub(' ','-',tolower(player.name), fixed = TRUE)
  q_body <- list(player_id = paste0('nfl-', name), season_id = paste0('nfl-', year))
  
  # run query
  game.log <- ss_get_result(sport = "football",
                            league = "nfl", ep = "game_logs", query = q_body, 
                            verbose = T)
  
  # strip extraneous outer layer
  game.log <- game.log[[1]]
  
  # check if query is correct/given player exists
  if(!is.null(game.log$error)){
    ab <- 'return error somehow'
  }
  
  if(game.log$players$position_abbreviation %in% offensive.positions) {
    abc <- "continue!"
    # otherwise say only offensive positions currently supported
  }
  
  
  # week info
  stats.frame <- data.frame("Week"=game.log$games$interval_number)
  
  # home or away
  home.away <- game.log$games$home_team_id
  home.away <-  ifelse(home.away == game.log$players$team_id,
                       'Home', 'Away')
  

  # quick rename, accesses the game log level of game logs
  gl <- game.log$game_logs
  
  # build up the data frame
  stats.frame$HomeAway <- home.away
  stats.frame$RushingYards <- as.numeric(gl$rushes_yards)
  stats.frame$ReceivingYards <- as.numeric(gl$receptions_yards)
  stats.frame$PassingYards <- as.numeric(gl$passes_yards_gross)
  stats.frame$TotalTouchdowns <- as.numeric(gl$total_touchdowns) # includes passing, anything
  stats.frame$ReceivingTouchdowns <- as.numeric(gl$receptions_touchdowns)
  stats.frame$RushingTouchdowns <- as.numeric(gl$rushes_touchdowns)
  stats.frame$PassingTouchdowns <- as.numeric(gl$passes_touchdowns)
  
  
  stat.list <- names(stats.frame)
  
  
  # arrange stats by week because for some reason they aren't in a weekly order
  stats.frame <- arrange(stats.frame, Week)
  stats.frame$Week <- as.character(stats.frame$Week)
  
  # non game dependent info
  default.stat <- switch(game.log$players$position_abbreviation, 
                         'QB' = 'PassingYards', 'RB' = 'RushingYards',
                         'WR' = 'ReceivingYards', 'TE' = 'ReceivingYards',
                         'K' = 'FieldGoalsMade')
  
  team.id <- game.log$players$team_id
  
  
  player.info <- list('name'= game.log$players$name,
                      'position' = game.log$players$position_name,
                      'team' = paste(game.log$teams$name, game.log$teams$nickname,sep = ' '),
                      'default.stat'= default.stat )
  
  
  return(list('stats.frame'=stats.frame, 'player'= player.info))
  
}


# handle bye week? right now it's just left out.


#gvistest <-  gvisBarChart(queryAPI('Eli Manning'))
#plot(gvistest)



# Javascript Code ---------------------------------------------------------

