function X = ndhelper(fn, X, dim)
   %NDHELPER Run a function for columns of a matrix on any nd-array
   %
   % Usage:
   %     X = ndhelper(fn, X[, dim])
   %
   % fn should take a matrix and *always* perform its operation on the columns,
   % that is run along dim=1.
   %
   % NDHELPER calls fn so that the operation is applied along dimension dim. If
   % dim is unspecified, the first non-singleton dimension is used. This
   % behavior is pervasive in Matlab-land. This routine lets your write simple
   % code that can assume 2D arrays and only runs along the first dimension. You
   % can then create a wrapper that passes the simple routine to NDHELPER,
   % providing an interface in the style of Matlab's standard library routines.
   %
   % A common problem is making the behavior of a function sensible on empty
   % arrays. In some circumstances it will be easier to make the wrapper deal
   % with these cases separately rather than getting NDHELPER to do the right
   % thing.
   %
   % Coding advice: if X is a matrix or other ND-array, always specify dim to
   % avoid bugs. If you know that X is always a vector then the Matlab style
   % means you don't have to specify dim, which makes supporting vectors that
   % could be either way around easier.

   % Iain Murray, November 2008, September 2010

   if ~exist('dim', 'var')
      dim = find(size(X)~=1, 1); % first non-singleton dimension (can be zero)
      if isempty(dim)
         dim = 2; % For histc Matlab sets to 2.
      end
   end

   % Arrange into a matrix for fn()
   nd = max(dim, ndims(X));
   if (nd > 2) || (dim ~= 1)
      perm = [dim:nd 1:(dim-1)];
      % The Matlab help explicitly suggests using shiftdim, but I couldn't cover
      % all cases correctly with that alone, so I went for permute/ipermute.
      X = permute(X, perm);
      sz = size(X);
      X = reshape(X, sz(1), prod(sz(2:end)));
   end

   X = fn(X);

   % Turn back into an ND-array.
   if (nd > 2) || (dim ~= 1)
      sz(1) = size(X, 1);
      X = reshape(X, sz);
      X = ipermute(X, perm);
   end
end
