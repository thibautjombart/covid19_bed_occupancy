#' Run the whole model
#'
#' This function wraps the forecasting of daily admissions and of bed
#' admissions.
#'
#' 
#' @param date_start A single `Date` used as a starting point to model future
#'   COVID-19 admissions
#'
#' @param n_start The number of COVID-19 admissions reported on `date_start`
#'
#' @param doubling The doubling time, in days.
#'
#' @param reporting The proportion of admissions reported; defaults to 1,
#'   i.e. all admissions are reported.
#'
#' @param r_los A `function` with a single parameter `n` returning `n` `integer`
#'   values of lenth of hospital stay (LoS) in days. Ideally, this should come
#'   from a discrete random distribution, such as `rexp` or any `distcrete`
#'   object.
#'
#' @param n_sim The number of times duration of hospitalisation is simulated for
#'   each admission. Defaults to 1. Only relevant for low (<30) numbers of
#'   initial admissions, in which case it helps accounting for the uncertainty
#'   in LoS.
#'
#' 
#' @author Thibaut Jombart
#'
#' @examples
#' 
#' ## make toy duration of hospitalisation (exponential distribution)
#' r_duration <- function(n = 1) rexp(n, .2)
#'
#' x <- run_model(Sys.Date(),
#'                n_start = 66,
#'                doubling = c(4.5, 5.1, 6, 4.8),
#'                duration = 14,
#'                r_los = r_duration,
#'                n_sim = 10)
#' x
#' plot(x)

run_model <- function(date_start,
                      n_start,
                      doubling,
                      duration,
                      r_los,
                      reporting = 1,
                      n_sim = 1) {

  ## get projected admissions
  proj_admissions <- predict_admissions(date_start = date_start,
                                        n_start = n_start,
                                        doubling = doubling,
                                        duration = duration,
                                        reporting = reporting)

  ## get daily bed needs predictions for each simulated trajectory of admissions
  dates <- projections::get_dates(proj_admissions)
  beds <- lapply(seq_len(ncol(proj_admissions)),
                 function(i) predict_beds(proj_admissions[,i],
                                          dates,
                                          r_duration,
                                          n_sim = n_sim))

  beds <- projections::merge_projections(beds)
  beds
}
