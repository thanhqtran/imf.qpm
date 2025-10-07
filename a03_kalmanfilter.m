clearvars
close all

addpath utils

[m,p,mss] = readmodel();

p.std_SHK_L_GDP_GAP   = 1;
p.std_SHK_DLA_GDP_BAR = 0.5;

p.std_SHK_DLA_CPI     = 0.75;
p.std_SHK_D4L_CPI_TAR = 2;

p.std_SHK_L_S = 3; 
p.std_SHK_RS  = 1;

p.std_SHK_RR_BAR    = 0.5;
p.std_SHK_DLA_Z_BAR = 0.5;

p.std_SHK_L_GDP_RW_GAP = 1;
p.std_SHK_RS_RW        = 1;
p.std_SHK_DLA_CPI_RW   = 2;
p.std_SHK_RR_RW_BAR    = 0.5;

m = assign(m,p);
m = solve(m);

m=modelreport(m);

sdate = qq(1998,1);
edate = qq(2013,4);

d = dbload('results/history.csv');

dd.OBS_L_CPI        = d.L_CPI;

dd.OBS_L_GDP        = d.L_GDP;
dd.OBS_L_S          = d.L_S;
dd.OBS_RS           = d.RS;

dd.OBS_RS_RW        = d.RS_RW;

dd.OBS_DLA_CPI_RW   = d.DLA_CPI_RW;
dd.OBS_L_GDP_RW_GAP = d.L_GDP_RW_GAP;
dd.OBS_D4L_CPI_TAR  = d.D4L_CPI_TAR;

[m_kf,g,v,delta,pe] = filter(m,dd,sdate:edate);

h = g.mean;
d = dbextend(d,h);

dbsave(d,'results/kalm_his.csv');
save('results/kalm_his.mat', 'g');

disp('Generating Filtration Report...');
x = Report.new('Filtration report','visible',true);

rng = sdate:edate;
sty = struct();
sty.line.linewidth = 0.5;
sty.title.fontsize = 6;
sty.axes.fontsize = 6;
sty.line.linestyle = {'-';'--'};
sty.line.color = {'k';'r'};
sty.axes.box = 'off';
sty.legend.location='Best';
sty.legend.FontSize=3;

x.figure('Observed and Trends','subplot',[2,3],'style',sty,'range',rng,'dateformat','YY:P');

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

x.figure('Gaps','subplot',[3,3],'style',sty,'range',rng,'dateformat','YY:P');

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

x.figure('Shocks','subplot',[3,3],'style',sty,'range',rng,'dateformat','YY:P');

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

x.figure('Interest rate and exchange rate','subplot',[3,3],'style',sty,'range',rng,'dateformat','YY:P');

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
x.series('',[d.DLA_S d.D4L_S], 'legendEntry=',{'qoq','yoy'});

x.graph('Inflation differential','legend',true);
x.series('',[d.DLA_CPI d.DLA_CPI_RW], 'legendEntry=', {'domestic inflation','foreign inflation'});

x.graph('Interest rate differential','legend',true);
x.series('',[d.RS d.RS_RW], 'legendEntry=', {'domestic IR','foreign IR'});

x.graph('Exchange rate shock','legend',false);
x.series('',[d.SHK_L_S]);

x.figure('Inflation','subplot',[3,1],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Inflation qoq, percent','legend',true);
x.series('',[d.DLA_CPI d.DLA_CPI-d.SHK_DLA_CPI], 'legendEntry=', {'Actual','Predicted'});

x.graph('Inflation and RMC, percent','legend',true);
x.series('',[d.DLA_CPI-d.D4L_CPI_TAR d.RMC],'legendEntry=', {'Inflation (deviation from the target)','RMC'});

x.graph('Marginal cost decomposition, pp','legend',true);
x.series('',[d.a3*d.L_GDP_GAP (1-d.a3)*d.L_Z_GAP],'legendEntry=',{'Output gap','RER gap'},'plotfunc',@barcon);
x.series('',d.RMC,'legendEntry=',{'RMC'});

x.figure('','style',sty,'range',rng,'dateformat','YY:P');
x.graph('Inflation decomposition, qoq percent','legend',true);
x.series('',[d.a1*d.DLA_CPI{-1} (1-d.a1)*d.E_DLA_CPI d.a2*d.a3*d.L_GDP_GAP d.a2*(1-d.a3)*d.L_Z_GAP d.SHK_DLA_CPI],...
  'legendEntry=',{'Persistency','Expectations','Output Gap','RER Gap','Shock'},'plotfunc',@barcon);
x.series('',d.DLA_CPI,'legendEntry=',{'Inflation'});

x.figure('Output gap','subplot',[2,1],'style',sty,'range',rng,'dateformat','YY:P');

x.graph('Output gap, percent','legend',true);
x.series('',[d.L_GDP_GAP d.L_GDP_GAP-d.SHK_L_GDP_GAP],'legendEntry=',{'Actual','Predicted'});

x.graph('Output gap decomposition, pp','legend',true);
x.series('',[d.b1*d.L_GDP_GAP{-1} -d.b2*d.b4*d.RR_GAP d.b2*(1-d.b4)*d.L_Z_GAP d.b3*d.L_GDP_RW_GAP d.SHK_L_GDP_GAP],...
    'legendEntry=',{'Lag','RIR gap','RER gap','Foreign gap','Shock'},'plotfunc',@barcon);

x.figure('Decomposition','subplot',[2,1],'style',sty,'range',rng,'dateformat','YY:P'); 

x.graph('MCI decomposition, pp','legend',true); 
x.series('',[d.b4*d.RR_GAP (1-d.b4)*(-d.L_Z_GAP)],'legendEntry=',{'RIR gap','RER gap'},'plotfunc',@barcon); 
x.series('',d.MCI,'legendEntry=','MCI'); 

x.publish('results/Filtration','display',false);
disp('Done!!!');

rmpath utils