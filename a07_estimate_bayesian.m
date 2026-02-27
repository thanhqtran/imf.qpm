%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ESTIMATION: BAYESIAN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;

%% PARAMETRIZE AND SOLVE THE MODEL
p = struct();
% === Steady state parameters ===

% Potential output growth
p.ss_DLA_GDP_BAR = 2.5;

% Domestic inflation target
p.ss_D4L_CPI_TAR = 2; 

% Domestic real interest rate 
p.ss_RR_BAR = 0.5; 

% Change in the real ER (negative number = real appreciation)
p.ss_DLA_Z_BAR = -1.5; 

% Foreign inflation or inflation target
p.ss_DLA_CPI_RW = 2;

% Level of foreign real interest rate
p.ss_RR_RW_BAR = 0.75;

% == Typical and specific parameter values be used in calibrations === 
%-------- 1. Aggregate demand equation (the IS curve)
% L_GDP_GAP = b1*L_GDP_GAP{-1} - b2*MCI + b3*L_GDP_RW_GAP + SHK_L_GDP_GAP;
% MCI 		= b4*RR_GAP + (1-b4)*(- L_Z_GAP);

% output persistence;
p.b1 = 0.8; % b1 varies between 0.1 (extremely flexible) and 0.95(extremely persistent)

% policy passthrough (the impact of monetary policy on real economy); 
p.b2 = 0.3; % b2 varies between 0.1 (low impact) to 0.5 (strong impact)

% the impact of external demand on domestic output; 
p.b3 = 0.5; % b3 varies between 0.1 and 0.7

% the weight of the real interest rate and real exchange rate gaps in Monetary Conditions Index;
p.b4 = 0.7; % b4 varies from 0.3 to 0.8

%-------- 2. Inflation equation (the Phillips curve)
% DLA_CPI = a1*DLA_CPI{-1} + (1-a1)*DLA_CPI{+1} + a2*RMC + SHK_DLA_CPI;
% RMC 	  = a3*L_GDP_GAP + (1-a3)*L_Z_GAP;

% inflation persistence; 
p.a1 = 0.7; % a1 varies between 0.4 (low persistence) to 0.9 (high persistence)

% passthrough of marginal costs to inflation (the impact of rmc on inflation); 
p.a2 = 0.2; % a2 varies between 0.1 (a flat Phillips curve and a high sacrifice ratio) to 0.5 (a steep Phillips curve and a low sacrifice ratio)

% the ratio of domestic costs in firms aggregate costs
p.a3 = 0.7; % a3 varies between 0.9 (for a relatively more closed economy) to 0.5 (for a relatively more open economy)

%-------- 3. Monetary policy reaction function (a forward-looking Taylor rule)
% RS = g1*RS{-1} + (1-g1)*(RSNEUTRAL + g2*(D4L_CPI{+4} - D4L_CPI_TAR{+4}) + g3*L_GDP_GAP) + SHK_RS;

% policy persistence; 
p.g1 = 0.7; % g1 varies from 0 (no persistence) to 0.8 ("wait and see" policy)

% policy reactiveness: the weight put on inflation by the policy-makers 
p.g2 = 0.5; % g2 has no upper limit but must be always higher then 0 (the Taylor principle)

% policy reactiveness: the weight put on the output gap by the policy-makers 
p.g3 = 0.5; % g3 has no upper limit but must be always higher then 0

%-------- 4. Uncovered Interest Rate Parity (UIP)
% L_S = (1-e1)*L_S{+1} + e1*(L_S{-1} + 2/4*(D4L_CPI_TAR - ss_DLA_CPI_RW + DLA_Z_BAR)) + (- RS + RS_RW + PREM)/4 + SHK_L_S;

% the weight of the backward-looking component
p.e1 = 0.4; % setting e1 equal to 0 reduces the equation to the simple UIP 

%-------- 5. Speed of convergence of selected variables to their trend values.
% Used for inflation target, trends, and foreign variables 

% persistence of inflation target adjustment to the medium-term target (higher values mean slower adjustment)
% D4L_CPI_TAR = rho_D4L_CPI_TAR*D4L_CPI_TAR{-1} + (1-rho_D4L_CPI_TAR)*ss_D4L_CPI_TAR + SHK_D4L_CPI_TAR;
p.rho_D4L_CPI_TAR = 0.5; 

% persistence in convergence of trend variables to their steady-state levels
% applies for:   DLA_GDP_BAR, DLA_Z_BAR, RR_BAR and RR_RW_BAR
% example:
% DLA_Z_BAR = rho_DLA_Z_BAR*DLA_Z_BAR{-1} + (1-rho_DLA_Z_BAR)*ss_DLA_Z_BAR + SHK_DLA_Z_BAR;
p.rho_DLA_Z_BAR   = 0.8;
p.rho_DLA_GDP_BAR = 0.8;
p.rho_RR_BAR      = 0.8;
p.rho_RR_RW_BAR   = 0.8;

% persistence in foreign output gap 
% L_GDP_RW_GAP = rho_L_GDP_RW_GAP*L_GDP_RW_GAP{-1} + SHK_L_GDP_RW_GAP;
p.rho_L_GDP_RW_GAP = 0.8;

% persistence in foreign interest rates and inflation
% RS_RW = rho_RS_RW*RS_RW{-1} + (1-rho_RS_RW)*(RR_BAR + DLA_CPI_RW) + SHK_RS_RW;
p.rho_RS_RW      = 0.8;
p.rho_DLA_CPI_RW = 0.8;

%% LOAD THE MODEL
% 1) command 'model' reads the text file 'model.model' (contains the model's equations), 
% assigns the parameters and steady state values from database 'p' (see above),
% and transforms the model for the matrix algebra. Transformed model is written in the object 'm'. 
m = model('model.model','linear=',true,'assign',p);
m = solve(m);
m = sstate(m);

%% Preparing for Bayesian estimation
% make sure the model is stored
disp(m);
% load data
d = dbload('results/history.csv');

%mapping
d.OBS_L_CPI        = d.L_CPI;

d.OBS_L_GDP        = d.L_GDP;
d.OBS_L_S          = d.L_S;
d.OBS_RS           = d.RS;

d.OBS_RS_RW        = d.RS_RW;

d.OBS_DLA_CPI_RW   = d.DLA_CPI_RW;
d.OBS_L_GDP_RW_GAP = d.L_GDP_RW_GAP;
d.OBS_D4L_CPI_TAR  = d.D4L_CPI_TAR;

startdate = qq(1998,1);
enddate = qq(2013,1);

%% Define priors for Bayesian estimation
% For Bayesian estimation, we specify prior distributions for each parameter.
% Format: {initial_value, lower_bound, upper_bound, 'distribution', prior_mean, prior_std}
% Common distributions: 'beta' (for [0,1] bounded), 'gamma' (for positive), 'normal' (unbounded)

priors = struct();

% Structural parameters
% Use beta distribution for parameters bounded between 0 and 1
priors.b1 = {p.b1, 0.1, 0.95, 'beta', p.b1, 0.15};  % output persistence
priors.b2 = {p.b2, 0.1, 0.50, 'gamma', p.b2, 0.10};  % policy passthrough
priors.b3 = {p.b3, 0.1, 0.70, 'gamma', p.b3, 0.15};  % impact of external demand
priors.b4 = {p.b4, 0.3, 0.80, 'beta', p.b4, 0.15};   % weight in MCI
priors.a1 = {p.a1, 0.4, 0.90, 'beta', p.a1, 0.15};   % inflation persistence
priors.a2 = {p.a2, 0.1, 0.50, 'gamma', p.a2, 0.10};  % Phillips curve slope
priors.a3 = {p.a3, 0.5, 0.90, 'beta', p.a3, 0.15};   % domestic cost weight
priors.e1 = {p.e1, 0.0, 0.95, 'beta', p.e1, 0.20};   % UIP backward weight
priors.g1 = {p.g1, 0.0, 0.80, 'beta', p.g1, 0.20};  % policy persistence
priors.g2 = {p.g2, 0.01, 5.0, 'gamma', p.g2, 0.20}; % inflation response (Taylor rule)
priors.g3 = {p.g3, 0.01, 5.0, 'gamma', p.g3, 0.20};  % output gap response (Taylor rule)

% Persistence parameters (all use beta distribution as they are bounded [0,1])
priors.rho_D4L_CPI_TAR = {p.rho_D4L_CPI_TAR, 0.1, 0.95, 'beta', p.rho_D4L_CPI_TAR, 0.15}; 
priors.rho_DLA_Z_BAR = {p.rho_DLA_Z_BAR, 0.1, 0.95, 'beta', p.rho_DLA_Z_BAR, 0.15};
priors.rho_DLA_GDP_BAR = {p.rho_DLA_GDP_BAR, 0.1, 0.95, 'beta', p.rho_DLA_GDP_BAR, 0.15};
priors.rho_RR_BAR = {p.rho_RR_BAR, 0.1, 0.95, 'beta', p.rho_RR_BAR, 0.15};
priors.rho_RR_RW_BAR = {p.rho_RR_RW_BAR, 0.1, 0.95, 'beta', p.rho_RR_RW_BAR, 0.15};
priors.rho_L_GDP_RW_GAP = {p.rho_L_GDP_RW_GAP, 0.1, 0.95, 'beta', p.rho_L_GDP_RW_GAP, 0.15};
priors.rho_RS_RW = {p.rho_RS_RW, 0.1, 0.95, 'beta', p.rho_RS_RW, 0.15};
priors.rho_DLA_CPI_RW = {p.rho_DLA_CPI_RW, 0.1, 0.95, 'beta', p.rho_DLA_CPI_RW, 0.15};

%% Bayesian Estimation
% The estimate function with priors performs Bayesian estimation
% It finds the posterior mode (MAP estimate) by maximizing the log-posterior
fprintf('\nStarting Bayesian estimation (finding posterior mode)...\n');
[Est, Poster, Table, Hess, MEst, V, Delta, PDelta] = estimate( ...
    m, d, startdate:enddate, priors);

fprintf('Bayesian estimation complete.\n\n');

%% Display estimation results
disp('------------------------------------------------------------------');
disp('Bayesian Estimation Results (Posterior Mode)');
disp('------------------------------------------------------------------');
disp(Est);




%% Load the estimated params into pE
pE = p;
pE.b1 = Est{'b1', 'PosterMode'};
pE.b2 = Est{'b2', 'PosterMode'};
pE.b3 = Est{'b3', 'PosterMode'};
pE.b4 = Est{'b4', 'PosterMode'};
pE.a1 = Est{'a1', 'PosterMode'};
pE.a2 = Est{'a2', 'PosterMode'};
pE.a3 = Est{'a3', 'PosterMode'};
pE.e1 = Est{'e1', 'PosterMode'};
pE.g1 = Est{'g1', 'PosterMode'};
pE.g2 = Est{'g2', 'PosterMode'};
pE.g3 = Est{'g3', 'PosterMode'};
pE.rho_D4L_CPI_TAR = Est{'rho_D4L_CPI_TAR', 'PosterMode'};
pE.rho_DLA_Z_BAR = Est{'rho_DLA_Z_BAR', 'PosterMode'};
pE.rho_DLA_GDP_BAR = Est{'rho_DLA_GDP_BAR', 'PosterMode'};
pE.rho_RR_BAR = Est{'rho_RR_BAR', 'PosterMode'};
pE.rho_RR_RW_BAR = Est{'rho_RR_RW_BAR', 'PosterMode'};
pE.rho_L_GDP_RW_GAP = Est{'rho_L_GDP_RW_GAP', 'PosterMode'};
pE.rho_RS_RW = Est{'rho_RS_RW', 'PosterMode'};
pE.rho_DLA_CPI_RW = Est{'rho_DLA_CPI_RW', 'PosterMode'};
