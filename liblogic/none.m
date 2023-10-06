function TF = none(X, varargin)
   %NONE Determine whether all elements of logical array X are false
   %
   %  TF = NONE(X) returns true if ~any(X) is true, false if any(X) is false
   %
   % Example
   %
   %
   % Matt Cooper, 30-Jan-2023, https://github.com/mgcooper
   %
   % See also any, isempty, notempty

   TF = ~any(X, varargin{:});
end
