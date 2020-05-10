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
                         reporting = 100){
    
    beds_plot <- plot_beds(results$beds,
                           ribbon_color = slider_color,
                           palette = cmmid_pal) +
        ggplot2::ggtitle(subtitle = "95% intervals shown as shaded ribbon",
                         label = "Projected bed occupancy")
    
    admissions_plot <- plot_admissions(results$data, results$admissions, reporting) +
        ggplot2::ggtitle(subtitle = "95% intervals shown as bars",
                         label = "Projected admissions")
    
    
    patchwork::wrap_plots(ncol = 1, beds_plot, admissions_plot)
    
}