# imf.qpm

This set of codes is based on IMF's Quarterly Projection Model

- Credits to IRIS Solutions team [(IRIS Toolbox)](https://github.com/IRIS-Solutions-Team/IRIS-Toolbox)  
- The codes are obtained from [IMFx MPAFx Monetary Policy Analysis and Forecasting](https://www.imf.org/en/Capacity-Development/Training/ICDTC/Courses/MPAFx) on EdX.

Please go to the site and enroll if you are interested. 


## What I added

In the original codes provided by IMF, the model used is a calibrated one. Calibrating a large system such as the QPM can be challenging and requires a lot of tedious trial and errors. In a lot of cases, we also want to be able to estimate the parameters so that the output is as close to the data as possible.

In this repo, I added three scripts that do exactly this, with 3 methods (maximum likelihood, Bayesian, and System Priors). 
The approach is based on [A Cook-Book of IRIS](https://www.mv.helsinki.fi/home/ajripatt/opetus/metrics/IRIS_cookbook.pdf#page=49.24) by Jaromir Benes & Martin Fukac. 
I adapted the codes there to produce `a07_estimate_mle` and `a07_estimate_bayesian` that perform the relevant estimation and then save the posterior mean into `pE`.
The script `readmodel_est.m` will replace `readmodel.m` in this case.
Benes later added a System-priors approach ([here](https://github.com/jaromir-benes/nifi-workshop-202109)), which can only be implemented with IRIS 2021 onwards. 
If you want to try this approach, run `a07_estimate_system` in the repo and remember to use IRIS 2021 instead of IRIS 2018.

## Comparison

The calibrated model

![](https://github.com/thanhqtran/imf.qpm/blob/76b631445f117985a0264d72f0cca351faadcfaa/calibrate.png)

The estimated model

![](https://github.com/thanhqtran/imf.qpm/blob/76b631445f117985a0264d72f0cca351faadcfaa/estimate.png)

## How to run stuff

- The calibrated model (IMF's EdX version)

`a02_makedata` -> `a03_kalmanfilter` -> `a05_forecast`

- The estimated model

`a02_makedata` -> (any) `a07...` -> `a03_kalmanfilter_est` 

Make sure to enable the `IRIS-Toolbox-Legacy-20211206` in `start.m` instead of `IRIS_Tbx_20181028`.




## Disclaimer
- This repository is for **educational and research purposes only**. This archieved version of the IRIS Toolbox here is obsolete and no longer in development. 
- The author of this repository does **not claim ownership** of the original IMF QPM framework, IRIS Toolbox, or the IMFx/MPAFx materials.  
- The materials may be subject to copyright and intellectual property rights of the **IMF**, **IRIS Solutions Team**, and/or their respective contributors.  
- No official endorsement by the IMF, IRIS Solutions Team, or EdX is implied.  
- Users are responsible for ensuring compliance with all applicable terms of use, licenses, and citations when using or redistributing these materials.
