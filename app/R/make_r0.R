make_r0 <- function(n, mean, cv) {
    if (cv == 0){
        R0 <- rep(mean, n)
        return(list(R0 = R0))
    } else {
        R0_parms <- epitrix::gamma_mucv2shapescale(mean, cv)
        R0 <- rgamma(n     = n,
                     shape = R0_parms$shape,
                     scale = R0_parms$scale)
        return(list(R0 = R0, R0_parms = R0_parms))
    }
    
    
}
