function varargout = unionn(varargin)
   %UNIONN Union of n inputs.
   %
   % [varargout] = unionn(varargin)
   %
   % varargout{1} is the union vector
   % varargout{i>1} are the indices of the various varargin (in their order)
   %
   % See also: intersectn

   N = length(varargin);
   U = varargin{1};
   for n = 2:N
      U = union(U, varargin{n});
   end
   varargout = cell(1, nargin+1);
   varargout{1} = U;
   for n = 1:N
      [U, ~, varargout{n+1}] = union(U, varargin{n});
   end
end
