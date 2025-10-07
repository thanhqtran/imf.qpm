clearvars
close all

[~,~,~] = mkdir('results');

[m,p,mss] = readmodel();

listshocks = {'SHK_DLA_CPI','SHK_L_GDP_GAP','SHK_L_S','SHK_RS'}; 
listtitles = {'Inflationary (cost-push) Shock','Aggregate Demand Shock', 'Exchange Rate Shock', 'Interest Rate (monetary policy) Shock'}; 

startsim = qq(0,1);
endsim = qq(3,4); 

for i = 1:length(listshocks)
    d.(listshocks{i}) = zerodb(m,startsim:endsim);
end

d.SHK_DLA_CPI.SHK_DLA_CPI(startsim) = 1;
d.SHK_L_GDP_GAP.SHK_L_GDP_GAP(startsim) = 1;
d.SHK_L_S.SHK_L_S(startsim) = 1;
d.SHK_RS.SHK_RS(startsim) = 1; 

for i=1:length(listshocks)    
    s.(listshocks{i}) = simulate(m,d.(listshocks{i}),startsim:endsim,'deviation',true);
end

x = Report.new('Shocks');

sty = struct();
sty.line.linewidth = 1;
sty.line.linestyle = {'-';'--'};
sty.line.color = {'k';'r'};
sty.legend.location = 'Best';

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

x.graph('Real Monetary Condition Index (%)');
x.series('', s.(listshocks{i}).MCI);

end

x.publish('results/Shocks.pdf','display',false);
disp('Done!!!');