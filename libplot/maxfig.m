function varargout = maxfig(varargin)

if nargin == 0
   fig = figure;
else
   fig = varargin{1};
end

units=get(fig,'units');
set(fig,'units','normalized','outerposition',[0 0 1 1]);
set(fig,'units',units);

if nargout == 1
   varargout{1}=fig;
end