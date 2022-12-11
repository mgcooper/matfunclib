% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %
%   
%   Abstract class for handling plot size information.
%
% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %


classdef (Abstract) SizesClass < handle
    properties (Abstract)
        FontSizeTick;
        FontSizeLeg;
        FontSizeLab;
        LineWidth;
    end
end
