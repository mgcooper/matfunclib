function varargout = circle(x,y,r,varargin)
%CIRCLE create a circle centered on x,y with radius r
% 
% 
% See also mapbox

theta = linspace(0,2*pi);
xcirc = r*cos(theta)+x;
ycirc = r*sin(theta)+y;

switch nargout
   case 1
      hold on
      H = plot(xcirc,ycirc,varargin{:});
      varargout{1} = H;
      hold off
   case 2
      varargout{1} = xcirc;
      varargout{2} = ycirc;
      
   case 3
      varargout{1} = xcirc;
      varargout{2} = ycirc;
      withwarnoff('MATLAB:polyshape:repairedBySimplify');
      varargout{3} = polyshape(xcirc, ycirc, 'KeepCollinearPoints', true);
      
      % NOTE: polyshape vertices do not contain the collinear point which
      % "closes" the polygon, so if they are pulled out of P, this is needed:
      % [PX, PY] = closePolygonParts(PX, PY);
end

