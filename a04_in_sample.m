close all;

clearvars;

addpath utils

stime = qq(2006,1); 

etime = qq(2013,4); 

list_xnames = {'DLA_CPI','D4L_CPI','L_GDP_GAP','D4L_GDP','L_S'}; 

in_sample_report(stime,etime,list_xnames)

rmpath utils