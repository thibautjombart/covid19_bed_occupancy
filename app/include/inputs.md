
### Data

#### Minimum data: admissions on a single day

The **minimum data** to use the app is a number of new admissions reported on a
given day, used as starting point for the growth model and subsequent simulation
of hospitalisations. If only this data is provided, the model will project bed
occupancy for **new admissions only**, i.e. **not accounting for cases admitted
before the starting point**.

* **Date of admission**: date of admission, provided using the format
  *yyyy-mm-dd*; defaults to current day
* **Number of admissions on that date**: number of new admissions on the date
  provided; defaults to 1
* **Assumed reporting level (%)**: the proportion of admissions reported;
  defaults to 100%, i.e. all admissions reported

 
#### Recommended data: admissions over time

The **recommended data** are numbers of daily admissions over time for the
recent days. This will allow the model to account for bed occupancy from
previously admitted patients as well as future admissions. To provide these
data, you need to upload a spreadsheet (we recommend `.xlsx` format), with 2
columns:

* **date**: dates at which new admissions have been recorded, using the
  *yyy-mm-dd* format; for instance, 1982-02-04 is the 4th February 1982
  
* **n_admissions**: number of new admissions on these days

To avoid data entry issues, we recommend using our 
<a href="https://github.com/thibautjombart/covid19_bed_occupancy/blob/master/app/extra/data_model.xlsx?raw=true"> data template</a>.


 

### Length of hospital stay

Several options are available to specify the distribution of the length of
hospital stay (LoS), i.e. the number of days between the admission to a service
and the discharge. LoS reported in the literature vary widely across countries
and type of hospitalisation (critical or non-critical), so that we recommend,
where possible, to use the *custom* distribution adapted to the context of the
analysis.

Currently available options are:

* **Custom**: will generate a discretized distribution with specified mean and
  coefficient of variation (i.e. <i>c<sub>v</sub></i> = &sigma;/&mu;, which expresses how spread out the
  distribution is as a fraction of its mean). The shape and scale parameters of
  the gamma distribution (_k_,  &theta;) or Weibull distribution (_k_,  &lambda;) are calculated by moment matching (deriving their 
  values from the values of &mu; and &sigma;). Note that the distribution is generated so that LoS
  must be positive.

* **Zhou et al non-critical care**: discretised Weibull (shape: 2, scale: 13) targeting a median of 11
    days, IQR 7-14, as reported for general hospitalisation in <a
	href="https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30566-3/fulltext">Zhou
	et al., 2020</a>:


* **Zhou et al critical care**: discretised Weibull (shape: 2, scale: 10) targeting a median of 8
    days, IQR 4-12, as reported for hospitalisation in critical care in <a
	href="https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30566-3/fulltext">Zhou
	et al., 2020</a>:


  
### Growth parameters

* **Assumed doubling time (days)** This is the estimated (mean) time taken for the epidemic to double in size, and serves as a measure of transmission intensity.
    + Default: 7
    + Plausible ranges: 1.8 - 9.3. See [Muniz-Rodriguez et al 2020](https://www.medrxiv.org/content/10.1101/2020.02.05.20020750v4.full.pdf), [Zhao et al 2020](https://www.medrxiv.org/content/medrxiv/early/2020/02/29/2020.02.26.20028449.full.pdf), [Wu et al 2020](https://www.nature.com/articles/s41591-020-0822-7), [Li et al 2020](https://www.nejm.org/doi/full/10.1056/NEJMoa2001316), [Cheng et al 2020](https://link.springer.com/content/pdf/10.1007/s15010-020-01401-y.pdf) and [Granozio 2020](https://arxiv.org/ftp/arxiv/papers/2003/2003.08661.pdf) for references. 
* **Uncertainty in doubling time (coefficient of variation)**: the sampling
  distribution for the doubling time is an inverse gamma distribution
  parameterised in terms of the mean doubling time (defined by the user) and the
  coefficient of variation (i.e. &sigma;/&mu;) which are then used for moment-matching
  to determine appropriate values of the distribution's shape and rate parameters (&alpha;, &beta;).
    + Default: &sigma;/&mu; = 0.1



## Simulation parameters

* **Duration of the forecast**, i.e. how far ahead to predict
  - Default: 7 days
* **Number of simulations** to incorporate uncertainty in the doubling time and LoS.
  - Default: 10 simulations.




### References

Zhou, Fei, et al. "Clinical Course and Risk Factors for Mortality of Adult Inpatients with COVID-19 in Wuhan, China: a Retrospective Cohort Study." _The Lancet_, 2020. <a href="https://doi.org/10.1016/s0140-6736(20)30566-3">doi:10.1016/s0140-6736(20)30566-3</a>.


