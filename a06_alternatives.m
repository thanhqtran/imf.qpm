%%%%%%%%%%%%
%% Alternatives ...
%%%%%%%%%%%%kalm
%% Housekeeping
clearvars
close all

addpath utils

%% Read the model
[m, p, mss] = readmodel();

%%
% Defines the time frame of the forecast
% Don't forget to change the time frame depending on your data and forecast period!
startfcast = qq(2014,1);
endfcast   = qq(2016,4);
fcastrange = startfcast:endfcast;


%% Data for alternative
% d = dbload('results/baseline.csv');
% 
% % store the baseline in h
% h = d; % for reporting and comparison purposes 

%% an approach demostrating the importance of the intial conditions and shocks shaping baseline
%Load the intial conditions
d = dbload('results/kalm_his.csv');

% Loads the baseline scenario
df = dbload('results/baseline.csv');

%re-take only shocks from baseline
enames = get(m ,'enames');
d_ = df*enames;

% merge the intial state database and shocks over the forecast horizon
d = dboverlay(d, d_);

% store the baseline in h
h = df; % for reporting and comparison purposes 


%% Alternative scenarios (additional assumptions relative to forecast.m)

%% Codes for alternative scenarios for which "plan" is used
% A plan refers to a situation where a hard tune is sought
% Define the "plan" 
simplan = plan(m,startfcast:endfcast);

%% i) What-if scenarios
%% Consumer confidence shock
% d.SHK_L_GDP_GAP(startfcast:startfcast+3) = h.SHK_L_GDP_GAP(startfcast:startfcast+3) + [1, 1, 1, 1]';

%% Tax increase
% d.SHK_DLA_CPI(startfcast) = h.SHK_DLA_CPI(startfcast) + 1;

%% Sudden capital outflows
% d.SHK_L_S(startfcast) = h.SHK_L_S(startfcast) + 1;
% d.SHK_L_S(startfcast:startfcast+3) = h.SHK_L_S(startfcast:startfcast+3) + 1;
% d.SHK_RR_BAR(startfcast) = h.SHK_RR_BAR(startfcast) + 1;

%% ii) Monetary policy experiments
%% Scenario -- Prompt policy response
% d.RS(startfcast) = 0;
%% Scenaro -- Procrastination
% d.RS(startfcast) = d.RS(startfcast-1);

% % Fixing the policy rate for the first quarter
% simplan = exogenize(simplan,{'RS'},startfcast);
% simplan = endogenize(simplan,{'SHK_RS'},startfcast);

%% complex scenario -- domestic economic recession
% d.SHK_L_GDP_GAP(startfcast: startfcast+1) = h.SHK_L_GDP_GAP(startfcast:startfcast+1) - 1;
% d.SHK_DLA_GDP_BAR (startfcast:startfcast+1) = h.SHK_DLA_GDP_BAR (startfcast:startfcast+1) - 0.25;
% d.SHK_DLA_Z_BAR (startfcast:startfcast+1) = h.SHK_DLA_Z_BAR (startfcast:startfcast+1) - 0.25;


%% UIP shock example
% d.SHK_L_S(startfcast) = h.SHK_L_S(startfcast) + 2;


%% Simulate alternative scenario
s = simulate(m, d, fcastrange, 'plan', simplan, 'anticipate', true);

%%
% Command 'dboverlay' puts together the historical database 'h' and the
% results of the simulation saved in object 's'. Single database 's' is
% created
d = dbextend(d,s);


%% Fiscal alternative - fiscal scenario brought from the Fiscal Workshop
% f_s = dbload('fiscal_scenario.csv');
% 
% list = get(m, 'xList'); % get list of state variables 
% list = list-{'RS_UNC', 'D4L_WFOOD', 'D4L_WOIL', 'D4L_S_TAR', 'D4L_CPI_DEV'};
% 
% for i = 1 : length(list)
%     d.(list{i}) = d.(list{i}) + f_s.(list{i});
% end

%% Merging baseline and alternative databases
f = h & d;

%% Results are saved in file 'fcastdata_alt.csv'  
dbsave('fcastdata_alt.csv',f);

%% Graphs and Tables
% Prepares the report: graphs and tables in the Acrobat .pdf format
Tablerng = startfcast-3:startfcast+7;
Plotrng = startfcast-3:startfcast+11;
Histrng = startfcast-3:startfcast-1;

% Specify country and units for exchange rate
country = 'The Czech Republic';
exchange = 'CZK/EUR';

alternative = 'Alternative';

%% Report
x = Report.new(country,'marks',{'Baseline';'Alternative'});

% Figures
sty = struct();
sty.line.linewidth = 1.5;
sty.line.linestyle = {'-';'--';':'};
sty.axes.box = 'off';
sty.legend.location = 'Best';
sty.legend.Box = 'off';

x.figure(alternative,'subplot',[2,3],'style',sty,'range',Plotrng,'dateformat','YYYY:P');

x.graph('Inflation, % qoq','legend',true);
x.series('',f.DLA_CPI);
x.highlight('',Histrng);

x.graph('Inflation, % y-o-y','legend',false);
x.series('',f.D4L_CPI);
x.highlight('',Histrng);

x.graph('Nom. Interest Rate, % p.a.','legend',false);
x.series('',f.RS);
x.highlight('',Histrng);

x.graph('Nom. Exchange Rate','legend',false);
x.series('',exp(f.L_S/100));
x.highlight('',Histrng);

x.graph('Output Gap, %','legend',false);
x.series('',f.L_GDP_GAP);
x.highlight('',Histrng);

x.graph('Monetary Conditions, %','legend',false);
x.series('',f.MCI);
x.highlight('',Histrng);

x.pagebreak();

% Tables
TableOptions = {'range',Tablerng,'vline',startfcast-1,'decimal',1,'dateformat','YYYY:P',...
    'long',true,'longfoot','---continued','longfootposition','right'};

x.table([alternative ' - Main Indicators'],TableOptions{:});

x.subheading('Inflation');
  x.series('CPI ',f.D4L_CPI,'units','% (y-o-y)');
  x.series('',f.DLA_CPI,'units','% (q-o-q)');

x.subheading('Nominal Interest Rates');
  x.series('Policy Rate',f.RS,'units','% p.a.');
  x.series('Policy Neutral Rate',f.RSNEUTRAL,'units','% p.a');
  
x.subheading('Nominal Exchange Rate');
  x.series(exchange,exp(f.L_S/100),'units','level');
  x.series('',f.L_S - f.L_S{-4},'units','% (y-o-y)');
  x.series('',f.DLA_S,'units','% (q-o-q)');

x.pagebreak();

x.table([alternative ' - Main Indicators'],TableOptions{:});

x.subheading('Real Economy');
  x.series('Output Gap',f.L_GDP_GAP,'units','%');
  x.series('GDP Growth',f.L_GDP - f.L_GDP{-4},'units','% (y-o-y)');

x.subheading('Monetary Conditions');
  x.series('Monetary Conditions',f.MCI,'units','%');
  x.series('Real Interest Rate Gap ',f.RR_GAP,'units','p.p.');
  x.series('Real Exchange Rate Gap',f.L_Z_GAP,'units','%');
  
x.pagebreak();

x.table([alternative 'Foreign Variables'],TableOptions{:});

x.subheading('European Monetary Union');
  x.series('Inflation',f.DLA_CPI_RW,'units','% (q-o-q)');
  x.series('Interest Rate',f.RS_RW,'units','%');
  x.series('Output Gap',f.L_GDP_RW_GAP,'units','%');

    
x.publish('results/alternative_comparison','display',false);
disp('Done!');