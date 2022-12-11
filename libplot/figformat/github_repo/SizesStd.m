% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
%   
%   Data class
%
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %


classdef SizesStd < SizesClass
    properties (Constant)
        defs = SizesStd;
    end

    properties
        FontSizeTick;
        FontSizeLeg;
        FontSizeLab;
        LineWidth;
    end

    methods (Access = private)
        function obj = SizesStd
            obj.FontSizeTick    = 13;
            obj.FontSizeLeg     = 15;
            obj.FontSizeLab     = 16;
            obj.LineWidth       = 1.5;    
        end
    end
end