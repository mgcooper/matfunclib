function assertWithAbsTol(returned, expected, tol, varargin)
   %ASSERTWITHABSTOL assert equality within an absolute tolerance.
   %
   % assertWithAbsTol(returned, expected) uses tol = 1e-6
   % assertWithAbsTol(returned, expected, tol)
   % assertWithAbsTol(returned, expected, tol, msg)
   %
   % Helper function to assert equality within an absolute tolerance.
   % Takes two values and an optional message and compares
   % them within an absolute tolerance of 1e-6.

   if nargin < 4 || isempty(tol), tol = 1e-6; end
   tf = abs(returned-expected) <= tol;
   assert(tf, varargin{:});
end