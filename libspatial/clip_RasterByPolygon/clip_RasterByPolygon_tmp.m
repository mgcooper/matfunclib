function [output,opts]=clip_RasterByPolygon_tmp(RData,RLat,RLon,PLat,PLon,...
   aggfunc,opts)
%clip_RasterByPolygon
%
%
%
%

% mgc: added above documentation. some important notes:
% - RData needs to be a regular grid
% - RLat/Lon need to be grid vectors with one fewer element than the respective
% RData dimensions
%
% TODO: cell interpretation

testplot = false;

%% checking input
validateattributes(RData,{'numeric'},{'3d'});
validateattributes(RLon,{'numeric'},{'vector','increasing'});
validateattributes(RLat,{'numeric'},{'vector','decreasing'});
validateattributes(PLon,{'numeric'},{'vector'});
validateattributes(PLat,{'numeric'},{'vector'});

if (nargin<=5 || isempty(aggfunc))
   aggfunc='AverageByArea'; %default value for Operation
end
validateattributes(aggfunc,{'char'},{'row','size',[1,NaN]});

% if ( (numel(RLat)~=(size(RData,1)+1)) || (numel(RLon)~=(size(RData,2)+1)) )
%    error('The size of RData does not match that of the RLat and RLon');
% end

%% get bounding box of the polygon
if ( ~exist('opts','var') || isempty(opts) || ~isfield(opts,'boundingBox') ...
      || isempty(opts.boundingBox) )
   % calculating the bounding box
   opts.boundingBox=[min(PLat), min(PLon); ...
      max(PLat), max(PLon)];
end

if (~isfield(opts,'boundingBoxIDX') || isempty(opts.boundingBoxIDX) )
   % calculating the bounding box
   opts.boundingBoxIDX=[find(RLat>=opts.boundingBox(2,1),1,'last'),  ...
      find(RLon<=opts.boundingBox(1,2),1,'last');  ...
      find(RLat<=opts.boundingBox(1,1),1,'first'), ...
      find(RLon>=opts.boundingBox(2,2),1,'first')];
end

if (~isfield(opts,'boundingBoxRaster') || isempty(opts.boundingBoxRaster) )
   % calculating the bounding box
   opts.boundingBoxRaster=...
      [RLat(opts.boundingBoxIDX(1,1)),RLon(opts.boundingBoxIDX(1,2)); ...
      RLat(opts.boundingBoxIDX(2,1)),RLon(opts.boundingBoxIDX(2,2))];
end
%%
if ( ~isfield(opts,'ellipsoidName') || isempty(opts.ellipsoidName) )
   if islatlon(RLat,RLon)
      opts.ellipsoidName='wgs84';
   else
      opts.ellipsoidName='wgs84'; % no harm in setting this for projected data
   end
end
if ( ~isfield(opts,'ellips') || isempty(opts.ellips) )
   if islatlon(RLat,RLon)
      opts.ellips = referenceEllipsoid(opts.ellipsoidName,'meter');
   else
      opts.ellips = [];
   end
end
if ( ~isfield(opts,'polyArea') || isempty(opts.polyArea) )
   if islatlon(RLat,RLon)
      opts.polyArea = sum(areaint(PLat,PLon,opts.ellips));
   else
      opts.polyArea = sum(area(polyshape(PLon,PLat)));
   end
end

%% test plots
if testplot == true
   figure; plot(RLon,RLat,'o'); hold on; plot(PLon,PLat);
   plotBbox(fliplr(opts.boundingBox));
   plotBbox(fliplr(opts.boundingBoxRaster));
end

%% Getting AreaOverlap if needed
if (~ismember(lower(aggfunc),{'aggregate','average','majority'}))
   if ( ~isfield(opts,'overlapArea') || isempty(opts.overlapArea) )

      nRows=opts.boundingBoxIDX(2,1)-opts.boundingBoxIDX(1,1);
      nCols=opts.boundingBoxIDX(2,2)-opts.boundingBoxIDX(1,2);

      overlapArea=NaN(nRows*nCols,1);
      minRowIDX=opts.boundingBoxIDX(1,1);
      minColIDX=opts.boundingBoxIDX(1,2);
      ellips=opts.ellips;

      % mgc compute this once
      A = polyshape(PLon,PLat,'Simplify',false);

%       parfor pixelID=1:(nRows*nCols)
      for pixelID=1:(nRows*nCols)
         [rowID,colID]=ind2sub([nRows,nCols],pixelID);
         rowID=rowID-1;
         colID=colID-1;
         cellLat=[RLat(minRowIDX+rowID); ...
            RLat(minRowIDX+rowID); ...
            RLat(minRowIDX+rowID+1); ...
            RLat(minRowIDX+rowID+1)]; %#ok<PFBNS>
         cellLon=[RLon(minColIDX+colID); ...
            RLon(minColIDX+colID+1); ...
            RLon(minColIDX+colID+1); ...
            RLon(minColIDX+colID)]; %#ok<PFBNS>

         % mgc fix polybool warning:
         % overlapped area
         %[overlap_lon,overlap_lat] = polybool('intersection',PLon,PLat,...
         % cellPolygon_lon,cellPolygon_lat);
         C = intersect(A,polyshape(cellLon,cellLat,'Simplify',false));
         [overlapLon,overlapLat] = boundary(C);

         % test plot
         if testplot == true
            figure; plot(RLon,RLat,'o'); hold on; plot(PLon,PLat);
            mapbox([min(cellLon) max(cellLon)],[min(cellLat) max(cellLat)]);
            plot(overlapLon,overlapLat); plot(C);
         end

         if (~isempty(overlapLat) || ~isempty(overlapLon))
            % mgc check if latlon
            if islatlon(overlapLat,overlapLon)
               tmpAreaArray = areaint(overlapLat,overlapLon,ellips);
            else
               tmpAreaArray = area(C);
            end
            isHole = ispolycw(overlapLon,overlapLat);
            isHole(isHole == 0) = -1; % deducting the hole areas.
            overlapArea(pixelID)=sum(tmpAreaArray.*isHole(:));
         else
            overlapArea(pixelID)=0;
         end

      end
      opts.overlapArea=reshape(overlapArea,nRows,nCols);
   end
end

%%
rowIDList=opts.boundingBoxIDX(1,1):(opts.boundingBoxIDX(2,1)-1);
colIDList=opts.boundingBoxIDX(1,2):(opts.boundingBoxIDX(2,2)-1);

switch (lower(aggfunc))
   case ('aggregatebyarea')
      output = sum(sum(bsxfun(@times,RData(rowIDList,colIDList,:),...
         opts.overlapArea),1,'omitnan'),2,'omitnan');
      % resizedOverLappedArea = repmat(Opt.overlapArea,1,1,size(RData,3));
      % output = sum( sum( RData(rowIDList,colIDList,:).*resizedOverLappedArea, 1),2);

   case 'averagebyarea'
      output = sum(sum(bsxfun(@times,RData(rowIDList,colIDList,:),...
         opts.overlapArea),1,'omitnan'),2,'omitnan')./sum(opts.overlapArea(:));
      % resizedOverLappedArea = repmat(Opt.overlapArea,1,1,size(RData,3));
      % output = sum(sum(RData(rowIDList,colIDList,:).*resizedOverLappedArea,1)...
      % ,2)./sum(Opt.overlapArea(:));
   case 'aggregate'
      output = sum(reshape(RData(rowIDList,colIDList,:),[],size(RData,3)),'omitnan');
   case 'average'
      output = mean(reshape(RData(rowIDList,colIDList,:),[],size(RData,3)),'omitnan');
   case 'majority'
      output = mode(reshape(RData(rowIDList,colIDList,:),[],size(RData,3)));
   otherwise
      error('Requested Operation is not recognized.')
end
