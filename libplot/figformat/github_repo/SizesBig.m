% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
%   
%   Data class
%
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %



classdef SizesBig < SizesClass
    properties (Constant)
        defs = SizesBig;
    end

    properties
        FontSizeTick;
        FontSizeLeg;
        FontSizeLab;
        LineWidth;
    end

    methods (Access = private)
        function obj = SizesBig
            obj.FontSizeTick    = 20;
            obj.FontSizeLeg     = 20;
            obj.FontSizeLab     = 30;
            obj.LineWidth       = 1.8;    
        end
    end
end