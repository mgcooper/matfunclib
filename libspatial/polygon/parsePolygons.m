function [P, PX, PY] = parsePolygons(P, kwargs)
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

   % This can be very slow for multi-polygon inputs. For exactremap, P needs to
   % be a polyshape to get area intersections in remapOnePolygon, BUT ONLY FOR
   % THE POLYGONS THAT ARE INVOLVED IN THE CALCULATION. A better method would
   % trim both X,Y and P to the minimum bounding boxes but then custom indexing
   % will be required to convert between the inputs and outputs.

   arguments
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

   if ~ispolygon(P) && isfile(P)
      P = polygonsFromFile(P, 'UseGeoCoords', kwargs.UseGeoCoords);
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


   % Below here shouldn't be needed but keep until it finds a home.

   % Determine the input format (cell vector, coordinate list, etc.)
   % inputFormat = parsePolygonFormat(P);

   % switch inputFormat
   %
   %    case 'PolyshapeCellVector'
   %
   %       validateattributes(P, {'cell'}, {'column'}, ...
   %          kwargs.mfilename, kwargs.argname, kwargs.argidx);
   %
   %    case 'CoordinateCellVector'
   %
   %       validateattributes(P, {'cell'}, {'column'}, ...
   %          kwargs.mfilename, kwargs.argname, kwargs.argidx);
   %
   %    case 'CoordinateCellArray'
   %
   %       validateattributes(P, {'cell'}, {'2d', 'ncols', 2}, ...
   %          kwargs.mfilename, kwargs.argname, kwargs.argidx);
   %
   %    case 'PolyshapeVector'
   %
   %       validateattributes(P, {'polyshape'}, {'column'}, ...
   %          kwargs.mfilename, kwargs.argname, kwargs.argidx);
   %
   %    case 'CoordinateArray'
   %
   %       validateattributes(P, {'numeric'}, {'2d', 'ncols', 2}, ...
   %          kwargs.mfilename, kwargs.argname, kwargs.argidx);
   %
   %       % This still may be needed here
   %       % P = arraymap(@(p) p, P.regions);
   %
   %       % For reference, an older method I thought was necessary
   %       % P = parseNanDelimitedPolygons(P);
   %
   %    otherwise
   %       error('Unrecognized polygonFormat')
   % end
   %
   % % Convert P to a cell array of polyshapes.
   % if kwargs.repairGeometry
   %
   %    P = cellmap(@(x,y) mkpolyshape(x,y), PX, PY);
   % else
   %
   %    P = cellmap(@(x,y) polyshape(x,y), PX, PY);
   % end
   %
   % % Repair the polygons - This should no longer be necessary because I moved
   % % the entire contents of repairPolyshape into mkpolyshape. However, the
   % % original workflow used "polyshape" where "mkpolyshape" is now used in the
   % % above if-else blocks and I had to stop developing this abruptly and did not
   % % take good notes on where I left off. When I picked back up I passed in a
   % % cell array of x,y vertices rather than a nan-delimited list, which works
   % % well with mkpolyshape, but it's possible there's something about
   % % nan-delimited for the case where a single polygon is passed in but it
   % % happens to have multi-parts that I still want this here.
   % %
   % % P = cellmap(@repairPolyshape, P);
   % % P = nonEmptyCells(P);
   %
   % % Put the X,Y vertices back into cell arrays
   % PX = cellmap( @(P) P.Vertices(:, 1), P);
   % PY = cellmap( @(P) P.Vertices(:, 2), P);
   % % Note, set 'Uniform' true to get a polyshape vector rather than cell array
   %
   % % % This was in the main for the case where Numel = 1, to get the full area
   % % px = P.Vertices(:, 1);
   % % py = P.Vertices(:, 2);
   % %
   % % [PX, PY] = polyjoin({px}, {py}) ;
end
