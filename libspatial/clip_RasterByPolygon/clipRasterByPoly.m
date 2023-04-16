function [V2,W,IN,ON,A] = clipRasterByPoly(V,X,Y,P,varargin)
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
%       W - interpolation weights
%       IN - Indices of grid cells fully within the polygon
%       ON - Indices of grid cells within the buffered polygon region
%
%   Note: The function currently only supports 3D data for 'structured' grids.

% I need to add documentatoin that clarifies how W is sued b/c I already got
% confused mysefl. For the case of multi-polygons, W is a cell array of size
% equal to the number of polygons. each element of W is an array of weights for
% all grid cells. So V.*W{i} produces the data for polygon i, which can then be
% summed to get the total in the polygon, or whatever operation. Alternatively,
% the cellPolyMapping,cellPolyWeights and polyCellMapping,polyCellWeights reduce
% the big W cell array down to lists of indices and weights, but overall the
% function should require that W be passed back in, and it knows what to do

%% parse inputs

[V,X,Y,P,PX,PY,dX,dY,PA,A,tfgeo,opts] = ...
   parse_inputs(V,X,Y,P,mfilename,varargin{:});

% TODO
% - Allow irregular grids w/ option 'GridType','Irregular', in which case cells
% are assumed to be rectangular and the mid points are used for edges. 
% - For unstructured, X,Y can be be matrices, and the first column is the
% centroid, then verts
% - IN and ON should be sparse and/or logical arrays of size Ncells x Npoly
% - Check if the grid cells completely cover the polygon and visa versa
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

% If i knew the entry and exit point of the polygon and the grid cells, i could
% compute the polygon from the path and the vertices, pre 

%% Prepare inputs

% Convert the grid arrays to lists of coordinate pairs
V = reshape(V, [], size(V,3) );
X = reshape(X, [], 1 );
Y = reshape(Y, [], 1 );

% Get the solid boundary orientation of the polygons. This is 
% used to construct grid cell polygons in the same orientation.
sbo = 'ccw';
if all(ispolycw(PX,PY))
   sbo = 'cw';
end

% For reference, if the SBO differs, can simply flipud (or fliplr)
% ispolycw(PX,PY)
% ispolycw(XV(1,:),YV(1,:))
% figure; plot(flipud(PX),flipud(PY))

% For geo coords, set the reference elliipsoid
E = referenceEllipsoid('wgs84','meter');

% Compute the total polygon area(s) (PA) if they were not passed in
if isnan(PA)
   PA = totalPolygonArea(P,tfgeo,E);
end

%% MAIN ROUTINE

% Find grid cells IN (fully enclosed by) and ON the boundary of all polygons
[W,IN,ON,AIN,AON] = cellmap( ...
   @(P,PX,PY) processOnePolygon(X,Y,P,PX,PY,dX,dY,sbo,tfgeo,E,opts.AggFunc), ...
   P,PX,PY);

% For reference:
% ALLIN = any(horzcat(IN{:}),2);
% ALLON = any(horzcat(ON{:}),2);
% ALLW = sum(horzcat(W{:}),2);
% % sum(ALLW) should be the # of grid cells enclosed by the outer
% % boundary of the entire polygon
% plotMapGrid(X(ALLON),Y(ALLON)); hold on;

%% CHECKS

% Compute the total area covered by grid cells

A = sum( cellfun( @sum, AIN )) + sum( cellfun( @sum, AON ));

% Non-cellfun case
% A = sum(AON) + sum(AIN);

% Warn if areas don't match to within 0.1%

if opts.GridType ~= "irregular" && abs(A-sum(PA))/sum(PA) > 1e-3
   
   warning( ...
      'overlap area differs from total polygon area by %s %%', ...
      100*abs(A-PA)/PA)
end

% IW = indices of which polygons the weights apply to, IV = which cells, so 
% Prepare for forward or reverse mapping
if opts.ReverseMapping == true

   [W,IW,IV] = reverseMapping(V,W,PA,X,Y,dX,dY,sbo,E);
   V2 = zeros(size(X));
   
else  % elseif opts.AggFunc ~= "clip"
   
   [W,IW,IV] = forwardMapping(V,W);
   V2 = zeros(size(P));
end


%% Compute the aggregation function

switch lower(opts.AggFunc)
   
   case {'weights','clip'} % return the weights
      
      % need to call a post-processing step to return the data as matrices for
      % the case of one polygon, as right now they are packaged up in cells.
      % Also, can the weights be combined into one layer? Since the polygons
      % contribute to more than one grid cell, I would need each grid cell to
      % have a list of cells and their weights.
      
      % Might be able to concat into matrices for the case of multiple polys
      if numel(W) == 1
         W = W{1};
         IN = IN{1};
         ON = ON{1};
         
      else
         
         % for this case, we want a list for each polygon that says which grid
         % cells contribute to the polygon and the weights
         
      end
      
      if (lower(opts.AggFunc)) == "clip"
         % Clip the raster to the polygon boundary (naive method)
   
      
         % Set grid cells outside the polygon nan
         V(~IN,:) = NaN;
         
         % % Reshape V and IN to match the shape they were passed in as? 
         % V(~inpolygon(X,Y,PX,PY),:) = NaN;
         % IN = reshape(inpolygon(X,Y,PX,PY),nr,nc);
         % V = reshape(V,nr,nc,nsteps);
      end
      
      return
   
   case 'areasum'
      
      % note, v has both nan and 0, need to figure that out

      % For each polygon, apply the weights vector in each element of W to the
      % indices of the variable vector V(i), and sum. Set 'uni',false for cell.
      V2(IV) = cellfun( @(i,w) sum(V(i).*w,'omitnan'), IW, W);

      % For the reverse case with one polygon, every element of IW = 1, IV is
      % the indices of the grid cells, and W is the fraction of the polygon
      % occupied by each grid cell.
      
      % This is the arrayfun method that works for fwd/rev. 
      % V2(IV) = arrayfun( @(n) sum(V(IW{n}).*W{n},'omitnan'), (numel(W):-1:1)');

      % These are the arrayfun method that differ b/w fwd/rev. For the forward
      % case, this is ~10x faster. For the reverse case, they're about equal.
      % if opts.ReverseMapping == true
      %    V2(IV) = arrayfun( @(n) sum(V(IW{n}).*W{n},'omitnan'), (numel(W):-1:1)');
      % else
      %  % Clip the raster cells by the polygons, one value per polygon
      %    V2 = arrayfun( @(n) sum(V.*W{n},'omitnan'), (numel(W):-1:1)' ) ;
      % end
      
      % Vector version:
      % V = sum(V(IN).*AIN(:),'omitnan') + sum(V(ON).*AON(:),'omitnan');
      
      
   case 'areaavg'
      
      V = arrayfun( @(n) sum(V.*W{n},'omitnan') / A, (1:numel(P))' ) ;
      
      % Vector version
      % V = (sum(V(IN).*AIN(:),'omitnan') + sum(V(ON).*AON(:),'omitnan')) / A;
      
   case 'sum'
      
      % Need to distinguish V.*W from V(IN) for the case where W is provided
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

% For the case of one polygon, convert to arrays. V2 and A will never be cells.
% It might also make sense to check if all elements are uniform and concat them.
% Also, if AIN or AON are sent back, they need to be added here. 
if numel(W) == 1
   W = W{1};
end

if numel(IN) == 1
   IN = IN{1};
end

if numel(ON) == 1
   ON = ON{1};
end

% figure; scatter(X(I),Y(I),20,V(I),'filled'); hold on; plot(PX,PY)

% figure;
% plot(squeeze(sum(sum(V.*overlapArea./sum(overlapArea(:)),'omitnan'),'omitnan')))
% hold on; plot(squeeze(V(1,3,:)));

end


%% SUBFUNCTIONS


%% Reverse mapping



%% One Grid Cell Area

function A = oneGridCellArea(X,Y,dX,dY,sbo,e)

[XV, YV] = gridCellCorners( X, Y, dX, dY, sbo );
   
% Area of grid cells IN the polygon interior
A = areaint( YV, XV, e);

end

%% TOTAL POLYGON AREA

function PA = totalPolygonArea(P,tfgeo,E)
%TOTALPOLYGONAREA

   if tfgeo == true   
   
      PA = cellfun( ...
         @(P) sum( (2.*ispolycw(P.Vertices(:,1),P.Vertices(:,2))-1) .* ...
         areaint(P.Vertices(:,2),P.Vertices(:,1),E)), ...
         P);
      % sqkm2sqmi(PA/1e6) m2->mi2
   else
      PA = sum(area(P));
   end

% % For reference, the simple case:
% PA = sum(areaint(PY, PX, E));
% PA = sum(areaint(py, px, E));
      
end


%% PARSE INPUTS

function [V,X,Y,P,PX,PY,CellSizeX,CellSizeY,PolygonAreas, ...
   GridCellAreas,tfGeoCoords,opts] = parse_inputs(V,X,Y,P,funcname,varargin)
% PARSEINPUTS

% Validate required inputs

% Note that '3d' won't error on 2d input, and '2d' won't error on vector input.
% To support gridvectors, remove the X,Y size check

% % I commented out the V validation for the reversemapping case
% % UPDATE I commented out the whole thing while I sort thorugh unstructured
% % X,Y,V are full grids or coordinate lists.
% if ismatrix(X) || numel(X) == numel(Y) % full grids || coordinate lists
%    % validateattributes(V,{'numeric'},{'3d','numel',numel(X)},funcname,'V',1);
%    validateattributes(X,{'numeric'},{'2d','size',size(Y)},funcname,'X',2);
%    validateattributes(Y,{'numeric'},{'2d','size',size(X)},funcname,'Y',3);
% else % X,Y are grid vectors, V can be a matrix or list
%    % validateattributes(V,{'numeric'},{'3d','numel',numel(X)*numel(Y)},funcname,'V',1);
%    validateattributes(X,{'numeric'},{'vector'},funcname,'X',2);
%    validateattributes(Y,{'numeric'},{'vector'},funcname,'Y',3);
% end
% 
% % P can be a polyshape, cell array of polyshapes, or cell array of X,Y vertices
% validateattributes(P,{'polyshape','cell','double'},{'nonempty'},funcname,'P',4);

% Validate optional inputs

validAggFuncs = ["areasum","areaavg","sum","average","majority","none","weights","clip"];
validGridOpts = ["gridvectors","fullgrid","unstructured"];
validCellTypes = ["cells","postings"];

validAggFuncs = @(x)~isempty(validatestring(x,validAggFuncs));
validGridOpts = @(x)~isempty(validatestring(x,validGridOpts));
validCellTypes = @(x)~isempty(validatestring(x,validCellTypes));
validCellVerts = @(x) isnumeric(x) && ismatrix(x);
validCellSize = @(x) isnumeric(x) && isscalar(x);
% Set defaults

defaultAggFunc = "none";
defaultGridOpt = "fullgrid";
defaultCellType = "cells";
defaultCellSize = NaN;
defaultCellVerts = NaN;

% Create input parser

p = inputParser;
p.FunctionName = funcname;
p.addOptional( 'AggFunc', defaultAggFunc, validAggFuncs);
p.addParameter('TestPlot', false, @(x)islogical(x));
p.addParameter('CellSizeX', defaultCellSize, validCellSize);
p.addParameter('CellSizeY', defaultCellSize, validCellSize);
p.addParameter('GridOption', defaultGridOpt, validGridOpts);
p.addParameter('PolygonAreas', NaN, @(x)isnumeric(x));
p.addParameter('CellVertices', defaultCellVerts, validCellVerts);
p.addParameter('GridCellAreas', NaN, @(x)isnumeric(x));
p.addParameter('ReverseMapping', false, @(x)islogical(x));
p.addParameter('CellInterpretation', defaultCellType, validCellTypes);


% Parse inputs

p.parse(varargin{:});
AggFunc = p.Results.AggFunc;
TestPlot = p.Results.TestPlot;
CellSizeX = p.Results.CellSizeX;
CellSizeY = p.Results.CellSizeY;
GridOption = p.Results.GridOption;
PolygonAreas = p.Results.PolygonAreas;
CellVertices = p.Results.CellVertices;
GridCellAreas = p.Results.GridCellAreas;
ReverseMapping = p.Results.ReverseMapping;
CellInterpretation = p.Results.CellInterpretation;


% PROCESS INPUTS

warning off

% P can be a vector or cell array of X,Y verts, a scalar or vector polyshape, or
% a cell array of polyshapes. Convert to a cell array of polyshapes.
   
% NOTE: this should be complete.

if iscell(P)
   
   % Note: if P is a cell array of polyshapes, then ismatrix(P) == true, so
   % check iscell first, then ismatrix

   if isa(P{1},'polyshape') % P is a cell array of polyshapes, nothing to do
      
      % validateattributes(P{1},{'polyshape'},{'vector'},funcname,'P',4);
      
   else % P is an Nx2 cell array with PXi = P{i,1} and PYi = P{i,2}
      
      validateattributes(P,{'cell'},{'2d'},funcname,'P',4);
      
      % Convert the X,Y vertices in each cell to a polyshape
      % NOTE this is very time consuming. We need each P to be a polyshape
      % to get area intersection in processOnePolygon, BUT ONLY FOR THE POLYGONS
      % THAT ARE INVOLVED IN THE CALCULATION. So we could trim both X,Y and P to
      % the minimum bounding boxes but that will be time consuming to figure out
      % exactly all the places it matters re indexing etc.
      P = cellfun( @(x,y) polyshape(x,y), P(:,1), P(:,2), 'uni', false ) ;
      
   end
   
elseif ismatrix(P) 
   
   if isa(P,'polyshape') % P is Nx1 vector of polyshapes, put it in a cell array
      
      validateattributes(P,{'polyshape'},{'vector'},funcname,'P',4);
      
      P = num2cell(P);

   else % P is Nx2 with PX = P(:,1) and PY = P(:,2)
      
      % Check for nan-delimited polygons
      if sum(isnan(P(:,1))) > 1 % P is multi-polygon
         
         % Note, this requires mapping toolbox, need a general method
         % [PY,PX] = polysplit(P(:,2),P(:,1));
         
         % Convert the X,Y vertices in each cell to a polyshape
         % P = cellfun( @(x,y) polyshape(x,y), P(:,1), P(:,2), 'uni', false ) ;
         
         PX = P(:,1); PY = P(:,2);
         for n = 1:sum(isnan(P(:,1)))
            % need method to find s,e (nan-delimited segments
            P = polyshape(PX(s:e),PY(s:e),'Simplify',true,'KeepCollinearPoints',false);
         end
         
      else % P is one polygon
         
         P = {polyshape(P(:,1),P(:,2),'Simplify',true,'KeepCollinearPoints',false)};
         
      end   
   end
end

% Put the X,Y vertices back into cell arrays
PX = cellfun( @(P) P.Vertices(:,1), P, 'uni', false );
PY = cellfun( @(P) P.Vertices(:,2), P, 'uni', false );
% Note, set 'uni' true to get a polyshape vector rather than cell array

% % This was in the main for the case where Numel = 1, to get the full area
% px = P.Vertices(:,1);
% py = P.Vertices(:,2);
% 
% [PX,PY] = polyjoin({px},{py}) ;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

% % TO FINISH, Uncomment below and confirm it is all in the above. The goal is to
% % get all inputs into cell arrays
% 
% % If P is not a polyshape, create one (P is a 2-column matrix of X,Y coords)
% if ~isa(P,'polyshape')
%    
%    if numel(P) == 1 
%    
%       if iscell(P)
%          
%          P = polyshape(P{:,1},P{:,2},'Simplify',true,'KeepCollinearPoints',false);
%          px = P.Vertices(:,1);
%          py = P.Vertices(:,2);
%          [PX,PY] = polyjoin({px},{py}) ;
%          
%       elseif ismatrix(P)
%          
%       end
%       
%    else % P is an X,Y matrix or cell array of X,Y 
%       
%       
%    end
%    
% elseif ~isa(P,'polyshape') && ~iscell(P)
% 
%    % Make P a cell array for unified cellfun methods w/ polys and multi-polys
%    P = {polyshape(P,'Simplify',true,'KeepCollinearPoints',false)};
%    
% % below this was commented out to signify that it's in the new block above.
% % above may also be there but I need to confirm
% 
% % elseif iscell(P)
% %    
% %    % Convert the X,Y vertices in each cell to a polyshape
% %    P = cellfun( @(x,y) polyshape(x,y), P(:,1), P(:,2), 'uni', false ) ;
% %    
% %    % Put the X,Y vertices back into cell arrays
% %    PX = cellfun( @(P) P.Vertices(:,1), P, 'uni', false );
% %    PY = cellfun( @(P) P.Vertices(:,2), P, 'uni', false );
% %    
% %    % Note, set 'uni' true to get a polyshape vector rather than cell array
% %    
% %    px = P.Vertices(:,1);
% %    py = P.Vertices(:,2);
% % 
% %    [PX,PY] = polyjoin({px},{py}) ;
% end

warning on


% % % % This was from the main function, now below the first P checks above, in
% the new scheme where I first get P into a cell array of x-y coordinates to
% apply the same cellfun method in each case

% % Get the polygon vertices
% if numel(P) == 1
%    
%    PX = P.Vertices(:,1);
%    PY = P.Vertices(:,2);
%    
%    [px,py] = polyjoin({PX},{PY}) ;
%    
% else
%    
%    % For reference, methods to make a cell and an array of all coords, but 
%    % PXY = {P(1:numel(P)).Vertices}.';
%    % PXY = vertcat(P(1:numel(P)).Vertices);
%    
%    PX = cellfun( @(P) P.Vertices(:,1), P, 'uni', false );
%    PY = cellfun( @(P) P.Vertices(:,2), P, 'uni', false );
%    
%    % PX = arrayfun( @(P) P.Vertices(:,1), P, 'uni', false );
%    % PY = arrayfun( @(P) P.Vertices(:,2), P, 'uni', false );
%    
%    % At this stage, not sure if we want PX, PY to be cell arrays, or
%    % nan-delimited lists, but px,py can be used for testing. AND it appears
%    % that either putting PX,PY into cell array regardless of how it comes in
%    % will simplify the rest of the code 
%    
%    [px,py] = polyjoin(PX,PY) ;
%    
% end




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

elseif GridOption == "unstructured"
   
   if all(~isnan(CellVertices))
      [CellSizeX, CellSizeY, GridType] = mapGridCellSize(X, Y);
   
      %CellSizeX = diff(X);
      %CellSizeY = diff(Y);
   else
      
   end
   
   tfGeoCoords = isGeoGrid(Y,X);

   
else % assume a structured grid

   % Get the grid info and confirm the provided CellSize matches the inferred ones
   if isnan(CellSizeX) || isnan(CellSizeY)
   
      [X,Y,CellSizeX,CellSizeY,GridType,tfGeoCoords] = prepareMapGrid(X,Y,"gridvectors");
   
   else
   
      [X,Y,CheckSizeX,CheckSizeY,GridType,tfGeoCoords] = prepareMapGrid(X,Y,"gridvectors");
   
      assert(CellSizeY == CheckSizeY);
      assert(CellSizeX == CheckSizeX);
   
   end


   if GridType == "irregular"
   
      % If the grid type is irregular, raise an error
      %error('The input X,Y data are irregular. This function only supports regular and uniform grids.');
   
   end
   
end


% Assign opts
opts.AggFunc = AggFunc;
opts.TestPlot = TestPlot;
opts.GridType = GridType;
opts.GridOption = GridOption;
opts.ReverseMapping = ReverseMapping;
opts.CellInterpretation = CellInterpretation;

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
