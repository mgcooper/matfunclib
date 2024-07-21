function [P, PX, PY] = mkpolyshape(P, kwargs)
   %MKPOLYSHAPE Create polyshape(s) from P = [PX, PY] vertices.
   %
   %  P = mkpolyshape(P)
   %  P = mkpolyshape(_, 'repairGeometry', false)
   %  P = mkpolyshape(_, 'simplify', false)
   %  P = mkpolyshape(_, 'rmslivers', false)
   %  P = mkpolyshape(_, 'rmholes', true)
   %  P = mkpolyshape(_, 'mergeregions', true)
   %  P = mkpolyshape(_, 'maxverts', maxverts)
   %  P = mkpolyshape(_, 'bufferDist', bufferDist)
   %  P = mkpolyshape(_, 'areaThreshold', areaThreshold)
   %  P = mkpolyshape(_, 'sliverTolerance', sliverTolerance)
   %  P = mkpolyshape(_, 'KeepCollinearPoints', true)
   %  P = mkpolyshape(_, 'SolidBoundaryOrientation', SolidBoundaryOrientation)
   %
   % Inputs:
   %  P - X,Y vertices for polyshape object
   %  bufferDist - Distance to expand and then contract the polyshape
   %  areaThreshold - Minimum area to retain a polygon region
   %
   % Name-Value pairs:
   %  'bufferDist' - default = 0.001
   %  'areaThreshold'- default = 0.01%
   %  'sliverTolerance' - default = 0.0
   %  'KeepCollinearPoints' - default = false
   %  'SolidBoundaryOrientation'- default = "auto"
   %
   % Output:
   %  P - The polyshape object(s).
   %
   % See also:

   % Note: Although it would be closer to polyshape if this function accepted
   % two inputs: x, y, it's more restrictive and requires calling
   % preparePolygons or some other method to create the x,y coordinates. Thus
   % even setting aside the idea to let this accept polyshapes for the purpose
   % of repairing them, it still makes sense to have a single input, P.

   arguments
      P {mustBePolygon}

      % Keep this for now in case it is useful in other functions
      % kwargs.inputFormat (1, :) {...
      %    mustBeMember(kwargs.inputFormat, ...
      %    ['Unknown', ...
      %    'PolyshapeVector', ...
      %    'PolyshapeCellVector', ...
      %    'CoordinateArray', ...
      %    'CoordinateCellVector', ...
      %    'CoordinateCellArray']) } ...
      %    = 'Unknown'

      kwargs.repairGeometry (1, 1) logical ...
         = true

      kwargs.ascell (1, 1) logical ...
         = false

      % Built in polyshape creation methods
      kwargs.Simplify (1, 1) logical = true
      kwargs.KeepCollinearPoints (1, 1) logical = false
      kwargs.SolidBoundaryOrientation (1, 1) string = "auto"

      % Built in polyshape member methods
      kwargs.rmslivers (1, 1) logical = true
      kwargs.rmholes (1, 1) logical = false

      % Custom methods
      kwargs.mergeregions (1, 1) logical = false

      % Parameters
      kwargs.maxverts {mustBeScalarOrEmpty} = 10000
      kwargs.bufferDist {mustBeScalarOrEmpty} = 0.001
      kwargs.areaThreshold {mustBeScalarOrEmpty} = 0.01
      kwargs.sliverTolerance {mustBeScalarOrEmpty} = []
      kwargs.KeepEmptyPolygons (1, 1) logical = false
   end

   withwarnoff('MATLAB:polyshape:repairedBySimplify');

   % Prepare the polygons for conversion to polyshape
   [P, PX, PY, inputFormat] = preparePolygons(P);

   % Make polyshapes if they're not already
   if ~waspolyshape(inputFormat)
      P = cellmap(@(x,y) ...
         polyshape(x, y, ...
         "Simplify", kwargs.Simplify, ...
         "KeepCollinearPoints", kwargs.KeepCollinearPoints, ...
         "SolidBoundaryOrientation", kwargs.SolidBoundaryOrientation), ...
         PX, PY);
   end

   % Ensure P is a polyshape vector
   if iscell(P)
      P = vertcat(P{:});
   end

   % Repair the polyshapes
   if kwargs.repairGeometry

      P = repairPolyshape(P, ...
         "Simplify", kwargs.Simplify, ...
         "maxverts", kwargs.maxverts, ...
         "rmholes", kwargs.rmholes, ...
         "rmslivers", kwargs.rmslivers, ...
         "sliverTolerance", kwargs.sliverTolerance, ...
         "bufferDist", kwargs.bufferDist, ...
         "mergeregions", kwargs.mergeregions, ...
         "areaThreshold", kwargs.areaThreshold, ...
         "KeepEmptyPolygons", kwargs.KeepEmptyPolygons, ...
         "KeepCollinearPoints", kwargs.KeepCollinearPoints, ...
         "SolidBoundaryOrientation", kwargs.SolidBoundaryOrientation);
   end

   % Remove any empty polyshapes
   if ~kwargs.KeepEmptyPolygons
      P = P(arrayfun(@(p) p.NumRegions > 0, P));
   end

   % Return the X,Y vertices of the repaired polyshape. Cast P to cell array
   % first, otherwise if P is scalar, cellmap returns numeric arrays and
   % converting them to cell arrays is more complicated because it requires
   % distinguishing between the scalar polygon versus vector case.
   if ~iscell(P)
      P = num2cell(P(:));
   end
   PX = cellmap( @(P) P.Vertices(:, 1), P);
   PY = cellmap( @(P) P.Vertices(:, 2), P);

   % Return P as a polyshape vector if requested
   if ~kwargs.ascell
      P = vertcat(P{:});
   end
end

function tf = waspolyshape(inputFormat)
   tf = any(strcmp(inputFormat, {'PolyshapeCellVector', 'PolyshapeVector'}));
end
