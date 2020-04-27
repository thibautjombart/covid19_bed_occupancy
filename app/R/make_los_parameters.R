los_parameters <- do.call(
    what = rbind,
    args = list(
        `Custom` = 
            data.frame(mean_los =  7,
                       cv_los   =  0.1,
                       los_dist = "gamma"),
        `Zhou et al. non-critical care` = 
            data.frame(mean_los = 11.52095,
                       cv_los   =  0.5227232,
                       los_dist = "weibull"),
        `Zhou et al. critical care` =
            data.frame(mean_los =  8.862269,
                       cv_los   =  0.5227232,
                       los_dist = "weibull")
    ))

los_parameters$name <- rownames(los_parameters)
los_parameters$los_dist <- as.character(los_parameters$los_dist)
