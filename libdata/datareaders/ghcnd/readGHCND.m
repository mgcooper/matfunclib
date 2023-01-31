function [Data,Atts] = readGHCND(varargin)
%READGHCND read global hydroclimate network database file
% 
%  [Data,Atts] = readGHCND(varargin)
% 
% 
% 
% note: rather than use the api, i could download all the data:
% https://www.ncei.noaa.gov/pub/data/ghcn/daily/
% would be worth it for a larger-scale project

p = magicParser;
p.CaseSensitive=false;
p.FunctionName=mfilename;
p.addParameter('station','USC00505136',@(x)ischarlike(x));
p.addParameter('name','none',@(x)ischarlike(x));
p.addParameter('lat',nan,@(x)isnumeric(x));
p.addParameter('lon',nan,@(x)isnumeric(x));
p.addParameter('latbuffer',0,@(x)isnumeric(x));
p.addParameter('lonbuffer',0,@(x)isnumeric(x));
p.addParameter('t1',NaT,@(x) isdatetime(x)|isnumeric(x));
p.addParameter('t2',NaT,@(x) isdatetime(x)|isnumeric(x));
p.parseMagically('caller');

% I had this note in a text file, I think it was in ref to the 'station' param
% in the json file, so i updated the input parser here with charlike and added
% it to the json file which before was just "char". UPDATE I think the problem
% is that ghcnd_stationlist is a cellstr with 118,492 eleements so autocomplete
% just doesn't work
% # try this for readGHCND
% ["char"], ["string"], ["cellstr"]

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
url   = 'https://www.ncei.noaa.gov/data/daily-summaries/access/';
url   = [url station '.csv'];

% this should work to get around the ssl certificate failure
opts  = weboptions; opts.CertificateFilename=('');

Data  = webread(url,opts);

% subset the data, metadata, and attributes
attvars  = {'PRCP_ATTRIBUTES','SNOW_ATTRIBUTES','SNWD_ATTRIBUTES', ...
   'TMAX_ATTRIBUTES','TMIN_ATTRIBUTES','TOBS_ATTRIBUTES'};
metavars = {'NAME','STATION','LATITUDE','LONGITUDE','ELEVATION'};
datavars = {'DATE','PRCP','SNOW','SNWD','TMAX','TMIN','TOBS'};
Atts     = Data(:,attvars);
Meta     = Data(1,metavars);
Data     = Data(:,datavars);

% the PRCP data is in tenths of milimeters, divide by 10 to get mm
Data.PRCP   = Data.PRCP./10;
Data.SNOW   = Data.SNOW./10;
Data.SNWD   = Data.SNWD./10;

% the Temp data is in tenths of celsius, divide by 10 to get celsius
Data.TMAX   = Data.TMAX./10;
Data.TMIN   = Data.TMIN./10;
Data.TOBS   = Data.TOBS./10;

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








