function [d, isDev] = zerodb(this, range, varargin)
% zerodb  Create model-specific zero-deviation database
%
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [D, IsDev] = zerodb(Model, SimulationRange, ~NumOfColumns, ...)
%
%
% __Input Arguments__
%
% * `Model` [ model ] - Model object for which the zero database will be
% created.
%
% * `SimulationRange` [ numeric ] - Intended simulation range; the zero
% database will be created on a range that also automatically includes all
% the necessary lags.
%
% * `~NumOfColumns` [ numeric | *`1`* ] - Number of columns created in the
% time series object for each variable; the input argument `NumOfColumns`
% can be only used on models with one parameterisation; may be omitted.
%
%
% __Options__
%
% * `ShockFunc=@zeros` [ `@lhsnorm` | `@randn` | `@zeros` ] - Function used
% to generate data for shocks. If `@zeros`, the shocks will simply be
% filled with zeros. Otherwise, the random numbers will be drawn using the
% specified function and adjusted by the respective covariance matrix
% implied by the current model parameterization.
%
%
% __Output Arguments__
%
% * `D` [ struct ] - Database with a tseries object filled with zeros for
% each linearised variable, a tseries object filled with ones for each
% log-linearised variables, and a scalar or vector of the currently
% assigned values for each model parameter.
%
% * `IsDev` [ `true` ] - The second output argument is always `true`, and
% can be used to set the option `Deviation=` in
% [`model/simulate`](model/simulate).
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

% zerodb, sstatedb

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('model.zerodb');
    inputParser.addRequired('Model', @(x) isa(x, 'model'));
    inputParser.addRequired('SimulationRange', @DateWrapper.validateProperRangeInput);
end
inputParser.parse(this, range);

%--------------------------------------------------------------------------

d = createSourceDbase(this, range, varargin{:}, 'Deviation=', true);

end
