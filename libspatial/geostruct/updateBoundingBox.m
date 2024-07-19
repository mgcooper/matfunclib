function S = updateBoundingBox(S, varargin)
   %UPDATEBOUNDINGBOX update BoundingBox property of geostruct S
   %
   %  S = updateBoundingBox(S)
   %  S = updateBoundingBox(S, latfieldname, lonfieldname)
   %
   % See also: geostructinit, isgeostruct

   % Convert table to geostruct. TODO: Either preserve table props or refactor
   % subfunctions to work with tables. Latter appears straightforward here.
   wastabular = istabular(S);
   if wastabular
      try
         S = table2struct(S);
      catch e
         rethrow(e) % throw for now, add handling later
      end
      warning('Converting input argument 1, S, from table to struct. Custom properties are not preserved.')
   end

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

   % Send it back as it came
   if wastabular
      try
         S = struct2table(S);
      catch e
         rethrow(e) % throw for now, add handling later
      end
   end
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
