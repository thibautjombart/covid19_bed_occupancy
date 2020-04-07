#' Function to plot discretised duration distribution
#'
#' This function provides custom plots for the output of `distcrete`.
#'
#' @param x a `numeric` vector of doubling times
#' @param title a string to be added to the resulting ggplot
#' 
#' @author Sam Clifford
#' 

plot_doubling_distribution <- function(x, title = NULL) {
  dat <- data.frame(x = x)  
  ggplot2::ggplot(data = dat,
                  ggplot2::aes(x = x)) +
    ggplot2::geom_histogram(fill = cmmid_color, col = "white") +
    ggplot2::xlab("Doubling time (days)") +
    ggplot2::ylab("Frequency") +
    ggplot2::ggtitle(title) +
    ggplot2::theme_bw() +
    large_txt
}
