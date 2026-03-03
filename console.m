%%% ==========================
%%% Hardtuning forecast ------
%%% ==========================

% Clear all
clear all; clc;

%% Initiate IRIS Toolbox
% Make sure 2021 version is selected
start;

%% Make data
% this includes importing dataframes, applying seasonal adjustments and apply band-pass or HP filter
a02_makedata;

%% Perform Bayesian estimation
a07_estimate_bayesian;
% if you prefer another estimation, choose
% a07_estimate_mle;
% a07_estimate_system;

%% Apply the Kalman filter and decompositional analysis
a03_kalmanfilter_est;

%% Forecast with hard tuning based on foreign exogenous variables
a05_video_forecast_est;
