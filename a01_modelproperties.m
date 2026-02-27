%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% IMPULSE RESPONSE FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Housekeeping
clearvars
close all

%% If non-existent, create "results" folder where all results will be stored
[~,~,~] = mkdir('results');

%% Read the model
[m,p,mss] = readmodel();

%% Define shocks
% One period unexpected shocks: inflation, output, exchange rate, interest rate
% Create a list of shock variables and a list of their titles. The shock variables
% must have the names found in the model code (in file 'model.model')
listshocks = {'SHK_DLA_CPI','SHK_L_GDP_GAP','SHK_L_S','SHK_RS'}; % The last shock (monetary policy) is added in the video
listtitles = {'Inflationary (cost-push) Shock','Aggregate Demand Shock', 'Exchange Rate Shock', 'Interest Rate (monetary policy) Shock'}; % The last shock (monetary policy) is added in the video

% Set the time frame for the simulation 
startsim = qq(0,1);
endsim = qq(3,4); % four-year simulation horizon

% For each shock a zero database is created (command 'zerodb') and named as 
% database 'd.{shock_name}'
for i = 1:length(listshocks)
    d.(listshocks{i}) = zerodb(m,startsim:endsim);
end

% Fill the respective databases with the shock values for the starting
% point of the simulation (startsim). For simplicity, all shocks are set to
% 1 percent
d.SHK_DLA_CPI.SHK_DLA_CPI(startsim) = 1;
d.SHK_L_GDP_GAP.SHK_L_GDP_GAP(startsim) = 1;
d.SHK_L_S.SHK_L_S(startsim) = 1;
d.SHK_RS.SHK_RS(startsim) = 1; % This shock (monetary policy) is added in the video

%% Simulate IRFs
% Simulate the model's response to a given shock using the command 'simulate'.
% The inputs are model 'm' and the respective database 'd.{shock_name}'.
% Results are written in database 's.{shock_name}'.
for i=1:length(listshocks)    
    s.(listshocks{i}) = simulate(m,d.(listshocks{i}),startsim:endsim,'deviation',true);
end

%% Generate pdf report
x = report.new('Shocks');

% Figure style
sty = struct();
sty.line.linewidth = 1;
sty.line.linestyle = {'-';'--'};
sty.line.color = {'k';'r'};
sty.legend.location = 'Best';

% Create separate page with IRFs for each shock
for i = 1:length(listshocks)

x.figure(listtitles{i},'zeroline',true,'style',sty, ...
         'range',startsim:endsim,'legend',false,'marks',{'Baseline','Alternative'});

x.graph('CPI Inflation QoQ (% ar)','legend',true);
x.series('',s.(listshocks{i}).DLA_CPI);

x.graph('Nominal Interest Rate (% ar)');
x.series('',s.(listshocks{i}).RS);

x.graph('Nominal ER Deprec. QoQ (% ar)');
x.series('',s.(listshocks{i}).DLA_S);

x.graph('Output Gap (%)');
x.series('',[s.(listshocks{i}).L_GDP_GAP]);

x.graph('Real Interest Rate Gap (%)');
x.series('', s.(listshocks{i}).RR_GAP);

x.graph('Real Exchange Rate Gap (%)');
x.series('', s.(listshocks{i}).L_Z_GAP);
 
% This graph is added in the video 
x.graph('Real Monetary Condition Index (%)');
x.series('', s.(listshocks{i}).MCI);

end

x.publish('results/Shocks.pdf','display',false);
disp('Done!!!');