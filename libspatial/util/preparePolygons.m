function [P, PX, PY, inputFormat] = preparePolygons(P, varargin)
   %preparePolygons Prepare polygon coordinate vertices for analysis.
   %
   %  [P, PX, PY] = preparePolygons(P)
   %  [P, PX, PY, inputFormat] = preparePolygons(P)
   %  [P, PX, PY, inputFormat] = preparePolygons(_, 'makePolyshape', true)
   %  [P, PX, PY, inputFormat] = preparePolygons(_, 'repairGeometry', true)
   %  [P, PX, PY, inputFormat] = preparePolygons(_, 'inputFormat', format)
   %
   % Description:
   %  [P, PX, PY, inputFormat] = preparePolygons(P) extracts polygon vertex
   %  coordinates in P and returns them in 1-d column cell arrays, PX and PY.
   %  If P is a vector and not a matrix, P is returned in 1-d column format.
   %  If P is a matrix, P is returned with coordinates oriented as columns,
   %  such that PX = P(:, 1) and PY = P(:, 2). Checks are made for edge cases
   %  to allow flexible input formats for P. These include 1-d vectors or
   %  cell-arrays of polyshapes, 1-d cell arrays of coordinate pairs, or 2-d
   %  arrays or cell arrays of coordinate pairs (Nx2 or 2xN). Nan-delimited
   %  polygons are not detected at this time.
   %
   %  [_] = preparePolygons(_, 'makePolyshape', true) converts each element of
   %  P into a polyshape and returns them in 1-d polyshape vector P.
   %
   %  [_] = preparePolygons(_, 'repairGeometry', true) attempts to repair bad
   %  geometry in P by performing a more stringent conversion to polyshape.
   %  The repair algorithm buffers the polygon outward and then inward by a
   %  very small amount, removes slivers, and removes interior regions with
   %  relative area below 0.01% of the total polygon area. For more control
   %  over the repair algorithm, set makePolyshape=false and call the
   %  mkpolyshape function directly on the returned PX, PY values.
   %
   %  [P, PX, PY, inputFormat] = preparePolygons(_, 'inputFormat', inputFormat)
   %  Uses the supplied INPUTFORMAT instead of calling parsePolygonFormat. Five
   %  inputFormat's are defined:
   %
   %
   %
   %
   % See also:

   [P, inputFormat, kwargs] = parseinputs(P, mfilename, varargin{:});

   % In each case, the command to create a polyshape directly from the input
   % format is included but commented out. The PX, PY are used to create
   % polyshapes using a unified command at the end.

   switch inputFormat

      case 'PolyshapeCellVector'

         P = P(:);
         PX = cellmap(@(p) p.Vertices(:,1), P);
         PY = cellmap(@(p) p.Vertices(:,2), P);

         % P = cellmap(@(p) mkpolyshape(p.Vertices(:,1), p.Vertices(:,2)), P);

      case 'CoordinateCellVector'

         P = P(:);
         PX = cellmap(@(p) p(:,1), P);
         PY = cellmap(@(p) p(:,2), P);

         % P = cellmap(@(p) mkpolyshape(p(:,1), p(:,2)), P);

      case 'CoordinateCellArray'

         if size(P, 2) > size(P, 1)
            P = transpose(P);
         end

         PX = P(:, 1);
         PY = P(:, 2);

         % P = cellmap(@(x,y) mkpolyshape(x,y), P(:,1), P(:,2));

      case 'PolyshapeVector'

         P = P(:);
         PX = arraymap(@(p) p.Vertices(:,1), P);
         PY = arraymap(@(p) p.Vertices(:,2), P);

         % P = arraymap(@(p) mkpolyshape(p.Vertices(:,1), p.Vertices(:,2)), P);

         % If a cellfun-like method is not used, cast directly to cell:
         % P = num2cell(P(:));

      case 'CoordinateArray'

         if size(P, 2) > size(P, 1)
            P = transpose(P);
         end

         PX = {P(:, 1)};
         PY = {P(:, 2)};

         % PX = num2cell(P(:, 1));
         % PY = num2cell(P(:, 2));

         % TLDR: I am nearly certain this works for the following cases:
         % - a single single-part polygon
         % - a single multi-part nan-delimited polygon
         % - multiple single-part nan-delimited polygons
         %
         % And does not work for:
         % - multiple multi-part nan-delimited polygons
         %
         % The multiple multi-part nan-delimited polygons case obviously doesn't
         % work because there's no way to know which "parent" polygons the parts
         % belong to.
         %
         % The other cases work as long as the polyshape is created first, and
         % then the call to P.regions ensures they are returned as multi-part
         % but individual polyshapes.

         % Below here are original notes from exactremap parsePolygons.

         % Note: This converts nan-delimited polygons into a single multi-region
         % polyshape. This can be problematic if multi-part polygons are first
         % converted to nan-delimited coordinate lists and then sent into this
         % function because the indivdual "parts" of each polygon are no longer
         % associated with their parent polygon. But that is a user issue and
         % there's no way to know once it gets here.

         % Convert the X,Y vertices to a polyshape.
         % P = mkpolyshape(P(:, 1), P(:, 2));

         % Extract each polygon region. This works for single polygons and
         % multi-region (nan-delimited) polygons.
         % P = arraymap(@(p) p, P.regions);

      otherwise
         error('Unrecognized polygonFormat')
   end

   % I THINK ITS BEST TO RETURN P ORIENTED COLUMNWISE AND PX, PY WHICH ARE
   % ALWAYS CELL ARRAYS ORIENTED COLUMNWISE THEN LET MKPOLYSHAPE OPERATE ON ANY
   % FORMAT AND CALL THIS TO FIND OUT.

   % % Create polyshapes with clean geometry
   % if kwargs.makePolyshape || kwargs.repairGeometry
   %
   %    if kwargs.repairGeometry
   %       P = cellmap(@(x,y) mkpolyshape([x,y], 'CoordinateArray'), PX, PY);
   %    elseif kwargs.makePolyshape
   %       P = cellmap(@(x,y) polyshape(x,y), PX, PY);
   %    end
   %
   %    % Put the X,Y vertices back into cell arrays
   %    PX = cellmap( @(P) P.Vertices(:, 1), P);
   %    PY = cellmap( @(P) P.Vertices(:, 2), P);
   % end
end

function [P, inputFormat, kwargs] = parseinputs(P, mfilename, varargin)

   parser = inputParser();
   parser.FunctionName = mfilename();
   parser.addRequired('P', @validPolygon)
   parser.addParameter('inputFormat', parsePolygonFormat(P), @isscalartext)
   parser.addParameter('makePolyshape', false, @islogicalscalar)
   parser.addParameter('repairGeometry', false, @islogicalscalar)
   parser.parse(P, varargin{:})

   kwargs = parser.Results;
   inputFormat = char(kwargs.inputFormat);
   kwargs.inputFormat = inputFormat;
end

function validPolygon(P)

   % @mustBePolygon could be too restrictive and/or needs to be made
   % consistent with this function and visa versa, so use this for now:
   validPolygon = (iscell(P) || isnumeric(P) || ispolyshape(P)) ...
      && min(size(P)) < 3;
end
