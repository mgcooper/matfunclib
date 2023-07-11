function [XV, YV] = gridCellCorners(X, Y, cellSizeX, cellSizeY, Orientation)

if nargin == 4
   Orientation = 'cw';
end

% to support gridvecs, would need to check then create the grid with fastgrid

switch Orientation
      
   case 'cw'

      % This produces cw solid boundary orientation
      XV = bsxfun(@plus, X(:), [-cellSizeX, -cellSizeX, cellSizeX, cellSizeX]/2);
      YV = bsxfun(@plus, Y(:), [-cellSizeY, cellSizeY, cellSizeY, -cellSizeY]/2);
      
   case 'ccw'
      
      % This produces ccw solid boundary orientation
      XV = bsxfun(@plus, X(:), [-cellSizeX, cellSizeX, cellSizeX, -cellSizeX]/2);
      YV = bsxfun(@plus, Y(:), [-cellSizeY, -cellSizeY, cellSizeY, cellSizeY]/2);

      % Test if adding an additional vertex changes the behavior of subsequent
      % Matlab computational geometry methods (appears it doesn't - if 'ccw' is
      % used here, polyshape(XV,YV) will produce a 'cw' orientation, so the
      % default orientation used here is 'cw'.
      
      % Xcorners = bsxfun(@plus, X(:), [-cellSizeX, cellSizeX, cellSizeX, -cellSizeX -cellSizeX]/2);
      % Ycorners = bsxfun(@plus, Y(:), [-cellSizeY, -cellSizeY, cellSizeY, cellSizeY, -cellSizeY]/2);
end

% % NOTES ON SOLID BOUNDARY ORIENTATION
% matlab:
% automatically determined based on boundary nesting
% can be set using 'SolidBoundaryOrientation' property
% 
% inpolygons :
% polygons = clockwise, holes = counter
% 
% exactextractr:
% polygons = counter, holes = clockwise
% 
% clipRasterByPoly:
% 
% 

% % old method
% Xedges = [unique(X(:))-CellSizeX/2, unique(X(:))+CellSizeX/2];
% Yedges = [unique(Y(:))-CellSizeY/2, unique(Y(:))+CellSizeY/2];
% 
% % Create arrays of the cell corners
% [Xcorners,Ycorners] = meshgrid(Xedges(:),Yedges(:));