%%%%%%%
%%% FILTRATION WITH ESTIMATED PARAMETERS
%%%%%%%

%% Housekeeping
%clearvars
%close all

addpath utils

%% Read the model with estimated parameters

[m,p,mss] = readmodel_est(p, Est);

% %% Set variances for Kalman filtration
% p.std_SHK_L_GDP_GAP   = 1;
% p.std_SHK_DLA_GDP_BAR = 0.5;
% 
% p.std_SHK_DLA_CPI     = 1;
% p.std_SHK_D4L_CPI_TAR = 0.75;
% 
% p.std_SHK_L_S = 0.25;
% p.std_SHK_RS  = 0.75;
% 
% p.std_SHK_RR_BAR    = 0.5;
% p.std_SHK_DLA_Z_BAR = 0.5;
% 
% p.std_SHK_L_GDP_RW_GAP = 2;
% p.std_SHK_RS_RW        = 0.5;
% p.std_SHK_DLA_CPI_RW   = 2;
% p.std_SHK_RR_RW_BAR    = 0.5;

m = assign(m,p);
m = solve(m);

%% Create model report
m=modelreport(m);

%% Data sample
sdate = qq(1998,1);
edate = qq(2013,1);

%% Load data
d = dbload('results/history.csv');

dd.OBS_L_CPI        = d.L_CPI;

dd.OBS_L_GDP        = d.L_GDP;
dd.OBS_L_S          = d.L_S;
dd.OBS_RS           = d.RS;

dd.OBS_RS_RW        = d.RS_RW;

dd.OBS_DLA_CPI_RW   = d.DLA_CPI_RW;
dd.OBS_L_GDP_RW_GAP = d.L_GDP_RW_GAP;
dd.OBS_D4L_CPI_TAR  = d.D4L_CPI_TAR;

%% Filtration
% Input arguments:
%   m - solved model object
%   dd - database with observations for measurement variables
%   sdate:edate - date range to tun the filter
% Some output arguments:
%   m_kf - model object
%   g - output structure with smoother or prediction data
%   v - estimated variance scale factor
[m_kf,g,v,delta,pe] = filter(m,dd,sdate:edate);

h = g.mean;
d = dbextend(d,h);

%% Save the database
% Database is saved in file 'kalm_his_est.mat'
dbsave(d,'results/kalm_his_est.csv');
save('results/kalm_his_est.mat', 'g');

%% Report
% full version
disp('Generating Filtration Report with Estimated Parameters...');
x = report.new('Filtration report (Estimated)','visible',true);

%% Figures
% rng = qq(2012,1):edate;
rng = sdate:edate;
sty = struct();
sty.line.linewidth = 1;
sty.line.linestyle = {'-';'--'};
sty.line.color = {'k';'r'};
sty.axes.box = 'on';
sty.legend.location='Best';
sty.legend.FontSize=12;
sty.axes.fontsize = 12;
sty.title.fontsize = 16;

x.figure('Observed and Trends (Estimated)','subplot',[2,3],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('GDP','legend',false);
x.series('',[d.L_GDP d.L_GDP_BAR]);

x.graph('Real Interest Rate','legend',false);
x.series('',[d.RR d.RR_BAR]);

x.graph('Foreign Real Interest Rate','legend',false);
x.series('',[d.RR_RW d.RR_RW_BAR]);

x.graph('Real Exchange Rate','legend',false);
x.series('',[d.L_Z d.L_Z_BAR]);

x.graph('Change in Eq. Real Exchange rate','legend',false);
x.series('',[d.DLA_Z_BAR]);

x.graph('Risk Premium','legend',false);
x.series('',[d.PREM]);

x.pagebreak();

x.figure('Gaps (Estimated)','subplot',[3,3],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Inflation','legend',false);
x.series('',[d.DLA_CPI d.D4L_CPI_TAR]);

x.graph('Marginal Cost','legend',false);
x.series('',[d.RMC]);

x.graph('GDP GAP','legend',false);
x.series('',[d.L_GDP_GAP]);

x.graph('Monetary Conditions','legend',false);
x.series('',[d.MCI]);

x.graph('Real Interest Rate Gap','legend',false);
x.series('',[d.RR_GAP]);

x.graph('Real Exchange Rate Gap','legend',false);
x.series('',[d.L_Z_GAP]);

x.graph('Foreign GDP Gap','legend',false);
x.series('',[d.L_GDP_RW_GAP]);

x.graph('Foreign inflation','legend',false);
x.series('',[d.DLA_CPI_RW]);

x.graph('Foreign interest rates','legend',false);
x.series('',[d.RS_RW]);

x.figure('Shocks (Estimated)','subplot',[3,3],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Inflation (cost-push)','legend',false);
x.series('',[d.SHK_DLA_CPI]);

x.graph('Output gap','legend',false);
x.series('',[d.SHK_L_GDP_GAP]);

x.graph('Interest Rate','legend',false);
x.series('',[d.SHK_RS]);

x.graph('Exchange Rate','legend',false);
x.series('',[d.SHK_L_S]);

x.graph('Trend Real Interest Rate','legend',false);
x.series('',[d.SHK_RR_BAR]);

x.graph('Trend Real Exchange Rate','legend',false);
x.series('',[d.SHK_DLA_Z_BAR]);

x.figure('Interest rate and exchange rate (Estimated)','subplot',[3,3],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Nominal interest rate','legend',false);
x.series('',[d.RS]);

x.graph('Real Interest Rate Gap','legend',false);
x.series('',[d.RR_GAP]);

x.graph('Inflation qoq','legend',false);
x.series('',[d.DLA_CPI]);

x.graph('Nominal exchange rate rate','legend',false);
x.series('',[d.S]);

x.graph('Real Exchange Rate Gap','legend',false);
x.series('',[d.L_Z_GAP]);

x.graph('Nominal exchange rate rate depreciation','legend',true);
x.series('',[d.DLA_S d.D4L_S],'legendEntry=',{'qoq','yoy'});

x.graph('Inflation differential','legend',true);
x.series('',[d.DLA_CPI d.DLA_CPI_RW],'legendEntry=', {'domestic inflation','foreign inflation'});

x.graph('Interest rate differential','legend',true);
x.series('',[d.RS d.RS_RW],'legendEntry=', {'domestic IR','foreign IR'});

x.graph('Exchange rate shock','legend',false);
x.series('',[d.SHK_L_S]);

% Actual vs Predicted
x.figure('Inflation','subplot',[2,2],'style',sty,'range',rng,'dateformat','YY:P', 'zeroLine', true);

x.graph('Inflation qoq, percent','legend',true);
x.series('',[d.DLA_CPI d.DLA_CPI-d.SHK_DLA_CPI], 'legendEntry=', {'Actual','Predicted'});

x.graph('Output qoq, percent','legend',true);
x.series('',[d.L_GDP_GAP d.L_GDP_GAP-d.SHK_L_GDP_GAP], 'legendEntry=', {'Actual','Predicted'});

x.graph('Interest rate, percent','legend',true);
x.series('',[d.RS d.RS-d.SHK_RS], 'legendEntry=', {'Actual','Predicted'});

x.graph('Exchange rate, percent','legend',true);
x.series('',[d.L_S d.L_S-d.SHK_L_S], 'legendEntry=', {'Actual','Predicted'});

% inflation and RMC decomp
x.figure('','subplot',[2,1],'style',sty,'range',rng,'dateformat','YY:P', 'zeroLine', true);
x.graph('Marginal cost decomposition, pp','legend',true);
x.series('',[p.a3*d.L_GDP_GAP (1-p.a3)*d.L_Z_GAP],'legendEntry=',{'Output gap','RER gap'},'plotfunc',@barcon);
x.series('',d.RMC,'legendEntry=',{'RMC'});

x.graph('Inflation decomposition, qoq percent','legend',true);
x.series('',[p.a1*d.DLA_CPI{-1} (1-p.a1)*d.E_DLA_CPI p.a2*p.a3*d.L_GDP_GAP p.a2*(1-p.a3)*d.L_Z_GAP d.SHK_DLA_CPI],...
  'legendEntry=',{'Persistency','Expectations','Output Gap','RER Gap','Shock'},'plotfunc',@barcon);
x.series('',d.DLA_CPI,'legendEntry=',{'Inflation'});

% output gap decomp
x.figure('Output gap (Estimated)','subplot',[2,1],'style',sty,'range',rng,'dateformat','YY:P', 'zeroLine', true);

x.graph('Output gap decomposition, pp','legend',true);
x.series('',[p.b1*d.L_GDP_GAP{-1} -p.b2*p.b4*d.RR_GAP p.b2*(1-p.b4)*d.L_Z_GAP p.b3*d.L_GDP_RW_GAP d.SHK_L_GDP_GAP],...
    'legendEntry=',{'Lead','Lag','RIR gap','RER gap','Foreign gap','Shock'},'plotfunc',@barcon);
x.series('',d.L_GDP_GAP,'legendEntry=','Output Gap');

x.graph('MCI decomposition, pp','legend',true);
x.series('',[p.b4*d.RR_GAP (1-p.b4)*(-d.L_Z_GAP)],'legendEntry=',{'RIR gap','RER gap'},'plotfunc',@barcon);
x.series('',d.MCI,'legendEntry=','MCI');

x.publish('results/Filtration_Est','display',false, 'cleanup=', false);
disp('Done!!!');

rmpath utils