function h = vertline(x,varargin)
   %VERTLINE Draw a vertical line on a plot at a specified x-coordinate.
   %
   % This function creates a vertical line on a plot at a given x-coordinate.
   % The line adjusts its position when the axes limits change, ensuring
   % that it spans the entire height of the plot.
   %
   % Syntax:
   %    h = vertline(x)
   %    h = vertline(x, Name, Value)
   %
   % Inputs:
   %    x - x-coordinate of the vertical line
   %
   % Name-Value pairs:
   %    Line properties can be passed as name-value pairs.
   %
   % Outputs:
   %    h - handle to the line object
   %
   % Example:
   %    vertline(5, 'Color', 'r', 'LineStyle', '--');
   %
   % See also: HORZLINE, LINE, PLOT

   washeld = ishold();
   hold on;

   ax = gca;
   ylims = get(ax, 'YLim');

   h = plot(ax, [x x], ylims, varargin{:});

   if ~isoctave()
      addlistener(ax, 'MarkedClean', @(src, event) redrawLine(src, event, h));
   end

   if washeld
      hold on;
   else
      hold off;
   end
end

function redrawLine(ax, ~, lineHandle)
   newYLim = get(ax, 'YLim');
   set(lineHandle, 'YData', newYLim);
end
