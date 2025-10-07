function in_sample_report(stime,etime,list_xnames)
% IN_SAMPLE_REPORT(stime,etime,list_xnames)
% This function generates in-sample forecasts and report the results in PDF
% Function inputs are
%       stime ........... [Iris date] intial period for the first simulation
%       etime ........... [Iris date] last reported period
% list_xnames ........... [cell of strings] list of model variable names to
%                         include in the report

%% Load model 
m = readmodel();

% get model variables descriptions 
desc = get(m,'descript');

%% Database preparation

% load Kalman filter results
h = dbload('results/kalm_his.csv');
% Remove all residuals from the database filter database
h = rmfield(h,get(m,'eList'));
% get range of the database h
h_range = dbrange(h);

% initialize results database "res"
for i = 1:length(list_xnames)
    res.(list_xnames{i}) = tseries();
end

%% Simulations ... (done in a "FOR loop")
%Beginning of the "FOR loop" ...
for time = stime:1:etime
  
    % set simulation range
    fcastrng = time:time+8;
    if fcastrng(end)>etime
        exorng = time:etime;
    else
        exorng = time:time+8;
    end

disp(' ');
disp('---------------------------------------------------------------------')
disp(['The first simulated time period of this projection round: ',char(dat2str(time+1))]);
disp(' ');

% Create simulation plan
fcast_plan  = plan(m,fcastrng);
    
% condition the forecast on the inflation target
fcast_plan  = exogenize(fcast_plan,'D4L_CPI_TAR',exorng);
fcast_plan  = endogenize(fcast_plan,'SHK_D4L_CPI_TAR',exorng);

% condition the forecast on the foreign output gap
fcast_plan  = exogenize( fcast_plan,'L_GDP_RW_GAP',exorng);
fcast_plan  = endogenize(fcast_plan,'SHK_L_GDP_RW_GAP',exorng);

% condition the forecast on the foreign nominal interest rate
fcast_plan  = exogenize( fcast_plan,'RS_RW',exorng);
fcast_plan  = endogenize(fcast_plan,'SHK_RS_RW',exorng);

% condition the forecast on the foreign real equilibrium interest rate
fcast_plan  = exogenize( fcast_plan,'RR_RW_BAR',exorng);
fcast_plan  = endogenize(fcast_plan,'SHK_RR_RW_BAR',exorng);

% condition the forecast on the foreign inflation rate
fcast_plan  = exogenize( fcast_plan,'DLA_CPI_RW',exorng);
fcast_plan  = endogenize(fcast_plan,'SHK_DLA_CPI_RW',exorng);

% Simulate the model
dbfcast = simulate(m,h,fcastrng,'plan',fcast_plan,'anticipate',false);

% combine Kalman filter results with the simulation results
s = dbextend(dbclip(h,h_range(1):fcastrng(1)-1),dbfcast);
    
% Add the results into the database "res"
for i = 1:length(list_xnames)
    res.(list_xnames{i}) = [res.(list_xnames{i}), s.(list_xnames{i})];
end

end %end of the simulation "loop"

%% Generate report

srep = stime-4; % beginning of reported range
erep = etime; % end of reported range

% Start the report
x = Report.new('In-Sample Forecasts','visible',false);

% Define style for figures
sty = struct();
sty.line.linewidth = 2;
sty.title.fontsize = 14;
sty.axes.fontsize = 14;

% plot figure in a FOR loop
for i = 1:length(list_xnames)
    % open new figure window
    x.figure('','range',srep:erep,'dateformat','YY:P','style',sty);
    % open new graph
    x.graph(desc.(list_xnames{i}),'legend',false);
    % plot simulation results
    x.series('',res.(list_xnames{i}));
    % plot filtered data
    x.series('',h.(list_xnames{i}),'plotOptions',{'color','k'});
end

% generate the PDF file
x.publish('results/In_sample.pdf','display',false);

end

