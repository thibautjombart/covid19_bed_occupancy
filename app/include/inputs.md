
## Data

### Minimum data: admissions on a single day

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

 
### Recommended data: admissions over time

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


 

## Length of hospital stay

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

* **Rees and Nightingale et al. non-critical care**: discretised Weibull (shape: 1.2, scale: 6.9) resulting from a systematic review of length of stay for general (non-ICU) admissions outside of China ([Rees and Nightingale et al., 2020](https://doi.org/10.1101/2020.04.30.20084780)).

* **Rees and Nightingale et al. critical care**: discretised Weibull (shape: 1.5, scale: 8.7) resulting from a systematic review of length of stay for ICU admissions outside of China ([Rees and Nightingale et al., 2020](https://doi.org/10.1101/2020.04.30.20084780)).

* **Zhou et al. non-critical care**: discretised Weibull (shape: 2, scale: 13) targeting a median of 11
    days, IQR 7-14, as reported for general hospitalisation in <a
	href="https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30566-3/fulltext">Zhou
	et al., 2020</a>:


* **Zhou et al. critical care**: discretised Weibull (shape: 2, scale: 10) targeting a median of 8
    days, IQR 4-12, as reported for hospitalisation in critical care in <a
	href="https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30566-3/fulltext">Zhou
	et al., 2020</a>:

The default option is the non-critical setting from non-China studies published by [Rees and Nightingale et al.  (2020)](https://doi.org/10.1101/2020.04.30.20084780)
  
## Growth parameters

### Doubling/halving time

* **Assumed doubling/halving time (days)** This is the estimated (mean) time taken for the epidemic to double (or halve) in size, and serves as a measure of transmission intensity.
    + Default: 7.7
    + Plausible ranges: 1.8 - 9.3. See [Muniz-Rodriguez et al 2020](https://doi.org/10.3201/eid2608.200219), [Zhao et al 2020](https://www.medrxiv.org/content/medrxiv/early/2020/02/29/2020.02.26.20028449.full.pdf), [Wu et al 2020](https://www.nature.com/articles/s41591-020-0822-7), [Li et al 2020](https://www.nejm.org/doi/full/10.1056/NEJMoa2001316), [Cheng et al 2020](https://link.springer.com/content/pdf/10.1007/s15010-020-01401-y.pdf) and [Granozio 2020](https://arxiv.org/ftp/arxiv/papers/2003/2003.08661.pdf) for references. 
* **Uncertainty in doubling time (coefficient of variation)**: the sampling
  distribution for the doubling time is an inverse gamma distribution
  parameterised in terms of the mean doubling time (defined by the user) and the
  coefficient of variation (i.e. &sigma;/&mu;) which are then used for moment-matching
  to determine appropriate values of the distribution's shape and rate parameters (&alpha;, &beta;).
    + Default: &sigma;/&mu; = 0.33

The default values here are drawn from the early dynamics reported by <a href="https://www.nejm.org/doi/full/10.1056/NEJMoa2001316">Li et al. (2020)</a>.

When "halving" is selected, the epidemic is considered to be decreasing in intensity by exponential decay in case numbers rather than increasing when characterised by a doubling time.

### Branching process

Alternatively, the epidemic may be parameterised according to a branching process where every generation time (or serial interval) each case generates a number of secondary cases. The number of secondary cases is parameterised with a negative binomial distribution with a mean, <i>&mu;</i>, and dispersion, _k_, parameter.

* **Basic reproduction number**, i.e <i>R</i><sub>0</sub> the average number of secondary infections each case goes on to cause. This is parameterised by an average and coefficient of variation <i>c<sub>v,R<sub>0</sub></sub></i> which are moment matched to the shape, &alpha;, and scale, &beta;, parameters of a gamma distribution. The average behaviour of the epidemic is governed by the size of <i>R</i><sub>0</sub>, namely whether or not sufficient new cases are being generated to replace those who recover.
    - <i>R</i><sub>0</sub> &gt; 1: the epidemic grows exponentially as cases infect above replacement
    - <i>R</i><sub>0</sub> &asymp; 1: the epidemic is stable 
    - <i>R</i><sub>0</sub> &lt; 1: cases are not being replaced and the epidemic growth slows until there are no new cases
    
The default value is for <i>R</i><sub>0</sub> to have an average of 2.5 and <i>c<sub>v,R<sub>0</sub></sub></i> of 0.26, corresponding to a 95% interval of (1.4, 3.9) which matches the early dynamics of the outbreak in Wuhan ([Li et al., 2020](https://doi.org/10.1056/NEJMoa2001316)) prior to the introduction of lockdown, travel restrictions or social distancing measures. Check local estimates of reproduction in order to describe how much transmission is occurring in your setting, e.g. https://epiforecasts.io/covid/reports.html.  

* **Dispersion parameter**, <i>k</i>, for a negative binomial distribution with mean <i>&mu; = R</i><sub>0</sub>, describes the number of cases <i>each individual</i> is likely to go on to infect. For smaller values of <i>k</i> and the same <i>R</i><sub>0</sub> it is more probable that an individual will cause 0 new infections. This parameter therefore controls how likely superspreading events are in driving the epidemic. The default value of 0.54 is based on an early estimate of human to human transmission ([Riou and Althaus, 2020](https://doi.org/10.2807/1560-7917.ES.2020.25.4.2000058)) and an alternative is provided based on analysis indicating that 80% of transmission is caused by 10% of cases ([Endo et al., 2020](https://doi.org/10.12688/wellcomeopenres.15842.1)).

* **Serial interval**, the length of time between successive generations of infection. This describes, on average, how long it takes from the infection of a case to a secondary infection. Specified as an average time and coefficient of variation, <i>c<sub>v,S</sub></i>, the specified parameters are moment matched to the shape, &alpha;, and scale, &beta;, of an inverse gamma distribution.
    * Defaults are based on the early transmission dynamics in [Li et al 2020](https://www.nejm.org/doi/full/10.1056/NEJMoa2001316)
        - Average serial interval: 7.5 days
        - <i>c<sub>v,S</sub></i>: 0.45

## Simulation parameters

* **Duration of the forecast**, i.e. how far ahead to predict
  - Default: 7 days
* **Number of simulations** to incorporate uncertainty in the doubling time and LoS.
  - Default: 10 simulations.




## References

Zhou, Fei, et al. "Clinical Course and Risk Factors for Mortality of Adult Inpatients with COVID-19 in Wuhan, China: a Retrospective Cohort Study." _The Lancet_, 2020. <a href="https://doi.org/10.1016/s0140-6736(20)30566-3">doi:10.1016/s0140-6736(20)30566-3</a>.


