#' Function to plot discretised duration distribution
#'
#' This function provides custom plots for the output of `distcrete`.
#'
#' @param los a length of stay distribution of class `distcrete`
#' @param title a string to be added to the resulting ggplot
#' 
#' @author Sam Clifford
#' 

plot_data <- function(data, title = NULL) {
    
    ggplot2::ggplot(data = data,
                    ggplot2::aes(x = as.Date(date), y = n_admissions)) +
        ggplot2::geom_col(fill = cmmid_color, width = 0.8) +
        ggplot2::xlab("Date") +
        ggplot2::ylab("Number of admissions") +
        ggplot2::ggtitle(title) +
        ggplot2::theme_bw() +
        ggplot2::scale_x_date(date_label = "%d %b %y") +
        ggplot2::scale_y_continuous(breaks = int_breaks, limits = c(0, NA)) + 
        rotate_x +
        large_txt 
}
