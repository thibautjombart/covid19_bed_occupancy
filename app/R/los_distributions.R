


## * **Duration of hospitalisation**:
##     + non critical care: discretised Weibull(shape:2, scale:13) to aim for a median of 11
##       days, IQR 7-14
##     + critical care: discretised Weibull(shape:2, scale:10) to aim for a median of 8
##       days, IQR 4-12
##     + See table 2 in 
## 	[source](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30566-3/fulltext)

## los = "length of stay"
## los_normal for non critical care hospitalisation
los_normal <- distcrete::distcrete("weibull", shape = 2, scale = 13, w = 0, interval = 1)

## los_critical for critical care
los_critical <- distcrete::distcrete("weibull", shape = 2, scale = 10, w = 0, interval = 1)
