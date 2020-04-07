#' Generate random values of doubling time
#'
#' Values are generated from a inverse Gamma distribution.
#'
#' @author Samuel Clifford
#'

r_doubling <- function(n, mean, cv) {
    ## parameterised in terms of an inverse gamma to avoid truncating at 0
    
  if (cv == 0){
    return(rep(x = mean, times = n))
  } else {
    invgamma::rinvgamma(
      n = n,
      shape = 2 + 1/cv^2,
      rate = mean*(1 + 1/cv^2))    
    }
    
}
