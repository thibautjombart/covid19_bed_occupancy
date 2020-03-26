#' Forecast admissions using an exponential model
#'
#' This function projects future admissions using a single point of reference (a
#' date and a number of admissions on that date) and a user-specficied growth
#' rate, with associated uncertainty.
#'
#' @author Thibaut Jombart
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
#' @param long A `logical` indicating whether output should have a `long`
#'   format, e.g. for easier plotting with `ggplot2`.
#'
#' @examples
#'
#' x <- predict_admissions(Sys.Date(),
#'                         n_start = 40,
#'                         doubling = 5,
#'                         doubling_error = 1,
#'                         duration = 14) 
#' x
#' 

predict_admissions <- function(date_start,
                               n_start,
                               doubling,
                               doubling_error,
                               duration,
                               reporting = 1,
                               long = FALSE) {

  ## Sanity checks
  if (!is.finite(n_start)) stop("`n_start` is not a number")
  if (n_start < 1) stop("`n_start` must be >= 1")

  if (!is.finite(doubling)) stop("`doubling` is not a number")
  if (!is.finite(doubling_error)) stop("`doubling_error` is not a number")

  if (!is.finite(duration)) stop("`duration` is not a number")
  if (duration < 1) stop("`duration` must be >= 1")

  if (!is.finite(reporting)) stop("`reporting` is not a number")
  if (reporting <= 0) stop("`reporting` must be > 0")
  if (reporting > 1) stop("`reporting` must be <= 1")
  

  ## Outline:

  ## This function calculates future admissions using an exponential model. The
  ## growth rate is calculated from the doubling time, using: r = log(2) / d
  
  ## future dates and initial conditions
  future_dates <- seq(date_start, length.out = duration, by = 1L)
  initial_admissions <- round(n_start / reporting)

  ## calculate growth rate from doubling times
  r <- log(2) / doubling
  r_low <- log(2) / (doubling - doubling_error)
  r_high <- log(2) / (doubling + doubling_error)

  ## calculate future admissions
  future_admissions <- initial_admissions * exp(r * (seq_len(duration) - 1))
  future_admissions_low <- initial_admissions * exp(r_low * (seq_len(duration) - 1))
  future_admissions_high <- initial_admissions * exp(r_high * (seq_len(duration) - 1))
  future_admissions <- round(future_admissions)
  future_admissions_low <- round(future_admissions_low)
  future_admissions_high <- round(future_admissions_high)

  ## build output
  out <- data.frame(date = future_dates,
                    mean = future_admissions,
                    low = future_admissions_low,
                    high = future_admissions_high)

  if (long) {
    out <- tidyr::pivot_longer(out, -1,
                               names_to = "prediction",
                               values_to = "n")
    out$prediction <- factor(out$prediction,
                             levels = c("low", "mean", "high"))
  }
  out
}

