function varargout = mapbox(xspan,yspan,varargin)
%MAPBOX draw a box of size xspan/yspan on the current plot 
% 
%  h = mapbox(xspan,yspan) plots a box and returns the handle h
% 
%  [xrect,yrect] = mapbox(xspan,yspan) returns the box coordinates
% 
%  [h,xrect,yrect] = mapbox(xspan,yspan) plots a box and returns the handle h
%  and the box coordinates 
% 
%  Note: Assumes min(xspan) == xspan(1), max(xspan) == xspan(2), etc.
% 
% See also: geobox

hold on;
xrect = [xspan(1) xspan(2) xspan(2) xspan(1) xspan(1)];
yrect = [yspan(1) yspan(1) yspan(2) yspan(2) yspan(1)];

% this could be used to allow arbitrary ordering, whereas above assumes
% min(xspan) == xspan(1), max(xspan) == xspan(2), etc.

% ymin = min(yspan);
% ymax = max(yspan);
% xmin = min(xspan);
% ymax = max(xspan);

switch nargout
   case 1
      h = plot(xrect,yrect,varargin{:});
      varargout{1} = h;
   case 2
      varargout{1} = xrect;
      varargout{2} = yrect;
end
   
