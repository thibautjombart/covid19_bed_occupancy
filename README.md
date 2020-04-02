[![DOI](https://zenodo.org/badge/249441528.svg)](https://zenodo.org/badge/latestdoi/249441528)


## App

To start the app, download this repository, start R in the `app/` folder, and type:

```r
shiny::runApp("app.R")
```

Alternatively, you can use the [online version of the app](https://cmmid-lshtm.shinyapps.io/hospital_bed_occupancy_projections/).


## Model

This folder contains a
[reportfactory](https://github.com/reconhub/reportfactory) with reports
providing a proof of concept and implementation of the model used for
forecasting admissions and hospital beds.


### Initial setup

You will first need to install dependencies before compiling the documents in
this factory. We recommend using the latest version of R. Double-click on
`open.Rproj` (or just start R in the `model/` folder) and copy-paste the
following instructions:

```r

if (!require(reportfactory)) remotes::install_github("reconhub/reportfactory")

library(reportfactory)
rfh_load_scripts()
install_deps()

```



### Compiling the report

 To compile the report, double-click on `open.Rproj` (or just start R
in the `model/` folder) and type:

```r

reportfactory::update_reports(clean_report_sources = TRUE)

```

Dated and time-stamped outputs (including the `html` version of the report) will
be generated in `report_outputs`.



### Using the source

The source of the report is an *Rmarkdown* document stored in
`report_sources/`. If you plan on working on your own local copy, we recommend
either using version control systems (e.g. GIT) to track changes, or creating
new versions in `report_sources/` with a more recent date in the file name. Note
that by default, `reportfactory::update_reports()` will always compile the
latest version of reports.




<br>
<br>

### License

This work is distributed under MIT License (see LICENSE file).
