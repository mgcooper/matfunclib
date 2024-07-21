function polygonFormat = parsePolygonFormat(P)
   %PARSEPOLYGONFORMAT Parse data format of polygon representations
   %
   % Five formats are defined:
   %
   %
   % TODO: Support structs (e.g., shapefiles) and tables
   %
   % See also: preparePolygons

   if iscell(P)

      if isempty(P)
         polygonFormat = 'EmptyCell';
      end

      if isvector(P)

         % Note:
         % isvector(cell(1, 0)) % true
         % isscalar(cell(1, 0)) % false
         % isempty (cell(1, 0)) % true

         if all(cellfun(@(p) isa(p, 'polyshape'), P))
            % P is an Nx1 or 1xN (N>=0) cell vector of polyshapes:
            % P = {P1;
            %      P2;
            %      ...
            %      PN};
            %
            % where:
            % i = 1;
            % PXi = P{i}.Vertices(:, 1);
            % PYi = P{i}.Vertices(:, 2);

            polygonFormat = 'PolyshapeCellVector';

            % PX = cellmap(@(p) p.Vertices(:,1), P(:));
            % PY = cellmap(@(p) p.Vertices(:,2), P(:));

         else
            % P is an Nx1 or 1xN (N>=0) cell vector of coordinate pairs:
            % P = {[PX1, PY1];
            %      [PX2, PY2];
            %      ...
            %      [PXN, PYN]};
            %
            % where:
            % i = 1;
            % PXi = P{i}(:, 1);
            % PYi = P{i}(:, 2);

            if all(cellfun(@isvector, P))
               % Special case: Scalar polygon stored as a 1x2 or 2x1 cell array.
               % Note this is equivalent to isCoordinateCellArray. It uses a
               % single "all"  because it can only get here if it is 1x2 or 2x1,
               % and the all(all(...) in isCoordinateCellArray handles the case
               % where Nx2 or 2xN is passed to it.
               polygonFormat = 'CoordinateCellArray';

            else
               % Expected format:
               polygonFormat = 'CoordinateCellVector';
            end

            % PX = cellmap(@(p) p(:,1), P(:));
            % PY = cellmap(@(p) p(:,2), P(:));

         end

      elseif ismatrix(P) && max(ndims(P)) == 2
         % P is an Nx2 or 2xN cell array of coordinate pairs:
         % P = {PX1, PY1;
         %      PX2, PY2;
         %      ...
         %      PXN, PYN};
         %
         % where:
         % i = 1;
         % PXi = P{i, 1}
         % PYi = P{i, 2}
         %
         % NOTE: The expected format is where PXi and PYi are vectors. If PXi
         % and PYi are scalars, this is an inefficient storage format and P
         % should be an Nx2 numeric array. See the demo at the end. These two
         % cases are not distinguished at this time.

         polygonFormat = 'CoordinateCellArray';

         % PX = P(:, 1);
         % PY = P(:, 2);

         % OR:

         % PX = P(1, :);
         % PY = P(2, :);

         % Need to check these two cases in calling function.

         % Also
         if all(cellfun(@isscalar, P))
            % this indicates P is a single polygon stored in the cell-equivalent
            % of a standard numeric array. This either should not occur, or if
            % it does, it needs to be handled differently because other
            % functions will expect each element of PX and PY to be the X,Y
            % coords of an entire polygon, whereas here they're one vertex. For
            % now, issue a warning, deal with it later if it comes up.
            wid = [mfilename ':DetectedScalarPolygonAsNonScalarCellArray'];
            msg = 'Detected scalar polygon stored as non-scalar cell array';
            warning(wid, msg)
         end

      else
         error('Unrecognized polygon format')

      end

   elseif (isnumeric(P) && ismatrix(P)) || isa(P, 'polyshape')

      if isempty(P)
         polygonFormat = 'EmptyArray';
      end

      if isa(P, 'polyshape')
         % P is an Nx1 or 1xN vector of polyshapes:
         % P = [P1;
         %      P2;
         %      ...
         %      PN]

         polygonFormat = 'PolyshapeVector';

         % PX = arraymap(@(p) p.Vertices(:,1), P);
         % PY = arraymap(@(p) p.Vertices(:,2), P);

      else
         % P is an Nx2 or 2xN coordinate array:
         % P = [PX1, PY1;
         %      PX2, PY2;
         %      ...
         %      PXN, PYN]
         %
         % where
         % PX = P(:, 1)
         % PY = P(:, 2)

         polygonFormat = 'CoordinateArray';

         % PX = num2cell(P(:, 1));
         % PY = num2cell(P(:, 2));
      end

   else

      error('Unrecognized polygon format')

   end

   % Started to refactor but left it as is
   % isPolyshapeCellScalar = iscell(P) & isa(P{1}, 'polyshape');
   % isCoordinateCellArray = iscell(P) & size(P, 2) == 2;

   run_demo = false;
   if run_demo == true
      demo_parsePolygonFormat(polygonFormat);
   end
end
