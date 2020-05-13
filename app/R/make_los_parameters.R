

los_parameters <- do.call(
    what = rbind,
    args = list(
        `Rees and Nightingale et al. non-critical care` = 
            data.frame(los_25 = 3,
                       los_75 = 9,
                       los_dist = "weibull"),
        `Rees and Nightingale et al. critical care` =
            data.frame(los_25 = 4,
                       los_75 = 11,
                       los_dist = "weibull"),
        `Zhou et al. non-critical care` = 
            data.frame(los_25 = 7,
                       los_75 = 14,
                       los_dist = "weibull"),
        `Zhou et al. critical care` =
            data.frame(los_25 = 4,
                       los_75 = 12,
                       los_dist = "weibull"),
        `Custom` = 
            data.frame(los_25   =  5,
                       los_75   =  13,
                       los_dist = "gamma")
    ))



los_parameters$name     <- rownames(los_parameters)
los_parameters$los_dist <- as.character(los_parameters$los_dist)
