function [Xq, Yq] = test_interppoints(x, y, varargin)

if nargin == 2
   option = 'default';
else
   option = varargin{1};
end

center = [mean(x), mean(y)];  % center of the center grid pixel

% center edge of the center grid pixel
center_edges = bsxfun(@plus, center, 0.5 * ...
   [0, diff(y(1:2)); diff(x(1:2)), 0; 0, -diff(y(1:2)); -diff(x(1:2)), 0]);

% corner of the center grid pixel
vec = [diff(x(1:2))/2, diff(y(1:2))/2];
corners = bsxfun(@plus, center, [vec; -vec; vec(2), -vec(1); -vec(2), vec(1)]);

% centers of pixels one row or column outside grid
if strcmp(option, 'insideedge')
   dy = abs(diff(y(1:2))/4);
   dx = abs(diff(x(1:2))/4);
else
   dy = abs(diff(y(1:2))/2);
   dx = abs(diff(x(1:2))/2);
end

outside_centers = [mean(x), min(y) - dy;
                   mean(x), max(y) + dy;
                   min(x) - dx, mean(y); 
                   max(x) + dx, mean(y)];

outside_corners = [min(x) - dx, min(y) - dy;  
                   min(x) - dx, max(y) + dy;  
                   max(x) + dx, max(y) + dy;
                   max(x) + dx, min(y) - dy];

interp_pts = unique( ...
   [center; center_edges; corners; outside_centers; outside_corners], ...
   'rows', 'stable');

Xq = interp_pts(:, 1);
Yq = interp_pts(:, 2);