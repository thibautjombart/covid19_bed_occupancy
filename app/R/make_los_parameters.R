

los_parameters <- do.call(
    what = rbind,
    args = list(
        `CMMID General (World)` = 
            data.frame(los_25 = 3,
                       los_75 = 9,
                       los_dist = "weibull"),
        `CMMID General (China)` =
            data.frame(los_25 = 10,
                       los_75 = 19,
                       los_dist = "weibull"),
        `Zhou non-ICU (China)` = 
            data.frame(los_25 = 7,
                       los_75 = 14,
                       los_dist = "weibull"),
        `CMMID ICU (World)` = 
            data.frame(los_25 = 4,
                       los_75 = 11,
                       los_dist = "weibull"),
        `CMMID ICU (China)` =
            data.frame(los_25 = 5,
                       los_75 = 13,
                       los_dist = "weibull"),
        `Zhou ICU (China)` =
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
