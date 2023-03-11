function varargout = mapbox(xlimits,ylimits,varargin)
%MAPBOX draw a box of size xlimits/ylimits on the current plot 
% 
%  h = mapbox(xlimits,ylimits) plots a box and returns the handle h
% 
%  [xrect,yrect] = mapbox(xlimits,ylimits) returns the box coordinates
% 
%  [h,xrect,yrect] = mapbox(xlimits,ylimits) plots a box and returns the handle h
%  and the box coordinates 
% 
%  Note: Assumes min(xlimits) == xlimits(1), max(xlimits) == xlimits(2), etc.
% 
% See also: geobox

hold on;
xrect = [xlimits(1) xlimits(2) xlimits(2) xlimits(1) xlimits(1)];
yrect = [ylimits(1) ylimits(1) ylimits(2) ylimits(2) ylimits(1)];

% this could be used to allow arbitrary ordering, whereas above assumes
% min(xlimits) == xlimits(1), max(xlimits) == xlimits(2), etc.

% ymin = min(ylimits);
% ymax = max(ylimits);
% xmin = min(xlimits);
% ymax = max(xlimits);

switch nargout
   case 1
      h = plot(xrect,yrect,varargin{:});
      varargout{1} = h;
   case 2
      varargout{1} = xrect;
      varargout{2} = yrect;
end
   
