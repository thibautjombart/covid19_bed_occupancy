## Model Description

This app implements a model to forecast COVID19 bed requirements based on a
starting point of admissions on a given date, a user-inputted epidemic growth rate, and an assumed distribution of length of stay after admission. This forecast can be adjusted to accommodate a certain assumed reporting percentage, if it is considered plausible that some hospitalised cases may not have their data reported. This may occur, for example, if admission rates are high and staff have limited opportunity to update the database with new records.

### Summary

The forecasting approach can be summarised as follows:

1. Augment the number of admissions by an assumed level of reporting. This is currently done by

<div style="text-align:center"> n<sub>aug</sub> = n<sub>reported</sub> / % <sub>reported</sub> </div>
 
2. Use a log-linear model, parametrised via the doubling time, to simulate epidemic trajectories; see for instance [Jombart et al 2020](https://www.eurosurveillance.org/content/10.2807/1560-7917.ES.2020.25.2.1900735). This is implemented by the RECON package [projections](https://cran.r-project.org/web/packages/projections/index.html).

3. For each admission, simulate duration of hospitalisation from the provided distribution.

4. Count beds for each day and simulation.


### User Inputs

The following values are specified by the user to tailor the model to a particular scenario. Model parameters are set with sensible defaults while a starting date and count for the forecast are required inputs.

* **Date of the reference admission**
  - *Required*
* **Number of admissions on that date**
  - *Required*
* **Duration of the forecast**, i.e. how far ahead to predict
  - Default: 14 days
* **Assumed reporting level in %** 
  - Default: 100%, i.e. all admissions reported
* **Assumed doubling time**, in days. This is the estimated time taken for the epidemic to double in size, and serves as a measure of transmission intensity.
  - Default: *look for sensible number from literature*
* **Uncertainty in doubling time**, in days. Since the doubling time is an estimated parameter, it is necessary to incorporate the potential error associated with it. Lower / upper bound will be doubling time +/- this value. 
  - Default: *?*
* **Number of simulations** to incorporate uncertainty in the duration of stay.
  Default: 50 simulated durations of stay per admission

### Pre-set model parameters

Two options for duration of hospitalisation are provided to match the results of [Zhou et al 2020](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30566-3/fulltext):

* Long-stay: discretised Weibull (shape:*?*, scale:*?*) to aim for a median of 11
    days, IQR 7-14
* Short-stay: discretised Weibull (shape:2, scale:10) to aim for a median of 8
    days, IQR 4-12

These distributions may not be appropriate in some settings, and the user should take this into account when interpreting a forecast.

## Caveats
* The current model assumes exponential growth. This is generally a reasonable approximation at the beginning of an epidemic however will become less appropriate as growth slows towards the peak. 

* Default distributions for the duration of stay will not be appropriate in all settings and this fact should be considered before drawing conclusions. 

## References

### Acknowledgements

The named authors (TJ, ESN, MJ, OLPDW, GMK, RME, AJK, CABP, WJE) had the following sources of funding: 
TJ receives funding from the Global Challenges Research Fund (GCRF) project 'RECAP' managed through RCUK and ESRC (ES/P010873/1), the UK Public Health Rapid Support Team funded by the United Kingdom Department of Health and Social Care and from the National Institute for Health Research (NIHR) - Health Protection Research Unit for Modelling Methodology. ESN receives funding from the Bill and Melinda Gates Foundation (grant number: OPP1183986). MJ receives funding from the Bill and Melinda Gates foundation (grant number: INV-003174) and the NIHR (grant numbers: 16/137/109 and HPRU-2012-10096). SRP receives funding  from the Bill and Melinda Gates Foundation (grant number: OPP1180644). RME receives funding from HDR UK (grant number: MR/S003975/1). SF is supported by a Sir Henry Dale Fellowship jointly funded by the Wellcome Trust and the Royal Society (Grant number 208812/Z/17/Z). AJK receives funding from the Wellcome Trust (grant number: 206250/Z/17/Z). GMK was supported by a fellowship from the UK Medical Research Council (MR/P014658/1).
 
The UK Public Health Rapid Support Team is funded by UK aid from the Department of Health and Social Care and is jointly run by Public Health England and the London School of Hygiene & Tropical Medicine. The University of Oxford and King's College London are academic partners. The views expressed in this publication are those of the authors and not necessarily those of the National Health Service, the National Institute for Health Research or the Department of Health and Social Care.

### Authors' contributions
In alphabetic order:
JE, MJ, TJ developed the methodology. 
ESN, MJ, TJ contributed code.
TJ performed the analyses.
ESN, TJ reviewed code.
ESN, TJ wrote the first draft of the manuscript.
GMK, AJK, CP, ESN, JE, MJ, OlP, RE, SF, TJ contributed to the manuscript.

CMMID COVID-19 Working Group gave input on the method, contributed data and provided elements of discussion. The following authors were part of the Centre for Mathematical Modelling of Infectious Disease 2019-nCoV working group: Billy J Quilty, Christopher I Jarvis, Petra Klepac, Charlie Diamond, Joel Hellewell, Timothy W Russell, Alicia Rosello, Yang Liu, James D Munday, Sam Abbott, Kevin van Zandvoort, Graham Medley, Samuel Clifford, Kiesha Prem, Nicholas Davies, Fiona Sun, Hamish Gibbs, Amy Gimma, Nikos I Bosse, Sebastian Funk. Each contributed in processing, cleaning and interpretation of data, interpreted findings, contributed to the manuscript, and approved the work for publication.
