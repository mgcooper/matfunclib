function varargout = centroid2box(xc,yc,xres,yres)

xbox=[...
   min(xc(:))-xres/2; ...    % lower left
   max(xc(:))+xres/2; ...    % lower right
   max(xc(:))+xres/2; ...    % upper right
   min(xc(:))-xres/2; ...    % upper left 
   min(xc(:))-xres/2];       % lower left

ybox=[...
   min(yc(:))-yres/2; ...    % lower left
   min(yc(:))-yres/2; ...    % lower right
   max(yc(:))+yres/2; ...    % upper right
   max(yc(:))+yres/2; ...    % upper left
   min(yc(:))-yres/2];       % lower left

switch nargout
   case 1
      varargout{1} = polyshape(xbox,ybox);
   case 2
      varargout{1} = xbox;
      varargout{2} = ybox;
end
