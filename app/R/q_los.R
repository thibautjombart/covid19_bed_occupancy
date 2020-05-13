#' Generate quantiles of length of stay time
#'
#' Values are generated from a discretised gamma
#'
#' @author Samuel Clifford
#'

q_los <- function(distribution, params, p = c(0.025, 0.975)) {
    
    
        
        if (distribution == "gamma"){
            q <- stats::qgamma(p = p, shape =  params$shape, scale = params$scale)
            short_name <- "&Gamma;"
            params_names <- c("k", "&theta;")
        }
        
        if (distribution == "weibull"){
            q <- stats::qweibull(p = p, shape = params$shape, scale = params$scale)
            short_name <- "W"
            params_names <- c("k", "&lambda;")
        }
        
    return(list(short_name = short_name,
                q          = q,
                params     = params,
                params_names = params_names))
}
