function coords = writeGeoShapefile(S,filename,varargin)
%WRITEGEOSHAPEFILE write a shapefile in geographic coordinate format
%
%  coords = writeGeoShapefile(S,filename,varargin)
%
% See also

%--------------------------------------------------------------------------
p=magicParser;
p.FunctionName='writeGeoShapefile';
p.CaseSensitive=false;
p.PartialMatching=true;
p.addRequired('S',@(x)isstruct(x)|istable(x)|ischar(x)|isa(x,'geopoint')|...
   isa(x,'mappoint')|isa(x,'geoshape')|isa(x,'mapshape'));
p.addRequired('filename',@(x)ischar(x));
p.addParameter('Geometry','Point',@(x)ischar(x));
p.addParameter('plotshp',false,@(x)islogical(x));
p.addParameter('lat',nan,@(x)isnumeric(x));
p.addParameter('lon',nan,@(x)isnumeric(x));
p.parseMagically('caller');
%--------------------------------------------------------------------------

saveshp = true;

% NEW sep 2022 - added isgeostruct
if isa(S,'geopoint') || isa(S,'mappoint') || isa(S,'geoshape') || ...
      isa(S,'mapshape') || isgeostruct(S)

   shapewrite(S,filename);
   copygeoprjtemplate(filename);
   return;
end

% NOTE: for a geostruct, size(S) = [1,numfeatures], but below I use
% [npts,natts] = size(S) (npts is the same thing as numfeatures). it
% doesn't seem to break anything b/c natts isn't used, and npts is only
% used for the case where geometry is missing, which won't be the case
% for geostructs. But it would be good to identify if the input is a
% geostruct, just like above where I identify if it is a geoshape, and
% write it straight to shapefile

if ischar(S) || isstring(S)
   % read in the data
   coords   = table2struct(readtable(S));
elseif istable(S)
   coords   = table2struct(S);
elseif isstruct(S)
   coords   = S;
else
   error('first input must be a filename to a table or a data table');
end

fields = fieldnames(coords);


% make sure there are lat/lon fields of some sort
if ~isnan(lat)
   % this means lat lon were provided
   coords.Lat  = lat;
   coords.Lon  = lon;
else
   coords = preplatlon(fields,coords);
end



[npts,natts] = size(coords);

% add a Geometry field if missing
if ~isfield(coords,'Geometry')
   warning('no Geometry field, using default type point or user-provided type')
   for n = 1:npts
      coords(n).Geometry = Geometry;
   end
else
   Geometry = coords(1).Geometry;
end

% convert to geopoint/shape
switch lower(Geometry)

   case 'point'
      coords = geopoint(coords);
   case 'line'
      coords = geoshape(coords); % default geometry is line
   case 'polygon'
      coords = geoshape(coords);
      coords.Geometry = 'polygon';
end

if plotshp

   figure;

   switch lower(geometry)
      case 'point'
         geoscatter(coords.Latitude,coords.Longitude,'filled')
      case {'line','polygon'}
         geoshow(coords.Latitude,coords.Longitude);
   end

end


if saveshp == true
   shapewrite(coords,filename);
   copygeoprjtemplate(filename);
end



function coords = preplatlon(fields,coords)

latfields   = {'LATITUDE','Lat','latitude','lat','LAT','Latitude'};
lonfields   = {'LONGITUDE','Lon','longitude','lon','LON','long','LONG','Longitude'};
xfields     = {'X','x'};
yfields     = {'Y','y'};

useX = false; useY = false;

% first get all lat/lon fields (in case there is more than one)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if sum(contains(fields,latfields)) > 0

   ilat  = find(contains(fields,latfields));

elseif sum(contains(fields,yfields)) > 0              % check for Y

   ilat  = find(contains(fields,yfields)); useY = true;

   warning('no lat coordinates found, using Y coordinates')

else
   error('no lat coordinates found');
end

% repeat for Lon
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if sum(contains(fields,lonfields)) > 0

   ilon  = find(contains(fields,lonfields));

elseif sum(contains(fields,xfields)) > 0

   ilon  = find(contains(fields,xfields)); useX = true;

   warning('no lon coordinates found, using X coordinates');

else
   error('no lon coordinates found');
end


% now pick one field to use as lat lon
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if useX == true && useY == true

   % if there is both an 'Y' and 'y' field, need to choose one
   pickLat  = {'Y'};
   pickLon  = {'X'};

else
   % for lat/lon there are more options, but use Lat/Lon
   pickLat  = {'Lat'};
   pickLon  = {'Lon'};
end

% rename them to 'Lat' and 'Lon' for compatibility with geopoint

% if multiple fields names contain 'Lat', pick the one that is 'Lat' or
% 'Latitude', otherwise isue an error
ilatkeep = nan;

if numel(ilat) > 1
   for n = 1:numel(ilat)
      %          if strcmp(fields{ilat(n)},'Lat') || strcmp(fields{ilat(n)},'Latitude')
      if strcmp(fields{ilat(n)},pickLat) % exact match
         ilatkeep = ilat(n);
      end
   end
   % having gone through all options, if
   if isnan(ilatkeep)
      error('no latitude field found, or multiple fields found')
   else
      ilat = ilatkeep;
   end
end

% now rename to 'Lat', so don't use pickLat anymore
if all(~ismember(fields(ilat),'Lat'))
   if isscalar(coords)  % should never be true
      coords = renamestructfields(coords,fields{ilat},'Lat');
   else
      coords = renameNonScalarStructField(coords,fields{ilat},'Lat');
   end
end

% repeat for Lon
ilonkeep = nan;
if numel(ilon) > 1
   for n = 1:numel(ilon)
      % if strcmp(fields{ilon(n)},'Lon') || strcmp(fields{ilon(n)},'Longitude')
      if strcmp(fields{ilon(n)},pickLon)
         ilonkeep = ilon(n);
      end
   end
   % having gone through all options, if
   if isnan(ilonkeep)
      error('no longitude field found, or multiple fields found')
   else
      ilon = ilonkeep;
   end
end

% now rename to 'Lat' or 'Lon', so don't use pickLat/Lon anymore
if all(~ismember(fields(ilon),'Lon'))
   if isscalar(coords)  % should never be true
      coords   = renamestructfields(coords,fields{ilon},'Lon');
   else
      coords   = renameNonScalarStructField(coords,fields{ilon},'Lon');
   end
end
