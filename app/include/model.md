
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
[this post (1)](https://cmmid.github.io/topics/covid19/current-patterns-transmission/ICU-projections.html).


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




### References

Jombart et al. "Forecasting critical care bed requirements for COVID-19 patients in England". CMMID post, first online 2020-03-22. https://cmmid.github.io/topics/covid19/current-patterns-transmission/ICU-projections.html
