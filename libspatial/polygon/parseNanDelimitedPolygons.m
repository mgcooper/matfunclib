function P = parseNanDelimitedPolygons(P)

   % Turns out this is not necessary - use P.regions instead. But see the note
   % below about ambiguity. It might be necessary to split the polygons first
   % and/or the methods here might be useful until the "regions" method is more
   % fully tested.

   return

   % Check for nan-delimited polygons
   if sum(isnan(P(:,1))) > 1

      % Note - there is some ambiguity here. In general the assumption
      % is that nan-delimited polygons represent distinct polygons but
      % in at least one test case a "single" polygon was passed in but
      % it had two regions, one tiny region which I wrote reparePolygon
      % to get rid of, and the actual watershed boundary polygon.

      % ---------------------------------------------------------------
      % This section is leftover from a prior effort to handle
      % nan-delimited polygons, where I thought it was necessary to
      % extract them first to then make polyshapes from each region.
      % But instead, make one polyshape and use "regions" to extract them.

      % First try repairing any issues
      % P = polyshape(P(:, 1), P(:, 2));
      % P = repairPolyshape(P);

      % P is multi-polygon, split into individual polygons.
      % Note, it should also work to use P.regions
      % [PY, PX] = coordsToCells(P(:,2), P(:,1));
      % ---------------------------------------------------------------

      % Convert the X,Y vertices in each cell to a polyshape
      P = polyshape(P(:,1), P(:,2), 'Simplify', true, ...
         'KeepCollinearPoints', false);

      % Extract each polygon using the "regions" member function
      P = arrayfun(@(p) p, P.regions, 'Uniform', false);

   else % P is one polygon
      P = {polyshape(P(:,1), P(:,2), 'Simplify', true, ...
         'KeepCollinearPoints', false)};
   end
end
