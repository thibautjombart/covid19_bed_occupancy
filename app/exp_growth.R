exp_growth <- function(R, serial_interval) {
  times <- seq(0, 10*serial_interval, by=0.1)
  plot(times, R**(times/serial_interval), type="l")
}