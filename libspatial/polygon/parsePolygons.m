function [P, PX, PY, inputP] = parsePolygons(P, kwargs)
   %PARSEPOLYGONS Convert polygon representation to a cell array of polyshapes.
   %
   %  [P, PX, PY] = parsePolygons(P, kwargs) Converts input P to a cell array of
   %  polyshapes and cell arrays of X and Y coordinates.
   %
   % Inputs
   %  P - Polygons. Can be a vector or cell array of X,Y verts, a scalar or
   %  vector polyshape, or a cell array of polyshapes.
   %
   % Outputs
   %  P - Cell array of polyshapes
   %  PX - Cell array of polyshape X-coordinates
   %  PY - Cell array of polyshape Y-coordinates
   %
   % See also:

   % NOTE: See merra.monthlyWaterBalance parsepoly subfunction for an example of
   % how a "mergepolygons" option could be added here if the input P is a multi
   % polygon and it needs to be returned as one merged outline

   arguments(Input)
      P
      kwargs.mfilename string {mustBeTextScalarOrEmpty} = mcallername(stacklevel=3)
      kwargs.argname string {mustBeTextScalarOrEmpty} = ""
      kwargs.argidx double {mustBeScalarOrEmpty} = []
      kwargs.ascell (1,1) logical = true
      kwargs.aspolyshape (1,1) logical = false
      kwargs.repairGeometry (1,1) logical = true
      kwargs.UseGeoCoords (1,1) logical = false
   end

   withwarnoff('MATLAB:polyshape:repairedBySimplify');

   % If P is a file, assign the full shapefile to inputP, otherwise assign P.
   if ~ispolygon(P) && isfile(P)
      [P, inputP] = polygonsFromFile(P, 'UseGeoCoords', kwargs.UseGeoCoords);
   else
      inputP = P;
   end

   % Prepare the polyshapes.
   [P, PX, PY] = mkpolyshape(P, ...
      "repairGeometry", kwargs.repairGeometry, "ascell", true);

   % P must be a polyshape (scalar or vector) or cell array of polyshapes.
   assert(isa(P, 'polyshape') || iscell(P))
   if ~iscell(P)
      P = num2cell(P(:));
   end
   assert(all(cellfun(@(p) isa(p, 'polyshape'), P)));

   if kwargs.aspolyshape
      P = vertcat(P{:});
   end

   % Determine the input format (cell vector, coordinate list, etc.)
   % inputFormat = parsePolygonFormat(P);
   % validatePolygonFormat(inputFormat);
   %
   % % Repair the polygons - shouldn't be needed b/c repairPolyshape is called by
   % % mkpolyshape but keep until tested with a nan-delimited multipart polygon
   %
   % % P = cellmap(@repairPolyshape, P);
   % % P = nonEmptyCells(P);
   % %
   % % Put the X,Y vertices back into cell arrays
   % PX = cellmap( @(P) P.Vertices(:, 1), P);
   % PY = cellmap( @(P) P.Vertices(:, 2), P);
   % % Note, set 'Uniform' true to get a polyshape vector rather than cell array
end
