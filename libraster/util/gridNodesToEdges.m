function [Xedges, Yedges] = gridNodesToEdges(X, Y)
%GRIDNODESTOEDGES Convert regular or uniform grid cell nodes to edges
%
% [Xedges, Yedges] = gridNodesToEdges(X, Y) returns the cell edges as
% coordinate arrays Xedges and Yedges, given the input X and Y grid vectors or
% coordinate arrays. 
%
% Input:
%   X, Y: Grid vectors or coordinate arrays representing the cell nodes.
%
% Output:
%   Xedges, Yedges: Coordinate arrays representing the cell edges.

% Convert grid vectors (or coordinate pair lists) to coordinate arrays
[X, Y, cellSizeX, cellSizeY, gridType] = prepareMapGrid(X,Y);

% If the grid type is irregular, raise an error
if gridType == "irregular"
   error('The input X,Y data are irregular. This function only supports regular and uniform grids.');
end

% Convert the X, Y coordinate arrays back to grid vectors
X = reshape(unique(X(:),'sorted'),1,[]);
Y = reshape(unique(Y(:),'sorted'),[],1);
X = [X-cellSizeX/2 X(end)+cellSizeX/2];
Y = [Y-cellSizeY/2; Y(end)+cellSizeY/2];
[Xedges,Yedges] = prepareMapGrid(X,Y);

% % Calculate the edge coordinates - this should work, and would be faster than
% the next method, but could be error prone
% Xedges = [X-cellSizeX/2, X(:,end)+cellSizeX/2];
% Xedges = [Xedges; Xedges(end,:)];
% Yedges = [Y+cellSizeY/2; Y(end,:)-cellSizeY/2];
% Yedges = [Yedges, Yedges(:,end)];

end
