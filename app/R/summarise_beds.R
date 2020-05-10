
## summarise output of run_model, return a table of quantiles per day

summarise_beds <- function(x) {

  ## auxiliary function used to generate the table summary
  summary_function <- function(x) {
    c(q_025 = round(quantile(x, 0.025)),
      q_25 = round(quantile(x, 0.25)),
      q_50 = round(quantile(x, 0.5)),
      q_75 = round(quantile(x, 0.75)),
      q_95 = round(quantile(x, 0.975)))
  }
  summary_table <- t(apply(x, 1, summary_function))

  ## Make dates a variable
  dates <- rownames(summary_table)
  summary_table <- as.data.frame(summary_table)
  rownames(summary_table) <- NULL
  summary_table$date <- as.Date(dates)
  
  ##Sort variables
  summary_table <- summary_table[, c(ncol(summary_table), 1:(ncol(summary_table) - 1))]
  
  colnames(summary_table) <- c("Date",
                               "lower 95%",
                               "lower 50%",
                               "Median",
                               "upper 50%",
                               "upper 95%")
  summary_table
}
