#' Generate quantiles of basic reproduction number
#'
#' @author Samuel Clifford
#'

q_r0 <- function(mean, cv, probs = c(0.025, 0.975)) {
    
    if (cv == 0){return(rep(x = mean, times = length(p)))} else{
        
            params <- epitrix::gamma_mucv2shapescale(mean, cv)
            params[[2]] <- 1/params[[2]]
            names(params)[2] <- "rate"
            q <- stats::qgamma(p = probs, shape =  params$shape, rate = params$rate)
            short_name <- "&Gamma;"
            params_names <- c("&alpha;", "&beta;")
        
    }
    
    return(list(short_name = short_name,
                q          = q,
                params     = params,
                params_names = params_names))
}
