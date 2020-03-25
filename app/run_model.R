#' Run the whole model
#'
#' This function wraps the forecasting of daily admissions and of bed
#' admissions.
#'

#' @param date_start A single `Date` used as a starting point to model future
#'   COVID-19 admissions
#'
#' @param n_start The number of COVID-19 admissions reported on `date_start`
#'
#' @param doubling The doubling time, in days.
#' 
#' @param doubling_error The uncertainty associated to the doubling time, in
#'   days. Upper and lower bounds of the forecast will be `doubling +/-
#'   doubling_error`.
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
#'   each admission. Defaults to 10. Only relevant for low (<30) numbers of
#'   initial admissions, in which case it helps accounting for the uncertainty
#'   in LoS.
#'
#' 
#' @author Thibaut Jombart
#'
#' @examples
#' 

#' ## get forecast for admissions
#' x <- predict_admissions(Sys.Date(),
#'                         n_start = 40,
#'                         doubling = 5,
#'                         doubling_error = 1,
#'                         duration = 14) 
#' x
#' 
#' ## make toy duration of hospitalisation (exponential distribution)
#' r_duration <- function(n = 1) rexp(n, .2)
#'
#' x <- run_model(Sys.Date(),
#'                n_start = 66,
#'                doubling = 7,
#'                doubling_error = 2,
#'                duration = 14,
#'                r_los = r_duration,
#'                n_sim = 1)
#' x
#' plot(x)

run_model <- function(date_start,
                      n_start,
                      doubling,
                      doubling_error,
                      duration,
                      reporting = 1,
                      r_los,
                      n_sim = 10) {

  ## get projected admissions
  proj_admissions <- predict_admissions(date_start = date_start,
                                        n_start = n_start,
                                        doubling = doubling,
                                        doubling_error = doubling_error,
                                        duration = duration,
                                        reporting = reporting,
                                        long = TRUE)

  ## split projections by type of prediction (low / mean / high)
  list_proj_admissions <- split(proj_admissions, proj_admissions$prediction)


  ## get projected bed needs for each type of prediction
  list_proj_beds <- lapply(list_proj_admissions,
                         function(e)
                           predict_beds(dates = e$date,
                                        n_admission = e$n,
                                        r_los = r_los,
                                        n_sim = n_sim))

  
  ## put results back together as a `projections` object
  beds <- projections::merge_projections(list_proj_beds)

  beds
}
