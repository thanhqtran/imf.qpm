clearvars
close all

addpath utils

[m, p, mss] = readmodel();

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

m = assign(m, p);
m = solve(m);

load('results/kalm_his.mat');
h = g;
clear g

startfcast = get(h.mean.L_GDP_GAP, 'last') + 1;
endfcast   = qq(2016,4);
fcastrange = startfcast:endfcast;

simplan = plan(m, fcastrange); 

s = jforecast(m, h, fcastrange, 'plan', simplan, 'anticipate', true);

s.mean = dbextend(h.mean, s.mean);
s.std = dbextend(h.std, s.std);

dbsave(s.mean,'results/baseline.csv');

Tablerng = startfcast-3:startfcast+11;
Plotrng = startfcast-5:startfcast+11;
Histrng = startfcast-5:startfcast-1;

country = 'Baseline';
exchange = 'CZK/EUR';

x = Report.new('Baseline');

sty = struct();
sty.line.linewidth = 1.5;
sty.line.linestyle = {'-';'--';':'};
sty.axes.box = 'off';
sty.legend.location = 'Best';
sty.legend.Box = 'off';

band_probs = [0.9 0.6 0.3];
x.figure('Forecast - Main Indicators', 'subplot', [3,2], 'style', sty, 'range', Plotrng, 'dateformat', 'YYYY:P');
x.graph('Inflation, yoy in %');
x.fanchart('', s.mean.D4L_CPI, s.std.D4L_CPI, band_probs);

x.graph('Nominal interest rate, %');
x.fanchart('', s.mean.RS , s.std.RS, band_probs);
x.graph('Real GDP, yoy in %');
x.fanchart('', s.mean.D4L_GDP, s.std.D4L_GDP, band_probs);
x.graph('Nominal exchange rate depreciation, yoy %');
x.fanchart('', s.mean.D4L_S, s.std.D4L_S, band_probs);

x.figure('Forecast - Main Indicators', 'subplot', [3,2], 'style', sty, 'range', Plotrng, 'dateformat', 'YYYY:P');

x.graph('Inflation, %', 'legend', true);
x.series('q-o-q', s.mean.DLA_CPI);
x.series('y-o-y', s.mean.D4L_CPI);
x.series('Target', s.mean.D4L_CPI_TAR);
x.vline('', startfcast-1);

x.graph('Nominal Interest Rate, % p.a.', 'legend', false);
x.series('', s.mean.RS);
x.vline('', startfcast-1);

x.graph('Nominal Exchange Rate Deprec., %', 'legend', true);
x.series('q-o-q', s.mean.DLA_S);
x.series('y-o-y', (s.mean.L_S - s.mean.L_S{-4}));
x.vline('', startfcast-1);

x.graph('Real exchange rate gap, %', 'legend', false);
x.series('', s.mean.L_Z_GAP);
x.vline('', startfcast-1);

x.graph('Output Gap, %', 'legend', false, 'zeroline', true);
x.series('', s.mean.L_GDP_GAP);
x.vline('', startfcast-1);

x.graph('Monetary Conditions, %', 'legend', true, 'zeroline', true);
x.series('MCI', s.mean.MCI);
x.series('RIR gap', s.mean.RR_GAP );
x.series('RER gap', s.mean.L_Z_GAP);
x.vline('', startfcast-1);

x.pagebreak();

TableOptions = {'range', Tablerng, 'vline', startfcast-1, 'decimal', 1, 'dateformat', 'YYYY:P',...
    'long', true, 'longfoot', '---continued', 'longfootposition', 'right'};

x.table('Forecast - Main Indicators', TableOptions{:});

x.subheading('');
  x.series('CPI ', s.mean.D4L_CPI, 'units', '% (y-o-y)');
  x.series('', s.mean.DLA_CPI, 'units', '% (q-o-q)');
  x.series('Target', s.mean.D4L_CPI_TAR, 'units', '%');
x.subheading('');  
  x.series('Exchange Rate', exp(s.mean.L_S/100), 'units', exchange);
  x.series('', (s.mean.L_S-s.mean.L_S{-4}), 'units', '% (y-o-y)');
x.subheading('');
  x.series('GDP', s.mean.D4L_GDP, 'units', '% (y-o-y)');
x.subheading('');
  x.series('Interest Rate', s.mean.RS, 'units', '% p.a.');

x.subheading('');
x.subheading('Real Economy');
  x.series('Output Gap', s.mean.L_GDP_GAP, 'units', '%');
  x.series('GDP', s.mean.DLA_GDP, 'units', '% (q-o-q)');
  x.series('Potential GDP', s.mean.DLA_GDP_BAR, 'units', '% (q-o-q)');

x.subheading('');
x.subheading('Monetary Conditions');
  x.series('Monetary Conditions', s.mean.MCI, 'units', '%');
  x.series('Real Interest Rate Gap', s.mean.RR_GAP, 'units', 'p.p.');
  x.series('Real Exchange Rate Gap', s.mean.L_Z_GAP, 'units', '%');

x.pagebreak();
x.table('Forecast - Decompositions', TableOptions{:});

x.subheading('');
x.subheading('Headline Inflation');
  x.series('Headline Inflation', s.mean.DLA_CPI, 'units', '%');
  x.series('Lag', s.mean.a1*s.mean.DLA_CPI{-1}, 'units', 'p.p.');
  x.series('Expectations', (1-s.mean.a1)*s.mean.E_DLA_CPI, 'units', 'p.p.');
  x.series('RMC', s.mean.a2*s.mean.RMC, 'units', 'p.p.');
  x.series('RMC - Domestic', s.mean.a2*s.mean.a3*s.mean.L_GDP_GAP, 'units', 'p.p.');
  x.series('RMC - Imported', s.mean.a2*(1-s.mean.a3)*s.mean.L_Z_GAP, 'units', 'p.p.');
  x.series('Shock', s.mean.SHK_DLA_CPI, 'units', 'p.p.');

x.subheading('');
x.subheading('Ouptut Gap Decomposition');
  x.series('Output Gap', s.mean.L_GDP_GAP, 'units', '%');
  x.series('Lag', s.mean.b1*s.mean.L_GDP_GAP{-1}, 'units', 'p.p.');
  x.series('Monetary Conditions', -s.mean.b2*s.mean.MCI, 'units', 'p.p.');
  x.series('Real Interest Rate', -s.mean.b2*s.mean.b4*s.mean.RR_GAP, 'units', 'p.p.');
  x.series('Real Exchange Rate', -s.mean.b2*(1-s.mean.b4)*(-s.mean.L_Z_GAP), 'units', 'p.p.');
  x.series('Foreign Output Gap', s.mean.b3*s.mean.L_GDP_RW_GAP, 'units', 'p.p.');
  x.series('Shock', s.mean.SHK_L_GDP_GAP, 'units', 'p.p.');

x.subheading('');
x.subheading('Supply Side Assumptions');
  x.series('Potential Output', s.mean.DLA_GDP_BAR, 'units', '% (q-o-q)');
  x.series('', (s.mean.L_GDP_BAR-s.mean.L_GDP_BAR{-4}), 'units', '% (y-o-y)');
  x.subheading('');
  x.series('Eq. Real Interest Rate', s.mean.RR_BAR, 'units', '%');
  x.subheading('');
  x.series('Eq. Real Exchange Rate', s.mean.DLA_Z_BAR, 'units', '% (q-o-q)');
  x.series('', (s.mean.L_Z_BAR-s.mean.L_Z_BAR{-4}), 'units', '% (y-o-y)'); 

x.pagebreak();
x.table('Forecast - Policy Decomposition', TableOptions{:});

x.subheading('Interest Rate Decomposition');
  x.series('Interest Rate', s.mean.RS, 'units', '% p.a.');
  x.series('Lag', s.mean.g1*s.mean.RS{-1}, 'units', 'p.p.');
  x.series('Neutral Rate', (1-s.mean.g1)*s.mean.RSNEUTRAL, 'units', 'p.p.');
  x.series('Expected Inflation DEv.', (1-s.mean.g1)*s.mean.g2*(s.mean.E_D4L_CPI - s.mean.D4L_CPI_TAR{+4}), 'units', 'p.p.');
  x.series('Output Gap', (1-s.mean.g1)*s.mean.g3*s.mean.L_GDP_GAP, 'units', 'p.p.');
  x.series('Residual', s.mean.SHK_RS, 'units', 'p.p.');

x.subheading('');
x.subheading('Monetary Conditions Decomposition');
  x.series('Monetary Conditions', s.mean.MCI, 'units', '%');
  x.series('Real Interest Rate Gap', s.mean.b4*s.mean.RR_GAP, 'units', 'p.p.');
  x.series('Real Exchange Rate Gap', (1-s.mean.b4)*(-s.mean.L_Z_GAP), 'units', 'p.p');

x.table('Forecast - Foreign Variables', TableOptions{:});

x.subheading('European Monetary Union -- EA19');
  x.series('Inflation', s.mean.DLA_CPI_RW, 'units', '% (q-o-q)');
  x.series('Interest Rate', s.mean.RS_RW, 'units', '% p.a.');
  x.series('Output Gap', s.mean.L_GDP_RW_GAP, 'units', '%');

x.pagebreak();
x.table('Structural shocks', TableOptions{:});
x.series('Shock: Output gap (demand)', s.mean.SHK_L_GDP_GAP);
x.series('Shock: CPI inflation (cost-push)', s.mean.SHK_DLA_CPI);
x.series('Shock: Exchange rate (UIP)', s.mean.SHK_L_S);
x.series('Shock: Interest rate (monetary policy)', s.mean.SHK_RS);
x.series('Shock: Inflation target', s.mean.SHK_D4L_CPI_TAR);
x.series('Shock: Real interest rate', s.mean.SHK_RR_BAR);
x.series('Shock: Real exchange rate depreciation', s.mean.SHK_DLA_Z_BAR);
x.series('Shock: Potential GDP growth', s.mean.SHK_DLA_GDP_BAR);
x.series('Shock: Foreign output gap', s.mean.SHK_L_GDP_RW_GAP );
x.series('Shock: Foreign nominal interest rate', s.mean.SHK_RS_RW);
x.series('Shock: Foreign inflation', s.mean.SHK_DLA_CPI_RW);
x.series('Shock: Foreign real interest rate', s.mean.SHK_RR_RW_BAR);

x.publish('results/Forecast', 'display', false);
disp('Done!');