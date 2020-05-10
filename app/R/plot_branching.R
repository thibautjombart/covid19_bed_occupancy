#' Functions for plotting branching process parameters
#'
#' 
#' @param R A `list` containing `R0`, a vector of sampled basic reproduction
#'   numbers, and `R0_parms`, a list containing the `shape` and `scale` parameters
#'   used to generate these samples
#'
#' 
#' @author Sam Clifford

plot_branching <- function(R, dispersion){
    
    r0_plot <- plot_r0(R)
    s_plot <- plot_secondary(R, dispersion)
    
    patchwork::wrap_plots(r0_plot, s_plot, ncol = 1)
}

plot_r0 <- function(R){
    
    q <- qgamma(p = c(0.0001, 0.9999),
                shape = R$R0_parms$shape,
                scale = R$R0_parms$scale)
    
    if (sd(R$R0) == 0){
        r0_plot <- ggplot2::ggplot(data = data.frame(R = unique(R$R0))) +
            ggplot2::geom_segment(aes(x = R, xend = R),
                                  y = 0, yend = 1,
                                  color = cmmid_color)
    } else {
        
        r0_plot <- ggplot2::ggplot(data = data.frame(R = q),
                                   aes(x = R)) +
            ggplot2::stat_function(geom = "area",
                                   n = 301,
                                   fill = cmmid_color,
                                   fun = dgamma, 
                                   args = list(shape = R$R0_parms$shape,
                                               scale = R$R0_parms$scale)) 
    }
    
    r0_plot +
        ggplot2::xlab(expression(R[0])) +
        ggplot2::ylab("Density") + 
        ggplot2::theme_bw() +
        ggplot2::ggtitle("Basic reproduction number") +
        large_txt 
    
}

plot_secondary <- function(R, dispersion){
    
    df <- data.frame(R = R$R0)
    df$y <- rnbinom(n = nrow(df), size = dispersion, mu = df$R)
    q <- qnbinom(p = 0.99, size = dispersion, mu = df$R)
    
    ggplot2::ggplot(data = df, aes(x=y)) +
        ggplot2::geom_bar(width = 0.8, fill = cmmid_color, color = NA,
                          aes(y = ..prop..)) +
        ggplot2::theme_bw() +
        ggplot2::xlab("Number of cases") +
        ggplot2::ylab("Density") +
        ggplot2::scale_x_continuous(limits = c(NA, q)) +
        ggplot2::ggtitle("Secondary cases generated\nby each case") +
        large_txt 
}
