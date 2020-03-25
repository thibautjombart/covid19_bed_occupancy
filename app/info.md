### Model Description

## Summary

The principle of the estimation is:

1. Augment the number of admissions using the reporting. This is currently done by

 n<sub>aug</sub> = n<sub>reported</sub> / % reported
 
2. Use a log-linear model, parametrised through the doubling time, to simulate epidemic trajectories; see for instance Jombart et al 2020; this is implemented by the RECON package projections.

3. For each admission, simulate duration of hospitalisation from provided distribution.

4. Count beds for each day and simulation.


### Model Parameters

This section contain information on the various parameters. We use these
data to generate a distribution, with discretisation when needed.

* **Duration of hospitalisation**:
    + non-critical care: discretised Weibull(shape:, scale:) to aim for a median of 11
      days, IQR 7-14
    + critical care: discretised Weibull(shape:2, scale:10) to aim for a median of 8
      days, IQR 4-12
    + See Table 2 in 
	[source](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30566-3/fulltext)

## Caveats
* The current model assumes exponential growth

* Default distributions for the duration of stay are provided by matching results of 
[Zhou et al 2020](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(20)30566-3/fulltext). 
These distributions may need changing under some settings.

## References

### Acknowledgements

The named authors (TJ, ESN, MJ, OLPDW, GK, RME, AJK, CABP, WJE) had the following sources of funding: 
TJ receives funding from the Global Challenges Research Fund (GCRF) project 'RECAP' managed through RCUK and ESRC (ES/P010873/1), the UK Public Health Rapid Support Team funded by the United Kingdom Department of Health and Social Care and from the National Institute for Health Research (NIHR) - Health Protection Research Unit for Modelling Methodology. ESN receives funding from the Bill and Melinda Gates Foundation (grant number: OPP1183986). MJ receives funding from the Bill and Melinda Gates foundation (grant number: INV-003174) and the NIHR (grant numbers: 16/137/109 and HPRU-2012-10096). SRP receives funding  from the Bill and Melinda Gates Foundation (grant number: OPP1180644). RME receives funding from HDR UK (grant number: MR/S003975/1). SF is supported by a Sir Henry Dale Fellowship jointly funded by the Wellcome Trust and the Royal Society (Grant number 208812/Z/17/Z). AJK receives funding from the Wellcome Trust (grant number: 206250/Z/17/Z).  
 
The UK Public Health Rapid Support Team is funded by UK aid from the Department of Health and Social Care and is jointly run by Public Health England and the London School of Hygiene & Tropical Medicine. The University of Oxford and King's College London are academic partners. The views expressed in this publication are those of the authors and not necessarily those of the National Health Service, the National Institute for Health Research or the Department of Health and Social Care.

## Authors' contributions
In alphabetic order:
JE, MJ, TJ developed the methodology. 
ESN, MJ, TJ contributed code.
TJ performed the analyses.
ESN, TJ reviewed code.
ESN, TJ wrote the first draft of the manuscript.
AK, CP, ESN, JE, MJ, OlP, RE, SF, TJ contributed to the manuscript.

CMMID COVID-19 Working Group gave input on the method, contributed data and provided elements of discussion. The following authors were part of the Centre for Mathematical Modelling of Infectious Disease 2019-nCoV working group: Billy J Quilty, Christopher I Jarvis, Petra Klepac, Charlie Diamond, Joel Hellewell, Timothy W Russell, Alicia Rosello, Yang Liu, James D Munday, Sam Abbott, Kevin van Zandvoort, Graham Medley, Samuel Clifford, Kiesha Prem, Nicholas Davies, Fiona Sun, Hamish Gibbs, Amy Gimma, Nikos I Bosse, Sebastian Funk. Each contributed in processing, cleaning and interpretation of data, interpreted findings, contributed to the manuscript, and approved the work for publication.
