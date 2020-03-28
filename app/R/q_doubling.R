#' Generate quantiles of doubling time
#'
#' Values are generated from a inverse Gamma distribution.
#'
#' @author Samuel Clifford
#'

q_doubling <- function(mean, cv, p=c(0.025, 0.975)) {
    ## parameterised in terms of an inverse gamma to avoid truncating at 0
    
    if (cv == 0){return(rep(x = mean, times = length(p)))} else{
        invgamma::qinvgamma(p=p, shape = 2 + 1/cv^2, rate = mean*(1 + 1/cv^2))    
    }
    
}
