#' Generate quantiles of length of stay time
#'
#' Values are generated from a discretised gamma
#'
#' @author Samuel Clifford
#'

q_los <- function(mean, cv, p=c(0.025, 0.975)) {
    
    if (cv == 0){return(rep(x = mean, times = length(p)))} else{
        params <- epitrix::gamma_mucv2shapescale(mean, cv)
        stats::qgamma(p = p, shape =  params$shape, scale = params$scale)
    }
    
}
