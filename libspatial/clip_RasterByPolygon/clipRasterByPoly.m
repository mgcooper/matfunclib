function [Z,I,ON] = clipRasterByPoly(Z,X,Y,P,varargin)
%CLIPRASTERBYPOLY clip raster Z with coordinates X,Y by poly P
%
%   This function clips a raster dataset (Z) with X and Y coordinates by
%   a given polygon (P). It returns the clipped raster (Z) and two sets of
%   indices (I and Ib) that represent the grid cells fully within the
%   polygon and those within the buffered polygon region, respectively.
%
%   Inputs:
%       Z - Numeric raster dataset
%       X - Numeric X coordinates of the raster dataset
%       Y - Numeric Y coordinates of the raster dataset
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
%       Z - Clipped raster dataset
%       I - Indices of grid cells fully within the polygon
%       Ib - Indices of grid cells within the buffered polygon region
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
[AggFunc,CellSizeX,CellSizeY,GridOption,CellInterpretation,TestPlot] = ...
   parse_inputs(Z,X,Y,P,mfilename,varargin{:});

% TODO
% - compute the polyshapes for the cells all at once, use the polyshape
% initialization trick
% - 

%% Process inputs

% If the input X,Y coordinates are grid vectors, convert them to full grids
if GridOption == "gridvectors"
   
   % Check if the full grid has the same size as Z. If not, then regrid Z onto
   % the full grid representation of X,Y. 
   
   if numel(X) * numel(Y) == numel(Z)
      % Do nothing (assume [X,Y] = meshgrid(X,Y) produces full grids X,Y that
      % are the same size as Z and represent the coordinate arrays for Z)
   else
      % regrid Z onto the full grids
      F = griddedInterpolant({X,Y},Z,'nearest','linear');
      Z = F(X,Y);
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

% If the grid type is irregular, raise an error
if GridType == "irregular"
   error('The input X,Y data are irregular. This function only supports regular and uniform grids.');
end

% Get the data size, then convert the grid arrays to lists of coordinate pairs
[nrows,ncols,nsteps] = size(Z);
Z = reshape(Z,nrows*ncols,nsteps);
X = reshape(X,nrows*ncols,1);
Y = reshape(Y,nrows*ncols,1);
ncells = size(Z,1);

% compute the polyshape or get the x,y vertices
% P = polyshape(PX,PY,'Simplify',false);
PX = P.Vertices(:,1);
PY = P.Vertices(:,2);

%% Case 1: naive clipping (no aggfunc)

% TEST - find all cells fully within the polygon
% If we know we are dealing with grid cells, then for each node, we could find
% the shortest distance to the polygon and if it is less than the norm(x,y)
% distance, we know the pixel overlaps the edge

% should be:
% 1. Remove all cells entirely outside the polygon
% 2. Keep all cells entirely within the polygon
% 3. Compute overlap for remaining cells on the edge of the polygon

for n = 1:ncells
   
end
% TEST

% Step 1: Buffer the polygon to ensure it encloses all cells
% B = polybuffer(P,norm([CellSizeX,CellSizeY])/2);
% inB = inpolygon(X,Y,B.Vertices(:,1),B.Vertices(:,2));

% Get indices of grid cells fully within the polygon
[IN,ON] = enclosedGridCells(X, Y, P.Vertices(:,1), P.Vertices(:,2));

% plotMapGrid(X(ON),Y(ON)); hold on; plot(PX,PY)
% plot(X(IN),Y(IN),'o','MarkerFaceColor','k','MarkerEdgeColor','none')
% plot(X(ON),Y(ON),'o','MarkerFaceColor','m','MarkerEdgeColor','none')


% Clip the raster to the polygon boundary (naive method)
if AggFunc == "none"
   
   % For this one, it might actually be best to use the centroids inside the
   % polygon b/c it splits the difference between IN|ON which extends beyond the
   % polygon, and IN which is inside.
   
   % Set cells outside the polygon nan and return
   Z(~(IN|ON),:) = NaN;
   
   % Return Z and I with the same shape they came in
   I = reshape((IN|ON),nrows,ncols);
   Z = reshape(Z,nrows,ncols,nsteps);
   return
end

% See notes on "unstructured" grid type at bottom


%% Case 2: aggfunc

% this checks if the minimum bounding box of the grid cells fully bound the
% polygon but not if the grid cells completely cover it (that is determined at
% the end after all partial areas have been computed)
% bboxcells = centroid2box(X,Y,cellsizeX,cellsizeY);
% figure; plot(bboxcells); hold on; plot(X(:),Y(:),'o');

% Find grid cells inside the polygon buffered to enclose all cells
% tic
% B = polybuffer(P,norm([CellSizeX,CellSizeY])/2);
% inB = inpolygon(X,Y,B.Vertices(:,1),B.Vertices(:,2));


% % this creates the box that bounds the grid
% tic
% xmin = min(X(:))-CellSizeX/2;
% xmax = max(X(:))+CellSizeX/2;
% ymin = min(Y(:))-CellSizeY/2;
% ymax = max(Y(:))+CellSizeY/2;
% inB = (X >= xmin) & (X <= xmax) & (Y>=ymin) & (Y<=ymax);
% toc
% 
% % this creates the box that bounds the polygon
% tic
% inB = ...
%    (X >= min(B.Vertices(:,1))-CellSizeX/2) & ...
%    (X <= max(B.Vertices(:,1))+CellSizeX/2) & ...
%    (Y >= min(B.Vertices(:,2))-CellSizeY/2) & ...
%    (Y <= max(B.Vertices(:,2))+CellSizeY/2);
% toc
% 
% tic
% B2 = polyshape([xmin, xmax, xmax, xmin, xmin],[ymin ymin ymax ymax ymin]);
% toc
% 
% figure; plot(B); hold on; plot(B2); plot(X(:),Y(:),'o');
% plot([xmin,xmin],[ymin,ymax],'-k')
% 
% enclosed = enclosedGridCells(X, Y, P.Vertices(:,1), P.Vertices(:,2));

%%% TEST - kdtree

% traverse polygon and find all points within norm([CellSizeX,CellSizeY])/2 

%%% TEST - kdtree

% set the ellipsoid for latlon data. NOTE: the accuracy of areaint is inversely
% proportional to the distance between nodes, and accuracy appears to be low for
% modestly sized areas in geo coords, so I am not sure if there is a substitute
% for computing the area of each cell
if tfGeoCoords == true
   ellipsoidName='wgs84';
   ellips = referenceEllipsoid(ellipsoidName,'meter');
   % NOTE: test areaquad vs areaint for rectangular domain
   polyArea = sum(areaint(PY,PX,ellips)); % sqkm2sqmi(polyArea/1e6) m2->mi2
else
   ellipsoidName='wgs84'; % no harm in setting this for projected data
   ellips = [];
   polyArea = sum(area(P));
end

% NEW - we know the area of the enclosed cells, so don't loop over them
% PICk UP HERE : fastest way to find the area of the enclosed cells , then loop
% over boundary cells and get intersection area

% Compute the polyshapes outside of the loop
% cellVerts = polyshape.empty(numCells, 0);

% Calculate AreaOverlap if needed
if (~ismember(lower(AggFunc),{'sum','average','majority'}))
   
   overlapArea = nan(ncells,1);

   hasplot = false;
   
   % parfor n=1:nrows*ncols
   for n=1:ncells
      
      % if this grid cell is not inside the polygon boundary, continue
      if not(ON(n))
         continue
      end

      % compute a box around the grid centroid
      B = centroid2box(X(n),Y(n),CellSizeX,CellSizeY);

      % compute the overlapped area of the grid box and the polygon
      C = intersect(P,B,'KeepCollinearPoints',false);
      [overlapX,overlapY] = boundary(C);

      % keep the overlapping poly's for testing
      %PC(n) = C;

      % test plot
      if TestPlot == true
         if hasplot == false
            hasplot = true;
            figure; plot(X(ON),Y(ON),'o'); hold on; plot(PX,PY);
            % labelpoints(X(:),Y(:),1:numel(X));
         end
         if ~isempty(overlapX)
            plot(B); plot(overlapX,overlapY); plot(C);
         end
      end

      if isempty(overlapY) || isempty(overlapX)
         overlapArea(n)=0;
      else
         if tfGeoCoords
            tmpAreaArray = areaint(overlapY,overlapX,ellips);
            isHole = ispolycw(overlapX,overlapY);
            isHole(isHole == 0) = -1; % deducting the hole areas.
            if isHole == 0
               disp(['isHole = 0, iter = ',num2str(n)])
            end
            overlapArea(n)=sum(tmpAreaArray.*isHole(:));
         else
            overlapArea(n) = area(C);
         end         
      end
   end
   %overlapArea=reshape(overlapArea,nrows,ncols);
   
   % warn if areas don't match
   dA = abs(polyArea-sum(overlapArea(:),'omitnan'))/polyArea;
   if dA > 1e-1
      warning('area of overlapping regions differs from total polygon area by %s %%',100*dA)
   end
end

% apply the agg func
switch (lower(AggFunc))
   case ('areasum')
      Z = sum(Z.*overlapArea,1,'omitnan');
   case 'areaavg'
      Z = sum(Z.*overlapArea./sum(overlapArea(:)),1,'omitnan');
   case 'sum'
      Z = sum(Z(I),'omitnan');
   case 'average'
      Z = mean(Z(I),'omitnan');
   case 'majority'
      Z = mode(Z(I));
   otherwise
      error('Requested Operation is not recognized.')
end
Z = squeeze(Z);
% Z = Z+dA.*Z;

% figure; scatter(X(I),Y(I),20,Z(I),'filled'); hold on; plot(PX,PY)

% figure; 
% plot(squeeze(sum(sum(Z.*overlapArea./sum(overlapArea(:)),'omitnan'),'omitnan')))
% hold on; plot(squeeze(Z(1,3,:)));

end

%%

function [AggFunc,CellSizeX,CellSizeY,GridOption,CellInterpretation,TestPlot] = ...
   parse_inputs(Z,X,Y,P,funcname,varargin)

% Validate required inputs. Note: '3d' won't error on 2d input, and '2d' won't
% error on vector input. To support gridvectors, remove the X,Y size check
validateattributes(Z,{'numeric'},{'3d','size',[size(X) NaN]},funcname,'Z',1);
validateattributes(X,{'numeric'},{'2d','size',size(Y)},funcname,'X',2);
validateattributes(Y,{'numeric'},{'2d','size',size(X)},funcname,'Y',3);
validateattributes(P,{'polyshape'},{'nonempty'},funcname,'P',4);

% Validate optional inputs
validAggFuncs = ["areasum","areaavg","sum","average","majority","none"];
validAggFuncs = @(x)~isempty(validatestring(x,validAggFuncs));
validCellSize = @(x) isnumeric(x) && isscalar(x);
validGridOpts = ["gridvectors","fullgrid"];
validGridOpts = @(x)~isempty(validatestring(x,validGridOpts));
validCellTypes = ["cells","postings"];
validCellTypes = @(x)~isempty(validatestring(x,validCellTypes));

defaultAggFunc = "none";
defaultGridOpt = "fullgrid";
defaultCellSize = NaN;
defaultCellType = "cells";

p = inputParser;
p.FunctionName = funcname;
p.addOptional( 'AggFunc', defaultAggFunc, validAggFuncs);
p.addParameter('CellSizeX', defaultCellSize, validCellSize);
p.addParameter('CellSizeY', defaultCellSize, validCellSize);
p.addParameter('GridOption', defaultGridOpt, validGridOpts);
p.addParameter('CellInterpretation',defaultCellType, validCellTypes);
p.addParameter('TestPlot', false, @(x)islogical(x));

p.parse(varargin{:});
AggFunc = p.Results.AggFunc;
CellSizeX = p.Results.CellSizeX;
CellSizeY = p.Results.CellSizeY;
GridOption = p.Results.GridOption;
CellInterpretation = p.Results.CellInterpretation;
TestPlot = p.Results.TestPlot;

end

%% Notes on unstructured grids

% % just putting this here
% if GridType == "unstructured"
%    
%    % I think what I tried to do here was convert unstructured to structured.
%    % First use the unstructured X,Y and use meshgrid to grid them, which
%    % produces lots of grid coordinates with no Z values. Then interpolate onto
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
%    Z = scatteredInterpolation(xvec,yvec,Z,X(:),Y(:),'nearest','linear');
% 
%    % this converts Z to a regular grid and inserts nan in the missing locations
%    % notok = ~ismember([X(:),Y(:)],[xvec yvec],'rows');
%    % Z = insertrows(Z,nan(sum(notok),size(Z,3)),find(notok)-1);
%    % Z = reshape(Z,size(X,1),size(X,2),size(Z,2));
%    % Z = fillmissing(Z,'linear');
%    
%    %I cannot get griddedInterpolant to fill the missing value. I am not sure if
%    %fillmissing is faster than looping with scatteredInterpolant
%    %F = griddedInterpolant(X',Y',pagetranspose(Z),'spline','spline');
%    %Z = F(X,Y);
% 
% % elseif GridType == "gridvectors"
% %    F = griddedInterpolant({X,Y},Z,'nearest','linear');
% %    Z = F(X,Y);
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
% %       % can I convert Z to a regular grid and insert nan in the missing indices?
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
