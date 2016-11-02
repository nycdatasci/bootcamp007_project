## global.R ##

## PyPI Ranking
## http://pypi-ranking.info/alltime?

options(stringsAsFactors = FALSE)

TOP_N <- 100

## load general data
qa_cnt <- readRDS("./data/qa_cnt.rds")

## load python data
p_tags <- readRDS("./data/python/Tags.rds")
p_pkgs <- readRDS("./data/python/python_pkgs.rds")
p_tag_cnt <- readRDS("./data/python/Tags_count.rds")

## load r data
r_tags <- readRDS("./data/r/Tags.rds")
r_pkgs <- readRDS("./data/r/r_pkgs.rds")
r_tag_cnt <- readRDS("./data/r/Tags_count.rds")

p_tag_top <- data.frame(count = table(p_tags$Tag)) %>% 
  rename(package = count.Var1,
         `Tag count` = count.Freq)

p_pkg_top <- p_tag_top %>%
  filter(package %in% p_pkgs) %>%
  top_n(TOP_N, `Tag count`) %>%
  arrange(desc(`Tag count`))


p_tpc_top <- p_tag_top %>%
  filter(!(package %in% c("python", p_pkgs))) %>%
  top_n(TOP_N, `Tag count`) %>%
  arrange(desc(`Tag count`))

r_tag_top <- data.frame(count = table(r_tags$Tag)) %>% 
  rename(package = count.Var1,
         `Tag count` = count.Freq)

r_pkg_top <- r_tag_top %>%
  filter(package %in% r_pkgs) %>%
  top_n(TOP_N, `Tag count`) %>%
  arrange(desc(`Tag count`))

r_tpc_top <- r_tag_top %>%
  filter(!(package %in% r_pkgs)) %>%
  top_n(TOP_N, `Tag count`) %>%
  arrange(desc(`Tag count`))

  
  
