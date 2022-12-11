% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
%   
%   Data class
%
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %


classdef SizesMed < SizesClass
    properties (Constant)
        defs = SizesMed;
    end

    properties
        FontSizeTick;
        FontSizeLeg;
        FontSizeLab;
        LineWidth;
    end

    methods (Access = private)
        function obj = SizesMed
            obj.FontSizeTick    = 17;
            obj.FontSizeLeg     = 17;
            obj.FontSizeLab     = 22;
            obj.LineWidth       = 1.65;    
        end
    end
end