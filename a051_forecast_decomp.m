%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Forecast decomposition to shocks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Housekeeping
clearvars
close all

addpath utils

%% Read the model
[m, p, mss] = readmodel();

%% Data in order to replicate baseline
% Loads the baseline scenario
d = dbload('results/baseline.csv');

% store the baseline in h
h = d; % for reporting and reference purposes 

%% Forecast and decomposition range
% The range has to be same as for the baseline

startfcast = qq(2014,1);
endfcast   = qq(2016,4);
fcastrange = startfcast:endfcast;

%% Simulate baseline scenario and compile decomposition
s = simulate(m, d, fcastrange, 'anticipate', true, 'contributions', true);

%% select the most significant shocks for list of variables
list_ = {'D4L_CPI'};

for i = 1:numel(list_)
    se = s.(list_{i}).^2;
    [sse, index] = sort(sum(se, 1), 'descend');
    n = numel(sse([sse~=0]));
    out.(list_{i}) = s.(list_{i}){:, index(1:n)}; 
end

disp('Reporting ... ')
%% Report
x = Report.new('Forecast Decomposition');

% report properties
sty = struct();
sty.line.linewidth = 1.5;
sty.axes.box = 'off';
sty.legend.location = 'SouthOutside';
sty.legend.Box = 'off';
sty.bar.EdgeColor = 'None';

x.figure('Decomposition of Headline inflation, y-o-y', 'style', sty, 'range', fcastrange, 'dateformat', 'YY:P'); % to be added during the video

x.graph('Inflation, y-o-y','legend',true); 
x.series('',[out.D4L_CPI],'plotfunc',@conbar, ...
            'legendEntry', cellstr(strrep(get(out.D4L_CPI, 'comment'), '_', '\_'))); 

x.publish('results/Forecast_decomposition', 'display', false);
disp('Done!');
