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

   % Input checks
   [V, X, Y] = validateGridData(V, X, Y, mfilename, 'V', 'X', 'Y');

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

   % Perform interpolation for each column of v

   if sum(inan) == 0
      for n = 1:size(V, 2)
         F = scatteredInterpolant(X, Y, V(:, n), method, extrap);
         Vq(:, n) = F(Xq, Yq);
      end

   else % interpolate over nans
      for n = 1:size(V, 2)
         m = inan(:, n);

         F = scatteredInterpolant(X(~m), Y(~m), V(~m, n), method, extrap);
         Vq(:, n) = F(Xq, Yq);

         % % Might need an intermediate step
         % F = scatteredInterpolant(x, y, v(:, n), method, extrap);
         % Vq(:, n) = F(xq, yq);
      end
   end

   % Return as a column if interpolating to one point
   if isrow(Vq)
      Vq = Vq(:);
   end

   % F = ConstructPolyInterpolant2D(x,y,xq,yq,1,8);
end
