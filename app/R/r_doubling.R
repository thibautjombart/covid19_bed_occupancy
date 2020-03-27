#' Generate random values of doubling time
#'
#' Values are generated from a normal distribution.
#'

r_doubling <- function(mean, cv, n) {
  rnorm(n, mean, cv * mean)
}
