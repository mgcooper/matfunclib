function [tf, pa] = polyorder(x,y,order)
%POLYORDER check if polygon vertex ordering is clockwise (true) or ccw (false)
%
% tf = polyorder(x,y) returns twice the area of the simple
% closed polygonal curve with vertices specified by vectors x and y.
% The result is:
%
%    Positive for clockwise vertex order
%    Negative for counter-clockwise vertex order
%    Zero if there are fewer than 3 vertices
%
% Reference:
% https://geometryalgorithms.com/Archive/algorithm_0101/algorithm_0101.html
% (with sign change in order to use clockwise-is-positive convention.)

if nargin < 3
   order = "cw";
end

if iscell(x)
   tf = false(size(x));
   pa = zeros(size(x));
   for k = 1:numel(x)
      pa(k) = signedPolyArea(x{k}, y{k});
      tf(k) = pa(k) >= 0;
   end
else
   % checkxy(lon, lat, mfilename, 'X', 'Y', 1, 2)
   [first, last] = findFirstLastNonNan(x);
   numParts = numel(first);
   if isrow(x)
      tf = zeros(1,numParts);
      pa = zeros(1,numParts);
   else
      tf = zeros(numParts,1);
      pa = zeros(numParts,1);
   end
   for k = 1:numParts
      s = first(k);
      e = last(k);
      pa(k) = signedPolyArea(x(s:e), y(s:e));
      tf(k) =  pa(k) >= 0;
   end
end

if order == "ccw"
   tf = ~tf;
   pa = -pa;
   % pa(tf == 1) = -pa(tf == 1);
   % pa(tf == 0) = -pa(tf == 0);
   
end



function A = signedPolyArea(x,y)

[x, y] = removeDuplicates(x, y);
x = x - mean(x);
n = numel(x);
if n <= 2
   A = 0;
else
   i = [2:n 1];
   j = [3:n 1 2];
   k = (1:n);
   A = sum(x(i) .* (y(k) - y(j)));
end
A = A/2;


function [x, y] = removeDuplicates(x, y)
% ... including duplicate start and end points.

is_closed = ~isempty(x) && (x(1) == x(end)) && (y(1) == y(end));
if is_closed
   x(end) = [];
   y(end) = [];
end

dups = [false; (diff(x(:)) == 0) & (diff(y(:)) == 0)];
x(dups) = [];
y(dups) = [];


function [first, last] = findFirstLastNonNan(x)
% Given a vector X containing NaN-delimited sequences of numbers, find the
% indices of the first and last element of each sequence.  X may contain
% runs of multiple NaNs, and X may start or end with one or more NaNs.
n = isnan(x(:));
first = find(~n & [true; n(1:end-1)]);
last = find(~n & [n(2:end); true]);
