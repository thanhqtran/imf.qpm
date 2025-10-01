function [hAx, hPlotTrue, hPlotFalse] = spy(varargin)
% spy  Visualise tseries observations that pass a test.
%
% __Syntax__
%
%     [hAx, hTrue, hFalse] = spy(x, ...)
%     [hAx, hTrue, hFalse] = spy(range, x, ...)
%
%
% __Input Arguments__
%
% * `x` [ Series ] - Input time series whose observations that pass or fail
% a test will be plotted as markers.
%
% * `range` [ Series ] - Date range on which the tseries observations will
% be visualised; if not specified the entire available range will be used.
%
%
% __Output Arguments__
%
% * `hAx` [ Axes ] - Handle to the axes created.
%
% * `hTrue` [ Line ] - Handle to the marks plotted for the observations
% that pass the test.
%
% * `hFalse` [ Line ] - Handle to the marks plotted for the observations
% that fail the test.
%
%
% __Options__
%
% * `'Names='` [ cellstr ] - Names that will be used to annotate individual
% columns of the input tseries object.
%
% * `'ShowTrue='` [ *`true`* | `false` ] - Display marks for the
% observations that pass the test.
%
% * `'ShowFalse='` [ `true` | *`false`* ] - Display marks for the
% observations that fail the test.
%
% * `'Squeeze='` [ `true` | *`false`*] - Adjust the PlotBoxAspecgtRatio
% property to squeeze the graph.
%
% * `'Test='` [ function_handle | *@(x)~isnan(x)* ] - Test applied to each
% observations; only the values returning a true will be displayed.
%
% See help on [`tseries/plot`](tseries/plot) and the built-in function
% `spy` for all options available.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

if all(ishghandle(varargin{1})) ...
        && strcmpi(get(varargin{1}(1), 'type'), 'axes')
    hAx = varargin{1}(1);
    varargin(1) = [ ];
else
    hAx = gca( );
end

if isnumeric(varargin{1})
    range = varargin{1};
    varargin(1) = [ ];
else
    range = Inf;
end

this = varargin{1};
varargin(1) = [ ];

persistent parser
if isempty(parser)
    parser = extend.InputParser('tseries.spy');
    parser.KeepUnmatched = true;
    parser.addRequired('Axes', @(x) all(ishandle(x)));
    parser.addRequired('Range', @DateWrapper.validateDateInput);
    parser.addRequired('TimeSeries', @(x) isa(x, 'tseries'));
    parser.addParameter('ShowTrue', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('ShowFalse', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Squeeze', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter({'Names', 'Name'}, { }, @iscellstr);
    parser.addParameter('Test', @isfinite, @(x) isa(x, 'function_handle'));
    parser.addPlotOptions( );
    parser.addDateOptions( );
end
parser.parse(hAx, range, this, varargin{:});
opt = parser.Options;
freq = get(this, 'freq');
unmatched = parser.UnmatchedInCell;

%--------------------------------------------------------------------------

[x, range] = rangedata(this, range);
x = x(:, :, 1);
x = opt.Test(x.');
if ~islogical(x)
    x = logical(x);
end
time = dat2dec(range, 'centre');
xCoor = repmat(1 : size(x, 2), size(x, 1), 1);
xCoor = time(xCoor);
yCoor = repmat(1 : size(x, 1), 1, size(x, 2));

if opt.ShowTrue
    markerTrue = '.';
else
    markerTrue = 'none';
end
if opt.ShowFalse
    markerFalse = '.';
else
    markerFalse = 'none';
end
markerSize = get(gcf( ), 'DefaultLineMarkerSize')*1.5;

holdStatus = ishold(hAx);
hPlotTrue = plot(hAx, xCoor(x), yCoor(x), ...
    'LineStyle', 'None', 'Marker', markerTrue, 'MarkerSize', markerSize);
hold on
hPlotFalse = plot(hAx, xCoor(~x), yCoor(~x), ...
    'LineStyle', 'None', 'Marker', markerFalse, 'MarkerSize', markerSize);
if ~holdStatus
    hold off
end
set( gca( ), 'YDir', 'Reverse', 'YLim', [0, size(x, 1)+1], ...
    'XLim', round([xCoor(1)-0.5, xCoor(end)+0.5]) );

if ~opt.ShowTrue
    grfun.excludefromlegend(hPlotTrue);
end
if ~opt.ShowFalse
    grfun.excludefromlegend(hPlotFalse);
end

setappdata(hAx, 'IRIS_SERIES', true);
setappdata(hAx, 'IRIS_FREQ', freq);
setappdata(hAx, 'IRIS_XLIM_ADJUST', true);
mydatxtick(hAx, range, time, freq, range, opt);

set(hAx, 'GridLineStyle', ':');
yLim = [1, size(x, 1)];
if ~isempty(opt.Names)
    set( hAx, 'YTick', yLim(1):yLim(end), 'YTickMode', 'Manual', ...
        'YTickLabel', opt.Names, 'yTickLabelMode', 'Manual', ...
        'YLim', [0.5, yLim(end)+0.5], 'YLimMode', 'Manual', ...
        'PlotBoxAspectRatio', [size(x,2)+1, size(x,1)+1, 1] );
else
    yTick = get(hAx, 'YTick');
    yTick(yTick<1) = [ ];
    yTick(yTick>size(x, 1)) = [ ];
    yTick(yTick~=round(yTick)) = [ ];
    set(hAx, 'YTick', yTick, 'YTickMode', 'Manual');
end

if opt.Squeeze
    set(hAx, 'PlotBoxAspectRatio', [size(x, 2)+5, size(x, 1)+2, 1]);
end

xlabel('');
if ~isempty(unmatched)
    set(hPlotTrue, unmatched{:});
end

end%
