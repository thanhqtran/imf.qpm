classdef commentOptional < irisinp.comment
    methods
        function this = commentOptional(varargin)
            this = this@irisinp.comment(varargin{:});
            this.Omitted = '';
            validFn = this.ValidFn;
            this.ValidFn = @(x, state) validFn(x) && ~iseven(state.NUserLeft);
        end
    end
end
