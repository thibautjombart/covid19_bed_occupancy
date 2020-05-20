make_si <- function(mean, cv){
    
    parms <- epitrix::gamma_mucv2shapescale(mean, cv)
    si <- distcrete::distcrete("gamma", shape = parms$shape, scale = parms$scale, interval = 1, w = 0)
    
    si
    
}
