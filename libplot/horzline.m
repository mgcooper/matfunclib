function varargout = horzline(y,varargin)
   %HORZLINE Draw a horizontal line on a plot at a specified y-coordinate.
   %
   % This function creates a horizontal line on a plot at a given y-coordinate.
   % The line adjusts its position when the axes limits change, ensuring
   % that it spans the entire width of the plot.
   %
   % Syntax:
   %    h = horzline(y)
   %    h = horzline(y, Name, Value)
   %
   % Inputs:
   %    y - y-coordinate of the horizontal line
   %
   % Name-Value pairs:
   %    Line properties can be passed as name-value pairs.
   %
   % Outputs:
   %    h - handle to the line object
   %
   % Example:
   %    horzline(5, 'Color', 'r', 'LineStyle', '--');
   %
   % See also: VERTLINE, LINE, PLOT

   washeld = ishold();
   hold on

   ax = gca;
   xlims = get(ax, 'XLim');

   h = plot(ax, xlims, [y y], varargin{:});

   if ~isoctave()
      addlistener(ax, 'MarkedClean', @(src, event) redrawLine(src, event, h));
   end

   if ~washeld
      hold off
   end

   if nargout == 1
      varargout{1} = h;
   end
end

function redrawLine(ax, ~, lineHandle)
   newXLim = get(ax, 'XLim');
   set(lineHandle, 'XData', newXLim);
end
