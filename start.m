%% IRIS
% This start file adds the paths needed to run IRIS
% Run this file before running any of the models

% Get the directory of this script
thisDir = fileparts(mfilename('fullpath'));

%% ===========================================
%% Change startup command depending on version
%% ===========================================

% Run startup for 2018 version
addpath(fullfile(thisDir, 'IRIS_Tbx_20181028'));
irisstartup;

% Run startup for 2021 version
addpath(fullfile(thisDir, 'IRIS-Toolbox-Legacy-20211206'));
iris.startup;

% Clean up
clear thisDir;
clear variables;
