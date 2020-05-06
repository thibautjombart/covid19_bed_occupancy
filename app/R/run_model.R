#' Run the whole model
#'
#' This function wraps the forecasting of daily admissions and of bed
#' admissions.
#'
#' 
#' @param dates A `Date` object indicating the dates of COVID-19 admissions.
#'
#' @param admissions An `integer` vector indicating the number of COVID-19
#'   admissions reported on dates `dates`.
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
#' ## make toy duration of hospitalisation (geometric distribution)
#' r_duration <- function(n = 1) rgeom(n, .2) + 2
#'
#' dates <- Sys.Date() - 1:3
#' admissions <- c(17, 15, 3)
#'
#' x <- run_model(dates,
#'                admissions,
#'                doubling = c(4.5, 5.1, 6, 4.8),
#'                duration = 14,
#'                r_los = r_duration,
#'                n_sim = 10)
#' x
#' plot(x)

run_model <- function(dates,
                      admissions,
                      doubling = NULL,
                      R = NULL,
                      si = NULL,
                      dispersion = 1,
                      duration,
                      r_los,
                      reporting = 1,
                      n_sim = 1) {
  ## check input
  if (all(is.null(c(doubling, si, R)))){
    msg <- "Must define either doubling times, `doubling`, or basic reproduction number, `R`, and serial interval, `si`"
    stop(msg)
  }
  
  n <- length(dates)
  if (n != length(admissions)) {
    msg <- "`dates` and `admissions` have different length"
    stop(msg)
  }
  if (n == 0L) {
    msg <- "`dates` is empty"
    stop(msg)
  }
  if (any(!is.finite(admissions))) {
    msg <- "some `admissions` are missing"
    stop(msg)
  }
  if (any(admissions < 1)) {
    msg <- "all `admissions` must be > 0"
    stop(msg)
  }
  
  
  ## order data
  dates <- linelist::guess_dates(dates,
                                 error_tolerance = 1,
                                 first_date = "2019-03-01",
                                 last_date = "3000-01-01")
  if (any(!is.finite(dates))) {
    msg <- "some `dates` are missing / invalid"
    stop(msg)
  }

  ord <- order(dates)
  dates <- dates[ord]
  admissions <- admissions[ord]
  last_date <- dates[n]
  last_admissions <- admissions[n]
  
  
  ## get projected admissions from the most recent date
  proj_admissions <- predict_admissions(date_start = last_date,
                                        n_start = last_admissions,
                                        doubling = doubling,
                                        R = R,
                                        si = si,
                                        dispersion = dispersion,
                                        duration = duration,
                                        reporting = reporting)

  ## add previous admission data
  if (n > 1) {
    previous_admissions <- projections::build_projections(
      x = admissions[-n],
      dates = dates[-n]
    )
    proj_admissions <- projections::merge_add_projections(
      list(previous_admissions,
           proj_admissions)
    )
  }

  ## get daily bed needs predictions for each simulated trajectory of admissions
  proj_dates <- projections::get_dates(proj_admissions)
  beds <- lapply(seq_len(ncol(proj_admissions)),
                 function(i) predict_beds(n_admissions = proj_admissions[,i],
                                          dates = proj_dates,
                                          r_los = r_los,
                                          n_sim = n_sim))

  beds <- projections::merge_projections(beds)
  beds
}
