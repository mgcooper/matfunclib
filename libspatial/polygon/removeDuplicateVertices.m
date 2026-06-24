function [x, y] = removeDuplicateVertices(x, y)
   %REMOVEDUPLICATEVERTICES Drop a closing vertex and consecutive duplicate vertices.
   %
   %  [x, y] = removeDuplicateVertices(x, y) returns x, y as column vectors with
   %  (1) the closing vertex removed if the ring is explicitly closed
   %  (x(1)==x(end) && y(1)==y(end)), and (2) consecutive duplicate vertices
   %  removed. Used by polygon routines (polyorder, sphericalpolyarea) so the
   %  vertex list is clean before an area/orientation computation.
   %
   % See also: polyorder, sphericalpolyarea, closepolygon

   x = x(:);
   y = y(:);

   % Drop an explicit closing vertex (first == last).
   if ~isempty(x) && x(1) == x(end) && y(1) == y(end)
      x(end) = [];
      y(end) = [];
   end

   % Drop consecutive duplicate vertices.
   dups = [false; (diff(x) == 0) & (diff(y) == 0)];
   x(dups) = [];
   y(dups) = [];
end
