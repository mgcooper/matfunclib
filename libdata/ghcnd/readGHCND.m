function varargout = readGHCND(varargin)
   %READGHCND Read global hydroclimate network database file
   %
   %  [stationlist] = readGHCND('stationlist')
   %  [stationnames] = readGHCND('stationnames')
   %  [Data, Atts] = readGHCND('station', stationNumber)
   %  [Data, Atts] = readGHCND('name', stationName)
   %  [Data, Atts] = readGHCND(_, 't1', time1, 't2', time2)
   %  [Data, Atts] = readGHCND(_, 'lat', lat, 'lon', lon)
   %
   % See also:
   
   % From the main noaa coop webpage:
   % https://www.ncei.noaa.gov/products/land-based-station/cooperative-observer-network
   %
   % Click on the link to the daily summaries:
   % https://www.ncei.noaa.gov/data/daily-summaries/
   % 
   % From there download the ghcnd-stations.txt file and the documentation, and
   % the syntax for the csv files url

   % note: rather than use the api, i could download all the data:
   % https://www.ncei.noaa.gov/pub/data/ghcn/daily/
   % would be worth it for a larger-scale project
   
   if nargin == 1 % && nargout == 1
      switch varargin{1}
         case 'stationlist'
            load('ghcndstations.mat', 'ghcndstationlist');
            varargout{1} = ghcndstationlist;
            return
         case 'stationnames'
            load('ghcndstations.mat', 'ghcndstationnames')
            varargout{1} = ghcndstationnames;
            return
         otherwise
      end
   end

   % PARSE INPUTS
   [station, name, lat, lon, latbuffer, lonbuffer, t1, t2] = ...
      parseinputs(varargin{:});

   % if lat is provided, make sure lon is too
   if ~isnan(lat) && isnan(lon)
      error('provide both lat and lon');
   end

   % if station is provided and lat/lon is also provided

   % if lat/lon is provided with no buffer, find the nearest station
   load('ghcnd-stations.mat','Meta');

   % if station name is provided, use it
   if strcmp(station,'none') == false
      idx = find(ismember(Meta.STATION,station));
   end

   % build the url using the station name
   url = 'https://www.ncei.noaa.gov/data/daily-summaries/access/';
   url = [url station '.csv'];

   % this should work to get around the ssl certificate failure
   opts = weboptions; opts.CertificateFilename=('');

   Data = webread(url,opts);

   % subset the data, metadata, and attributes
   attvars = {'PRCP_ATTRIBUTES','SNOW_ATTRIBUTES','SNWD_ATTRIBUTES', ...
      'TMAX_ATTRIBUTES','TMIN_ATTRIBUTES','TOBS_ATTRIBUTES'};
   metavars = {'NAME','STATION','LATITUDE','LONGITUDE','ELEVATION'};
   datavars = {'DATE','PRCP','SNOW','SNWD','TMAX','TMIN','TOBS'};
   Atts = Data(:,attvars);
   Meta = Data(1,metavars);
   Data = Data(:,datavars);

   % the PRCP data is in tenths of milimeters, divide by 10 to get mm
   Data.PRCP = Data.PRCP./10;
   Data.SNOW = Data.SNOW./10;
   Data.SNWD = Data.SNWD./10;

   % the Temp data is in tenths of celsius, divide by 10 to get celsius
   Data.TMAX = Data.TMAX./10;
   Data.TMIN = Data.TMIN./10;
   Data.TOBS = Data.TOBS./10;

   Data = table2timetable(Data,'RowTimes','DATE');
   Data = renametimetabletimevar(Data);
   Data = settableunits(Data,{'mm','mm','mm','C','C','C'});

   % add the metadata
   Data = addprop(Data,metavars,repmat({'table'},1,numel(metavars)));

   % update the properties
   for n = 1:numel(metavars)
      thisvar = Meta.(metavars{n});
      if iscell(thisvar)
         thisvar = thisvar{:};
      end
      Data.Properties.CustomProperties.(metavars{n}) = thisvar;
   end
   
   switch nargout 
      case 1
         varargout{1} = Data;
      case 2
         varargout{1} = Data;
         varargout{2} = Atts;
   end
end

%% INPUT PARSER
function [station, name, lat, lon, latbuffer, lonbuffer, t1, t2] = ...
      parseinputs(varargin)

   p = inputParser;
   p.CaseSensitive = false;
   p.FunctionName = mfilename;
   p.addParameter('station', 'USC00505136', @ischarlike);
   p.addParameter('name', 'none', @ischarlike);
   p.addParameter('t1', NaT, @isdatelike);
   p.addParameter('t2', NaT, @isdatelike);
   p.addParameter('lat', nan, @isnumeric);
   p.addParameter('lon', nan, @isnumeric);
   p.addParameter('latbuffer', 0, @isnumeric);
   p.addParameter('lonbuffer', 0, @isnumeric);
   p.parse(varargin{:});

   t1 = p.Results.t1;
   t2 = p.Results.t2;
   lat = p.Results.lat;
   lon = p.Results.lon;
   name = p.Results.name;
   station = p.Results.station;
   latbuffer = p.Results.latbuffer;
   lonbuffer = p.Results.lonbuffer;
end
