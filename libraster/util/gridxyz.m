function varargout = gridxyz(X, Y, V, GridOption, varargin)
   %GRIDXYZ grid geolocated x, y, z data
   %
   %  [X, Y, V] = gridxyz(X, Y, V) returns geolocated data X, Y, V as a regular
   %  grid and gap-fills missing values in V
   %
   % See also

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
   if nargin < 4 || isempty(GridOption); GridOption = 'fullgrids'; end
   if nargin < 5; testplot = false; else; testplot = varargin{1}; end

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
   V = scatteredInterpolation(X(:), Y(:), V, X(:), Y(:), 'natural', 'nearest');

   % send the data back in full
   switch GridOption
      case 'fullgrids'
         V = reshape(V, size(X, 1), size(X, 2), []);
      case 'coordinates'
         X = X(:);
         Y = Y(:);
   end

   % georeference
   R = rasterref(X, Y);

   % use this to confirm that V is oriented the same as X, Y
   if testplot == true
      figure;
      subplot(1, 2, 1);
      scatter(X1(:), Y1(:), 150, mean(V1, 2), 'filled'); hold on; plot(P{:});
      scatter(X(:), Y(:), 20, 'r', 'filled');
      title('original data')

      subplot(1, 2, 2);
      scatter(X(:), Y(:), 150, mean(V, 2), 'filled'); hold on; plot(P{:});
      scatter(X(:), Y(:), 20, 'r', 'filled');
      title('gridded and gap filled data')
   end

   switch nargout
      case 1
      case 2
         [varargout{1:nargout}] = dealout(V, R);
      case 3
         [varargout{1:nargout}] = dealout(V, X, Y);
      case 4
         [varargout{1:nargout}] = dealout(V, R, X, Y);
   end
end
