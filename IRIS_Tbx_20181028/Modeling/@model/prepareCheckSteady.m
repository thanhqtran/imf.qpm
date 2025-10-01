function opt = prepareCheckSteady(this, mode, varargin) %#ok<INUSL>
% prepareCheckSteady  Prepare steady-state check
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

if numel(varargin)==1 && isequal(varargin{1}, false)
    opt = false;
    return
end

if numel(varargin)==1 && isequal(varargin{1}, true)
    varargin(1) = [ ];
end

persistent parser
if isempty(parser)
    parser = extend.InputParser('model.prepareCheckSteady');
    parser.addRequired('Model', @(x) isa(x, 'model'));
    parser.addRequired('Mode', @validateMode);
    parser.addParameter({'Kind', 'Type', 'Eqtn', 'Equation', 'Equations'}, 'Dynamic', @validateKind);
end
parser.parse(this, mode, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

end%

%
% Validators
%

function flag = validateMode(value)
    if ~ischar(value) && ~(isa(value, 'string') && isscalar(value))
        flag = false;
        return
    end
    flag = any(strcmpi(value, {'Verbose', 'Silent'}));
end%


function flag = validateKind(value)
    if ~ischar(value) && ~(isa(value, 'string') && isscalar(value))
        flag = false;
        return
    end
    flag = any(strcmpi(value, {'Dynamic', 'Full', 'Steady', 'SState'}));
end%

