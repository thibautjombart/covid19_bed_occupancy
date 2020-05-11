los_parameters <- do.call(
    what = rbind,
    args = list(
        `Rees and Nightingale et al. non-critical care` = 
            data.frame(mean_los = 6.49,
                       cv_los   = 0.84,
                       los_dist = "weibull"),
        `Rees and Nightingale et al. critical care` =
            data.frame(mean_los = 7.93,
                       cv_los   = 0.696,
                       los_dist = "weibull"),
        `Zhou et al. non-critical care` = 
            data.frame(mean_los = 11.52095,
                       cv_los   =  0.5227232,
                       los_dist = "weibull"),
        `Zhou et al. critical care` =
            data.frame(mean_los =  8.862269,
                       cv_los   =  0.5227232,
                       los_dist = "weibull"),
        `Custom` = 
            data.frame(mean_los =  7,
                       cv_los   =  0.1,
                       los_dist = "gamma")
    ))

los_parameters$name <- rownames(los_parameters)
los_parameters$los_dist <- as.character(los_parameters$los_dist)
