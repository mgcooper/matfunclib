function poly = simplifyPolyshape(poly, kwargs)
   %SIMPLIFYPOLYSHAPE Reduce polyshape vertex count and remove holes.
   %
   %  poly = simplifyPolyshape(poly)
   %  poly = simplifyPolyshape(_, rmholes=false)
   %  poly = simplifyPolyshape(_, maxverts=maxverts)
   %
   % Description
   %
   %  poly = simplifyPolyshape(poly) Removes holes, reduces the vertex count to
   %  10000 or fewer, and recreates poly by calling polyshape to access built-in
   %  simplification/repair steps.
   %
   % See also: polyshape, polyreduce, simplifyPolyline, reducepoly

   arguments
      poly
      kwargs.rmholes (1, 1) logical = true
      kwargs.maxverts (1, 1) = 10000
   end

   withwarnoff('MATLAB:polyshape:repairedBySimplify');

   % Simplify the polyshapes
   for n = 1:numel(poly)
      poly(n) = processOnePoly(poly(n), kwargs);
   end
end

function poly = processOnePoly(poly, kwargs)

   % Remove holes
   if kwargs.rmholes
      poly = rmholes(poly);
   end

   % Reduce the number of vertices to <10000 or user-specified
   factor = max(1, fix(size(poly.Vertices, 1) / kwargs.maxverts));
   poly = polyshape(poly.Vertices(1:factor:end, 1), ...
      poly.Vertices(1:factor:end, 2));
end
