function varargout = getplotdata(varargin)
   %GETPLOTDATA Get the data plotted in the current axes
   %
   %  xdata = getplotdata()
   %  [xdata, ydata] = getplotdata(ax)
   %  [xdata, ydata, zdata] = getplotdata(ax)
   %
   %  [xdata, ydata, zdata] = getplotdata(ax) returns the XData, YData, and
   %  ZData of the children of axes ax. It returns one of these, in order,
   %  for each requested output. With no input, ax is the current axes (gca).
   %  Each output holds the data of the children that have that property;
   %  getplotdata skips a child without it, for example a Text annotation
   %  (no XData) or an image (no ZData). If more than one child has the
   %  property, the output is a cell array with one element for each child.
   %
   % See also: getlegend

   if nargin == 0
      ax = gca;
   else
      ax = varargin{1};
   end

   % Read each property only from the children that have it, so an
   % annotation or image child does not raise an error.
   children = get(ax,'Children');
   xdata = get(findobj(children, 'flat', '-property', 'XData'), 'XData');
   ydata = get(findobj(children, 'flat', '-property', 'YData'), 'YData');
   zdata = get(findobj(children, 'flat', '-property', 'ZData'), 'ZData');

   switch nargout
      case 1
         varargout{1} = xdata;
      case 2
         varargout{1} = xdata;
         varargout{2} = ydata;
      case 3
         varargout{1} = xdata;
         varargout{2} = ydata;
         varargout{3} = zdata;
   end

   % % this could be used to get specific types of plotted data
   %    hp = findobj(gca,'Type', 'bar');
   %    xd = get(hp, 'XData');
   %    yd = get(hp, 'YData');



   % % this method works with gcf
   %    if nargin == 0
   %       fig = gcf;
   %    else
   %       fig = varargin{1};
   %    end
   %    dataobjs = findobj(fig,'-property','YData');
   %    xdata = findobj(fig,'-property','XData');
   %    ydata = findobj(fig,'-property','YData');
   %
   %    % this retrieves the min/max value of all the plotted data series
   %    numdata = numel(xdata);
   %    minx = nan; maxx = nan; miny = nan; maxy = nan;
   %    count = 0;
   %    while count < numdata
   %       count = count+1;
   %       xd = dataobjs(count).XData;
   %       yd = dataobjs(count).YData;
   %       minx = min(minx,min(xd));
   %       maxx = max(maxx,max(xd));
   %       miny = min(miny,min(yd));
   %       maxy = max(maxy,max(yd));
   %    end
   %
   %    % here I was gonna loop through the xdata objects and get the actual data
   %    if numel(xdata)>1
   %
   %    end
end
