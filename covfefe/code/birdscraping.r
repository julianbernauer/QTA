## Some example code for getting Tweets with rtweet 

library(rtweet)
library(quanteda)

# extracting the Tweets of three politicians 
tmls_pops <- get_timelines(c("alice_weidel", "HCStracheFP", "NatalieRickli"), n = 1000)

# Plot the frequency of tweets for each user over time
tmls_pops %>%
  dplyr::filter(created_at > "2018-09-01") %>%
  dplyr::group_by(screen_name) %>%
  ts_plot("days", trim = 1L) +
  ggplot2::geom_point() +
  ggplot2::theme_minimal() +
  ggplot2::theme(
    legend.title = ggplot2::element_blank(),
    legend.position = "bottom",
    plot.title = ggplot2::element_text(face = "bold")) +
  ggplot2::labs(
    x = NULL, y = NULL,
    title = "Frequency of Twitter statuses posted by three populist politicians",
    subtitle = "Twitter status (tweet) counts aggregated by day",
    caption = "\nSource: Data collected from Twitter's REST API via rtweet"
  )
