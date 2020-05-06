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
                              lty = 3
        ) +
        ggplot2::geom_segment(data = projections,
                              aes(y = `lower 50%`,
                                  xend = date,
                                  yend = `upper 50%`),
                              lty = 1
        ) +
        # ggplot2::geom_linerange(data = projections,
        #                         aes(ymin = `lower 50%`,
        #                             ymax = `upper 50%`),
        #                         size = 2) +
        ggplot2::scale_fill_manual(values = my_palette,
                                   name = "Reporting status",
                                   limits = names(my_palette)) +
        ggplot2::theme(legend.position = "bottom")
    
    
}
