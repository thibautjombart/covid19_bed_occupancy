#' Function to plot discretised duration distribution
#'
#' This function provides custom plots for the output of `distcrete`.
#'
#' @param x a `numeric` vector of doubling times
#' @param title a string to be added to the resulting ggplot
#' 
#' @author Sam Clifford
#' 

plot_doubling_distribution <- function(v, trim = TRUE, ...) {
  
  if (trim){
    q <- quantile(v, c(0.001, 0.999))
    v <- v[v < q[2] & v > q[1]]
  }
  
  dat <- data.frame(x = v)  
  ggplot2::ggplot(data = dat,
                  ggplot2::aes(x = x)) +
    ggplot2::geom_histogram(fill = cmmid_color,
                            col = "white",
                            bins = 30,
                            aes(y = ..density..)) +
    ggplot2::labs(...) +
    ggplot2::theme_bw() +
    large_txt
}
