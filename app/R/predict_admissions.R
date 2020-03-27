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
#' @param doubling A vector of doubling times, in days.
#'
#' @param reporting The proportion of admissions reported; defaults to 1,
#'   i.e. all admissions are reported.
#'
#' @param long A `logical` indicating whether output should have a `long`
#'   format, e.g. for easier plotting with `ggplot2`.
#'
#' @examples
#'
#' doubling_times <- rnorm(50, mean = 5, sd = 0.5)
#' x <- predict_admissions(Sys.Date(),
#'                         n_start = 40,
#'                         doubling = doubling_times,
#'                         duration = 14) 
#' x
#' 

predict_admissions <- function(date_start,
                               n_start,
                               doubling,
                               duration,
                               reporting = 1) {

  ## Sanity checks
  if (!is.finite(n_start)) stop("`n_start` is not a number")
  if (n_start < 1) stop("`n_start` must be >= 1")

  if (!all(is.finite(doubling))) stop("`doubling` is not a number")

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
  r_values <- log(2) / doubling

  ## calculate future admissions
  future_admissions <- lapply(r_values,
                              function(r)
    round(initial_admissions * exp(r * (seq_len(duration) - 1))))

  ## build output
  future_admissions <- matrix(unlist(future_admissions), ncol = length(doubling))
  out <- projections::build_projections(x = future_admissions,
                                        date = future_dates)
  out
}

