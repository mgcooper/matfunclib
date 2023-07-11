function [IN, ON] = enclosedGridCells(X, Y, PX, PY)
%ENCLOSEDGRIDCELLS Find cells enclosed within a polygon and cells that contain
%the boundary of the polygon.
%
% [IN, ON] = enclosedGridCells(X, Y, PX, PY) returns a logical array IN of the
% same size as X and Y, with true values for the grid cells that are entirely
% enclosed within the polygon defined by the x-y coordinate lists PX and PY, and
% a logical array ON the same size as X and Y, with true values for the grid
% cells that contain the boundary of the polygon, which are those grid cells
% that are partially enclosed by the polygon.
%
% Input:
%   X, Y        - Column vectors or 2D arrays of grid centroid coordinates
%   PX, PY      - Column vectors of polygon vertex coordinates
%
% Output:
%   IN          - Logical array (same size as X, Y) with true values for
%                 the grid cells that are entirely enclosed within the polygon
%
%   ON          - Logical array (same size as X, Y) with true values for
%                 the grid cells that contain the boundary of the polygon
%
% Example:
%   [IN, ON] = enclosedGridCells(X, Y, PX, PY);
%
%
% See also

% Debug plot
debug = false;


% Get the cell sizes
[CellSizeX, CellSizeY, gridType] = mapGridCellSize(X, Y);
% [CellSizeX, CellSizeY, gridType] = mapGridCellSize(unique(X), unique(Y));


if gridType == "irregular"
   % decide how to handle this
   % CellSizeX = max(CellSizeX);
   % CellSizeY = max(CellSizeY);
end


% Reduce the cell-search space by finding cells inside a minimum bounding box
IB = ...
   (X >= min(PX)-median(abs(CellSizeX))/2) & ...
   (X <= max(PX)+median(abs(CellSizeX))/2) & ...
   (Y >= min(PY)-median(abs(CellSizeY))/2) & ...
   (Y <= max(PY)+median(abs(CellSizeY))/2) ;

% For unstructured grids, need to subset cellsize again
if numel(CellSizeX) > 1
   CellSizeX = CellSizeX(IB);
   CellSizeY = CellSizeY(IB);
end


% Get fully and partially enclosed cells
[in,on] = getEnclosedCells(X(IB),Y(IB),CellSizeX,CellSizeY,PX,PY);


% Initialize IN and ON to the same size as input X and Y. This is compatible
% with both 1D and 2D input arrays. 
IN = false(size(X));
ON = false(size(X));
IN(IB) = in(:);
ON(IB) = on(:);


% Plot the result
if debug == true
   % plotMapGrid(X(IB),Y(IB)); hold on; plot(PX,PY)
   figure;
   plotMapGrid(X(ON),Y(ON)); hold on; plot(PX,PY)
   plot(X(ON), Y(ON), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'none');
   plot(X(IN), Y(IN), 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'none');

end

end


%%
function [IN, ON] = getEnclosedCells(X, Y, cellSizeX, cellSizeY, PX, PY)
%GETENCLOSEDCELLS Determine which grid cells are fully enclosed within a polygon
% and which cells contain the boundary of the polygon.
%
%   [IN, ON] = GETENCLOSEDCELLS(X, Y, cellSizeX, cellSizeY, PX, PY)
%
%   Input:
%       X, Y        - Grid centroid coordinates (1D arrays)
%       cellSizeX   - Cell size in the X direction
%       cellSizeY   - Cell size in the Y direction
%       PX, PY      - Polygon vertices coordinates (column vectors)
%
%   Output:
%       IN          - Logical 1D array (same size as X, Y) with true values for
%                     the grid cells that are fully enclosed within the polygon
%       ON          - Logical 1D array (same size as X, Y) with true values for
%                     the grid cells that contain the boundary of the polygon
%
% Note: This subfunction is called within the enclosedGridCells function.
%
% TODO:
%   For lat/lon, check if the coords cross the Antimeridian or contain a pole
%   (which means the longitude data spans 360 deg)

% Calculate the coordinates of the 4 corner vertices for each cell
[XV, YV] = gridCellCorners(X, Y, cellSizeX, cellSizeY);

% Find grid cells that contain a polygon vertex (grid cells on the boundary)
ON = arrayfun(@(n) any(inpolygon(PX, PY, XV(n, :), YV(n, :))), 1:numel(X));

% Fill in the interior of the polygon using the flood fill algorithm
IN = floodFillExterior(reshape(ON, numel(unique(Y)), numel(unique(X))), 1, 1);

% Set the boundary cells false
IN(ON) = false;

end


function filled = floodFillExterior(binaryImage, startX, startY)
%FLOODFILLEXTERIOR Fill the exterior region of a binary image.
%
%   filled = FLOODFILLEXTERIOR(binaryImage, startX, startY) fills the
%   exterior region of a binary image using a flood-fill algorithm. The
%   filling starts from the specified point (startX, startY). The output
%   'filled' is a binary image of the same size as the input 'binaryImage',
%   with the exterior region filled (set to true) and the interior region
%   unchanged.
%
%   Input arguments:
%   - binaryImage: A binary image with the region of interest set to true.
%   - startX, startY: The starting point (row and column indices) for the
%                     flood-fill algorithm.
%
%   Output:
%   - filled: A binary image with the exterior region filled.
%
%   Example:
%   binaryImage = [0 0 0 0;
%                  0 1 1 0;
%                  0 1 1 0;
%                  0 0 0 0];
%   startX = 1;
%   startY = 1;
%   filled = floodFillExterior(binaryImage, startX, startY);
%
%   The output 'filled' will be:
%   [1 1 1 1;
%    1 0 0 1;
%    1 0 0 1;
%    1 1 1 1]

paddedImage = padarray(binaryImage, [1 1], false, 'both');
filled = paddedImage;
[rows, cols] = size(paddedImage);
N = rows * cols;

if startX < 1 || startX > rows || startY < 1 || startY > cols
   return;
end

startIdx = sub2ind(size(paddedImage), startX, startY);
if paddedImage(startIdx) == true
   return;
end

deque = zeros(1, N, 'uint32');
deque(1) = startIdx;
dequeIdx = 1;
dequeEnd = 1;

neighbors = [-1, 1, -rows, rows];

while dequeIdx <= dequeEnd
   idx = deque(dequeIdx);
   dequeIdx = dequeIdx + 1;

   if filled(idx) == false
      filled(idx) = true;

      for neighborOffset = neighbors
         neighborIdx = idx + neighborOffset;
         if neighborIdx > 0 && neighborIdx <= N
            dequeEnd = dequeEnd + 1;
            deque(dequeEnd) = neighborIdx;
         end
      end
   end
end

filled = ~filled;
filled = filled(2:end-1, 2:end-1); % Remove padding
end

