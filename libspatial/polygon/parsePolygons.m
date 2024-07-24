function [P, PX, PY, inputP, wasfile, attrs] = parsePolygons(P, kwargs)
   %PARSEPOLYGONS Convert polygon representation to a cell array of polyshapes.
   %
   %  [P, PX, PY] = parsePolygons(P)
   %  [_, inputP, wasfile, attrs] = parsePolygons(P)
   %  [_] = parsePolygons(P, repairGeometry=false)
   %  [_] = parsePolygons(P, aspolyshape=true)
   %
   % Description
   %  [P, PX, PY] = parsePolygons(P, kwargs) Converts input P to a cell array of
   %  polyshapes and cell arrays of X and Y coordinates. Use aspolyshape=true to
   %  return P as a polyshape vector.
   %
   % Inputs
   %  P - Polygons. Can be a vector or cell array of X,Y verts, a scalar or
   %  vector polyshape, or a cell array of polyshapes.
   %
   % Outputs
   %  P - Cell array of polyshapes
   %  PX - Cell array of polyshape X-coordinates
   %  PY - Cell array of polyshape Y-coordinates
   %  inputP - the input P, or if input P is a file, the data read into memory.
   %  wasfile - logical flag indicating if P was a file.
   %  attrs - attribute table if P was a file with an attribute table.
   %
   % See also: parsePolygonFormat

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
   wasfile = ~ispolygon(P) && isfile(P);
   if wasfile
      [P, inputP] = polygonsFromFile(P, 'UseGeoCoords', kwargs.UseGeoCoords);
      % TODO: parse attributes.
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

   if kwargs.aspolyshape || ~kwargs.ascell
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
