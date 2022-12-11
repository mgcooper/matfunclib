function [output, Opt]=clip_RasterByPolygon(RData,RLat,RLon,PLat,PLon,Operation,Opt)
%% checking input
validateattributes(RData,{'numeric'},{'3d'});
validateattributes(RLon,{'numeric'},{'vector','increasing'});
validateattributes(RLat,{'numeric'},{'vector','decreasing'});
validateattributes(PLon,{'numeric'},{'vector'});
validateattributes(PLat,{'numeric'},{'vector'});

if (nargin<=5 || isempty(Operation)) 
    Operation='AverageByArea'; %default value for Operation
end
validateattributes(Operation,{'char'},{'row','size',[1,NaN]});

if ( (numel(RLat)~=(size(RData,1)+1)) || (numel(RLon)~=(size(RData,2)+1)) )
  error('The size of RData does not match that of the RLat and RLon');
end

%% get bounding box of the polygon
if ( ~exist('Opt','var') || ...
     isempty(Opt) || ...
     ~isfield(Opt,'boundingBox') || ...
     isempty(Opt.boundingBox) )
	% calculating the bounding box
      Opt.boundingBox=[min(PLat), min(PLon); ...
                       max(PLat), max(PLon)];
end

if (~isfield(Opt,'boundingBoxIDX') || ...
     isempty(Opt.boundingBoxIDX) )
	% calculating the bounding box
  Opt.boundingBoxIDX=[find(RLat>=Opt.boundingBox(2,1),1,'last'),  find(RLon<=Opt.boundingBox(1,2),1,'last');  ...
                      find(RLat<=Opt.boundingBox(1,1),1,'first'), find(RLon>=Opt.boundingBox(2,2),1,'first')];
end

if (~isfield(Opt,'boundingBoxRaster') || ...
    isempty(Opt.boundingBoxRaster) )
    % calculating the bounding box
    Opt.boundingBoxRaster=[RLat(Opt.boundingBoxIDX(1,1)),RLon(Opt.boundingBoxIDX(1,2)); ...
                           RLat(Opt.boundingBoxIDX(2,1)),RLon(Opt.boundingBoxIDX(2,2))];
end
%%
if ( ~isfield(Opt,'ellipsoidName') || ...
     isempty(Opt.ellipsoidName) )
  Opt.ellipsoidName='wgs84';
end
if ( ~isfield(Opt,'ellips') || ...
     isempty(Opt.ellips) )
  Opt.ellips = referenceEllipsoid(Opt.ellipsoidName,'meter');
end
if ( ~isfield(Opt,'polyArea') || ...
     isempty(Opt.polyArea) )
  Opt.polyArea = sum(areaint(PLat,PLon,Opt.ellips));
end

%% Getting AreaOverlap if needed
if (~ismember(lower(Operation),{'aggregate','average','majority'}))
    if ( ~isfield(Opt,'overlapArea') || ...
         isempty(Opt.overlapArea) )


      nRows=Opt.boundingBoxIDX(2,1)-Opt.boundingBoxIDX(1,1);
      nCols=Opt.boundingBoxIDX(2,2)-Opt.boundingBoxIDX(1,2);

      overlapArea=NaN(nRows*nCols,1);
      minRowIDX=Opt.boundingBoxIDX(1,1);
      minColIDX=Opt.boundingBoxIDX(1,2);
      ellips=Opt.ellips;
      parfor pixelID=1:(nRows*nCols)
    %   for pixelID=1:(nRows*nCols)
        [rowID,colID]=ind2sub([nRows,nCols],pixelID);
        rowID=rowID-1;
        colID=colID-1;
        cellPolygon_lat=[RLat(minRowIDX+rowID); ...
                         RLat(minRowIDX+rowID); ...
                         RLat(minRowIDX+rowID+1); ...
                         RLat(minRowIDX+rowID+1)]; %#ok<PFBNS>
        cellPolygon_lon=[RLon(minColIDX+colID); ...
                         RLon(minColIDX+colID+1); ...
                         RLon(minColIDX+colID+1); ...
                         RLon(minColIDX+colID)]; %#ok<PFBNS>

        % overlapped area
        [overlap_lon,overlap_lat] = polybool('intersection',PLon,PLat,cellPolygon_lon,cellPolygon_lat);

        if (~isempty(overlap_lat) || ~isempty(overlap_lon))
          tmpAreaArray = areaint(overlap_lat,overlap_lon,ellips);
          isHole = ispolycw(overlap_lon,overlap_lat);
          isHole(isHole == 0) = -1; % deducting the hole areas.
          overlapArea(pixelID)=sum(tmpAreaArray.*isHole(:));
        else
          overlapArea(pixelID)=0;
        end

      end
      Opt.overlapArea=reshape(overlapArea,nRows,nCols);
    end
end

%%
rowIDList=Opt.boundingBoxIDX(1,1):(Opt.boundingBoxIDX(2,1)-1);
colIDList=Opt.boundingBoxIDX(1,2):(Opt.boundingBoxIDX(2,2)-1);

switch (lower(Operation))
  case ('aggregatebyarea')
      output = nansum( nansum( bsxfun(@times,RData(rowIDList,colIDList,:),Opt.overlapArea), 1),2);
%       resizedOverLappedArea = repmat(Opt.overlapArea,1,1,size(RData,3));
%       output = sum( sum( RData(rowIDList,colIDList,:).*resizedOverLappedArea, 1),2);

  case 'averagebyarea'
      output = nansum( nansum(  bsxfun(@times,RData(rowIDList,colIDList,:),Opt.overlapArea) ,1),2)./sum(Opt.overlapArea(:));
%       resizedOverLappedArea = repmat(Opt.overlapArea,1,1,size(RData,3));
%       output = sum( sum(  RData(rowIDList,colIDList,:).*resizedOverLappedArea ,1),2)./sum(Opt.overlapArea(:));
    case 'aggregate'
        output = nansum(reshape(RData(rowIDList,colIDList,:),[],size(RData,3)));
    case 'average'
      output = nanmean(reshape(RData(rowIDList,colIDList,:),[],size(RData,3)));
  case 'majority'
      output = mode(reshape(RData(rowIDList,colIDList,:),[],size(RData,3)));
  otherwise
    error('Requested Operation is not recognized.')
end
