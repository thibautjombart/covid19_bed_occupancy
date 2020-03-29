
## produce only integer breaks
int_breaks <- function(x, n = 5) {
  pretty(x, n)[pretty(x, n) %% 1 == 0]
}


## make text bigger on ggplot2 plots
large_txt <- ggplot2::theme(text = ggplot2::element_text(size = 16),
                            axis.text = ggplot2::element_text(size = 14))
smaller_axis_txt <- ggplot2::theme(axis.text = ggplot2::element_text(size = 12))

scale_months <- ggplot2::scale_x_date(breaks = "1 month",
                                      date_label = format("%d %b %Y"))


scale_weeks <- ggplot2::scale_x_date(breaks = "1 week",
                                     date_label = format("%d %b %Y"))



## strips for vertical facetting: horizontal labels, nice colors
custom_vert_facet <-
  ggplot2::theme(
               strip.text.y = ggplot2::element_text(size = 12, angle = 0, color = "#6b6b47"),
               strip.background = ggplot2::element_rect(fill = "#ebebe0", color = "#6b6b47"))

custom_horiz_facet <-
  ggplot2::theme(
               strip.text.x = ggplot2::element_text(size = 12, angle = 90, color = "#6b6b47"),
               strip.background = ggplot2::element_rect(fill = "#ebebe0", color = "#6b6b47"))

## rotate x annotations by 45 degrees
rotate_x <-
  ggplot2::theme(
               axis.text.x = ggplot2::element_text(angle = 45, hjust = 1L))




add_ribbon <- function(x, proj, ci = 0.95) {
  alpha <- 1 - ci
  projections::add_projections(
                   x,
                   proj,
                   quantiles = FALSE,
                   ribbon_alpha = ribbon_alpha,
                   ribbon_color = ribbon_color,
                   ribbon_quantiles = c(alpha / 2, 1 - (alpha  / 2)))
}

# color choices
cmmid_color <- "#0D5257"
lshtm_grey  <- "#A7A8AA"
annot_color <- "#738E87"
slider_color <- "#6F9E93"

cmmid_pal <- function(n){
  
  colorRampPalette(colors = c("#388a68","#0D5257"))(n)
  
}
