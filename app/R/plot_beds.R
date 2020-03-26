#' Function to plot outputs of predict_beds
#'
#' This function provides custom plots for the output of `predict_beds`.
#'
#' @param x the output of `predict_beds`
#'
#' @param ... further arguments passed to `plot.projections`
#' 
#' @author Thibaut Jombart
#' 
#' @examples
#' 
#' ## get forecast for admissions
#' x <- predict_admissions(Sys.Date(),
#'                         n_start = 40,
#'                         doubling = 5,
#'                         doubling_error = 1,
#'                         duration = 14) 
#' x
#' 
#' ## make toy duration of hospitalisation (exponential distribution)
#' r_duration <- function(n = 1) rexp(n, .2)
#'
#' ## get daily bed needs predictions
#' beds <- predict_beds(x$date, x$mean, r_duration)
#' beds
#' plot_beds(beds)

plot_beds <- function(x, ...) {
  plot(x,
       quantiles = c(.025, .5),
       ribbon = TRUE, ...) +
    ggplot2::theme_bw() +
    theme(legend.position = "bottom") +
    large_txt +
    ggplot2::scale_x_date(date_label = "%d %b %y") +
    rotate_x +
    ggplot2::labs(title = "Predicted bed occupancy",
                  x = NULL,
                  y = "Daily numbers of beds")
}
