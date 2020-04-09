#' Check input data.frame
#'
#' Internal function to check content of the data uploaded by the user. If the
#' data is `NULL` or missing, it returns `NULL`. The function performs a number
#' of checks, issuing errors if they fail. If not, it returns a clean
#' `data.frame` which can be passed on to `run_model` for further analysis.
#'
#' @author Thibaut Jombart
#'


check_uploaded_data <- function(x) {
  if (is.null(x) || missing(x)) {
    return(NULL)
  }

  if (ncol(x) != 2) {
    msg <- "Input data must have 2 columns"
    stop(msg)
  }

  if (!nrow(x)) {
    msg <- "Input data must have at least one row of data"
    stop(msg)
  }

  names(x) <- c("date", "n_admissions")
  x

}
