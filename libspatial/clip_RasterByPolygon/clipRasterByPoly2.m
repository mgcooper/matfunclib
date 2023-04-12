function [V,W,IN,ON,A,PA] = clipRasterByPoly2(V,X,Y,P,varargin)
%CLIPRASTERBYPOLY clip raster V with coordinates X,Y by poly P
%
%   This function clips a raster dataset (V) with X and Y coordinates by
%   a given polygon (P). It returns the clipped raster (V) and two sets of
%   indices (I and Ib) that represent the grid cells fully within the
%   polygon and those within the buffered polygon region, respectively.
%
%   Inputs:
%       V - Numeric raster data (variable)
%       X - Numeric X coordinates of the raster data
%       Y - Numeric Y coordinates of the raster data
%       P - Polyshape object representing the polygon
%
%   Optional Inputs:
%       'AggFunc' - Aggregation function to apply within the clipped region
%                   ('areasum', 'areaavg', 'sum', 'average', 'majority', 'none')
%       'GridType' - Type of grid ('structured', 'unstructured', 'gridvectors')
%       'CellSize' - Cell size of the raster (scalar or 2-element vector)
%       'CellInterpretation' - Interpretation of the raster cells ('cells')
%       'testplot' - Logical flag to enable/disable test plotting
%
%   Outputs:
%       V - Clipped raster dataset
%       IN - Indices of grid cells fully within the polygon
%       ON - Indices of grid cells within the buffered polygon region
%
%   Note: The function currently only supports 3D data for 'structured' grids.
%
%   TODO: Ensure the grid cells completely cover the polygon and implement
%         a method to fill in the gaps. Currently, the function just uses
%         the input grid as is.
%
% TODO: need to ensure the grid cells completely cover the polygon and if not, a
% method to fill in. it is easy to create a regular grid and use
% griddedInterpolant to fill in, but need to first determine the minimum
% bounding grid cells. For now, just use whatever is passed in

%% parse inputs

% % I should be able to do this:
[aggFunc,gridOption,cellInterpretation,testPlot,X,Y,V,cellSizeX,cellSizeY, ...
   gridType,tfGeoCoords] = parse_inputs(V,X,Y,P,mfilename,varargin{:});

% TODO
% - Check solid boundary orientation of P and set XV,YV etc. accordingly
% - compute the polyshapes for the cells all at once, use the polyshape
% initialization trick
% - for map rectangles, use rectint
% - for geo rectangles, use areaquad
% - test areaquad vs areaint for rectangular domain
% - clarify two bad cases: the raster does not cover all polygons, or visa versa
% - test kdtree (traverse polygon and find all points within
% norm([CellSizeX,CellSizeY])/2 ? )

% Question
% If we know we are dealing with grid cells, then for each node, if the
% shortest distance to the polygon is greater than norm(cellsizex,cellsizey)/2,
% do we know the pixel is fully contained within the polygon?

% Algorithm
% 1. Remove all cells entirely outside the polygon (minimum bounding box + buffer)
% 2. Find cells that contain the polygon boundary (inpolygon)
% 3. Find cells outside the polygon boundary (floodfill)
% 4. Find cells entirely within the polygon (boolean setdiff of 2,3)
% 5. Compute area of cells entirely within the polygon
% 6. Compute area overlap of cells on the polygon boundary

% The accuracy of areaint is inversely proportional to the distance between
% nodes, and accuracy appears low for modestly sized areas in geo coords, so it
% may not be I am not sure if there is a substitute for computing the area of
% each cell


% just a thought, if i knew the entry and exit point of the polygon and the
% grid cells, i could compute the polygon from the path and the vertices, pre

%% Prepare inputs

% Get the data size, then convert the grid arrays to lists of coordinate pairs
[nrows,ncols,nsteps] = size(V);
V = reshape(V,nrows*ncols,nsteps);
X = reshape(X,nrows*ncols,1);
Y = reshape(Y,nrows*ncols,1);
ncells = size(V,1);


% Get the polygon vertices
PX = P.Vertices(:,1);
PY = P.Vertices(:,2);


% Set the solid boundary orientation based on the polygon. This is used to
% construct grid cell polygons in the same orientation.
sbo = 'ccw';
if ispolycw(PX,PY)
   sbo = 'cw';
end

% For reference, if the SBO differs, can simply flipud (or fliplr)
% ispolycw(PX,PY)
% ispolycw(XV(1,:),YV(1,:))
% figure; plot(flipud(PX),flipud(PY))


% Compute the total polygon area
if tfGeoCoords == true

   % For geo coords, set the ellipsoid
   E = referenceEllipsoid('wgs84','meter');
   PA = sum(areaint(PY, PX, E)); % sqkm2sqmi(PA/1e6) m2->mi2

else

   PA = sum(area(P));

end

%% Case 1: naive clipping (no aggfunc)

% Clip the raster to the polygon boundary (naive method)
if aggFunc == "none"

   % For a simple clip, find grid centroids inside the polygon,
   % which splits the difference between (IN|ON) which extends
   % beyond the polygon, and IN, which does not extend to the
   % polygon boundary.

   % Use inpolygon to find grid centroids inside the polygon

   % Set grid cells outside the polygon nan
   V(~inpolygon(X,Y,PX,PY),:) = NaN;

   % Reshape V and IN to match the shape they were passed in as
   IN = reshape(inpolygon(X,Y,PX,PY),nrows,ncols);
   V = reshape(V,nrows,ncols,nsteps);

   % Return ON as scalar false
   ON = false;

   % Here we could compute polygon and grid total area
   [XV, YV] = gridCellCorners(X(IN), Y(IN), cellSizeX, cellSizeY, sbo);
   A = sum(arrayfun(@(n) areaint(YV(n, :), XV(n, :), E), 1:size(XV,1)));

   % Check: (A - PA) / PA

   %%%% This uses the IN,ON method

   % Set cells outside the polygon nan and return
   % V(~(IN|ON),:) = NaN;

   % Return V and I with the same shape they came in
   % I = reshape((IN|ON),nrows,ncols);
   % V = reshape(V,nrows,ncols,nsteps);


   return
end



%% Case 2: aggfunc

% Find grid cells IN (fully enclosed by) and ON the boundary of the polygon
[IN,ON] = enclosedGridCells(X, Y, PX, PY);

% plotMapGrid(X(ON),Y(ON)); hold on; plot(PX,PY)
% plot(X(IN),Y(IN),'o','MarkerFaceColor','k','MarkerEdgeColor','none')
% plot(X(ON),Y(ON),'o','MarkerFaceColor','m','MarkerEdgeColor','none')

% For projected coordinates, use cellSizeX,Y to compute area of IN cells
if tfGeoCoords == false

   AIN = cellSizeX * cellSizeY * ncells;

else

   % Corner vertices for cells IN the polygon interior
   [XV, YV] = gridCellCorners( X(IN), Y(IN), cellSizeX, cellSizeY, sbo );

   % Area of grid cells IN the polygon interior
   AIN = arrayfun( @(n) areaint(YV(n, :), XV(n, :), E), 1:size(XV,1) ) ;

   % Corner vertices for cells ON the polygon boundary
   [XV, YV] = gridCellCorners( X(ON), Y(ON), cellSizeX, cellSizeY, sbo );

   % Area of grid cells ON the polygon boundary
   % AON = arrayfun( @(n) areaint(YV(n, :), XV(n, :), E), 1:size(XV,1) );

   % Compute a polyshape for each grid cell ON the boundary
   % PON = arrayfun( @(n) polyshape(XV(n, :), YV(n, :)), (1:size(XV,1)) );

   % Get all intersections
   PB = intersect(P,arrayfun(@(n) polyshape(XV(n, :),YV(n, :)),1:size(XV,1)));

   % Area of intersections. The 2*ispolycw-1 multiplication accounts for holes.
   AON = arrayfun( ...
      @(n) sum( (2.*ispolycw(PB(n).Vertices(:,1),PB(n).Vertices(:,2))-1) .* ...
      areaint(PB(n).Vertices(:,2),PB(n).Vertices(:,1),E)), ...
      1:numel(PB) );
   
   % Interpolation weights
   W = double(IN);
   W(ON) = AON ./ arrayfun( @(n) areaint(YV(n, :), XV(n, :), E), 1:size(XV,1) );
   
   % Instead of 2*ispolycw-1, use geoarea
   % AON = arrayfun( ...
   %    @(n) sum( geoarea(PB(n).Vertices(:,2),PB(n).Vertices(:,1),E)), ...
   %    1:numel(PB) );
   
   % For reference, what the line above does:
   % AON = zeros(numel(PB),1);
   % for n = 1:numel(PB)
   %    AON(n) = sum(areaint(PB(n).Vertices(:,2),PB(n).Vertices(:,1),E));
   % end

   % compute the percent error
   % 100 * (sum(AON) + AIN - PA) / PA

   % plotMapGrid(X(ON),Y(ON)); hold on;
   % plot(PB);
   % plot(PX,PY,'r');
   % plot(X(IN),Y(IN),'o','MarkerFaceColor','k','MarkerEdgeColor','none')
   % plot(X(ON),Y(ON),'o','MarkerFaceColor','m','MarkerEdgeColor','none')
   % copygraphics(gcf)
  

end


% Warn if areas don't match to within 0.1%
A = sum(AON) + sum(AIN);
if abs(A-PA)/PA > 1e-3
   warning( ...
      'overlap area differs from total polygon area by %s %%',100*abs(A-PA)/PA)
end

if (lower(aggFunc)) == "weights"
   return
end

% apply the agg func
switch (lower(aggFunc))
   case ('areasum')
      V = sum(V(IN).*AIN(:),'omitnan') + sum(V(ON).*AON(:),'omitnan');
   case 'areaavg'
      V = (sum(V(IN).*AIN(:),'omitnan') + sum(V(ON).*AON(:),'omitnan')) / A;
   case 'sum'
      V = sum(V(IN),'omitnan');
   case 'average'
      V = mean(V(IN),'omitnan');
   case 'majority'
      V = mode(V(IN));
   otherwise
      error('Requested Operation is not recognized.')
end
V = squeeze(V);
% V = V+dA.*V;

% figure; scatter(X(I),Y(I),20,V(I),'filled'); hold on; plot(PX,PY)

% figure;
% plot(squeeze(sum(sum(V.*overlapArea./sum(overlapArea(:)),'omitnan'),'omitnan')))
% hold on; plot(squeeze(V(1,3,:)));

end


% PARSE INPUTS

function [AggFunc,GridOption,CellInterpretation,TestPlot,X,Y,V,CellSizeX, ...
   CellSizeY,GridType,tfGeoCoords] = parse_inputs(V,X,Y,P,funcname,varargin)
% PARSEINPUTS

% Validate required inputs

% Note that '3d' won't error on 2d input, and '2d' won't error on vector input.
% To support gridvectors, remove the X,Y size check

validateattributes(V,{'numeric'},{'3d','size',[size(X) NaN]},funcname,'V',1);
validateattributes(X,{'numeric'},{'2d','size',size(Y)},funcname,'X',2);
validateattributes(Y,{'numeric'},{'2d','size',size(X)},funcname,'Y',3);
validateattributes(P,{'polyshape'},{'nonempty'},funcname,'P',4);

% Validate optional inputs

validAggFuncs = ["areasum","areaavg","sum","average","majority","none","weights"];
validGridOpts = ["gridvectors","fullgrid"];
validCellTypes = ["cells","postings"];

validAggFuncs = @(x)~isempty(validatestring(x,validAggFuncs));
validGridOpts = @(x)~isempty(validatestring(x,validGridOpts));
validCellTypes = @(x)~isempty(validatestring(x,validCellTypes));
validCellSize = @(x) isnumeric(x) && isscalar(x);

% Set defaults

defaultAggFunc = "none";
defaultGridOpt = "fullgrid";
defaultCellType = "cells";
defaultCellSize = NaN;

% Create input parser

p = inputParser;
p.FunctionName = funcname;
p.addOptional( 'AggFunc', defaultAggFunc, validAggFuncs);
p.addParameter('CellSizeX', defaultCellSize, validCellSize);
p.addParameter('CellSizeY', defaultCellSize, validCellSize);
p.addParameter('GridOption', defaultGridOpt, validGridOpts);
p.addParameter('CellInterpretation',defaultCellType, validCellTypes);
p.addParameter('TestPlot', false, @(x)islogical(x));

% Parse inputs

p.parse(varargin{:});
AggFunc = p.Results.AggFunc;
TestPlot = p.Results.TestPlot;
CellSizeX = p.Results.CellSizeX;
CellSizeY = p.Results.CellSizeY;
GridOption = p.Results.GridOption;
CellInterpretation = p.Results.CellInterpretation;


% PROCESS INPUTS


% If P is not a polyshape, create one (P is a 2-column matrix of X,Y coords)
if ~isa(P,'polyshape')
   P = polyshape(P,'Simplify',true,'KeepCollinearPoints',false);
end


% If the input X,Y coordinates are grid vectors, convert them to full grids
if GridOption == "gridvectors"

   % Check if the full grid has the same size as V. If not, then regrid V onto
   % the full grid representation of X,Y.

   if numel(X) * numel(Y) == numel(V)

      % Do nothing (assume [X,Y] = meshgrid(X,Y) produces full grids X,Y that
      % are the same size as V and represent the coordinate arrays for V)
   else

      % Regrid V onto the full grids
      F = griddedInterpolant({X,Y},V,'nearest','linear');
      V = F(X,Y);
   end
end


% Get the grid info and confirm the provided CellSize matches the inferred ones
if isnan(CellSizeX) || isnan(CellSizeY)

   [X,Y,CellSizeX,CellSizeY,GridType,tfGeoCoords] = prepareMapGrid(X,Y);

else

   [X,Y,CheckSizeX,CheckSizeY,GridType,tfGeoCoords] = prepareMapGrid(X,Y);

   assert(CellSizeY == CheckSizeY);
   assert(CellSizeX == CheckSizeX);

end


if GridType == "irregular"

   % If the grid type is irregular, raise an error
   error('The input X,Y data are irregular. This function only supports regular and uniform grids.');

end



% % TODO: check if the raster covers all polygons, and visa versa

% % Step 1: Buffer the polygon to ensure it encloses all cells. NOTE: This is not
% % a compatibility check, this is a first step in finding all cells within the
% % polygon, to ensure the centroids + edges are within the polygon. I am not sure
% % this is needed with the new method that finds cells containing the polygon
% % edge. Instead, the minimum bounding box of the polygon +/- the grid cell size
% % is used to reduce the search space of grid cells in the enclosedGridCells
% % function, which is the same thing as the polybuffer step below but faster

% % This buffers the polygon to ensure it encloses all grid cells
% B = polybuffer(P,norm([CellSizeX,CellSizeY])/2);
% inB = inpolygon(X,Y,B.Vertices(:,1),B.Vertices(:,2));

% % This checks if the grid cells' minimum bounding box encloses the polygon.
% % Note that we might not want to exclude this case - if the grid cell domain is
% % smaller than the polygon, we could still return the polygon values for the
% % raster cells, but that should probably be in a different function.
% bboxcells = centroid2box(X,Y,cellsizeX,cellsizeY);
% figure; plot(bboxcells); hold on; plot(X(:),Y(:),'o');

% % This creates a box that bounds the grid (same thing as centroid2box, but
% % with the logical inB check)
% xmin = min(X(:))-CellSizeX/2;
% xmax = max(X(:))+CellSizeX/2;
% ymin = min(Y(:))-CellSizeY/2;
% ymax = max(Y(:))+CellSizeY/2;
%
% tic
% inB = ...
%    (X >= min(X(:))-CellSizeX/2) & ...
%    (X <= max(X(:))+CellSizeX/2) & ...
%    (Y >= min(Y(:))-CellSizeY/2) & ...
%    (Y <= max(Y(:))+CellSizeY/2);
% toc
%
% This creates a box that bounds the polygon
% tic
% inB = ...
%    (X >= min(B.Vertices(:,1))-CellSizeX/2) & ...
%    (X <= max(B.Vertices(:,1))+CellSizeX/2) & ...
%    (Y >= min(B.Vertices(:,2))-CellSizeY/2) & ...
%    (Y <= max(B.Vertices(:,2))+CellSizeY/2);
% toc
% This (probably) shows that polyshape is slower
% tic
% GB = polyshape([xmin, xmax, xmax, xmin, xmin],[ymin ymin ymax ymax ymin]);
% inB = inpolygon(B.Vertices(:,1),B.Vertices(:,2),GB.Vertices(:,1),GB.Vertices(:,2))
% toc
%
% figure; plot(B); hold on; plot(B2); plot(X(:),Y(:),'o');
% plot([xmin,xmin],[ymin,ymax],'-k')
%
% enclosed = enclosedGridCells(X, Y, P.Vertices(:,1), P.Vertices(:,2));

end

%% Notes on unstructured grids

% % just putting this here
% if GridType == "unstructured"
%
%    % I think what I tried to do here was convert unstructured to structured.
%    % First use the unstructured X,Y and use meshgrid to grid them, which
%    % produces lots of grid coordinates with no V values. Then interpolate onto
%    % the regular grid to fill in the missing coordinates. But, this is clearly
%    % not conservative, and seems like it must have been a temporary shortcut to
%    % avoid finding the area of the unsstructured grid cells, or the full
%    % coordinate list of the unstructured cells, which could then be treated in
%    % the same manner as the
%
%    xvec = X; yvec = Y;
%    [X,Y] = meshgrid(unique(X,'sorted'),unique(Y,'sorted'));
%
%    % scatteredInterpolation requires looping over all timsteps, but is still
%    % faster than the insertrows / reshape to grid method below b/c
%    % griddedInterpolant does not inpaint nans
%    V = scatteredInterpolation(xvec,yvec,V,X(:),Y(:),'nearest','linear');
%
%    % this converts V to a regular grid and inserts nan in the missing locations
%    % notok = ~ismember([X(:),Y(:)],[xvec yvec],'rows');
%    % V = insertrows(V,nan(sum(notok),size(V,3)),find(notok)-1);
%    % V = reshape(V,size(X,1),size(X,2),size(V,2));
%    % V = fillmissing(V,'linear');
%
%    %I cannot get griddedInterpolant to fill the missing value. I am not sure if
%    %fillmissing is faster than looping with scatteredInterpolant
%    %F = griddedInterpolant(X',Y',pagetranspose(V),'spline','spline');
%    %V = F(X,Y);
%
% % elseif GridType == "gridvectors"
% %    F = griddedInterpolant({X,Y},V,'nearest','linear');
% %    V = F(X,Y);
% end

%% Notes on first method
% % calculate the bounding box of the polygon
% boundingBox=[min(PLat), min(PLon); max(PLat), max(PLon)];
%
% % calculate the bounding box indices
% boundingBoxIDX=[...
%    find(RLat>=boundingBox(2,1),1,'last'),  ...
%    find(RLon<=boundingBox(1,2),1,'last');  ...
%    find(RLat<=boundingBox(1,1),1,'first'), ...
%    find(RLon>=boundingBox(2,2),1,'first')];
%
% % calculate the bounding box of the raster
% boundingBoxRaster=[...
%    RLat(boundingBoxIDX(1,1)),RLon(boundingBoxIDX(1,2)); ...
%    RLat(boundingBoxIDX(2,1)),RLon(boundingBoxIDX(2,2))];

% %% test plots
% if testplot == true
%    figure; plot(X,Y,'o'); hold on; plot(PX,PY);
%    plotBbox(fliplr(boundingBox));
%    plotBbox(fliplr(boundingBoxRaster));
% end

% % if we don't do the RasterRef cellsize check, and if X/Y are grid vectors,
% then this should work
%       cellLat=[...
%          Y(n)+(Y(n+1)-Y(n))/2; ...
%          Y(n)+(Y(n+1)-Y(n))/2; ...
%          Y(n)-(Y(n+1)-Y(n))/2; ...
%          Y(n)-(Y(n+1)-Y(n))/2];
%       cellLon=[...
%          X(n)-(X(n+1)-X(n))/2; ...
%          X(n)+(X(n+1)-X(n))/2; ...
%          X(n)+(X(n+1)-X(n))/2; ...
%          X(n)-(X(n+1)-X(n))/2];


%       % if X/Y are arrays (or gridvectors converted to arrays), this should work
%       cellX=[...
%          X(n)-cellsizeX/2; ...
%          X(n)+cellsizeX/2; ...
%          X(n)+cellsizeX/2; ...
%          X(n)-cellsizeX/2];
%       cellY=[...
%          Y(n)+cellsizeY/2; ...
%          Y(n)+cellsizeY/2; ...
%          Y(n)-cellsizeY/2; ...
%          Y(n)-cellsizeY/2];


% if isnan(cellsizeX) || isnan(cellsizeY)
%    % if cellsize is not provided and the raster is unstructured (meaning a list
%    % of values and corresponding x,y coordinates), then it is difficult to
%    % determine the cell size, so maybe issue a warning? Or, try gridding the
%    % vectors and setting missing grid points nan?
%    if GridType == "unstructured"
% %       xvec = X; yvec = Y;
% %       [X,Y] = meshgrid(unique(X,'sorted'),unique(Y,'sorted'));
% %       notok = ismember([X(:),Y(:)],[xvec yvec],'rows');
% %       % can I convert V to a regular grid and insert nan in the missing indices?
%    else
%       try
%          [X,Y,cellsize,tflatlon] = prepareMapGrid(X,Y);
%       catch ME
%          % if prepareMapGrid fails, this should too, but leaving it for now
%
%       end
%    end
% else
%    if GridType == "regular"
%       %[X,Y,checkX,checkY,tf,tol] = prepareMapGrid(X,Y);
%       %if checkX ~= cellsizeX || checkY ~= cellsizeY
%       %   error('provided cell sizes do not match grid cell sizes')
%       %end
%    elseif GridType == "unstructured"
%    end
% end
