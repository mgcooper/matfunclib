function [X,Y,cellsizeX,cellsizeY,tfgeo,tfreg,tol] = prepareMapGrid(X,Y,varargin)

% determine if the input vectors (or grids) are regular and/or geographic/planar
[tfreg,tfgeo,tol] = isxyregular(x,y,varargin);
if ~tfreg
   error('X,Y data are irregular')
end

% set the regular or unstructured grid type
GridType = "regular";
if nargin > 2
   GridType = varargin{1};
end

% if unstructured, we just need the cellsize
if GridType == "unstructured"
   cellsizeX = abs(X(2)-X(1));
   cellsizeY = abs(Y(2)-Y(1));
   return
end

% if x,y are 1-d vectors, build a 2-d grid. E-W/N-S orientation is handled below
if isvector(X) && isvector(Y)
   [X,Y] = meshgrid(unique(X,'sorted'),unique(Y,'sorted'));
end

% ensure the X,Y arrays are oriented W-E and N-S
[X,Y] = orientmapgrid(X,Y);

% get the cell size in the x and y directions
cellsize = mapgridcellsize(X,Y);

% % determine if the data are planar or geographic
% tf = islatlon(Y(1,1),X(1,1));


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% this was after the mesh grid part
% % This was in a duplicate version of rasterref saved in rasterize/util
% which i deleted. I think we want this in the function but since i am not
% 100% sure I commented it out for now:
% % NEW Nov 2021, wrap to 360 to make it easier to check inputs
% % determine if the data are planar or geographic (moved here from
% tf = islatlon(Y(1,1),X(1,1));
% if tf == true
%     X =  wrapTo360(X); % this is used to check uniform gridding
% end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %