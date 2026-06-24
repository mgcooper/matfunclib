function [tf, pa] = polyorder(x,y,order)
   %POLYORDER Return polygon vertex ordering 'cw' or 'ccw'
   %
   % vorder = polyorder(x,y) returns 'cw' if the x,y polygon vertex ordering is
   % clockwise and 'ccw' if the ordering is counterclockwise.
   %
   % [vorder, parea] = polyorder(x,y) also returns the polygon area, twice the
   % area of the simple closed polygonal curve with vertices specified by
   % vectors x and y. The result is:
   %
   %    Positive for clockwise vertex order
   %    Negative for counter-clockwise vertex order
   %    Zero if there are fewer than 3 vertices
   %
   % Reference:
   % https://geometryalgorithms.com/Archive/algorithm_0101/algorithm_0101.html
   % (with sign change in order to use clockwise-is-positive convention.)

   % TODO: change to:
   % [vorder, parea] = polyorder(x,y) to return the order and area of each polygon
   % [vorder, parea] = polyorder(x,y,'all') to return the order and area of all
   % polygons (i.e., scalar output)
   %
   % I updated the documentation but

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
      [first, last] = nonnansegments(x(:));
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
         tf(k) = pa(k) >= 0;
      end
   end

   if order == "ccw"
      tf = ~tf;
      pa = -pa;
      % pa(tf == 1) = -pa(tf == 1);
      % pa(tf == 0) = -pa(tf == 0);
   end
end

function A = signedPolyArea(x,y)

   [x, y] = removeDuplicateVertices(x, y);
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
end

