function varargout = testhistogram(X, varargin)
   H = histogram(X(:), varargin{:});
   if nargout == 1
      varargout{1} = H;
   end
end