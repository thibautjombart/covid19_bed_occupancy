#' Simulator for projecting bed occupancy
#'
#' This function predits bed occupancy from admission data (dates, and numbers
#' of admissions on these days). Duration of hospitalisation is provided by a
#' function returning `integer` values for the number of days in hospital.
#' 
#' @param dates A vector of dates, ideally as `Date` but `integer` should work too.
#'
#' @param n_admissions An `integer` vector giving the number of admissions
#'   predicted for each date in `dates`.
#'
#' @param r_los A `function` with a single parameter `n` returning `n` `integer`
#'   values of lenth of hospital stay (LoS) in days. Ideally, this should come
#'   from a discrete random distribution, such as `rexp` or any `distcrete`
#'   object.
#'
#' @param n_sim The number of times duration of hospitalisation is simulated for
#'   each admission. Defaults to 10. Only relevant for low (<30) numbers of
#'   initial admissions, in which case it helps accounting for the uncertainty
#'   in LoS.
#'
#' @author Thibaut Jombart
#'
#' @examples
#' 
##  ## get forecast for admissions
##  x <- predict_admissions(Sys.Date(),
##                          n_start = 40,
##                          doubling = c(3.5,5, 6.1, 4.6),
##                          duration = 14) 
##  x

##  ## make toy duration of hospitalisation (exponential distribution)
##  r_duration <- function(n = 1) rexp(n, .2)


## ## get daily bed needs predictions for each simulated trajectory of admissions
## beds <- lapply(1:ncol(x),
##               function(i) predict_beds(x[,i],
##               projections::get_dates(x),
##               r_duration))
## beds <- projections::merge_projections(beds)
## plot(beds)

predict_beds <- function(n_admissions, dates, r_los, n_sim = 10) {
  
  ## sanity checks
  if (!length(dates)) stop("`dates` is empty")
  
  if (!is.finite(n_admissions[1])) stop("`n_admissions` is not a number")

  if (inherits(r_los, "distcrete")) {
    r_los <- r_los$r
  }
  if (!is.function(r_los)) stop("`r_los` must be a function")
  
  if (!is.finite(n_sim)) stop("`n_sim` is not a number")
  if (n_sim[1] < 1) stop("`n_sim` must be >= 1")
  
  # check if we have no new admissions
  # if we do, return 0 bed usage
  if (all(n_admissions < 1)) {
    empty_proj <- projections::build_projections(x = rep(0, length(dates)), dates = dates)
    return(projections::merge_projections(lapply(X = 1:n_sim, FUN = function(x){empty_proj})))
  }
  
  
  
  ## Outline:
  
  ## We take a vector of dates and incidence of admissions, and turn this into a
  ## vector of admission dates, whose length is sum(n_admissions). We will
  ## simulate for each date of admission a duration of stay, and a corresponding
  ## vector of dates at which this case occupies a bed. Used beds are then
  ## counted (summing up all cases) for each day. To account for stochasticity
  ## in duration of stay, this process can be replicated `n_sim` times,
  ## resulting in `n_sim` predictions of bed needs over time.
  
  
  admission_dates <- rep(dates, n_admissions)
  n <- length(admission_dates)
  last_date <- max(dates)
  out <- vector(n_sim, mode = "list")
  
  for (j in seq_len(n_sim)) {
    los <- r_los(n)
    list_dates_beds <- lapply(seq_len(n),
                              function(i) seq(admission_dates[i],
                                              length.out = los[i],
                                              by = 1L))
    ## Note: unlist() doesn't work with Date objects
    
    # what to do when date has length 0?
    
    dates_beds <- do.call(c, list_dates_beds)
    
    if (length(dates_beds) == 0){
      out[[j]] <- projections::build_projections(x = rep(0, length(dates)), dates = dates)
    } else {
      
      beds_days <- incidence::incidence(dates_beds)
      if (!is.null(last_date)) {
        to_keep <- incidence::get_dates(beds_days) <= last_date
        beds_days <- beds_days[to_keep, ]
      }
      
      get_beds_days <- incidence::get_dates(beds_days)
      
      if (!is.null(get_beds_days)){
        
        out[[j]] <- projections::build_projections(
          x = beds_days$counts,
          dates = get_beds_days)
      } else {
        out[[j]] <- projections::build_projections(x = rep(0, length(dates)), dates = dates)
      }
    }
  }
  
  projections::merge_projections(out)
  
}
