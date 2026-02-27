%% IRIS
% This start file adds the paths needed to run IRIS
% Run this file before running any of the models

% Get the directory of this script
thisDir = fileparts(mfilename('fullpath'));

% Add relative paths
% addpath(fullfile(thisDir, 'IRIS_Tbx_20181028'));
% Start IRIS
% irisstartup;

% Add relative paths
addpath(fullfile(thisDir, 'IRIS-Toolbox-Legacy-20211206'));
% Start IRIS
iris.startup;

% Clean up
clear thisDir;
clear variables;