%%%%%%%%%%%%%%%%%%%%%%%%
%%% In-sample Simulation
%%%%%%%%%%%%%%%%%%%%%%%%

% close all figure windows
close all;

% clear workspace
clearvars;

% add folder "utils" on matlab path
addpath utils

%% Set time ranges
stime = qq(2006,1); %starting point of the first simulation 
                    %stime-1 is the initial state
                    %stime is the first simulated time period
etime = qq(2013,4); %the end of the known history
       
%% Selection of model variables to include in the report:

list_xnames = {'DLA_CPI','D4L_CPI','L_GDP_GAP','D4L_GDP','L_S'}; 

%% Calling function (stored in "utils" folder) which generates the in-sample simulations and reports the results
in_sample_report(stime,etime,list_xnames)

% remove folder "utils" from matlab path
rmpath utils