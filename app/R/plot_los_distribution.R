#' Function to plot discretised duration distribution
#'
#' This function provides custom plots for the output of `distcrete`.
#'
#' @param los a length of stay distribution of class `distcrete`
#' @param title a string to be added to the resulting ggplot
#' 
#' @author Sam Clifford
#' 

plot_los_distribution <- function(los, ...) {
  min_days <- 0 
  max_days <- pmax(40, max(1, los$q(.999) + 2))
  days     <- min_days:max_days
  dat      <- data.frame(days = days,
                         y    = los$d(days))
  
  ggplot2::ggplot(data = dat,
                  ggplot2::aes(x = days, y = y)) +
    ggplot2::geom_col(fill = cmmid_color, width = 0.8) +
    ggplot2::labs(...) +
    ggplot2::theme_bw() +
    ggplot2::scale_x_continuous(breaks = int_breaks) +
    large_txt 
}
