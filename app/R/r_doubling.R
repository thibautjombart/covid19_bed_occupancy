#' Generate random values of doubling time
#'
#' Values are generated from a inverse Gamma distribution.
#'
#' @author Samuel Clifford
#'

r_doubling <- function(n, mean_si, cv_si, mean_r0, cv_r0) {
    ## parameterised in terms of an inverse gamma to avoid truncating at 0
  
  # convert the serial interval to an inverse gamma distribution
  if (cv_si == 0){
    Tc <- (rep(x = mean_si, times = n))
  } else {
    Tc_parms <- list(shape = 2 + 1/cv_si^2,
                     rate  = mean_si*(1 + 1/cv_si^2))    
    Tc   <- invgamma::rinvgamma(n = n,
                                shape = Tc_parms$shape,
                                rate  = Tc_parms$rate)
  }
  
  # convert R0 to a gamma distribution
  if (cv_r0 == 0){
    R0 <- rep(mean_r0, n)
  } else {
    R0_parms <- epitrix::gamma_mucv2shapescale(mean_r0, cv_r0)
    R0 <- rgamma(n     = n,
                 shape = R0_parms$shape,
                 scale = R0_parms$scale)
  }
  
  # Wallinga and Lipsitch?
  #return(log(R0)/Tc)
  
  #r <- log(R0) / Tc
  #if (cv == 0){
  r <- log(R0)/Tc
  #} else {
  #  r <- (1 + sqrt(1 - 2*cv^2*log(R0)))/(mean*cv^2)
  #}
  
  return(log(2)/r)

  
      
}
