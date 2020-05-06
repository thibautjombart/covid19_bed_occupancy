#' Function to plot discretised duration distribution
#'
#' This function provides custom plots for the output of `distcrete`.
#'
#' @param los a length of stay distribution of class `distcrete`
#' @param title a string to be added to the resulting ggplot
#' 
#' @author Sam Clifford
#' 

plot_data <- function(data, reporting = 100, 
                      title = NULL) {
    data$date <- as.Date(data$date)
    data$Status <- "Reported"
    
    if (reporting < 100){
        unreported <- data
        unreported$Status <- "Unreported"
        unreported$n_admissions <- round(data$n_admissions*100/reporting - data$n_admissions)
        
        data <- rbind(data, unreported)
        #data$Status <- factor(data$Status, levels = c("Unreported", "Reported", "Projected"))
    }
    
    my_palette <- my_palette[names(my_palette) %in% unique(data$Status)]
    
    out_plot <- ggplot2::ggplot(data = data,
                    ggplot2::aes(x = date, y = n_admissions)) +
        ggplot2::geom_col(width = 0.8,
                          aes(fill = Status)) +
        ggplot2::xlab("Date") +
        ggplot2::scale_fill_manual(values = my_palette,
                                   name = "Reporting status",
                                   limits = names(my_palette)) +
        ggplot2::ylab("Number of admissions") +
        ggplot2::ggtitle(title) +
        ggplot2::theme_bw() +
        ggplot2::scale_x_date(date_label = "%d %b %y") +
        ggplot2::scale_y_continuous(breaks = int_breaks, limits = c(0, NA)) + 
        rotate_x +
        large_txt 
    
    if (length(unique(data$Status)) > 1){
        out_plot <- out_plot + ggplot2::theme(legend.position = "bottom")
    } else {
        out_plot <- out_plot + ggplot2::theme(legend.position = "none")
    }
    
    if (max(data$n_admissions) == 1){
        out_plot <- out_plot + 
            ggplot2::scale_y_continuous(breaks = c(0, 1),
                                        limits = c(0, NA))  
    }
    
    out_plot
}
