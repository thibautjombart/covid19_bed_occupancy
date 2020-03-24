old_faithful <- function(bins) {
  x    <- faithful[, 2]
  bins <- seq(min(x), max(x), length.out = bins + 1)
  
  # draw the histogram with the specified number of bins
  hist(x, breaks = bins, col = 'darkgray', border = 'white')
}