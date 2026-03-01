# imf.qpm

This set of codes is based on IMF's Quarterly Projection Model

- Credits to IRIS Solutions team [(IRIS Toolbox)](https://github.com/IRIS-Solutions-Team/IRIS-Toolbox)  
- The codes are obtained from [IMFx MPAFx Monetary Policy Analysis and Forecasting](https://www.imf.org/en/Capacity-Development/Training/ICDTC/Courses/MPAFx) on EdX.

Please go to the site and enroll if you are interested. 

The data is likely for the Czech Republic.


## What I added

In the original codes provided by IMF, the model used is a calibrated one. Calibrating a large system such as the QPM can be challenging and requires a lot of tedious trial and errors. In a lot of cases, we also want to be able to estimate the parameters so that the output is as close to the data as possible.

In this repo, I added three scripts that do exactly this, with 3 methods (maximum likelihood, Bayesian, and System Priors). 
The approach is based on [A Cook-Book of IRIS](https://www.mv.helsinki.fi/home/ajripatt/opetus/metrics/IRIS_cookbook.pdf#page=49.24) by Jaromir Benes & Martin Fukac. 
I adapted the codes there to produce `a07_estimate_mle` and `a07_estimate_bayesian` that perform the relevant estimation and then save the posterior mean into `pE`.
The script `readmodel_est.m` will replace `readmodel.m` in this case.
Benes later added a System-priors approach ([here](https://github.com/jaromir-benes/nifi-workshop-202109)), which can only be implemented with IRIS 2021 onwards. 
If you want to try this approach, run `a07_estimate_system` in the repo and remember to use IRIS 2021 instead of IRIS 2018. 

(Note: In the Bayesian estimation, the old 6-element format `{init, lb, ub, 'beta', mean, std}` worked in IRIS 2018 but will fail in the 2021 version. The 2021 version only accepts `distribution.Distribution` object, a function handle, or a numeric penalty as the 4th element. If we follow the old syntax, a plain string like `'beta'` doesn't match any of those checks and is ignored, leaving all priors as "Flat", and the estimation will default to MLE)

Based on [this repo](https://github.com/youarenadin/Replication-of-the-IMF-QPM-Model), I wrote a dynare implementation of the current QPM model. You can run `qpm_dynare.mod` via the command `dynare qpm_dynare.mod` (make sure to add DYNARE path first). Note that the end result is not very good because the Log-lik is about -4128, while other methods produce the Log-lik of about -622. I think there is semething wrong with my `dynare` code.

## Comparison

The calibrated model

![](https://github.com/thanhqtran/imf.qpm/blob/76b631445f117985a0264d72f0cca351faadcfaa/calibrate.png)

The estimated model

![](https://github.com/thanhqtran/imf.qpm/blob/76b631445f117985a0264d72f0cca351faadcfaa/estimate.png)

| Parameter            | Calibrated | Estimated |
|----------------------|------------|------------|
| ss_DLA_GDP_BAR       | 2.5000     | 2.5000     |
| ss_D4L_CPI_TAR       | 2.0000     | 2.0000     |
| ss_RR_BAR            | 0.5000     | 0.5000     |
| ss_DLA_Z_BAR         | -1.5000    | -1.5000    |
| ss_DLA_CPI_RW        | 2.0000     | 2.0000     |
| ss_RR_RW_BAR         | 0.7500     | 0.7500     |
| b1                   | 0.8000     | 0.5052     |
| b2                   | 0.3000     | 0.1000     |
| b3                   | 0.5000     | 0.5794     |
| b4                   | 0.7000     | 0.8000     |
| a1                   | 0.7000     | 0.4000     |
| a2                   | 0.2000     | 0.1000     |
| a3                   | 0.7000     | 0.7064     |
| g1                   | 0.7000     | 0.8000     |
| g2                   | 0.5000     | 0.0621     |
| g3                   | 0.5000     | 0.3563     |
| e1                   | 0.4000     | 0.2566     |
| rho_D4L_CPI_TAR      | 0.5000     | 0.9500     |
| rho_DLA_Z_BAR        | 0.8000     | 0.9500     |
| rho_DLA_GDP_BAR      | 0.8000     | 0.9289     |
| rho_RR_BAR           | 0.8000     | 0.9500     |
| rho_RR_RW_BAR        | 0.8000     | 0.9500     |
| rho_L_GDP_RW_GAP     | 0.8000     | 0.9423     |
| rho_RS_RW            | 0.8000     | 0.9500     |
| rho_DLA_CPI_RW       | 0.8000     | 0.3604     |

## How to run stuff

- The calibrated model (IMF's EdX version)

`a02_makedata` -> `a03_kalmanfilter` -> `a05_forecast`

- The estimated model

`a02_makedata` -> (any) `a07...` -> `a03_kalmanfilter_est` 

Make sure to enable the `IRIS-Toolbox-Legacy-20211206` in `start.m` instead of `IRIS_Tbx_20181028`.

- Try dynare

copy `history.csv` from `results` folder, change the variable name of the observed variables to match `varobs` in the `dynare` file. Then run `dynare qpm_dynare.mod`




## Disclaimer
- This repository is for **educational and research purposes only**. This archieved version of the IRIS Toolbox here is obsolete and no longer in development. 
- The author of this repository does **not claim ownership** of the original IMF QPM framework, IRIS Toolbox, or the IMFx/MPAFx materials.  
- The materials may be subject to copyright and intellectual property rights of the **IMF**, **IRIS Solutions Team**, and/or their respective contributors.  
- No official endorsement by the IMF, IRIS Solutions Team, or EdX is implied.  
- Users are responsible for ensuring compliance with all applicable terms of use, licenses, and citations when using or redistributing these materials.
