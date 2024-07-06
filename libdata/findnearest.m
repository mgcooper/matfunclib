function [val, idx] = findnearest(X, target, varargin)
   %FINDNEAREST find value in X nearest in magnitude to target value
   %
   %  Y = FINDNEAREST(X, TARGET)
   %  
   % Description
   %  Y = FINDNEAREST(X, 2) finds the value in X nearest 2
   %  Y = FINDNEAREST(T, datetime(2000, 1, 1)) finds the value in X nearest in
   %  time to 2000, 1, 1.
   %
   % Example
   %  X = datetime(2000,1,1,1:24,0,0);
   %  target = datetime(2000,1,1,12,0,0);
   %  [val, idx] = findnearest(X, target)
   %
   % val =
   %   datetime
   %    01-Jan-2000 12:00:00
   % idx =
   %     12
   %
   % Matt Cooper, 16-Feb-2023, https://github.com/mgcooper
   %
   % See also

   % parse inputs
   [X, target, n] = parseinputs(X, target, mfilename, varargin{:});

   % findnearest
   idx = find(min(abs(X-target))==abs(X-target),n,'first');
   val = X(idx);
end

%% parse inputs
function [X, target, n] = parseinputs(X, target, funcname, varargin)

   p = inputParser;
   p.FunctionName = funcname;
   p.CaseSensitive = false;
   p.KeepUnmatched = true;
   p.addRequired( 'X', @(x)isnumeric(x) | isdatetime(x));
   p.addRequired( 'target', @(x)isnumeric(x) | isdatetime(x));
   p.addOptional( 'n', 1, @(x)isnumericscalar(x));
   p.parse(X,target,varargin{:});

   X = p.Results.X;
   target = p.Results.target;
   n = p.Results.n;
end
