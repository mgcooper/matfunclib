function S = prepLatLonFields(S, newfieldnames)
   %PREPLATLONFIELDS Detect and rename latitude/longitude fields in struct S
   %
   %  S = PREPLATLONFIELDS(S)
   %  S = PREPLATLONFIELDS(S, {'Lat','Lon'})
   %
   % Example
   %
   %
   % Matt Cooper, 25-Jan-2023, https://github.com/mgcooper
   %
   % See also: latlonFromGeoStruct, isgeostruct

   % NOTE: this mainly exists to convert standard lat/lon names like Latitude
   % Longitude to Lat Lon for compatibility with geopoint. Need to add
   % additional checks around

   % parse arguments
   arguments
      S (:,:) struct
      newfieldnames (1,2) cell = {'Lat', 'Lon'}
   end

   % set defaults
   latfields = {'LATITUDE','Lat','latitude','lat','LAT','Latitude'};
   lonfields = {'LONGITUDE','Lon','longitude','lon','LON','long','LONG','Longitude'};
   xfields = {'X','x'};
   yfields = {'Y','y'};
   fields = fieldnames(S);
   useX = false;
   useY = false;

   % first get all lat/lon fields (in case there is more than one)
   %------------------------------------------------------------
   if sum(contains(fields, latfields)) > 0

      ilat = find(contains(fields, latfields));

   elseif sum(contains(fields, yfields)) > 0 % check for Y

      ilat = find(contains(fields, yfields));
      useY = true;

      warning('no lat coordinates found, using Y coordinates')

   else
      error('no lat coordinates found');
   end

   % repeat for Lon
   %------------------------------------------------------------
   if sum(contains(fields, lonfields)) > 0

      ilon = find(contains(fields, lonfields));

   elseif sum(contains(fields, xfields)) > 0

      ilon = find(contains(fields,xfields));
      useX = true;
      warning('no lon coordinates found, using X coordinates');
   else
      error('no lon coordinates found');
   end

   % now pick one field to use as lat lon
   %------------------------------------------------------------

   % if there is both an 'Y' and 'y' field, need to choose one
   if useX == true && useY == true
      newfieldnames = {'Y', 'X'};
   else
      % for lat/lon there are more options, but use default Lat/Lon
   end

   % rename them to 'Lat' and 'Lon' for compatibility with geopoint, unless
   % newfieldnames were given e.g., 'lat', 'long' for compatibility with
   % updategeostruct.

   % if multiple fields names contain 'Lat', pick the one that is 'Lat' or
   % 'Latitude', otherwise issue an error
   ilatkeep = nan;

   % THIS IS WHERE I NEED TO CHECK MORE VALUES B/C RIGHT NOW IT TRIES TO FIND A
   % FIELD ALREADY NAMED 'LAT/LON' AND CHOOSES THEM
   if numel(ilat) > 1
      for n = 1:numel(ilat)
         if strcmp(fields{ilat(n)}, newfieldnames(1)) % exact match
            ilatkeep = ilat(n);
         end
      end
      % having gone through all options, if
      if isnan(ilatkeep)
         error('no latitude field found, or multiple ambiguous fields found')
      else
         ilat = ilatkeep;
      end
   end

   % now rename to 'Lat', so don't use pickLat anymore
   if all(~ismember(fields(ilat), 'Lat'))

      S = renamestructfields(S, fields{ilat}, newfieldnames{1});

      % March 2024, renameNonScalarStructField is no longer present in the
      % function library, I think I made renamestructfields work for scalar and
      % non-scalar.
      % if isscalar(S)  % should never be true
      %    S = renamestructfields(S, fields{ilat}, newfieldnames{1});
      % else
      %    S = renameNonScalarStructField(S, fields{ilat}, 'Lat');
      % end
   end

   % repeat for Lon
   ilonkeep = nan;
   if numel(ilon) > 1
      for n = 1:numel(ilon)
         if strcmp(fields{ilon(n)}, newfieldnames(2))
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
   if all(~ismember(fields(ilon), newfieldnames(2)))
      S = renamestructfields(S, fields{ilon}, newfieldnames(2));

      % if isscalar(S)  % should never be true
      %    S = renamestructfields(S, fields{ilon}, 'Lon');
      % else
      %    S = renameNonScalarStructField(S,fields{ilon},'Lon');
      % end
   end
end
