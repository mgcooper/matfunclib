function varargout = xylabel(xlab,ylab,varargin)
%XYLABEL wrapper to plot both labels with one command
% 
% xylabel('xlabel','ylabel')
% 
% See also

h(1) = xlabel(xlab,varargin{:});
h(2) = ylabel(ylab,varargin{:});

switch nargout
   case 0
   case 1
      varargout{1} = h;
   otherwise
      error('unrecognized number of outputs')
end
