%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ESTIMATION: SYSTEM PRIORS
%%% Adapted from model_VN_estimate for MPAFx_example (IMF synthetic data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% System priors constrain the model as a WHOLE SYSTEM, rather than
% individual parameters in isolation. The posterior combines:
%   - Data likelihood
%   - Individual (Bayesian) priors
%   - System priors (e.g., sacrifice ratio, monetary transmission)
%
% NOTE: Requires IRIS with SystemPriorWrapper support.
% If your IRIS version does not support SystemPriorWrapper,
% use a07_estimate_bayesian.m instead.

clear all;

%% PARAMETRIZE AND SOLVE THE MODEL (MPAFx calibration)
p = struct();

% Steady state (IMF synthetic data)
p.ss_DLA_GDP_BAR = 2.5;
p.ss_D4L_CPI_TAR = 2;
p.ss_RR_BAR      = 0.5;
p.ss_DLA_Z_BAR   = -1.5;
p.ss_DLA_CPI_RW  = 2;
p.ss_RR_RW_BAR   = 0.75;

%-------- 1. Aggregate demand (IS curve) - MPAFx has b1 only, no b0
p.b1 = 0.8;
p.b2 = 0.3;
p.b3 = 0.5;
p.b4 = 0.7;

%-------- 2. Phillips curve
p.a1 = 0.7;
p.a2 = 0.2;
p.a3 = 0.7;

%-------- 3. Taylor rule
p.g1 = 0.7;
p.g2 = 0.5;
p.g3 = 0.5;

%-------- 4. UIP
p.e1 = 0.4;

%-------- 5. Persistence
p.rho_D4L_CPI_TAR  = 0.5;
p.rho_DLA_Z_BAR    = 0.8;
p.rho_DLA_GDP_BAR  = 0.8;
p.rho_RR_BAR       = 0.8;
p.rho_RR_RW_BAR    = 0.8;
p.rho_L_GDP_RW_GAP = 0.8;
p.rho_RS_RW        = 0.8;
p.rho_DLA_CPI_RW   = 0.8;

%% LOAD THE MODEL
m = model('model.model','linear=',true,'assign',p);
m = solve(m);
m = sstate(m);

%% Load data
d = dbload('results/history.csv');
d.OBS_L_CPI        = d.L_CPI;
d.OBS_L_GDP        = d.L_GDP;
d.OBS_L_S          = d.L_S;
d.OBS_RS           = d.RS;
d.OBS_RS_RW        = d.RS_RW;
d.OBS_DLA_CPI_RW   = d.DLA_CPI_RW;
d.OBS_L_GDP_RW_GAP = d.L_GDP_RW_GAP;
d.OBS_D4L_CPI_TAR  = d.D4L_CPI_TAR;

startdate = qq(1998,1);
enddate   = qq(2013,1);

%% Define individual (Bayesian) priors
priors = struct();
priors.b1 = {p.b1, 0.1, 0.95, 'beta', p.b1, 0.15};
priors.b2 = {p.b2, 0.1, 0.50, 'gamma', p.b2, 0.10};
priors.b3 = {p.b3, 0.1, 0.70, 'gamma', p.b3, 0.15};
priors.b4 = {p.b4, 0.3, 0.80, 'beta', p.b4, 0.15};
priors.a1 = {p.a1, 0.4, 0.90, 'beta', p.a1, 0.15};
priors.a2 = {p.a2, 0.1, 0.50, 'gamma', p.a2, 0.10};
priors.a3 = {p.a3, 0.5, 0.90, 'beta', p.a3, 0.15};
priors.e1 = {p.e1, 0.0, 0.95, 'beta', p.e1, 0.20};
priors.g1 = {p.g1, 0.0, 0.80, 'beta', p.g1, 0.20};
priors.g2 = {p.g2, 0.01, 5.0, 'gamma', p.g2, 0.20};
priors.g3 = {p.g3, 0.01, 5.0, 'gamma', p.g3, 0.20};
priors.rho_D4L_CPI_TAR  = {p.rho_D4L_CPI_TAR,  0.1, 0.95, 'beta', p.rho_D4L_CPI_TAR,  0.15};
priors.rho_DLA_Z_BAR    = {p.rho_DLA_Z_BAR,    0.1, 0.95, 'beta', p.rho_DLA_Z_BAR,    0.15};
priors.rho_DLA_GDP_BAR  = {p.rho_DLA_GDP_BAR,  0.1, 0.95, 'beta', p.rho_DLA_GDP_BAR,  0.15};
priors.rho_RR_BAR       = {p.rho_RR_BAR,       0.1, 0.95, 'beta', p.rho_RR_BAR,       0.15};
priors.rho_RR_RW_BAR    = {p.rho_RR_RW_BAR,    0.1, 0.95, 'beta', p.rho_RR_RW_BAR,    0.15};
priors.rho_L_GDP_RW_GAP = {p.rho_L_GDP_RW_GAP, 0.1, 0.95, 'beta', p.rho_L_GDP_RW_GAP, 0.15};
priors.rho_RS_RW        = {p.rho_RS_RW,        0.1, 0.95, 'beta', p.rho_RS_RW,        0.15};
priors.rho_DLA_CPI_RW   = {p.rho_DLA_CPI_RW,   0.1, 0.95, 'beta', p.rho_DLA_CPI_RW,   0.15};

%% Define system priors (if SystemPriorWrapper exists)
try
    z = SystemPriorWrapper.forModel(m);

    % System Property 1: Disinflation simulation
    dsim = zerodb(m, 1:40);
    dsim.SHK_D4L_CPI_TAR(1) = -1;
    p1 = simulate(m, dsim, 1:40, 'Deviation', true, 'SystemProperty', 'S');
    z.addSystemProperty(p1);
    z.addSystemPrior('-sum(S(L_GDP_GAP, :))/4', distribution.Normal.fromMeanStd(0.5, 0.30));

    % System Property 2: Monetary policy shock
    dsim2 = zerodb(m, 1:40);
    dsim2.SHK_RS(1) = 1;
    p2 = simulate(m, dsim2, 1:40, 'Deviation', true, 'SystemProperty', 'MP');
    z.addSystemProperty(p2);
    z.addSystemPrior('MP(L_GDP_GAP, 4)', distribution.Normal.fromMeanStd(-0.15, 0.15));

    z.seal();

    fprintf('\nStarting estimation with system priors...\n');
    [Est, Poster, Table, Hess, MEst, V, Delta, PDelta] = estimate( ...
        m, d, startdate:enddate, priors, z, ...
        'NoSolution', 'penalty', ...
        'EvalDataLik', 1, ...
        'EvalIndiePriors', 1, ...
        'EvalSystemPriors', 1, ...
        'Summary', 'struct' ...
    );
    fprintf('Estimation with system priors complete.\n\n');

catch ME
    if contains(ME.message, 'SystemPriorWrapper') || contains(ME.identifier, 'UndefinedFunction')
        warning('SystemPriorWrapper not available. Falling back to Bayesian estimation only.');
        [Est, Poster, Table, Hess, MEst, V, Delta, PDelta] = estimate( ...
            m, d, startdate:enddate, priors);
    else
        rethrow(ME);
    end
end

%% Display results
disp('------------------------------------------------------------------');
disp('System Priors Estimation Results (or Bayesian if fallback)');
disp('------------------------------------------------------------------');
disp(Est);

%% Save for use in a03_kalmanfilter_est and a05_forecast
% Store Est in a format that readmodel_est can use
save('results/Est_system.mat', 'Est', 'p');
