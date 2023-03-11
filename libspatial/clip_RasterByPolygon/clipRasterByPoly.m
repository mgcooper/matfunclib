function [Z,I] = clipRasterByPoly(Z,X,Y,P,varargin)
%CLIPRASTERBYPOLY clip raster Z with coordinates X,Y by poly P
%
%
%
%
%
% TODO: need to ensure the grid cells completely cover the polygon and if not, a
% method to fill in. it is easy to create a regular grid and use
% griddedInterpolant to fill in, but need to first determine the minimum
% bounding grid cells. For now, just use whatever is passed in
%-------------------------------------------------------------------------------
validstrings   = {'areasum','areaavg','aggregate','average','majority'};
validoption    = @(x)any(validatestring(x,validstrings));

p              = magicParser;
p.FunctionName = mfilename;
p.addRequired( 'Z',                                @(x)isnumeric(x)        );
p.addRequired( 'X',                                @(x)isnumeric(x)        );
p.addRequired( 'Y',                                @(x)isnumeric(x)        );
p.addRequired( 'P',                                @(x)isa(x,'polyshape')  );
p.addOptional( 'aggfunc',           'none',        validoption             );
p.addParameter('GridType',          'structured',  @(x)ischar(x)           );
p.addParameter('CellSize',          [nan,nan],     @(x)isnumeric(x)        );
p.addParameter('CellInterpretation','cells',       @(x)ischar(x)           );
p.addParameter('testplot',          false,         @(x)islogical(x)        );

p.parseMagically('caller');
%-------------------------------------------------------------------------------

if aggfunc == "none"
   % set cells outside the polygon nan
   I = inpolygon(X(:),Y(:),P.Vertices(:,1),P.Vertices(:,2));
   Z(~I) = NaN;
   return
end

% just putting this here
if GridType == "unstructured"
   xvec = X; yvec = Y;
   [X,Y] = meshgrid(unique(X,'sorted'),unique(Y,'sorted'));

   % scatteredInterpolation requires looping over all timsteps, but is still
   % faster than the insertrows / reshape to grid method below b/c
   % griddedInterpolant does not inpaint nans
   Z = scatteredInterpolation(xvec,yvec,Z,X(:),Y(:),'nearest','linear');

   % this converts Z to a regular grid and inserts nan in the missing locations
   % notok = ~ismember([X(:),Y(:)],[xvec yvec],'rows');
   % Z = insertrows(Z,nan(sum(notok),size(Z,3)),find(notok)-1);
   % Z = reshape(Z,size(X,1),size(X,2),size(Z,2));
   % Z = fillmissing(Z,'linear');
   
   %I cannot get griddedInterpolant to fill the missing value. I am not sure if
   %fillmissing is faster than looping with scatteredInterpolant
   %F = griddedInterpolant(X',Y',pagetranspose(Z),'spline','spline');
   %Z = F(X,Y);

elseif GridType == "gridvectors"
   F = griddedInterpolant({X,Y},Z,'nearest','linear');
   Z = F(X,Y);
end

if numel(CellSize) == 1
   cellsizeX = CellSize;
   cellsizeY = CellSize;
else
   cellsizeX = CellSize(1);
   cellsizeY = CellSize(2);
end

if isnan(cellsizeX) || isnan(cellsizeY)
   [X,Y,cellsizeX,cellsizeY,tfgeo,tfreg] = prepareMapGrid(X,Y,GridType);
else
   [tfreg,tfgeo] = isxyregular(X,Y);
end

% this checks if the minimum bounding box of the grid cells fully bound the
% polygon but not if the grid cells completely cover it (that is determined at
% the end after all partial areas have been computed)
% bboxcells = centroid2box(X,Y,cellsizeX,cellsizeY);
% figure; plot(bboxcells); hold on; plot(X(:),Y(:),'o');

% get the number of rows and columns and convert to a list
if GridType == "structured" 
   if ndims(Z)>3
      error('only 3-d data currently supported')
   else
      [nrows,ncols,nsteps] = size(Z);
   end
   Z = reshape(Z,nrows*ncols,nsteps);
   X = reshape(X,nrows*ncols,1);
   Y = reshape(Y,nrows*ncols,1);
end
ncells = size(Z,1);

% find grid cells inside the polygon + a buffer large enough
B = polybuffer(P,2*norm([cellsizeX,cellsizeY]));
I = inpolygon(X,Y,B.Vertices(:,1),B.Vertices(:,2));

% compute the polyshape or get the x,y vertices
% P = polyshape(PX,PY,'Simplify',false);
PX = P.Vertices(:,1);
PY = P.Vertices(:,2);

% set the ellipsoid for latlon data
if islatlon(Y,X)
   ellipsoidName='wgs84';
   ellips = referenceEllipsoid(ellipsoidName,'meter');
   polyArea = sum(areaint(PY,PX,ellips));
else
   ellipsoidName='wgs84'; % no harm in setting this for projected data
   ellips = [];
   polyArea = sum(area(P));
end

% Calculate AreaOverlap if needed
if (~ismember(lower(aggfunc),{'aggregate','average','majority'}))
   
   overlapArea = nan(ncells,1);

   hasplot = false;
   
   % parfor n=1:nrows*ncols
   for n=1:ncells
      
      % if this grid cell is outside the polygon, continue
      if ~I(n)
         continue
      end

      % compute a box around the grid centroid
      B = centroid2box(X(n),Y(n),cellsizeX,cellsizeY);

      % compute the overlapped area of the grid box and the polygon
      C = intersect(P,B,'KeepCollinearPoints',true);
      [overlapX,overlapY] = boundary(C);

      % keep the overlapping poly's for testing
      %PC(n) = C;

      % test plot
      if testplot == true
         if hasplot == false
            hasplot = true;
            figure; plot(X(I),Y(I),'o'); hold on; plot(PX,PY);
            % labelpoints(X(:),Y(:),1:numel(X));
         end
         if ~isempty(overlapX)
            plot(B); plot(overlapX,overlapY); plot(C);
         end
      end

      if isempty(overlapY) || isempty(overlapX)
         overlapArea(n)=0;
      else
         if islatlon(overlapY,overlapX)
            tmpAreaArray = areaint(overlapY,overlapX,ellips);
            isHole = ispolycw(overlapX,overlapY);
            isHole(isHole == 0) = -1; % deducting the hole areas.
            overlapArea(n)=sum(tmpAreaArray.*isHole(:));
         else
            overlapArea(n) = area(C);
         end         
      end
   end
   %overlapArea=reshape(overlapArea,nrows,ncols);
end

% warn if areas don't match
dA = abs(polyArea-sum(overlapArea(:),'omitnan'))/polyArea;
if dA > 1e-1
   warning('area of overlapping regions differs from total polygon area by %s %%',100*dA)
end

% apply the agg func
switch (lower(aggfunc))
   case ('areasum')
      Z = sum(Z.*overlapArea,1,'omitnan');
   case 'areaavg'
      Z = sum(Z.*overlapArea./sum(overlapArea(:)),1,'omitnan');
   case 'aggregate'
      Z = sum(reshape(Z,[],size(Z,3)),'omitnan');
   case 'average'
      Z = mean(reshape(Z,[],size(Z,3)),'omitnan');
   case 'majority'
      Z = mode(reshape(Z,[],size(Z,3)));
   otherwise
      error('Requested Operation is not recognized.')
end
Z = squeeze(Z);
% Z = Z+dA.*Z;


% figure; 
% plot(squeeze(sum(sum(Z.*overlapArea./sum(overlapArea(:)),'omitnan'),'omitnan')))
% hold on; plot(squeeze(Z(1,3,:)));

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
