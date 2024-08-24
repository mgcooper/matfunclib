function [B, poly] = polyshape2geostruct(poly, projname)

   % this is somewhat specific to the interface basin boundaries, its designed
   % to convert polyshapes used in more recent code like exactremap into
   % geo/mapstruct used in older code, some of which was folded into the
   % +activelayer namespace.

   if nargin > 1
      proj = loadprojcrs(projname);
   else
      proj = [];
   end

   for n = numel(poly):-1:1

      [x, y] = deal(poly(n).Vertices(:, 1), poly(n).Vertices(:, 2));

      if ~isempty(proj) && islatlon(y, x)
         [x, y] = projfwd(proj, y, x);

         silent = withwarnoff('MATLAB:polyshape:repairedBySimplify');
         poly(n) = polyshape(x, y);
      end

      B(n).X = x;
      B(n).Y = y;
   end
end
