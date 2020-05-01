#' Function to plot discretised duration distribution
#'
#' This function provides custom plots for the output of `distcrete`.
#'
#' @param los a length of stay distribution of class `distcrete`
#' @param title a string to be added to the resulting ggplot
#' 
#' @author Sam Clifford
#' 

plot_data <- function(data, reporting = 100, title = NULL) {
    
    data$status <- "Reported"
    
    if (reporting < 100){
        unreported <- data
        unreported$status <- "Unreported"
        unreported$n_admissions <- round(data$n_admissions*100/reporting - data$n_admissions)
        
        data <- rbind(data, unreported)
        data$status <- factor(data$status, levels = c("Unreported", "Reported"))
    }
    
    ggplot2::ggplot(data = data,
                    ggplot2::aes(x = as.Date(date), y = n_admissions)) +
        ggplot2::geom_col(fill = cmmid_color, width = 0.8,
                          aes(alpha = status)) +
        ggplot2::xlab("Date") +
        ggplot2::scale_alpha_manual(values = c("Unreported" = 0.5,
                                               "Reported" = 1)) +
        ggplot2::ylab("Number of admissions") +
        ggplot2::ggtitle(title) +
        ggplot2::theme_bw() +
        ggplot2::scale_x_date(date_label = "%d %b %y") +
        ggplot2::scale_y_continuous(breaks = int_breaks, limits = c(0, NA)) + 
        rotate_x +
        large_txt 
}
