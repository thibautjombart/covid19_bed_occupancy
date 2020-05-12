weibull_q2shapescale <- function(q, p=c(0.025,0.975)){
# https://www.johndcook.com/quantiles_parameters.pdf    
    if (length(p) != length(q)){
        stop("`p` and `q` must have identical lengths")
    }
    
    if (any(q <= 0)){
        stop("Weibull distribution is strictly non-negative; check quantile probabilities, `q`.")
    }
    
    if (any(duplicated(p))){
        stop("Quantile probabilities, `p`, must be unique")
    }
    
    if (any(duplicated(q))){
        stop("Quantile values, `q`, must be unique")
    }
    
    if (any(p <= 0 | p >= 1)){
        stop("Quantile probabilities, `p` must be in range (0,1)")
    }
    
    if (!all(sign(diff(p[order(p)])) == sign(diff(q[order(p)])))){
        stop("Quantile pairs do not mutually monotonically increase.")
    }
    
    if (length(p) > 2){
        warning("Only two quantiles required to specify a two-parameter distribution, using the first two elements of `p` and `q`")
    }
    
    shape <- as.numeric((log(-log(1 - p[2])) - log(-log(1 - p[1]))  )/(log(q[2]) - log(q[1])))
    scale <- q[1]/(-log(1 - p[1]))^(1/shape)
    
    return(list(shape = shape, scale = scale))
}
