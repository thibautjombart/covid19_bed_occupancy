
## Model Description

This app can be used to forecast COVID-19 bed requirements for up to 21 days in
a given location (e.g. a healthcare facility, a county, a state). Data on a
number of reported admissions on a given date are used to define the starting
point of the model. Future admissions are simulated using an exponential model
and length of hospital stay for each new admitted patient is simulated using
pre-specified distributions, depending on the type of hospitalisation (critical
or non-critical care).

Forecast can be adjusted to accommodate a certain assumed reporting percentage,
if it is considered plausible that some hospitalised cases may not have their
data reported. This may occur, for example, if admission rates are high and
staff have limited opportunity to update the database with new records.
Bed occupancies for non-critical care and critical care are modelled separately
(see caveats).

This app generalises a model used for predicting COVID-19 critical care bed requirements in
England introduced in 
[this post](https://cmmid.github.io/topics/covid19/current-patterns-transmission/ICU-projections.html).



### Summary

The forecasting approach can be summarised as follows; for each simulation:

1. Augment the number of admissions by an assumed level of reporting. This is
   currently done by:
<div> n<sub>aug</sub> = n<sub>reported</sub> / %<sub>reported</sub> </div>
 
2. Use a log-linear model, parametrised via the doubling time (drawn from an
   inverse Gamma distribution, with user-specified mean and coefficient of
   variation), to simulate future daily admissions trajectories.

3. For each admission, simulate duration of hospitalisation from the
   length-of-stay distribution. This is drawn from the chosen distribution (see
   below: "Duration of hospitalisation").

4. Count beds for each day simulation.




## Inputs

### Data

The following values are specified by the user to tailor the model to a
particular scenario. Model parameters are set with sensible defaults while a
starting date and count for the forecast are required inputs.

* **Date of the reference admission**
  - *Required*
* **Number of admissions on that date**
  - *Required*
  - Either critical admissions or non-critical admissions

 

### Duration of hospitalisation

Several options are available to specify the distribution of the length of
hospital stay (LOS), i.e. the number of days between the admission to a service
and the discharge. LOS reported in the literature vary widely across countries
and type of hospitalisation (critical or non-critical), so that we recommend,
where possible, to use the *custom* distribution adapted to the context of the
analysis.

Currently available options are:

* **Custom**: will generate a discretized Gamma distribution with specified mean and
  coefficient of variation. Note that the distribution is generated so that LOS
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

* **Duration of the forecast**, i.e. how far ahead to predict
  - Default: 7 days
* **Assumed reporting level (%)** 
  - Default: 100%, i.e. all admissions reported
* **Assumed doubling time (days)** This is the estimated (mean) time taken for the epidemic to double in size, and serves as a measure of transmission intensity.
  - Default: 2
  - Plausible ranges 1.8 - 9.3. See [Muniz-Rodriguez et al 2020](https://www.medrxiv.org/content/10.1101/2020.02.05.20020750v4.full.pdf), [Zhao et al 2020](https://www.medrxiv.org/content/medrxiv/early/2020/02/29/2020.02.26.20028449.full.pdf), [Wu et al 2020](https://www.nature.com/articles/s41591-020-0822-7), [Li et al 2020](https://www.nejm.org/doi/full/10.1056/NEJMoa2001316), [Cheng et al 2020](https://link.springer.com/content/pdf/10.1007/s15010-020-01401-y.pdf) and [Granozio 2020](https://arxiv.org/ftp/arxiv/papers/2003/2003.08661.pdf) for references. 
* **Uncertainty in doubling time (coefficient of variation)** Since the doubling time is an estimated parameter, it is necessary to incorporate the potential error associated with it. The sampling distribution for the doubling time is an inverse gamma distribution parameterised in terms of the mean doubling time (defined by the user) and the coefficient of variation (i.e. &sigma;/&mu;). The shape and rate parameters of the inverse gamma distribution are calculated by moment matching. 
  - Default: &sigma;/&mu; = 0.1
* **Number of simulations** to incorporate uncertainty in the doubling time and duration of stay.
  - Default: 10 simulations.




## Caveats

* The current model assumes exponential growth. This is generally a reasonable
  approximation at the beginning of an epidemic however will become less
  appropriate as growth slows towards the peak.

* Default distributions for the duration of stay will not be appropriate in all
  settings and this fact should be considered before drawing conclusions.

* The bed occupancy in non-critical and critial wards are modelled
  independently, so that there is no interplay between the two. Fruther
  refinements of the model are looking at incorporating patient movements
  between non-critical and critical care wards.


### References

Jombart et al. "Forecasting critical care bed requirements for COVID-19 patients in England". CMMID post, first online 2020-03-22. https://cmmid.github.io/topics/covid19/current-patterns-transmission/ICU-projections.html

Zhou, Fei, et al. "Clinical Course and Risk Factors for Mortality of Adult Inpatients with COVID-19 in Wuhan, China: a Retrospective Cohort Study." _The Lancet_, 2020. <a href="https://doi.org/10.1016/s0140-6736(20)30566-3">doi:10.1016/s0140-6736(20)30566-3</a>.


