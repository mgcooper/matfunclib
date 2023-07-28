function V = naninterp2(X,Y,V,method,extrap)
%NANINTERP2 2-d interpolation over NaN values in vector V on coordinates X, Y
%
%   Vq = NANINTERP2(X, Y, V) interpolates to find Vq, the values of the
%   underlying function V=F(X) at the query points Xq, Yq which are the values
%   of X, Y where V is nan.
% 
%   Note: libraster/scatteredInterpolation is recommended over this function.
% 
% Matt Cooper, 29 Dec 2022, https://github.com/mgcooper
% 
% See also: interp2, naninterp1, interp1, scatteredInterpolation

% User note: interp2 expects meshgrid format.

% interp2 valid methods: ["linear", "nearest", "cubic", "makima", "spline"]
% griddata valid methods: ["linear", "nearest", "natural", "cubic", "v4"]
% scatteredInterpolant valid methods: ["linear", "nearest", "natural"]

withwarnoff('MATLAB:interp2:NaNstrip');

% This input parsing is valid for interp2, but if a different method is used
% such as griddata or scatteredInterpolant, different parsing will be needed

% Update: I think this needs to be rewritten. I think extrap has to be true for
% the nans to be filled. But I have not tested this when the missing value is in
% the middle of the array, so until then, keep the extrap = NaN.

% Input checks
[X, Y, V] = validateGridData(X, Y, V, mfilename, 'X', 'Y', 'V');

% Parse input
if nargin == 1
   if isvector(V)
      error('If V is a vector, X and Y must be supplied')
      
      % For reference, this does not work:
      % X = reshape(linspace(0, 1, numel(V)), size(V,1), []);
      % Y = X;
   else
      [Yq, Xq] = find(isnan(V));
      V(isnan(V)) = interp2(V, Xq, Yq, 'makima');
      return
      
      % For reference, this does not work b/c X(isnan(V)), Y(isnan(V)) is not
      % the correct indexing when using X=1:n, Y=1:m, instead if V is a vector,
      % must use the syntax interp2(V, Xq, Yq, method);
      
      % [m, n] = size(V);
      % X = 1:n;
      % Y = 1:m;
      
      % This does not work for the same reason, but is here for reference to
      % remember that the default grid is 1:n, 1:m not 0-1, 0-1.
      % X = linspace(0, 1, size(V,2));
      % Y = linspace(0, 1, size(V,1));
   end
   
elseif nargin == 2
   error('unrecognized input')
elseif nargin == 3 % NANINTERP2(X,Y,V)
   method = 'makima';
   extrap = NaN;
elseif nargin == 4 % NANINTERP2(X,Y,V,method)
   extrap = NaN;
elseif nargin == 5 
   if strcmp(extrap, 'extrap') % NANINTERP2(X,Y,V,method,'extrap')  
      validatestring(method, {'spline', 'makima'}, mfilename, 'method', 4);
   else % NANINTERP2(X,Y,V,method,extrapval)
      validateattributes(extrap, {'numeric'}, {'scalar'}, mfilename, 'extrapval', 5);
   end
end

%% interp2

% interp2 can operate on a grid like griddedInterpolant which needs all X,Y
% values, or on scattered data like scatteredInterpolant, but the results seem
% to differ esp. the errors that occur e.g. when nan values lie near the
% boundary. 
      
inan = isnan(V);
for n = 1:size(V, 2)

   m = inan(:, n);

   if all( V(:, n) == 0 | m ) % all zero or nan
      V(m, n) = 0;

   else
      try
         % This is the method that was working, not sure what changed
         % V(m, n) = interp2(X, Y, V(:, n), X(m), Y(m), method);

         % This only uses non-nan values, also fails sometimes unexpectedly
         V(m, n) = interp2(X(~m), Y(~m), V(~m, n), X(m), Y(m), method);

      catch e

         % % use this to check the data for this timestep
         % figure; scatter(X(~m), Y(~m), 50, V(~m, n), 'filled'); hold on;
         % scatter(X(m), Y(m), 50, 'k', 'filled');

         % I think this means the nan point(s) lie on the boundary
         if strcmp(e.message, 'Interpolation requires at least two sample points for each grid dimension.')

            % With scatteredInterpolant, all methods extrapolate
            F = scatteredInterpolant(X(~m), Y(~m), V(~m, n), 'natural');
            V(m, n) = F(X(m), Y(m));

            % With griddata, only v4 will extrapolate
            % V(m, n) = griddata(X(~m), Y(~m), V(~m, n), X(m), Y(m), 'v4');
         else
            rethrow(e)
         end
      end
   end
end
