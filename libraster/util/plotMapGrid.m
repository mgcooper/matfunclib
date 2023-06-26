function varargout = plotMapGrid(varargin)
%PLOTMAPGRID Plot a complete representation of a regular or uniform grid.
%
% H = plotMapGrid(X, Y) plots the grid centroids and grid edges for the input X and Y
% grid vectors or coordinate arrays and returns the figure handle, axes handle, and
% plot handles as an array H.
%
% H = plotMapGrid(fig, X, Y) or H = plotMapGrid(ax, X, Y) plots the grid centroids and
% grid edges into the specified figure or axis.

% TODO: simplify the input parsing with parsegraphics
% Parse possible axes input.
% [H, args, nargs, isfigure] = parsegraphics(varargin{:}); %#ok<ASGLU>

% Parse inputs
if isnumeric(varargin{1}) && isnumeric(varargin{2}) && ...
      numel(varargin{1}) > 1 && numel(varargin{2}) > 1 
    % If the first two inputs are non-scalar numeric, we assume they are X and Y
    target = gcf;
    X = varargin{1};
    Y = varargin{2};
    if nargin == 3
        opt = varargin{3};
    else
        opt = 'both';
    end
elseif (isgraphics(varargin{1}, 'figure') || isgraphics(varargin{1}, 'axes')) && ...
      numel(varargin{1}) == 1
    % If the first input is a figure or axes handle, we assume it's the target
    target = varargin{1};
    X = varargin{2};
    Y = varargin{3};
    if nargin == 4
        opt = varargin{4};
    else
        opt = 'both';
    end
else
    error('Invalid input. Please refer to the function documentation.')
end

% Obtain the grid edges
[Xedges, Yedges] = gridNodesToEdges(X, Y);

% TODO: check size of X,Y and if too big, exit. Add optional argument to force.

% Plot the grid centroids and edges
H = plotGrid(target, X, Y, Xedges, Yedges, opt);

% Prep output
if nargout == 1
   varargout{1} = H;
end

end

function H = plotGrid(target, X, Y, Xedges, Yedges, opt)
% Plot the grid centroids and edges

H = gobjects(1, 4);

% NOTE: because I did not realize that mesh was plotting white background, it is
% possible the first version would ahve worked
if isgraphics(target, 'figure')
   fig = target;
   set(fig, 'Name', 'MapGrid');

   % method 1: fails
   % ax = axes(fig);

   % method 2: 
   % ax = axes(fig,'NextPlot','add');

   % method 3: 
   % ax = ancestor(fig,'Axes');

   % method 4: 
   ax = findobj(fig, 'Type', 'axes', 'Tag', 'MapGrid');
   if isempty(ax)
      ax = axes(fig);
   end

else
   ax = target;
   fig = ancestor(ax, 'figure');
   set(fig, 'Name', 'MapGrid');
end

set(fig, 'Tag', 'MapGrid');
set(ax, 'Tag', 'MapGrid');

hold(ax, 'on');

if strcmp(opt, 'edges') || strcmp(opt, 'both')
   % Plot the grid edges
   p1 = mesh(Xedges, Yedges, zeros(size(Xedges)),'FaceAlpha',0);
   view(2);
   H(3) = p1;
end

if strcmp(opt, 'centroids') || strcmp(opt, 'both')
   % Plot the grid centroids
   [x,y] = fastgrid(X,Y);
   % p2 = scatter(ax, x(:), y(:), 'ro', 'filled');
   p2 = plot(ax, x(:), y(:), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'none');
   H(4) = p2;   

   % this produces a graphics handle with one element per column (so does
   % scatter(x,y)), so its easier to create the grid and use scatter(x(:),y(:))
   % which creates a single graphics handle
   % reason 
   %    p2 = scatter(ax, Xedges(1:end-1,1:end-1) + diff(Xedges(1,:),1,2)./2, ...
   %       Yedges(1:end-1,1:end-1) + diff(Yedges(:,1),1,1)./2, 'ro', 'filled');

end

xlabel(ax, 'X');
ylabel(ax, 'Y');
title(ax, 'Grid Centroids and Edges');
hold(ax, 'off');

grid off
axis tight

H(1) = fig;
H(2) = ax;

end

% Old parsing, very slow b/c it checks isgraphics first whcih could be on X,Y
% if any(isgraphics(varargin{1}, 'figure') | isgraphics(varargin{1}, 'axes'))
%    target = varargin{1};
%    X = varargin{2};
%    Y = varargin{3};
%    if nargin == 4
%       opt = varargin{4};
%    else
%       opt = 'both';
%    end
% else
%    target = gcf;
%    X = varargin{1};
%    Y = varargin{2};
%    if nargin == 3
%       opt = varargin{3};
%    else
%       opt = 'both';
%    end
% end
