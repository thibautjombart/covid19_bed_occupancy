## Model Description

This app implements a model to forecast COVID19 bed requirements based on a
starting point of admissions on a given date, a user-inputted epidemic growth
rate, and an assumed distribution of length of stay after admission. This
forecast can be adjusted to accommodate a certain assumed reporting percentage,
if it is considered plausible that some hospitalised cases may not have their
data reported. This may occur, for example, if admission rates are high and
staff have limited opportunity to update the database with new records.

### Summary

The forecasting approach can be summarised as follows:

1. Augment the number of admissions by an assumed level of reporting. This is
   currently done by
<div style="text-align:center"> n<sub>aug</sub> = n<sub>reported</sub> / %<sub>reported</sub> </div>
 
2. Use a log-linear model, parametrised via the doubling time, to simulate
   epidemic trajectories.

3. For each admission, simulate duration of hospitalisation from the
   length-of-stay distribution.

4. Count beds for each day and simulation.


### User Inputs

The following values are specified by the user to tailor the model to a
particular scenario. Model parameters are set with sensible defaults while a
starting date and count for the forecast are required inputs.

* **Date of the reference admission**
  - *Required*
* **Number of admissions on that date**
  - *Required*
  - Either critical admissions or non-critical admissions
* **Duration of the forecast**, i.e. how far ahead to predict
  - Default: 7 days
* **Assumed reporting level (%)** 
  - Default: 100%, i.e. all admissions reported
* **Assumed doubling time (days)** This is the estimated (mean) time taken for the epidemic to double in size, and serves as a measure of transmission intensity.
  - Default: 2
  - Plausible ranges 1.8 - 9.3. See [Muniz-Rodriguez et al 2020](https://www.medrxiv.org/content/10.1101/2020.02.05.20020750v4.full.pdf), [Zhao et al 2020](https://www.medrxiv.org/content/medrxiv/early/2020/02/29/2020.02.26.20028449.full.pdf), [Wu et al 2020](https://www.nature.com/articles/s41591-020-0822-7), [Li et al 2020](https://www.nejm.org/doi/full/10.1056/NEJMoa2001316), [Cheng et al 2020](https://link.springer.com/content/pdf/10.1007/s15010-020-01401-y.pdf) and [Granozio 2020](https://arxiv.org/ftp/arxiv/papers/2003/2003.08661.pdf) for references. 
* **Uncertainty in doubling time (coefficient of variation)** Since the doubling time is an estimated parameter, it is necessary to incorporate the potential error associated with it. The sampling distribution for the doubling time is an inverse gamma distribution parameterised in terms of the mean doubling time (defined by the user) and the coefficient of variation (i.e. &sigma;/&mu;). The shape and rate parameters of the inverse gamma distribution are calculated by moment matching. 
  - Default: &sigma;/&mu; = 0.1
* **Number of simulations** to incorporate uncertainty in the duration of stay.
  - Default: 10 simulated durations of stay per admission



### Pre-set model parameters

Two options for duration of hospitalisation are provided to match the results of
<a
href="https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30566-3/fulltext">Zhou
et al., 2020</a>:


* Long-stay: discretised Weibull (shape: 2, scale: 13) targeting a median of 11
    days, IQR 7-14
* Short-stay: discretised Weibull (shape: 2, scale: 10) targeting a median of 8
    days, IQR 4-12

These distributions may not be appropriate in some settings, and the user should
take this into account when interpreting a forecast.



## Caveats

* The current model assumes exponential growth. This is generally a reasonable
  approximation at the beginning of an epidemic however will become less
  appropriate as growth slows towards the peak.

* Default distributions for the duration of stay will not be appropriate in all
  settings and this fact should be considered before drawing conclusions.



## References

Jombart et al. "Forecasting critical care bed requirements for COVID-19 patients in England". CMMID post, first online 2020-03-22. https://cmmid.github.io/topics/covid19/current-patterns-transmission/ICU-projections.html

Zhou, Fei, et al. "Clinical Course and Risk Factors for Mortality of Adult Inpatients with COVID-19 in Wuhan, China: a Retrospective Cohort Study." _The Lancet_, 2020. <a href="https://doi.org/10.1016/s0140-6736(20)30566-3">doi:10.1016/s0140-6736(20)30566-3</a>.

