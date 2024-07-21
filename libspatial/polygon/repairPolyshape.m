function poly = repairPolyshape(poly, kwargs)
   %repairPolyshape Repair polyshape geometry.
   %
   %  P = repairPolyshape(P)
   %  P = repairPolyshape(_, 'simplify', false)
   %  P = repairPolyshape(_, 'rmslivers', false)
   %  P = repairPolyshape(_, 'rmholes', true)
   %  P = repairPolyshape(_, 'mergeregions', true)
   %  P = repairPolyshape(_, 'maxverts', maxverts)
   %  P = repairPolyshape(_, 'bufferDist', bufferDist)
   %  P = repairPolyshape(_, 'areaThreshold', areaThreshold)
   %  P = repairPolyshape(_, 'sliverTolerance', sliverTolerance)
   %  P = repairPolyshape(_, 'KeepCollinearPoints', true)
   %  P = repairPolyshape(_, 'SolidBoundaryOrientation', SolidBoundaryOrientation)
   %
   % Inputs:
   %   poly - Input polyshape object
   %   bufferDist - Distance to expand and then contract the polyshape
   %   areaThreshold - Minimum area to retain a polygon region
   %
   % Name-Value pairs:
   %  'bufferDist' - default = 0.001
   %  'areaThreshold'- default = 0.01%
   %  'sliverTolerance' - default = 0.0
   %  'KeepCollinearPoints' - default = false
   %  'SolidBoundaryOrientation'- default = "auto"
   %
   % Output:
   %   poly - Repaired polyshape object
   %
   % Description:
   %  Removes small artifacts from
   %
   % See also:

   arguments
      poly {mustBePolygon}

      % Built in polyshape creation methods
      kwargs.Simplify (1, 1) logical = true
      kwargs.KeepCollinearPoints (1, 1) logical = false
      kwargs.SolidBoundaryOrientation (1, 1) string = "auto"

      % Built in polyshape member methods
      kwargs.rmslivers (1, 1) logical = true
      kwargs.rmholes (1, 1) logical = false

      % Custom methods
      kwargs.mergeregions (1, 1) logical = false
      % Note - the only way I could find to selectively remove a region (here,
      % based on areaThreshold) was to convert the polyshape (which has regions)
      % into a "polyvec" using poly.regions, and then use union to merge them
      % back into a single polyshape, after which thre are no longer regions. I
      % am not sure how to disaggregate, filter, then reaggregate w/regions, but
      % it would likely work with nan-separarted lists. Thus for now,
      % mergeregions is true by default if any regions are remvoed due to the
      % areaThreshold (and likely due to rmslivers), and if it is set true, then
      % a call to union can be used to remove regions, but if its false, I don't
      % currently honor that for the case where regions are removed.

      % Parameters
      kwargs.maxverts {mustBeScalarOrEmpty} = 10000
      kwargs.bufferDist {mustBeScalarOrEmpty} = 0.001
      kwargs.areaThreshold {mustBeScalarOrEmpty} = 0.01
      kwargs.sliverTolerance {mustBeScalarOrEmpty} = []
      kwargs.KeepEmptyPolygons (1, 1) logical = false
   end

   withwarnoff('MATLAB:polyshape:repairedBySimplify');

   % Simplify the polyshapes
   for n = numel(poly):-1:1
      poly(n) = processOnePoly(poly(n), kwargs);
   end

   % Remove any empty polyshapes
   if ~kwargs.KeepEmptyPolygons
      poly = poly(arrayfun(@(p) p.NumRegions > 0, poly));
   end
end

function poly = processOnePoly(poly, kwargs)

   info = polyinfo(poly);

   % Expand and contract the polygon to smooth edges and remove small artifacts
   poly = polybuffer(poly, kwargs.bufferDist, "JointType", "miter");
   poly = polybuffer(poly,-kwargs.bufferDist, "JointType", "miter");

   % Split the polygon into its constituent regions (create a polyvec)
   poly = poly.regions;

   % Remove polygon regions smaller than the threshold. This is similar to
   % rmslivers and rmholes, but for closed regions. This occurred in some
   % watershed boundary shapefiles which contained "extra" regions, e.g.,
   % a single square or tiny area along the border, likely due to reversed
   % vertex ordering or otherwise bad geometry when the shapefile was written.
   keep = arrayfun(@(x) area(x)/sum(area(poly)) > kwargs.areaThreshold, poly);

   if sum(keep) > 1
      poly = union(poly(keep), ...
         'KeepCollinearPoints', kwargs.KeepCollinearPoints);

   elseif sum(keep) == 1
      poly = poly(keep);

   else
      poly = polyshape();
      warning(['Removing empty polygon. Check polygon quality and/or ' ...
         'adjust function parameters if you think this is an error.'])
      return
   end

   % Simplify the polyshape to clean up unnecessary vertices
   if kwargs.Simplify
      poly = poly.simplify("KeepCollinearPoints", kwargs.KeepCollinearPoints);
   end
   if kwargs.rmslivers && ~isempty(kwargs.sliverTolerance)
      poly = poly.rmslivers(kwargs.sliverTolerance);
   end
   if kwargs.rmholes
      poly = poly.rmholes();
   else
      % remove holes smaller than the areaThreshold?
      polyholes = poly.holes();
      if all(area(polyholes)./sum(area(poly)) < kwargs.areaThreshold)
         poly = poly.rmholes();
      end
   end

   % Reduce the total number of vertices and holes
   % This is producing polygons with multiple regions so I commented it out.
   % poly = simplifyPolyshape(poly, ...
   %    "rmholes", kwargs.rmholes, ...
   %    "maxverts", kwargs.maxverts);

   % Could use this to apply the options. This is the only one I
   % poly = polyshape(poly.Vertices(:, 1), poly.Vertices(:, 2), ...
   %    'Simplify', kwargs.Simplify, ...
   %    'KeepCollinearPoints', kwargs.KeepCollinearPoints, ...
   %    'SolidBoundaryOrientation', kwargs.SolidBoundaryOrientation);
end
