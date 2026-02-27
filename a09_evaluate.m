%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EVALUATION OF ESTIMATION METHODS
%%% Adapted from model_VN_estimate for MPAFx_example
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare three estimation approaches:
%   1. Maximum Likelihood (MLE)
%   2. Bayesian (posterior mode)
%   3. System Priors (if available; otherwise skip)
%
% Metrics: Log-likelihood, AIC, BIC, in-sample RMSE

close all;

%% ========================================================================
%  SECTION 1 — Common Setup (MPAFx parameters, no b0)
%  ========================================================================

p = struct();
p.ss_DLA_GDP_BAR = 2.5;
p.ss_D4L_CPI_TAR = 2;
p.ss_RR_BAR      = 0.5;
p.ss_DLA_Z_BAR   = -1.5;
p.ss_DLA_CPI_RW  = 2;
p.ss_RR_RW_BAR   = 0.75;

p.b1 = 0.8;  p.b2 = 0.3;  p.b3 = 0.5;  p.b4 = 0.7;
p.a1 = 0.7;  p.a2 = 0.2;  p.a3 = 0.7;
p.g1 = 0.7;  p.g2 = 0.5;  p.g3 = 0.5;
p.e1 = 0.4;

p.rho_D4L_CPI_TAR  = 0.5;
p.rho_DLA_Z_BAR    = 0.8;
p.rho_DLA_GDP_BAR  = 0.8;
p.rho_RR_BAR       = 0.8;
p.rho_RR_RW_BAR    = 0.8;
p.rho_L_GDP_RW_GAP = 0.8;
p.rho_RS_RW        = 0.8;
p.rho_DLA_CPI_RW   = 0.8;

m = model('model.model', 'linear=', true, 'assign', p);
m = solve(m);
m = sstate(m);

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

param_names = {'b1','b2','b3','b4','a1','a2','a3','e1','g1','g2','g3', ...
    'rho_D4L_CPI_TAR','rho_DLA_Z_BAR','rho_DLA_GDP_BAR','rho_RR_BAR', ...
    'rho_RR_RW_BAR','rho_L_GDP_RW_GAP','rho_RS_RW','rho_DLA_CPI_RW'};
nParams = numel(param_names);

ylist   = get(m, 'yList');
nObs    = length(startdate:enddate);

%% ========================================================================
%  SECTION 2 — MLE Estimation
%  ========================================================================
fprintf('\n===  MLE Estimation  ===\n');

E_mle = struct();
E_mle.b1 = [p.b1, 0.1, 0.95];
E_mle.b2 = [p.b2, 0.1, 0.50];
E_mle.b3 = [p.b3, 0.1, 0.70];
E_mle.b4 = [p.b4, 0.3, 0.80];
E_mle.a1 = [p.a1, 0.4, 0.90];
E_mle.a2 = [p.a2, 0.1, 0.50];
E_mle.a3 = [p.a3, 0.5, 0.90];
E_mle.e1 = [p.e1, 0.0, 0.95];
E_mle.g1 = [p.g1, 0.0, 0.80];
E_mle.g2 = [p.g2, 0.01, Inf];
E_mle.g3 = [p.g3, 0.01, Inf];
E_mle.rho_D4L_CPI_TAR  = [p.rho_D4L_CPI_TAR,  0.1, 0.95];
E_mle.rho_DLA_Z_BAR    = [p.rho_DLA_Z_BAR,    0.1, 0.95];
E_mle.rho_DLA_GDP_BAR  = [p.rho_DLA_GDP_BAR,  0.1, 0.95];
E_mle.rho_RR_BAR       = [p.rho_RR_BAR,       0.1, 0.95];
E_mle.rho_RR_RW_BAR    = [p.rho_RR_RW_BAR,    0.1, 0.95];
E_mle.rho_L_GDP_RW_GAP = [p.rho_L_GDP_RW_GAP, 0.1, 0.95];
E_mle.rho_RS_RW        = [p.rho_RS_RW,        0.1, 0.95];
E_mle.rho_DLA_CPI_RW   = [p.rho_DLA_CPI_RW,   0.1, 0.95];

[~, ~, ~, ~, m_mle] = estimate(m, d, startdate:enddate, E_mle);

%% ========================================================================
%  SECTION 3 — Bayesian Estimation
%  ========================================================================
fprintf('\n===  Bayesian Estimation  ===\n');

E_bay = struct();
E_bay.b1 = {p.b1, 0.1, 0.95, 'beta', p.b1, 0.15};
E_bay.b2 = {p.b2, 0.1, 0.50, 'gamma', p.b2, 0.10};
E_bay.b3 = {p.b3, 0.1, 0.70, 'gamma', p.b3, 0.15};
E_bay.b4 = {p.b4, 0.3, 0.80, 'beta', p.b4, 0.15};
E_bay.a1 = {p.a1, 0.4, 0.90, 'beta', p.a1, 0.15};
E_bay.a2 = {p.a2, 0.1, 0.50, 'gamma', p.a2, 0.10};
E_bay.a3 = {p.a3, 0.5, 0.90, 'beta', p.a3, 0.15};
E_bay.e1 = {p.e1, 0.0, 0.95, 'beta', p.e1, 0.20};
E_bay.g1 = {p.g1, 0.0, 0.80, 'beta', p.g1, 0.20};
E_bay.g2 = {p.g2, 0.01, 5.0, 'gamma', p.g2, 0.20};
E_bay.g3 = {p.g3, 0.01, 5.0, 'gamma', p.g3, 0.20};
E_bay.rho_D4L_CPI_TAR  = {p.rho_D4L_CPI_TAR,  0.1, 0.95, 'beta', p.rho_D4L_CPI_TAR,  0.15};
E_bay.rho_DLA_Z_BAR    = {p.rho_DLA_Z_BAR,    0.1, 0.95, 'beta', p.rho_DLA_Z_BAR,    0.15};
E_bay.rho_DLA_GDP_BAR  = {p.rho_DLA_GDP_BAR,  0.1, 0.95, 'beta', p.rho_DLA_GDP_BAR,  0.15};
E_bay.rho_RR_BAR       = {p.rho_RR_BAR,       0.1, 0.95, 'beta', p.rho_RR_BAR,       0.15};
E_bay.rho_RR_RW_BAR    = {p.rho_RR_RW_BAR,    0.1, 0.95, 'beta', p.rho_RR_RW_BAR,    0.15};
E_bay.rho_L_GDP_RW_GAP = {p.rho_L_GDP_RW_GAP, 0.1, 0.95, 'beta', p.rho_L_GDP_RW_GAP, 0.15};
E_bay.rho_RS_RW        = {p.rho_RS_RW,        0.1, 0.95, 'beta', p.rho_RS_RW,        0.15};
E_bay.rho_DLA_CPI_RW   = {p.rho_DLA_CPI_RW,   0.1, 0.95, 'beta', p.rho_DLA_CPI_RW,   0.15};

[~, ~, ~, ~, m_bay] = estimate(m, d, startdate:enddate, E_bay);

%% ========================================================================
%  SECTION 4 — System Priors (optional, if available)
%  ========================================================================
m_sys = [];
method_names = {'MLE', 'Bayesian'};

try
    fprintf('\n===  System Priors Estimation  ===\n');
    z = SystemPriorWrapper.forModel(m);
    dsim = zerodb(m, 1:40);
    dsim.SHK_D4L_CPI_TAR(1) = -1;
    p1 = simulate(m, dsim, 1:40, 'Deviation', true, 'SystemProperty', 'S');
    z.addSystemProperty(p1);
    z.addSystemPrior('-sum(S(L_GDP_GAP, :))/4', distribution.Normal.fromMeanStd(0.5, 0.30));
    dsim2 = zerodb(m, 1:40);
    dsim2.SHK_RS(1) = 1;
    p2 = simulate(m, dsim2, 1:40, 'Deviation', true, 'SystemProperty', 'MP');
    z.addSystemProperty(p2);
    z.addSystemPrior('MP(L_GDP_GAP, 4)', distribution.Normal.fromMeanStd(-0.15, 0.15));
    z.seal();
    [~, ~, ~, ~, m_sys] = estimate(m, d, startdate:enddate, E_bay, z, ...
        'NoSolution', 'penalty', ...
        'EvalDataLik', 1, 'EvalIndiePriors', 1, 'EvalSystemPriors', 1);
    method_names{3} = 'SystemPriors';
catch
    warning('SystemPriorWrapper not available. Skipping System Priors comparison.');
end

%% ========================================================================
%  SECTION 5 — Compute Log-Likelihood, AIC, BIC, RMSE
%  ========================================================================
fprintf('\n===  Computing evaluation metrics  ===\n');

models = {m_mle, m_bay};
if ~isempty(m_sys)
    models{3} = m_sys;
end
nMethods = numel(models);

mll    = nan(1, nMethods);
aic    = nan(1, nMethods);
bic    = nan(1, nMethods);
rmse   = nan(numel(ylist), nMethods);

for j = 1:nMethods
    try
        [obj_j, ~, ~, PE_j] = loglik(models{j}, d, startdate:enddate);
        mll(j) = obj_j;
        logL = -obj_j;
        aic(j) = -2*logL + 2*nParams;
        bic(j) = -2*logL + nParams*log(nObs);
        for k = 1:numel(ylist)
            pe_k = PE_j.(ylist{k});
            pe_vals = pe_k(startdate:enddate);
            rmse(k,j) = sqrt(nanmean(pe_vals.^2));
        end
    catch
        mll(j) = NaN; aic(j) = NaN; bic(j) = NaN;
        rmse(:,j) = NaN;
    end
end

%% ========================================================================
%  SECTION 6 — Display Comparison Table
%  ========================================================================

fprintf('\n==================================================================\n');
fprintf('  ESTIMATION METHOD COMPARISON\n');
fprintf('==================================================================\n\n');

fprintf('%-25s', 'Metric');
for j = 1:nMethods
    fprintf(' %12s', method_names{j});
end
fprintf('\n%s\n', repmat('-', 1, 25 + 12*nMethods));

fprintf('%-25s', 'Minus Log-Likelihood');
for j = 1:nMethods
    fprintf(' %12.2f', mll(j));
end
fprintf('\n');

fprintf('%-25s', 'AIC');
for j = 1:nMethods
    fprintf(' %12.2f', aic(j));
end
fprintf('\n');

fprintf('%-25s', 'BIC');
for j = 1:nMethods
    fprintf(' %12.2f', bic(j));
end
fprintf('\n%s\n', repmat('-', 1, 25 + 12*nMethods));

fprintf('RMSE by measurement variable:\n');
for k = 1:numel(ylist)
    fprintf('  %-23s', ylist{k});
    for j = 1:nMethods
        fprintf(' %12.4f', rmse(k,j));
    end
    fprintf('\n');
end
fprintf('  %-23s', 'Average RMSE');
for j = 1:nMethods
    fprintf(' %12.4f', mean(rmse(:,j), 'omitnan'));
end
fprintf('\n%s\n\n', repmat('-', 1, 25 + 12*nMethods));

[~, best_aic] = min(aic);
[~, best_bic] = min(bic);
fprintf('Best by AIC : %s\n', method_names{best_aic});
fprintf('Best by BIC : %s\n\n', method_names{best_bic});
