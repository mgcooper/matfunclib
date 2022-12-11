function h = xybox(xspan,yspan,varargin)
%XYBOX h = xybox(xspan,yspan) draws a box of size xspan / yspan on the current plot
%   Assumes min(xspan) == xspan(1), max(xspan) == xspan(2), etc.

hold on;

xrect = [xspan(1) xspan(2) xspan(2) xspan(1) xspan(1)];
yrect = [yspan(1) yspan(1) yspan(2) yspan(2) yspan(1)];

% this could be used to allow arbitrary ordering, whereas above assumes
% min(xspan) == xspan(1), max(xspan) == xspan(2), etc.

% ymin = min(yspan);
% ymax = max(yspan);
% xmin = min(xspan);
% ymax = max(xspan);

h = plot(xrect,yrect,varargin{:});

end

