function resultfcn = fifelse(condfcn, thenfcn, elsefcn, varargin)
%FIFELSE Functional inline if-else-then statement.
%
%    y = fifelse(@condfcn, @thenFcn, @elseFcn, ...)
%
% See also ifelse

arguments
   condfcn (1,1) function_handle
   thenfcn (1,1) function_handle
   elsefcn (1,1) function_handle
end

arguments (Repeating)
   varargin
end

if condfcn(varargin{:})
   resultfcn = thenfcn(varargin{:});
else
   resultfcn = elsefcn(varargin{:});
end