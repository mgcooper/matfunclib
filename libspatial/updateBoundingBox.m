function S = updateBoundingBox(S,varargin)
   %UPDATEBOUNDINGBOX update BoundingBox property of geostruct S
   %
   %  S = updateBoundingBox(S)
   %  S = updateBoundingBox(S, latfieldname, lonfieldname)
   % 
   % See also: geostructinit, isgeostruct

   if nargin > 1
      xfield = varargin{1};
      yfield = varargin{2};
   else
      xfield = getCoordFieldName(S,{'X','Lon'});
      yfield = getCoordFieldName(S,{'Y','Lat'});
   end

   X = {S.(xfield)};
   Y = {S.(yfield)};

   for n = 1:numel(X)
      S(n).BoundingBox = [min(X{n}), min(Y{n}); max(X{n}), max(Y{n})];
   end
   % Set all BoundingBox fields to the computed bounding box
   % BoundingBox = [ min(X(:)), min(Y); max(X), max(Y)];
   %[S.BoundingBox] = deal(BoundingBox);

   S = reorderShapeFields(S,xfield,yfield);
end

function S = reorderShapeFields(S,xfield,yfield)
   C = fieldnames(S);
   P = [find(ismember(C,'Geometry')),find(ismember(C,'BoundingBox')),...
      find(ismember(C,xfield)),find(ismember(C,yfield))];
   P = cat(2,P,setdiff(1:numel(C),P));
   S = orderfields(S,P);
end

function name = getCoordFieldName(S, names)
   name = [];
   fields = fieldnames(S);
   for i=1:length(names)
      if any(strcmp(names{i},fields))
         name = names{i};
         break
      end
   end
end
