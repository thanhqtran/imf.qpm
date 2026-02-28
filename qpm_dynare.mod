/*
 * Dynare implementation of the Quarterly Projection Model (QPM)
 * Based on iris_target_qpm.txt and priors from a07_estimate_bayesian.m
 * Estimation with diffuse filter for unit roots
 */

% Endogenous variables 
var 
    L_GDP            // Real GDP (log)
    L_GDP_BAR        // Potential output (log)
    L_GDP_GAP        // Output gap
    DLA_GDP          // Q-o-Q GDP growth (annualized)
    D4L_GDP          // Y-o-Y GDP growth
    DLA_GDP_BAR      // Potential output growth (annualized)
    MCI              // Monetary Conditions Index
    L_CPI            // CPI (log)
    DLA_CPI          // Q-o-Q CPI inflation (annualized)
    E_DLA_CPI        // Expected inflation
    D4L_CPI          // Y-o-Y CPI inflation
    D4L_CPI_TAR      // Inflation target
    RMC              // Real marginal cost
    L_S              // Nominal exchange rate (log)
    DLA_S            // Q-o-Q depreciation (annualized)
    D4L_S            // Y-o-Y depreciation
    RS               // Policy interest rate
    RR               // Real interest rate
    RR_BAR           // Equilibrium real interest rate
    RR_GAP           // Real interest rate gap
    RSNEUTRAL        // Neutral nominal rate
    L_Z              // Real exchange rate (log)
    L_Z_BAR          // Trend real exchange rate (log)
    L_Z_GAP          // Real exchange rate gap
    DLA_Z            // Q-o-Q real depreciation (annualized)
    DLA_Z_BAR        // Trend real depreciation (annualized)
    L_GDP_RW_GAP     // Foreign output gap
    RS_RW            // Foreign policy rate
    RR_RW            // Foreign real rate
    RR_RW_BAR        // Foreign equilibrium real rate
    RR_RW_GAP        // Foreign real rate gap
    L_CPI_RW         // Foreign CPI (log)
    DLA_CPI_RW       // Foreign Q-o-Q inflation (annualized)
    PREM             // Risk Premium
    OBS_L_GDP        // Observation: GDP
    OBS_L_CPI        // Observation: CPI
    OBS_RS           // Observation: policy rate
    OBS_L_S          // Observation: exchange rate
    OBS_D4L_CPI_TAR  // Observation: inflation target
    OBS_L_GDP_RW_GAP // Observation: foreign output gap
    OBS_DLA_CPI_RW   // Observation: foreign inflation
    OBS_RS_RW        // Observation: foreign policy rate
;

% Exogenous shocks (unchanged)
varexo 
    SHK_L_GDP_GAP
    SHK_DLA_CPI
    SHK_L_S
    SHK_RS
    SHK_D4L_CPI_TAR
    SHK_RR_BAR
    SHK_DLA_Z_BAR
    SHK_DLA_GDP_BAR
    SHK_L_GDP_RW_GAP
    SHK_RS_RW
    SHK_DLA_CPI_RW
    SHK_RR_RW_BAR
;

% Parameters
parameters 
    b1 b2 b3 b4
    a1 a2 a3
    e1
    g1 g2 g3
    rho_D4L_CPI_TAR
    rho_DLA_Z_BAR
    rho_RR_BAR
    rho_DLA_GDP_BAR
    rho_L_GDP_RW_GAP
    rho_RS_RW
    rho_DLA_CPI_RW
    rho_RR_RW_BAR
    ss_D4L_CPI_TAR
    ss_DLA_Z_BAR
    ss_RR_BAR
    ss_DLA_GDP_BAR
    ss_DLA_CPI_RW
    ss_RR_RW_BAR
;

% Shock standard deviations (to be estimated)
parameters 
    stderr_L_GDP_GAP
    stderr_DLA_CPI
    stderr_L_S
    stderr_RS
    stderr_D4L_CPI_TAR
    stderr_RR_BAR
    stderr_DLA_Z_BAR
    stderr_DLA_GDP_BAR
    stderr_L_GDP_RW_GAP
    stderr_RS_RW
    stderr_DLA_CPI_RW
    stderr_RR_RW_BAR
;

% ----- Calibration (prior means) -----
b1 = 0.8;
b2 = 0.3;
b3 = 0.5;
b4 = 0.7;
a1 = 0.7;
a2 = 0.2;
a3 = 0.7;
e1 = 0.4;
g1 = 0.7;
g2 = 0.5;
g3 = 0.5;

rho_D4L_CPI_TAR = 0.5;
rho_DLA_Z_BAR   = 0.8;
rho_RR_BAR      = 0.8;
rho_DLA_GDP_BAR = 0.8;
rho_L_GDP_RW_GAP = 0.8;
rho_RS_RW       = 0.8;
rho_DLA_CPI_RW  = 0.8;
rho_RR_RW_BAR   = 0.8;

ss_D4L_CPI_TAR = 2.0;
ss_DLA_Z_BAR   = -1.5;          // will be adjusted to 0 for consistency? Keep original for now
ss_RR_BAR      = 0.5;
ss_DLA_GDP_BAR = 2.5;
ss_DLA_CPI_RW  = 2.0;
ss_RR_RW_BAR   = 0.75;

% Initial values for shock stdevs (will be estimated)
stderr_L_GDP_GAP = 0.1;
stderr_DLA_CPI   = 0.1;
stderr_L_S       = 0.1;
stderr_RS        = 0.1;
stderr_D4L_CPI_TAR = 0.1;
stderr_RR_BAR    = 0.1;
stderr_DLA_Z_BAR = 0.1;
stderr_DLA_GDP_BAR = 0.1;
stderr_L_GDP_RW_GAP = 0.1;
stderr_RS_RW     = 0.1;
stderr_DLA_CPI_RW = 0.1;
stderr_RR_RW_BAR = 0.1;

% ----- Model equations -----
model(linear);

    % 1. IS curve
    L_GDP_GAP = b1*L_GDP_GAP(-1) - b2*MCI + b3*L_GDP_RW_GAP + stderr_L_GDP_GAP*SHK_L_GDP_GAP;

    % 2. Monetary Conditions Index
    MCI = b4*RR_GAP + (1-b4)*(- L_Z_GAP);

    % 3. Phillips curve
    DLA_CPI = a1*DLA_CPI(-1) + (1-a1)*DLA_CPI(+1) + a2*RMC + stderr_DLA_CPI*SHK_DLA_CPI;

    % 4. Real marginal cost
    RMC = a3*L_GDP_GAP + (1-a3)*L_Z_GAP;

    % 5. Expected inflation (definition)
    E_DLA_CPI = DLA_CPI(+1);

    % 6. Taylor rule
    RS = g1*RS(-1) + (1-g1)*(RSNEUTRAL + g2*(D4L_CPI(+4) - D4L_CPI_TAR(+4)) + g3*L_GDP_GAP) + stderr_RS*SHK_RS;

    % 7. Neutral rate
    RSNEUTRAL = RR_BAR + D4L_CPI(+1);

    % 8. UIP (with parameter PREM)
    L_S = (1-e1)*L_S(+1) + e1*(L_S(-1) + 2/4*(D4L_CPI_TAR - ss_DLA_CPI_RW + DLA_Z_BAR)) + (-RS + RS_RW + PREM)/4 + stderr_L_S*SHK_L_S;

    % 9. Real interest rate (Fisher)
    RR = RS - D4L_CPI(+1);

    % 10. Real exchange rate definition
    L_Z = L_S + L_CPI_RW - L_CPI;

    % 11. Long-run UIP (forward form) – using parameter PREM
    DLA_Z_BAR(+1) = RR_BAR - RR_RW_BAR - PREM;

    % 12. Potential output growth definition
    DLA_GDP_BAR = 4*(L_GDP_BAR - L_GDP_BAR(-1));

    % 13. Trend real depreciation definition
    DLA_Z_BAR = 4*(L_Z_BAR - L_Z_BAR(-1));

    % 14. Actual real depreciation
    DLA_Z = 4*(L_Z - L_Z(-1));

    % 15. GDP growth
    DLA_GDP = 4*(L_GDP - L_GDP(-1));

    % 16. Inflation
    DLA_CPI = 4*(L_CPI - L_CPI(-1));

    % 17. Nominal depreciation
    DLA_S = 4*(L_S - L_S(-1));

    % 18. Y-o-Y GDP growth
    D4L_GDP = L_GDP - L_GDP(-4);

    % 19. Y-o-Y inflation
    D4L_CPI = L_CPI - L_CPI(-4);

    % 20. Y-o-Y depreciation
    D4L_S = L_S - L_S(-4);

    % 21. Real interest rate gap
    RR_GAP = RR - RR_BAR;

    % 22. Real exchange rate gap
    L_Z_GAP = L_Z - L_Z_BAR;

    % 23. Output gap (identity)
    L_GDP_GAP = L_GDP - L_GDP_BAR;

    % 24. Inflation target process
    D4L_CPI_TAR = rho_D4L_CPI_TAR*D4L_CPI_TAR(-1) + (1-rho_D4L_CPI_TAR)*ss_D4L_CPI_TAR + stderr_D4L_CPI_TAR*SHK_D4L_CPI_TAR;

    % 25. Trend real depreciation process
    DLA_Z_BAR = rho_DLA_Z_BAR*DLA_Z_BAR(-1) + (1-rho_DLA_Z_BAR)*ss_DLA_Z_BAR + stderr_DLA_Z_BAR*SHK_DLA_Z_BAR;

    % 26. Equilibrium real rate process
    RR_BAR = rho_RR_BAR*RR_BAR(-1) + (1-rho_RR_BAR)*ss_RR_BAR + stderr_RR_BAR*SHK_RR_BAR;

    % 27. Potential growth process
    DLA_GDP_BAR = rho_DLA_GDP_BAR*DLA_GDP_BAR(-1) + (1-rho_DLA_GDP_BAR)*ss_DLA_GDP_BAR + stderr_DLA_GDP_BAR*SHK_DLA_GDP_BAR;

    % 28. Foreign output gap process
    L_GDP_RW_GAP = rho_L_GDP_RW_GAP*L_GDP_RW_GAP(-1) + stderr_L_GDP_RW_GAP*SHK_L_GDP_RW_GAP;

    % 29. Foreign inflation process
    DLA_CPI_RW = rho_DLA_CPI_RW*DLA_CPI_RW(-1) + (1-rho_DLA_CPI_RW)*ss_DLA_CPI_RW + stderr_DLA_CPI_RW*SHK_DLA_CPI_RW;

    % 30. Foreign interest rate
    RS_RW = rho_RS_RW*RS_RW(-1) + (1-rho_RS_RW)*(RR_RW_BAR + DLA_CPI_RW) + stderr_RS_RW*SHK_RS_RW;

    % 31. Foreign equilibrium real rate process
    RR_RW_BAR = rho_RR_RW_BAR*RR_RW_BAR(-1) + (1-rho_RR_RW_BAR)*ss_RR_RW_BAR + stderr_RR_RW_BAR*SHK_RR_RW_BAR;

    % 32. Foreign real rate
    RR_RW = RS_RW - DLA_CPI_RW;

    % 33. Foreign real rate gap
    RR_RW_GAP = RR_RW - RR_RW_BAR;

    % 34. Foreign inflation definition (already used in process)
    DLA_CPI_RW = 4*(L_CPI_RW - L_CPI_RW(-1));

    % ----- Measurement equations -----
    OBS_L_GDP = L_GDP;
    OBS_L_CPI = L_CPI;
    OBS_RS    = RS;
    OBS_L_S   = L_S;
    OBS_D4L_CPI_TAR = D4L_CPI_TAR;
    OBS_L_GDP_RW_GAP = L_GDP_RW_GAP;
    OBS_DLA_CPI_RW   = DLA_CPI_RW;
    OBS_RS_RW        = RS_RW;
end;

% ----- Steady state -----
steady_state_model;
    % Gaps
    L_GDP_GAP = 0;
    L_Z_GAP   = 0;
    RR_GAP    = 0;
    RR_RW_GAP = 0;

    % Growth rates (annualized)
    DLA_GDP_BAR = ss_DLA_GDP_BAR;
    DLA_Z_BAR   = ss_DLA_Z_BAR;
    D4L_CPI_TAR = ss_D4L_CPI_TAR;
    DLA_CPI_RW  = ss_DLA_CPI_RW;
    RR_BAR      = ss_RR_BAR;
    RR_RW_BAR   = ss_RR_RW_BAR;
    PREM        = RR_BAR - RR_RW_BAR - DLA_Z_BAR;

    % Derived growth rates
    DLA_GDP = DLA_GDP_BAR;
    DLA_CPI = D4L_CPI_TAR;
    DLA_Z   = DLA_Z_BAR;
    DLA_S   = DLA_Z + DLA_CPI - DLA_CPI_RW;
    D4L_GDP = DLA_GDP_BAR;
    D4L_CPI = D4L_CPI_TAR;
    D4L_S   = DLA_S;

    % Levels (set to 0 for stationary part)
    L_GDP     = 0;
    L_GDP_BAR = 0;
    L_CPI     = 0;
    L_S       = 0;
    L_Z       = 0;
    L_Z_BAR   = 0;
    L_CPI_RW  = 0;

    % Other variables
    MCI       = 0;
    RMC       = 0;
    E_DLA_CPI = DLA_CPI;
    RS        = RR_BAR + D4L_CPI;
    RR        = RR_BAR;
    RSNEUTRAL = RR_BAR + D4L_CPI;
    RS_RW     = RR_RW_BAR + DLA_CPI_RW;
    RR_RW     = RR_RW_BAR;
    L_GDP_RW_GAP = 0;               // added missing assignment

    % Observations
    OBS_L_GDP = L_GDP;
    OBS_L_CPI = L_CPI;
    OBS_RS    = RS;
    OBS_L_S   = L_S;
    OBS_D4L_CPI_TAR = D4L_CPI_TAR;
    OBS_L_GDP_RW_GAP = L_GDP_RW_GAP;
    OBS_DLA_CPI_RW   = DLA_CPI_RW;
    OBS_RS_RW        = RS_RW;
end;

shocks;
    var SHK_L_GDP_GAP = 1;
    var SHK_DLA_CPI = 1;
    var SHK_L_S = 1;
    var SHK_RS = 1;
    var SHK_D4L_CPI_TAR = 1;
    var SHK_RR_BAR = 1;
    var SHK_DLA_Z_BAR = 1;
    var SHK_DLA_GDP_BAR = 1;
    var SHK_L_GDP_RW_GAP = 1;
    var SHK_RS_RW = 1;
    var SHK_DLA_CPI_RW = 1;
    var SHK_RR_RW_BAR = 1;
end;

% ----- Observed variables -----
varobs OBS_L_GDP OBS_L_CPI OBS_RS OBS_L_S OBS_D4L_CPI_TAR OBS_L_GDP_RW_GAP OBS_DLA_CPI_RW OBS_RS_RW;

% ----- Diagnostics -----
%steady;
%check;
%model_diagnostics;

% ----- Estimated parameters (priors from a07_estimate_bayesian) -----
estimated_params;
    // Structural parameters
    b1,   0.8, 0.1, 0.95, beta_pdf,   0.8, 0.15;
    b2,   0.3, 0.1, 0.50, gamma_pdf,  0.3, 0.10;
    b3,   0.5, 0.1, 0.70, gamma_pdf,  0.5, 0.15;
    b4,   0.7, 0.3, 0.80, beta_pdf,   0.7, 0.15;
    a1,   0.7, 0.4, 0.90, beta_pdf,   0.7, 0.15;
    a2,   0.2, 0.1, 0.50, gamma_pdf,  0.2, 0.10;
    a3,   0.7, 0.5, 0.90, beta_pdf,   0.7, 0.15;
    e1,   0.4, 0.0, 0.95, beta_pdf,   0.4, 0.20;
    g1,   0.7, 0.0, 0.80, beta_pdf,   0.7, 0.20;
    g2,   0.5, 0.01, 5.0, gamma_pdf,  0.5, 0.20;
    g3,   0.5, 0.01, 5.0, gamma_pdf,  0.5, 0.20;

    // Persistence parameters
    rho_D4L_CPI_TAR, 0.5, 0.1, 0.95, beta_pdf, 0.5, 0.15;
    rho_DLA_Z_BAR,   0.8, 0.1, 0.95, beta_pdf, 0.8, 0.15;
    rho_RR_BAR,      0.8, 0.1, 0.95, beta_pdf, 0.8, 0.15;
    rho_DLA_GDP_BAR, 0.8, 0.1, 0.95, beta_pdf, 0.8, 0.15;
    rho_L_GDP_RW_GAP,0.8, 0.1, 0.95, beta_pdf, 0.8, 0.15;
    rho_RS_RW,       0.8, 0.1, 0.95, beta_pdf, 0.8, 0.15;
    rho_DLA_CPI_RW,  0.8, 0.1, 0.95, beta_pdf, 0.8, 0.15;
    rho_RR_RW_BAR,   0.8, 0.1, 0.95, beta_pdf, 0.8, 0.15;

    // Shock standard deviations (normal_pdf, truncated at zero)
    stderr_L_GDP_GAP,   0.1, 0.001, 3.0, normal_pdf, 0.1, 0.05;
    stderr_DLA_CPI,     0.1, 0.001, 3.0, normal_pdf, 0.1, 0.05;
    stderr_L_S,         0.1, 0.001, 3.0, normal_pdf, 0.1, 0.05;
    stderr_RS,          0.1, 0.001, 3.0, normal_pdf, 0.1, 0.05;
    stderr_D4L_CPI_TAR, 0.1, 0.001, 3.0, normal_pdf, 0.1, 0.05;
    stderr_RR_BAR,      0.1, 0.001, 3.0, normal_pdf, 0.1, 0.05;
    stderr_DLA_Z_BAR,   0.1, 0.001, 3.0, normal_pdf, 0.1, 0.05;
    stderr_DLA_GDP_BAR, 0.1, 0.001, 3.0, normal_pdf, 0.1, 0.05;
    stderr_L_GDP_RW_GAP,0.1, 0.001, 3.0, normal_pdf, 0.1, 0.05;
    stderr_RS_RW,       0.1, 0.001, 3.0, normal_pdf, 0.1, 0.05;
    stderr_DLA_CPI_RW,  0.1, 0.001, 3.0, normal_pdf, 0.1, 0.05;
    stderr_RR_RW_BAR,   0.1, 0.001, 3.0, normal_pdf, 0.1, 0.05;
end;

% ----- Estimation -----
estimation(
    datafile = 'datadynare.csv',    // replace with your data file
    first_obs = 2,
    nobs = 72,
    presample = 0,
    diffuse_filter,
    kalman_tol = 1e-10,
    diffuse_kalman_tol = 1e-6,
    filter_step_ahead = [1:4],
    mode_compute = 6,
    mode_check,
    mh_replic = 20000,
    mh_nblocks = 2,
    mh_drop = 0.5,
    mh_jscale = 0.3,
    smoother,
    filtered_vars,
    forecast = 8,
    bayesian_irf,
    irf = 20
);