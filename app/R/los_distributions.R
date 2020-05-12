


## * **Duration of hospitalisation**:
##     + non critical care: discretised Weibull(shape:2, scale:13) to aim for a median of 11
##       days, IQR 7-14
##     + critical care: discretised Weibull(shape:2, scale:10) to aim for a median of 8
##       days, IQR 4-12
##     + See table 2 in 
## 	[source](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30566-3/fulltext)

## los = "length of stay"
## los_normal for non critical care hospitalisation
los_zhou_general <- distcrete::distcrete("weibull", shape = 2, scale = 13, w = 0, interval = 1)

## los_critical for critical care
los_zhou_critical <- distcrete::distcrete("weibull", shape = 2, scale = 10, w = 0, interval = 1)

weibull_k_value <- function(k, cv){ cv^2 - (gamma(1 + 2/k)/gamma(1 + 1/k)^2) + 1  }

weibull_mucv2shapescale <- function(mean, cv){
  params       <- list(shape = uniroot(f = weibull_k_value, interval = c(0.1, 1000), cv = cv)$root)
  params$scale <- mean/gamma(1 + 1/params$shape)
  params
}


## Customised version: user defined mean and CV
## we want to avoid having 0 days LoS, so what we do is actually:
## - generate a discretised Gamma with (mean - 1)
## - add 1 to simulated LoS
los_dist <- function(distribution = "gamma", q) {
  
  if (distribution == "gamma"){
    params <- gamma_q2shapescale(q, p = c(0.25, 0.75))
    auxil <- distcrete::distcrete("gamma",
                                  shape = params$shape,
                                  scale = params$scale,
                                  w = 0.5, interval = 1)
    r <- function(n) auxil$r(n) + 1
    d <- function(x) {
      out <- auxil$d(x - 1)
      out[x < 1] <- 0
      out
    }
    q <- function(x) {
      1 + auxil$q(x)
    }
  }
  
  if (distribution == "weibull"){
    
    params <- weibull_q2shapescale(q, p = c(0.25, 0.75))
    auxil <- distcrete::distcrete(distribution,
                                  shape = params$shape,
                                  scale = params$scale,
                                  w = 0.5, interval = 1)
    
    r <- function(n) auxil$r(n) + 1
    d <- function(x) {
      out <- auxil$d(x - 1)
      out[x < 1] <- 0
      out
    }
    q <- function(x) {
      auxil$q(x) + 1
    }
    
  }
  
  list(r = r, d = d, q = q)
}

los_params <- function(distribution = "gamma", q) {
  
  if (distribution == "gamma"){
    params <- gamma_q2shapescale(q, p = c(0.25, 0.75))
  }
  
  if (distribution == "weibull"){
    params <- weibull_q2shapescale(q, p = c(0.25, 0.75))
  }
  
  as.list(params)
}
