q_secondary <- function(R, dispersion, probs = c(0.025, 0.5, 0.975)){
    df <- data.frame(R = R$R0)
    df$y <- rnbinom(n = nrow(df), size = dispersion, mu = df$R)
    
    q <- stats::quantile(x = df$y, probs = probs)
    
    nz <- mean(df$y > 0)
    params <- fitdistrplus::fitdist(df$y, "nbinom")$estimate[c(2,1)]
    short_name <- "NegBin"
    params_names <- c("&mu;", "k")
    
    return(list(short_name = short_name,
                q          = q,
                params     = params,
                params_names = params_names))
    
}