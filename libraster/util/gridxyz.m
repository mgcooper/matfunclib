function varargout = gridxyz(X, Y, V, varargin)
   %GRIDXYZ grid geolocated x, y, z data
   %
   %  [X, Y, V] = gridxyz(X, Y, V)
   %  [X, Y, V] = gridxyz(X, Y, V, OutputFormat='fullgrids')
   %  [X, Y, V] = gridxyz(X, Y, V, OutputFormat='coordinates')
   %  [X, Y, V] = gridxyz(_, testplot=true)
   %
   % Description:
   %
   %  [X, Y, V] = gridxyz(X, Y, V) returns geolocated data X, Y, V as a regular
   %  grid and gap-fills missing values in V.
   %
   % Note that gridxyz creates fullgrids from the input X,Y regardless of their
   % format, then uses scatteredInterpolation with nearest-neighbor
   % extrapolation, so it is guaranteed to infill missing pixels of the fullgrid
   % representations of X and Y. Care is needed to ensure the values returned by
   % this function are valid if the input X,Y coordinates and data V are not
   % fullgrids.
   %
   % See also: rasterize

   % See map2grid, need to decide which to keep

   %% notes

   % inpainting needs to happen on the full grid, but note that
   % inpaintn and inpaintn_nans do not utilize the x,y coordinates, so
   % use naninterp2
   % round(inpaintn(V))
   % round(inpaint_nans(V))
   % naninterp2(X, Y, V)

   % % If inpaintn is used, this might be necessary:
   % V = inpaintn(V);
   % prec = ceil(log10(abs(V)));
   % prec(prec>0) = 0;
   % V = round(V, mode(prec(:)));

   % % just keeping in case it comes in handy
   % if numel(xgridvec(X)) * numel(ygridvec(Y)) ~= numel(V)
   % end

   % % This would be the default parsing for mapinterp
   % if nargin < 5
   %    method = 'linear';
   % else
   %    method = validatestring(method, {'nearest', 'linear', 'cubic', 'spline'}, ...
   %       mfilename, 'method');
   % end

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

   % validate x,y,v inputs
   [V, X, Y] = validateGridData(V, X, Y, mfilename, 'V', 'X', 'Y');

   % keep the original data
   X1 = X;
   Y1 = Y;
   V1 = V;

   % prepare the grid
   [X, Y, dX, dY, GridType, tfgeo, I, LOC] = prepareMapGrid(X, Y, 'fullgrids');

   % I is true for x,y pairs in X,Y that are also in X1,Y1
   % LOC is the indices of these x,y pairs on X1,Y1 such that:
   assert( isequal( X(I), X1(LOC(LOC>0)) ) )
   assert( isequal( Y(I), Y1(LOC(LOC>0)) ) )

   % If X or Y were flipped in prepareMapGrid, then V needs to be
   % flipped / rotated accordingly first, before I is applied
   V = nan(numel(X), size(V1, 2));
   V(I(:), :) = V1(LOC(LOC>0), :);

   % inpaint missing values
   V = scatteredInterpolation(X(:), Y(:), V, X(:), Y(:), ...
      kwargs.method, kwargs.extrap);

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
      scatter(X1(:), Y1(:), 150, mean(V1, 2), 'filled'); % plot(P{:});
      scatter(X(:), Y(:), 20, 'r', 'filled');
      title('original data')

      subplot(1, 2, 2)
      hold on
      scatter(X(:), Y(:), 150, mean(V, 2), 'filled'); % plot(P{:});
      scatter(X(:), Y(:), 20, 'r', 'filled');
      title('gridded and gap filled data')

      % P = loadSitePoly("leverett", "min");
      % plot(P)
   end

   switch nargout
      case 1
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
