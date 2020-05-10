#' Function to plot discretised duration distribution
#'
#' This function provides custom plots for the output of `distcrete`.
#'
#' @param los a length of stay distribution of class `distcrete`
#' @param title a string to be added to the resulting ggplot
#' 
#' @author Sam Clifford
#' 

plot_admissions <- function(data,
                            projections, 
                            reporting = 100, 
                            title = NULL) {
    
    
    
    projections <- summarise_beds(projections[-c(1:nrow(data)),])
    
    projections$Status <- "Projected"
    projections$n_admissions <- NA
    projections$date <- projections$Date
    
    # my_palette <- c(Reported = cmmid_color,
    #                 Unreported = alpha(cmmid_color, 0.5),
    #                 Projected = "#00AEC7")
    
    palette_to_use <- c("Reported", 
                        "Unreported",
                        "Projected")[
                            c(TRUE,
                              reporting < 100,
                              TRUE)]
    
    out_plot <- plot_data(data = data, 
                          reporting = reporting,
                          title = title)
    out_plot +
        ggplot2::geom_col(data = projections,
                          width = 0.8,
                          aes(fill = Status,
                              y = Median)) +
        ggplot2::geom_segment(data = projections,
                              aes(y = `lower 95%`,
                                  xend = date,
                                  yend = `upper 95%`),
                              size = 1
        ) +
        # ggplot2::geom_segment(data = projections,
        #                       aes(y = `lower 50%`,
        #                           xend = date,
        #                           yend = `upper 50%`),
        #                       size = 2,
        #                       color = cmmid_pal(1)
        # ) +
        ggplot2::scale_fill_manual(values = my_palette[palette_to_use],
                                   breaks = palette_to_use,
                                   name = "Reporting status") +
        ggplot2::theme(legend.position = "bottom") +
        ggplot2::scale_y_continuous(limits = c(0, NA), breaks = int_breaks) +
        ggplot2::scale_x_date(date_label = "%d %b %y")
    
    
}
