function assertWithRelTol(returned, expected, relTol, varargin)
   %ASSERTWITHABSTOL assert equality within a relative tolerance.
   %
   %  assertWithRelTol(returned, expected) uses relTol = 0.1%
   %  assertWithRelTol(returned, expected, relTol)
   %  assertWithRelTol(returned, expected, relTol, msg)
   %
   % Helper function to assert equality within a relative tolerance.
   % Takes two values and an optional message and compares
   % them within a relative tolerance of 0.1%.
   %
   % See also: assertEqual assertError assertSuccess assertWithAbsTol

   if nargin < 3 || isempty(relTol), relTol = 0.001; end

   tf = abs(expected - returned) <= relTol * abs(expected);
   assert(all(tf), varargin{:});
end
