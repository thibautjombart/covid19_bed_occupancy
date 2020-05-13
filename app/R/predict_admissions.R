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

predict_admissions <- function(dates,
                               n_admissions,
                               doubling,
                               R,
                               si,
                               dispersion,
                               duration,
                               reporting = 1) {
  
  ## Sanity checks
  if (length(dates) < 1L) stop("`dates` must contain at least one number")
  if (length(n_admissions) < 1L) stop("`n_admissions` must contain at least one number")
  if (!all(is.finite(n_admissions))) stop("`n_admissions` are not all numeric and finite")
  #if (any(n_start < 1)) stop("`n_admissions` must be >= 1") # i'm not sure this is necessary
  
  if (!is.null(doubling) & !all(is.finite(doubling))) stop("`doubling` is not a number")
  
  if (!is.finite(duration)) stop("`duration` is not a number")
  if (duration < 1) stop("`duration` must be >= 1")
  
  if (length(reporting) != 1L) stop("`reporting` must contain exactly one value")
  if (!is.finite(reporting)) stop("`reporting` is not a number")
  if (reporting <= 0) stop("`reporting` must be > 0")
  if (reporting > 1) stop("`reporting` must be <= 1")
  
  ## Outline:
  
  ## This function calculates future admissions using an exponential model. The
  ## growth rate is calculated from the doubling time, using: r = log(2) / d
  
  ## future dates and initial conditions
  future_dates       <- seq(tail(dates,1), length.out = duration, by = 1L)
  all_admissions     <- round(n_admissions / reporting)
  initial_admissions <- tail(all_admissions, 1) # this is for the doubling process

  
  if (!is.null(doubling) & length(doubling) > 0){
    ## calculate growth rate from doubling times
    r_values <- log(2) / doubling
    dates_num <- as.numeric(dates)
    tail_date <- tail(dates_num,1)
    
    ## calculate future admissions
    future_admissions <- lapply(r_values,
                                function(r){
                                  # fit a model for the doubling/halving rate to recent data
                                  # use this to get expected number of cases on final day of admissions
                                  model <- stats::glm(n_admissions ~ 1, 
                                                      offset = r*dates_num,
                                                      family = "poisson")
                                  admissions0 <- as.numeric(
                                    stats::predict.glm(object = model,
                                                       newdata = data.frame(
                                                         dates_num = tail_date,
                                                         r = r), 
                                                       type = "response"))
                                  # end fit a model
                                  round(admissions0 * exp(r * (seq_len(duration) - 1)))
                                })
    
    ## build output
    future_admissions <- matrix(unlist(future_admissions), ncol = length(doubling))
    out <- projections::build_projections(x = future_admissions,
                                          date = future_dates)
  } else {
    
    # use branching process
    current_incidence <- incidence::incidence(dates = rep(dates, n_admissions))
    out <- projections::project(x = current_incidence, 
                                R = R,
                                si = si,
                                n_sim = length(R), 
                                n_days = duration,
                                R_fix_within = TRUE,
                                model = "negbin",
                                size = dispersion)
  } 
  
  
  
  
  out
}

