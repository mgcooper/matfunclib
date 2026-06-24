function varargout = gridxyz(X, Y, V, varargin)
   %GRIDXYZ Grid geolocated x, y, z data and gap-fill missing values.
   %
   % Output arguments are returned in the order V, R, X, Y, I, LOC. Request as
   % many as needed (note: with THREE outputs you get V, X, Y -- not R):
   %
   %  V                    = gridxyz(X, Y, V)
   %  [V, R]               = gridxyz(X, Y, V)
   %  [V, X, Y]            = gridxyz(X, Y, V)
   %  [V, R, X, Y]         = gridxyz(X, Y, V)
   %  [V, R, X, Y, I]      = gridxyz(X, Y, V)
   %  [V, R, X, Y, I, LOC] = gridxyz(X, Y, V)
   %  [...] = gridxyz(_, OutputFormat='fullgrids')    % default; X,Y,V as 2-d grids
   %  [...] = gridxyz(_, OutputFormat='coordinates')  % X,Y as column vectors
   %  [...] = gridxyz(_, method=..., extrap=..., testplot=true)
   %
   % Outputs:
   %  V   - gridded values with missing cells gap-filled. Known cells are
   %        preserved exactly; only NaN/missing cells are interpolated.
   %  R   - spatial referencing object for the fullgrid (from rasterref).
   %  X,Y - fullgrid coordinates (2-d grids, or column vectors for
   %        OutputFormat='coordinates').
   %  I   - logical mask, true where a fullgrid cell matches an input X,Y pair.
   %  LOC - indices of those matching pairs in the original input X, Y.
   %
   % Description:
   %
   %  gridxyz returns geolocated data X, Y, V as a regular grid and gap-fills
   %  missing values in V. It creates fullgrids from the input X,Y regardless of
   %  their format, then uses scatteredInterpolation (with the requested method
   %  and extrapolation) to infill missing pixels of the fullgrid. Care is needed
   %  to ensure the returned values are valid if the input X,Y coordinates and
   %  data V are not fullgrids. Unlike rasterize, gridxyz supports multi-column V
   %  (e.g. a stack of layers sharing a single X,Y grid).
   %
   % See also: rasterize, scatteredInterpolation, rasterref

   % Relationship to rasterize (assessed Jun 2026): rasterize converts SCATTERED
   % (x,y,z) data to a raster at a caller-specified resolution
   % (rasterSize/cellextent) for a single 2-d layer, via griddata. gridxyz instead
   % takes coordinates that already imply a grid (possibly with gaps), builds that
   % fullgrid, and gap-fills it for one OR MANY value columns, returning the
   % cell<->input index mapping (I, LOC). They are complementary: rasterize is not
   % a drop-in replacement for gridxyz (no multi-column support, different
   % resolution model), so both are kept.
   % (The earlier "% See map2grid, need to decide which to keep" note was removed:
   % no map2grid function exists in this repo's history.)

   %% notes

   % Why scatteredInterpolation and not inpaintn/inpaint_nans here: inpaintn
   % ignores the x,y coordinates (assumes unit cell spacing), so it is only valid
   % on a UNIFORM grid. gridxyz must also gap-fill regular-but-non-uniform grids,
   % which need coordinate-aware interpolation -- hence scatteredInterpolation
   % below. (rasterize's regular branch can use inpaintn because it runs only when
   % isxyregular passed, i.e. the grid is uniform.) naninterp2(X,Y,V) is the
   % coordinate-aware inpaintn variant if a grid-shaped fill is ever wanted.

   % The "is V a full grid?" check -- numel(xgridvec(X))*numel(ygridvec(Y)) ==
   % numel(V) -- is necessary but not sufficient (see isfullgrid); it is not
   % needed here anyway, because prepareMapGrid builds the full grid and returns
   % the I/LOC mapping that places known values and leaves gaps NaN.

   %% main code

   % parse inputs
   parser = inputParser();
   parser.FunctionName = mfilename();
   parser.addOptional('OutputFormat', 'fullgrids', @validGridFormat)
   parser.addParameter('method', 'natural', @validInterpMethod)
   parser.addParameter('extrap', 'none', @validExtrapMethod)
   parser.addParameter('testplot', false, @islogicalscalar)
   parse(parser, varargin{:})
   kwargs = parser.Results;

   % NOTE: Calling validateGridData is sensible if the purpose is to grid xyz
   % data which is already gridded but is not in fullgrid format ... but
   % otherwise this will fail so I commented it out.
   % validate x,y,v inputs
   % [V, X, Y] = validateGridData(V, X, Y, mfilename, 'V', 'X', 'Y');

   % keep the original data
   X1 = X;
   Y1 = Y;
   V1 = V;

   % prepare the grid (also report the transforms it applied)
   [X, Y, ~, ~, ~, ~, I, LOC, ~, ~, tform] = ...
      prepareMapGrid(X, Y, 'fullgrids');

   % prepareMapGrid computes the I/LOC membership against its internally
   % canonicalized copy of the input. If it transposed an ndgrid full grid and/or
   % flipped it to reach meshgrid W-E/N-S, replay the SAME transforms on the saved
   % input X1,Y1,V1 so the indices line up. Coordinate-list input is never
   % transformed (all flags false), so this is a no-op there.
   X1 = applyGridTransform(X1, tform);
   Y1 = applyGridTransform(Y1, tform);
   V1 = applyGridTransform(V1, tform);
   if tform.didTranspose || tform.didFlipLR || tform.didFlipUD
      % A transformed V is a full grid here; flatten to a value list
      % (npts x nlayers) so it indexes like the coordinate lists below.
      V1 = reshape(V1, [], size(V1, 3));
   end

   % I is true for x,y pairs in X,Y that are also in X1,Y1
   % LOC is the indices of these x,y pairs on X1,Y1 such that:
   assert( isequal( X(I), X1(LOC(LOC>0)) ) )
   assert( isequal( Y(I), Y1(LOC(LOC>0)) ) )

   % Build the output value array and place the known values.
   V = nan(numel(X), size(V1, 2));
   V(I(:), :) = V1(LOC(LOC>0), :);

   % Gap-fill only the missing entries: build the interpolant from the known
   % samples (NaNs are excluded inside scatteredInterpolation), query the full
   % grid, then overwrite ONLY the previously-missing cells. Known cells keep
   % their exact input values rather than being replaced by interpolated ones,
   % matching the documented "gap-fill" contract. Skip the work entirely when
   % nothing is missing.
   inan = isnan(V);
   if any(inan(:))
      % Query only the nodes that are missing in at least one column, rather than
      % the whole grid. The interpolant is built from all known samples either
      % way, but for a grid with few gaps this evaluates far fewer query points.
      qrows = any(inan, 2);
      Vq = scatteredInterpolation(X(:), Y(:), V, X(qrows), Y(qrows), ...
         kwargs.method, kwargs.extrap);
      % Overwrite only the previously-missing entries among the queried nodes;
      % known cells keep their exact input values.
      block = V(qrows, :);
      qnan = inan(qrows, :);
      block(qnan) = Vq(qnan);
      V(qrows, :) = block;
   end

   % send the data back in full
   switch kwargs.OutputFormat
      case 'fullgrids'
         V = reshape(V, size(X, 1), size(X, 2), []);
      case 'coordinates'
         X = X(:);
         Y = Y(:);
   end

   % georeference
   R = rasterref(X, Y);

   % use this to confirm that V is oriented the same as X, Y
   if kwargs.testplot

      figure
      subplot(1, 2, 1)
      hold on
      scatter(X1(:), Y1(:), 150, mean(V1, 2), 'filled');
      scatter(X(:), Y(:), 20, 'r', 'filled');
      title('original data')

      subplot(1, 2, 2)
      hold on
      scatter(X(:), Y(:), 150, mean(V, 2), 'filled');
      scatter(X(:), Y(:), 20, 'r', 'filled');
      title('gridded and gap filled data')
   end

   switch nargout
      case 1
         [varargout{1:nargout}] = dealout(V);
      case 2
         [varargout{1:nargout}] = dealout(V, R);
      case 3
         [varargout{1:nargout}] = dealout(V, X, Y);
      case 4
         [varargout{1:nargout}] = dealout(V, R, X, Y);
      case 5
         [varargout{1:nargout}] = dealout(V, R, X, Y, I);
      case 6
         [varargout{1:nargout}] = dealout(V, R, X, Y, I, LOC);
   end
end

function tf = validGridFormat(f)
   tf = any(validateGridFormat(f, {'fullgrids', 'coordinates'}));
end

function tf = validInterpMethod(m)
   tf = any(validateInterpMethod(m, {'nearest', 'linear', 'natural'}));
end

function tf = validExtrapMethod(m)
   tf = any(validatestring(m, {'nearest', 'linear', 'none'}));
end
