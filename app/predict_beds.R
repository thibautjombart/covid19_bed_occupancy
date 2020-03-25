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

#' ## get forecast for admissions
#' x <- predict_admissions(Sys.Date(),
#'                         n_start = 40,
#'                         doubling = 5,
#'                         doubling_error = 1,
#'                         duration = 14) 
#' x
#' 
#' ## get forecast for beds
#' 
#' ## make toy duration of hospitalisation (exponential distribution)
#' r_duration <- function(n = 1) rexp(n, .2)
#'
#' ## get daily bed needs predictions
#' beds <- predict_beds(x$date, x$mean, r_duration)
#' beds
#' plot(beds)


predict_beds <- function(dates, n_admissions, r_los, n_sim = 10) {

  ## sanity checks
  if (!length(dates)) stop("`dates` is empty")

  if (!is.finite(n_admissions[1])) stop("`n_admissions` is not a number")
  if (n_admissions[1] < 1) stop("`n_admissions` must be >= 1")

  if (inherits(r_los, "distcrete")) {
    r_los <- r_los$r
  }
  if (!is.function(r_los)) stop("`r_los` must be a function")

  if (!is.finite(n_sim)) stop("`n_sim` is not a number")
  if (n_sim[1] < 1) stop("`n_sim` must be >= 1")

  
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
    dates_beds <- do.call(c, list_dates_beds)
    beds_days <- incidence::incidence(dates_beds)
    if (!is.null(last_date)) {
      to_keep <- incidence::get_dates(beds_days) <= last_date
      beds_days <- beds_days[to_keep, ]
    }

    out[[j]] <- projections::build_projections(
                                 x = beds_days$counts,
                                 dates = incidence::get_dates(beds_days))
  }

  projections::merge_projections(out)
 
}
