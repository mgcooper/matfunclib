function myaxistight( ax , varargin)
%MYAXISTIGHT sets the axis of your choice to be tight
children        =   ax.Children;
xmin            =   min(children.XData);
xmax            =   max(children.XData);
ymin            =   min(children.YData);
ymax            =   max(children.YData);

for n = 1:length(ax)
if varargin{1} == 'x' || varargin{2} == 'x'
    ax(n).XLim  =   [xmin xmax];
elseif varargin{1} == 'y' || varargin{2} == 'y'
    ax(n).YLim  =   [ymin ymax];
end

end

