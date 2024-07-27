function TF = notall(X, varargin)
   %NOTALL return TRUE if ~all(X) is TRUE
   %
   %  TF = notall(X)
   %  TF = notall(X, 'all')
   %  TF = notall(X, dim)
   %  TF = notall(X, vecdim)
   %
   % See also: none notempty notequal
   TF = ~all(X, varargin{:});
end
