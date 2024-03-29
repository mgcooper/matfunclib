function varargout = fillplot(x, y, err, c, varargin)
   %FILLPLOT Create a filled (patch) plot.
   %
   %  Syntax:
   %     H = fillplot(X, Y, E, C)
   %     H = fillplot(X, Y, E, C, dim)
   %     H = fillplot(X, Y, E, C, Name, Value)
   %
   %  Input:
   %     X - X-axis data points
   %     Y - Y-axis data points
   %     E - Error margin(s), can be Nx2 or Nx1 array
   %     C - Color to use for the fill, can be 1x3 rgb array or char color name
   %     dim - (Optional) dimension to apply error, 'x' or 'y'
   %     Name, Value - additional Patch properties
   %
   %  Output:
   %     H - Handle to patch object
   %
   %  Example:
   %    x = sort(randi(100, 100, 1));
   %    y = 2*x;
   %    e = 10.*ones(size(x));
   %    c = rgb('bright blue');
   %
   %    % Basic fill plot
   %    fillplot(x, y, e, c)
   %
   %    % Apply error to x instead of default y
   %    fillplot(x, y, e, c, 'x')
   %
   %    % Apply patch properties, and a char specifier for the patch color:
   %    fillplot(x, y, e, 'r', "FaceAlpha", 0.35, "LineStyle", ':')
   %
   %    % Plot data with nan's, including leading and trailing nan's
   %    y(randi(100, 10, 1)) = nan;
   %    y(1) = nan;
   %    y(end) = nan;
   %    fillplot(x, y, e, c, "FaceAlpha", 0.35)
   %
   %    % Plot into the current axes
   %    figure
   %    plot(x, y, 'k')
   %    fillplot(x, y, e, c, "FaceAlpha", 0.35)
   %
   %    % Specify an axes or figure to plot into
   %    f = figure;
   %    s(1) = subplot(1, 2, 1);
   %    plot(x, y, 'k'); hold on % without hold on, fillplot resets the axes
   %    s(2) = subplot(1, 2, 2);
   %    plot(x, y, 'k'); hold on
   %    % plot into s(1)
   %    fillplot(x, y, e, c, s(1), "FaceAlpha", 0.35) % fillplot respects the hold state
   %    % plot into s(2), using a different patch color
   %    fillplot(x, y, e, 'orange', s(2), "FaceAlpha", 0.35)
   %    % plot into s(1) using built-in 'plot'
   %    plot(s(1), x, y, 'm') % plot respects the hold state
   %
   % See also: fill, patch

   % Parse possible axes input.
   [ax, varargin, ~, isfigure] = parsegraphics(varargin{:});

   % Get handle to either the requested or a new axis.
   if isempty(ax)
      ax = gca;
   elseif isfigure
      ax = gca(ax);
   end
   washeld = get(ax, 'NextPlot');
   % hold(ax, 'on')

   % Parse optional dim argument
   [dim, varargin] = parseoptarg(varargin, {'x', 'y'}, 'y');

   % Ensure rows and equal length
   x = x(:)';
   y = y(:)';
   assert(length(x) == length(y), 'Expected X and Y to be the same size')

   % Ensure E is oriented row-wise
   err = reorientError(err, length(y));

   % Ensure C is a nx3 rgb color matrix. Undocumented: allow char
   if ischar(c)
      if isscalar(c)
         try
            c = matlabcolor2rgb(c);
         catch ME
            rethrow(ME)
         end
      else
         try
            c = rgb(c);
         catch ME
            rethrow(ME);
         end
      end
   end

   % Sort the data
   [x, order] = sort(x);
   y = y(order);
   err = err(:, order);

   % Identify contiguous segments of non-NaN data
   [s, e] = nonnansegments(x, y, err);

   % Initialize plot handle
   H = gobjects(0);

   % Loop over each segment, construct patch vertices, and plot
   for n = 1:length(s)

      X = x(s(n):e(n));
      Y = y(s(n):e(n));
      E = err(:, s(n):e(n));

      [X, Y] = constructVertices(X, Y, E, dim);

      H(n) = fill(ax, X, Y, c, 'LineStyle', 'none', varargin{:});
      hold(ax, 'on')
   end

   % Restore hold state
   set(ax, 'NextPlot', washeld);

   if nargout == 1
      varargout{1} = H;
   end
end

%% Local functions
function e = reorientError(e, n)
   if isvector(e)
      e = e(:)';
      e = [e; e];
   else
      [~, m] = size(e);
      if m == 2
         e = e.';
      end
   end
   assert(numel(e) == 2 * n, ...
      'Expected error margin, E, to be an Nx2 or Nx1 array with N=numel(X)')
end

function [x, y] = constructVertices(x, y, e, dim)
   if strcmp(dim, 'y')
      x = [x, fliplr(x)];
      y = [y - e(2, :), fliplr(y + e(1, :))];
   else
      x = [x - e(2, :), fliplr(x + e(1, :))];
      y = [y, fliplr(y)];
   end
end

function [s, e] = nonnansegments(x, y, err)
   ok = ~isnan(x) & ~isnan(y) & ~any(isnan(err), 1);
   s = find(ok & [true ~ok(1:end-1)]);
   e = find(ok & [~ok(2:end) true]);
end
