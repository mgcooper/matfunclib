function demo_parsePolygonFormat(inputFormat)

   % Note: this is meant to be called from within a function where inputFormat
   % is available for debugging, but this makes it not fail if called with no
   % inputs.
   if nargin < 1
      inputFormat = 'PolyshapeCellVector';
   end

   % Problem cases which need solutions
   % - DONE (warning added) Scalar polygon stored as non-scalar cell array (one
   % vertex per element)
   % - DONE (if-else added) Scalar polygon stored as 1x2 or 2x1 cell array,
   % which is a vector so it gets caught by isvector but should defined as a
   % CoordinateCellArray.
   % (note: scalar polygon stored as 1x1 cell is not problematic because it is
   % treated the same as a cell vector which works identically for a scalar)
   % - CoordinateCellArray stored as 2xN instead of Nx2. Since the if-else check
   % was added to the 1x2 or 2x1 case it should be OK to add a check if the
   % format is CoordinateCellArray and the dim 2 > dim 1, transpose.
   % - Nan-delimited coordinate array. Note this may not need to be
   % distinguished, the methods may handle it.

   % Generate test data
   [P1, P2, PN, PX1, PY1, PX2, PY2, PXN, PYN] = ...
      exactremap.generateTestPolyshapes('parsePolygonFormat');

   % Plot the test data
   figure
   plotpolygon([P1; P2; PN])
   axis equal
   axis([0.5, 4.0, 0.5, 4.0])

   % Define functions to determine polygon format. These are defined here
   % because they demonstrate why the order of checks (isvector first then
   % ismatrix) is important. The actual functions isCoordinateCellVector and
   % isCoordinateCellArray are used in parsePolygonFormat.
   isCellVector = @(P) iscell(P) && isvector(P);
   isCellMatrix = @(P) iscell(P) && ismatrix(P);

   % These are used for the PX, PY checks.
   isCellRow = @(P) iscell(P) && isrow(P);
   isCellColumn = @(P) iscell(P) && iscolumn(P);

   % I don't think these are needed, but at one point I thought one or both
   % would be useful for the isvector vs ismatrix ambiguity.
   % isCellVectorNotMatrix = @(P) isCellVector(P) && ~ismatrix(P);
   % isCellMatrixNotVector = @(P) isCellMatrix(P) && ~isvector(P);

   % These are retained for reference but were converted into functions
   % isVectorValued = @(P) all(cellfun(@isvector, P));
   % isMatrixValued = @(P) all(cellfun(@ismatrix, P)) && none(cellfun(@isvector, P));
   % isCoordinateCellVector = @(P) isCellVector(P) && isMatrixValued(P);
   % isCoordinateCellArray = @(P) isCellMatrix(P) && all(isVectorValued(P));

   switch inputFormat

      case 'PolyshapeCellVector'
         % P is an Nx1 or 1xN (N>=0) cell vector of polyshapes:
         P = {
            P1;
            P2;
            ...
            PN };

         % where
         i = 1;
         PXi = P{i}.Vertices(:, 1);
         PYi = P{i}.Vertices(:, 2);

         % The first one must be true. The second can be true.
         assert(isCellVector(P))
         isCellMatrix(P)

         % Not sure if these must or must not be true, they can be used to
         % prevent an incorrect interpretation if needed.
         % isCellVectorNotMatrix(P)
         % isCellMatrixNotVector(P)

         % Put X and Y into expected format:
         PX = cellmap(@(p) p.Vertices(:,1), P);
         PY = cellmap(@(p) p.Vertices(:,2), P);
         assert(isCellColumn(PX))
         assert(isCellColumn(PY))

         % If P is a row vector:
         P = P.';
         PX = cellmap(@(p) p.Vertices(:,1), P(:));
         PY = cellmap(@(p) p.Vertices(:,2), P(:));
         assert(isCellColumn(PX))
         assert(isCellColumn(PY))
         % preparePolygonCoordinates uses (:) indexing for this reason.

         % If P is one polygon:
         P = {P1};
         assert(isCellVector(P))
         isCellMatrix(P)

      case 'CoordinateCellVector'
         % P is an Nx1 or 1xN cell vector of coordinate pairs:

         P = {
            [PX1, PY1];
            [PX2, PY2];
            ...
            [PXN, PYN] };

         % where
         i = 1;
         PXi = P{i}(:, 1);
         PYi = P{i}(:, 2);

         % The first one must be true. The second can be true.
         assert(isCellVector(P))
         isCellMatrix(P)

         isCoordinateCellVector(P)
         isCoordinateCellArray(P)
         % isCellVectorNotMatrix(P)
         % isCellMatrixNotVector(P)


         % In typical code:
         P = {[PX1, PY1]; [PX2, PY2]; [PXN, PYN]};

         % Put X and Y into expected format:
         PX = cellmap(@(p) p(:,1), P);
         PY = cellmap(@(p) p(:,2), P);
         assert(isCellColumn(PX))
         assert(isCellColumn(PY))

         % If P is a row vector:
         P = P.';
         PX = cellmap(@(p) p(:,1), P(:));
         PY = cellmap(@(p) p(:,2), P(:));
         assert(isCellColumn(PX))
         assert(isCellColumn(PY))
         % preparePolygonCoordinates uses (:) indexing for this reason.

         % If P is one-polygon:
         P = {[PX1, PY1]};
         assert(isCellVector(P))
         assert(isCoordinateCellVector(P))
         isCellMatrix(P)

         % SPECIAL CASE:

         % Need to distinguish this "cellvector":
         % 1×1 cell array
         %  {4×2 double}
         %
         % From this "cellarray":
         % 1×2 cell array
         %  {4×1 double}    {4×1 double}
         %
         % Or this one:
         % 2×1 cell array
         %  {4×1 double}
         %  {4×1 double}
         %
         % More specifically, need to distinguish the second case from any sized cell
         % vector, such as:
         %
         % 3×1 cell array
         %  {4×2 double}
         %  {3×2 double}
         %  {6×2 double}
         %
         % Do that by checking isvector on each element of P

         % An alternative would be to make P into a CoordinateCellVector that
         % way the assertions would pass.

      case 'CoordinateCellArray'
         % P is an Nx2 or 2xN cell array of coordinate pairs:
         P = {
            PX1, PY1;
            PX2, PY2;
            ...
            PXN, PYN};

         % where:
         i = 1;
         PXi = P{i, 1};
         PYi = P{i, 2};

         % Equivalent notation:
         P = {PX1, PY1; PX2, PY2; PXN, PYN};
         P = [{PX1; PX2; PXN}, {PY1; PY2; PYN}]; % note: brackets required
         P = [{PX1, PY1}; {PX2, PY2}; {PXN, PYN}];

         % NOTE: This one is tricky because (1) the one-polygon case can be a
         % cell vector (1x2 or 2x1), and (2) its necessary to determine
         % orientation unlike the vector case where (:) can be used. (1) is
         % solved by the isCoordinateCellArray and isCoordinateCellVector
         % checks, (2) will be handled in calling functions.

         % The first one cannot be true. The second one must be true.
         assert(~isCellVector(P))
         assert(isCellMatrix(P))

         assert(~isCoordinateCellVector(P))
         assert(isCoordinateCellArray(P))

         % Not certain if these are useful
         % isCellVectorNotMatrix(P)
         % isCellMatrixNotVector(P)

         % Put X and Y into expected format:
         PX = P(:, 1);
         PY = P(:, 2);
         assert(isCellColumn(PX))
         assert(isCellColumn(PY))

         % Concatenation of the two returns the original:
         P
         [PX PY]

         % If P is a row vector:
         P = P.';

         % TODO: Add method to check and/or transpose in calling function:
         PX = P(1, :).';
         PY = P(2, :).';
         assert(isCellColumn(PX))
         assert(isCellColumn(PY))

         % The first one cannot be true. The second one must be true.
         assert(~isCellVector(P))
         assert(isCellMatrix(P))

         assert(~isCoordinateCellVector(P))
         assert(isCoordinateCellArray(P))

         % If P is one polygon with M verts stored in an Mx2 or 2xM cell array:
         P = num2cell([PX1, PY1]);

         % Note: This is the cell equivalent of a standard numeric array and
         % should not be used, but it's possible this could arise in an
         % intermediate step e.g. if a single polygon is stored in a scalar cell
         % array and it's coordinates are extracted using a cellfun-like method
         % and then this function is called on those coordinates.

         % The first one cannot be true. The second one must be true.
         assert(~isCellVector(P))
         assert(isCellMatrix(P))

         assert(~isCoordinateCellVector(P))
         assert(isCoordinateCellArray(P))

         % Put X and Y into expected format:
         PX = P(:, 1);
         PY = P(:, 2);
         assert(isCellColumn(PX))
         assert(isCellColumn(PY))

         % Note: The checks above pass, but PX and PY are coordinates for just
         % one polygon, whereas other functions will expect each element of PX
         % and PY to be the coordinates for one entire polygon. The isCellMatrix
         % and isCoordinateCellArray checks pass because they enforce that the
         % cell array itself is a matrix and the elements are vector valued,
         % which includes scalars. To exclude that, add a ~isscalar condition.

         % A WARNING WAS ADDED TO ADDRESS THE ABOVE CASE.


         % Expected scalar polygon case: P is stored in a 1x2 or 2x1 cell array:
         P = {PX1, PY1};

         % The first one cannot be true. The second one must be true.
         assert(~isCellVector(P)) % THIS IS THE PROBLEM
         assert(isCellMatrix(P))

         assert(~isCoordinateCellVector(P)) % BUT THIS SOLVES IT
         assert(isCoordinateCellArray(P))

         % Put X and Y into expected format:
         PX = P(:, 1);
         PY = P(:, 2);
         assert(isCellColumn(PX))
         assert(isCellColumn(PY))

         % Note: This is the 'CoordinateCellVector' case with one polygon:
         P = {[PX1, PY1]}; % 1×1 cell array: {4×2 double}

         % Rebuild the expected case
         P = {PX1, PY1; PX2, PY2; PXN, PYN};

      case 'PolyshapeVector'
         % P is an Nx1 or 1xN vector of polyshapes:
         P = [
            P1;
            P2;
            ...
            PN];

         % TODO: Continue migrating the examples from parsePolygonFormat

         PX = arraymap(@(p) p.Vertices(:,1), P(:));
         PY = arraymap(@(p) p.Vertices(:,2), P(:));

      case 'CoordinateArray'
         % P is an Nx2 or 2xN coordinate array:
         P = [
            PX1, PY1;
            nan, nan;
            PX2, PY2;
            nan, nan;
            ...
            PXN, PYN]

         % where
         PX = P(:, 1);
         PY = P(:, 2);

         % NOTE: Need to pick up on this - confirm if nan-delimited polygons are
         % detected - I think the reason this is not dealt with explicitly is
         % because polyshape does it automatically.

         % This is wrong, it creates the scalar polygon stored in non-scalar
         % cell array:
         % PX = num2cell(P(:, 1));
         % PY = num2cell(P(:, 2));

         % Should be this:
         PX = {P(:, 1)};
         PY = {P(:, 2)};

      otherwise
         error('Unrecognized polygonFormat')
   end
end

% function mustBeCellVector(P)
%    % The first one must be true. The second can be true.
%    assert(isCellVector(P))
%    isCellMatrix(P)
% end
% function mustNotBeCellVector
%
% end
% function mustBeVectorValued(P)
%    assert(all(cellfun(@isvector, P)));
% end
% function tf = isCellVector(P)
%    tf = iscell(P) && isvector(P);
% end
% function tf = isCellMatrix(P)
%    tf = iscell(P) && ismatrix(P);
% end
