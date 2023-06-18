function maxfig(varargin)
if nargin==0; fig = gcf; else; fig = varargin{1}; end
units=get(fig,'units');
set(fig,'units','normalized','outerposition',[0 0 1 1]);
set(fig,'units',units);