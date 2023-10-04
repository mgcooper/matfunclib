function varargout = getplotdata(varargin)
   %GETPLOTDATA Get the data plotted in the current axes
   %
   %  xdata = getplotdata()
   %  [xdata, ydata] = getplotdata(ax)
   %  [xdata, ydata, zdata] = getplotdata(ax)
   %
   % See also: getlegend

   if nargin == 0
      ax = gca;
   else
      ax = varargin{1};
   end

   children = get(ax,'Children');
   xdata = get(children, 'XData');
   ydata = get(children, 'YData');
   zdata = get(children, 'ZData');

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
