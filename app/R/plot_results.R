#' Function to plot outputs of predict_beds
#'
#' This function provides custom plots for the output of `predict_beds`.
#' 
#' It exists only to wrap `plot_beds` and `plot_admissions`
#'
#' @param x the output of `predict_beds`
#'
#' 
#' @author Sam Clifford
#' 
#' @examples

plot_results <- function(results,
                         reporting = 100,
                         time = 7,
                         warning_text = NULL){
    
    
    n_data <- nrow(results$data)
    
    beds  <- summarise_beds(results$beds)
    beds$var <- "Bed occupancy"
    beds$Status <- "Projected"
    
    results$data$Status <- "Reported"
    
    if (reporting < 100){
        unreported <- results$data
        unreported$Status <- "Unreported"
        unreported$n_admissions <- round(results$data$n_admissions*100/reporting - results$data$n_admissions)
        
        results$data <- rbind(results$data, unreported)
        results$data$Status <- factor(results$data$Status, levels = c("Unreported", "Reported"))
    }
    
    results$data$var <- "Cases per day"
    results$data$Date <- as.Date(results$data$date)
    
    cases        <- summarise_beds(results$admissions[-n_data,])
    cases$var    <- "Cases per day"
    cases$Status <- "Projected"
    
    palette_to_use <- c("Reported", 
                        "Unreported",
                        "Projected")[
                            c(TRUE,
                              reporting < 100,
                              TRUE)]
    
    
    results_plot <-
        ggplot2::ggplot(
            mapping = aes(x = Date)) +
        ggplot2::geom_col(data = cases,
                          aes(fill = Status,
                              y = Median),
                          width = 0.8) + 
        ggplot2::geom_col(data = results$data,
                          aes(fill = Status,
                              y = n_admissions),
                          width = 0.8) + 
        ggplot2::geom_linerange(data = cases,
                                aes(ymin = `lower 95%`,
                                    ymax = `upper 95%`)) + 
        ggplot2::geom_ribbon(data = beds,
                             aes(ymin = `lower 95%`,
                                 ymax = `upper 95%`,
                                 fill = Status),
                             color = NA,
                             alpha = 0.25) + 
        ggplot2::geom_line(data = beds, aes(y = Median,
                                            color = Status)) +
        ggplot2::facet_wrap( ~ var, ncol = 1, scales = "free_y") +
        ggplot2::theme_bw() + 
        ggplot2::scale_fill_manual(values = my_palette[palette_to_use],
                                   breaks = palette_to_use,
                                   name = "Reporting status") +
        ggplot2::scale_color_manual(values = my_palette[palette_to_use],
                                    breaks = palette_to_use,
                                    name = "Reporting status", 
                                    guide = FALSE) +
        ggplot2::theme(legend.position = "bottom",
                       axis.title = element_blank(),
                       strip.background = element_blank(),
                       panel.border = element_rect(colour = "black"),
                       strip.text = element_text(size = 18)) +
        ggplot2::scale_y_continuous(limits = c(0, NA), breaks = int_breaks) +
        ggplot2::scale_x_date(date_label = "%d %b %y") +
        large_txt + rotate_x 
    
    if (n_data < time){
        results_plot <- results_plot +
            ggplot2::annotate("text", 
                              x = min(results$data$Date),
                              y = Inf, label = sprintf("Warning: Uploaded data\nshorter than %s", warning_text),
                              hjust=0, vjust=1.25, col = "#FE5000", cex=6,
                              fontface = "bold", alpha = 0.8)
        
    }
    
    results_plot
    
}