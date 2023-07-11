function varargout = xylabel(xlabelstring,ylabelstring,varargin)
%XYLABEL place xlabel and ylabel with one command
% 
% xylabel('xlabel','ylabel')
% 
% See also

h(1) = xlabel(xlabelstring,varargin{:});
h(2) = ylabel(ylabelstring,varargin{:});

switch nargout
   case 0
   case 1
      varargout{1} = h;
   otherwise
      error('unrecognized number of outputs')
end
