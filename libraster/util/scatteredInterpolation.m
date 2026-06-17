function [Vq] = scatteredInterpolation(X, Y, V, Xq, Yq, varargin)
   %SCATTEREDINTERPOLATION Interpolate scattered data.
   %
   % [Vq] = scatteredInterpolation(X, Y, V, Xq, Yq) performs scattered
   % interpolation using the default method 'natural' and no extrapolation.
   %
   % [Vq] = scatteredInterpolation(_, method) performs scattered interpolation
   % using the specified method and no extrapolation.
   %
   % [Vq] = scatteredInterpolation(_, method, extrap) performs scattered
   % interpolation using the specified method and specified extrapolation
   % method.
   %
   % See also: scatteredInterpolant
   %
   % Note: scatteredInterpolant does not support "multivalued" interpolation,
   % meaning V has additional dimensions above X, Y, but the interpolant is
   % computed on X, Y, then applied to all values of V in the higher dimensions
   % (like a time series).

   % Input checks. validateGridData requires X,Y to form a recognized grid, but
   % scatteredInterpolant (and this wrapper) also handle genuinely scattered
   % (irregular) points. Branch on the detected format so irregular input gets a
   % lightweight column check instead of being rejected as an invalid grid.
   if ismember(mapGridFormat(X, Y), {'irregular', 'unstructured'})
      [V, X, Y] = validateScatteredData(V, X, Y, mfilename);
   else
      [V, X, Y] = validateGridData(V, X, Y, mfilename, 'V', 'X', 'Y');
   end

   % Set default method and extrapolation
   method = 'natural';
   extrap = 'none';

   % Update method and extrapolation if specified
   if nargin >= 6
      method = varargin{1};
      if nargin >= 7
         extrap = varargin{2};
      end
   end

   % https://www.mathworks.com/help/matlab/math/scattered-data-extrapolation.html
   % https://www.mathworks.com/help/matlab/math/interpolating-scattered-data.html#bspy6dx-1
   if strcmp(method, 'linear') && strcmp(extrap, 'nearest')
      warning(['"linear" interpolation and "nearest" extrapolation may ' ...
         'produce poor results due to discontinuity at the convex hull'])
   end

   % Initialize output
   Vq = nan(numel(Xq), size(V, 2));

   % Check for nan values
   inan = isnan(V);

   % Interpolate each column of V. The scattered interpolant's triangulation
   % depends only on the sample locations (X, Y), not the values, so it is built
   % once and reused across columns by reassigning F.Values rather than
   % reconstructing F (and its Delaunay triangulation) for every column.

   if ~any(inan(:))
      % No NaNs: all columns share the same sample locations, so a single
      % interpolant serves every column.
      F = scatteredInterpolant(X, Y, V(:, 1), method, extrap);
      Vq(:, 1) = F(Xq, Yq);
      for n = 2:size(V, 2)
         F.Values = V(:, n);
         Vq(:, n) = F(Xq, Yq);
      end

   else % interpolate over nans
      % With NaNs the sample set differs per column, but columns that share an
      % identical NaN mask share a triangulation. Group columns by their mask so
      % the interpolant is rebuilt only once per distinct mask, not per column.
      [~, ~, groupOfColumn] = unique(inan.', 'rows');
      for g = unique(groupOfColumn).'
         cols = find(groupOfColumn == g);
         m = inan(:, cols(1));

         % Build the interpolant once for this mask, then reuse it for the
         % remaining columns in the group by swapping only F.Values. Index by
         % position (2:numel(cols)) so a single-column group runs zero inner
         % iterations rather than one empty iteration.
         F = scatteredInterpolant(X(~m), Y(~m), V(~m, cols(1)), method, extrap);
         Vq(:, cols(1)) = F(Xq, Yq);
         for k = 2:numel(cols)
            F.Values = V(~m, cols(k));
            Vq(:, cols(k)) = F(Xq, Yq);
         end
      end
   end

   % Return as a column if interpolating to one point
   if isrow(Vq)
      Vq = Vq(:);
   end

   % F = ConstructPolyInterpolant2D(x,y,xq,yq,1,8);
end
