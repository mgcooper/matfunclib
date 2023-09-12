function [Xedges, Yedges] = gridNodesToEdges(X, Y, gridOption, varargin)
   %GRIDNODESTOEDGES Convert regular or uniform grid cell nodes to edges.
   %
   % [Xedges, Yedges] = gridNodesToEdges(X, Y) returns the cell edges as
   % coordinate arrays ("fullgrids") Xedges and Yedges, given the input X and Y
   % grid vectors or coordinate arrays.
   %
   % [Xedges, Yedges] = gridNodesToEdges(X, Y, gridOption) returns the cell
   % edges as coordinate arrays if gridOption is "fullgrids", or as grid vectors
   % if gridOption is "gridvectors".
   %
   % Input:
   %   X, Y: Grid vectors or coordinate arrays representing the cell nodes.
   %
   % Output:
   %   Xedges, Yedges: Coordinate arrays representing the cell edges.
   %
   % See also: gridCellCorners

   % Determine input grid format.
   gridFormat = mapGridFormat(X, Y);

   % If gridOption was not provided, use the input format.
   if nargin < 3 || isempty(gridOption)
      gridOption = gridFormat;
   end

   % Determine the gridType and cell size in the X and Y directions
   [gridType, cellSizeX, cellSizeY] = mapGridInfo(X, Y, gridFormat);

   % If the grid type is irregular, raise an error
   if gridType == "irregular"
      error(['The input X,Y data are irregular. ' ...
         'This function only supports regular and uniform grids.']);

   elseif gridType == "point"
      if nargin < 4
         error(['The input X,Y data are scalar. ' ...
            'This function requires cellsizex and cellsizey inputs.']);
      else
         cellSizeX = varargin{1};
         cellSizeY = varargin{2};
      end
   end

   % Convert the X, Y coordinate arrays back to grid vectors
   [X, Y] = gridvec(X, Y);

   X = [X-cellSizeX/2 X(end)+cellSizeX/2];
   Y = [Y(1)+cellSizeY/2; Y-cellSizeY/2];

   % Conver to the requested grid format
   [Xedges, Yedges] = prepareMapGrid(X, Y, gridOption);

   % For reference, before using gridvec, both were sorted in ascending order X
   % = reshape(unique(X(:),'sorted'),1,[]); 
   % Y = reshape(unique(Y(:),'sorted'),[],1); 
   % X = [X-cellSizeX/2 X(end)+cellSizeX/2]; 
   % Y = [Y-cellSizeY/2; Y(end)+cellSizeY/2];

   % % Calculate the edge coordinates - this should work, and would be faster
   % than the next method, but could be error prone 
   % Xedges = [X-cellSizeX/2, X(:,end)+cellSizeX/2]; 
   % Xedges = [Xedges; Xedges(end,:)]; 
   % Yedges = [Y+cellSizeY/2; Y(end,:)-cellSizeY/2]; 
   % Yedges = [Yedges, Yedges(:,end)];
end
