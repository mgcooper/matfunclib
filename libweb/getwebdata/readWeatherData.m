function wd = readWeatherData(stID)
% wd = readWeatherData(stID);
%
% Returns weather related data for the location specificied by its station
% ID stID. This weather data is retrived from the National Digital Forecast 
% Database XML Web Service by the National Weather Service (NWS)
% Details of this service can be found at: http://www.weather.gov/xml/
%
% This function produces the weather data in a Matlab friendly format. 
% One can invoke this function periodically and use the data to generate 
% trend graphs. 
%
% Input to the function is the station ID (case insensitive) specified as a 
% string. For example: 
%   'kmsp' = Minneapolis/St Paul International Airport
%   'kbos' = Boston, Logan International Airport
%   'kcmx' = Hancock, Houghton County Memorial Airport
%  
% See http://www.weather.gov/data/current_obs/ to search for the weather
% station of interest. 
%
% The function returns the data as a MATLAB structure with the following
% fields: 
% 		wd.observation_time:  Observation time in datenum format
% 		wd.temp_f: Temperature in F
% 		wd.wind_mph: Wind speed in MPH
% 		wd.pressure_in: Barometric pressure in inches
% 		wd.dewpoint_f:  Dewpoint in F
% 		wd.heat_index_f: Heat index in F
% 		wd.windchill_f: Wind chill in F
% 		wd.visibility_mi: Visibility in miles
%
%
% Notes: 
%   1. If the function cannot connect to the National Weather Server, then wd = []
%   2. It goes without saying, run this function on a machine connected to the Internet. 
%   3. If any of the data is not available, then the value shall be NaN. 
%   4. Default value for wd.observation_time is 0. 
%   5. This function may need modification, if the NWS changes its XML format. 
%   6. The function uses rather fragile xml parsing. Robustness can be
%      increased by using well published xml toolboxes. 
%   7. The function uses java io classes. 
%
% Usage: 
%   wd = READWEATHERDATA('ksmp');
%
% $Revision: 3 $
% $Date: 11/15/06 2:42p $
%

%% Attributes that shall be extracted from the weather service data server. 
myAttributes = {'observation_time', ...
    'temp_f',...
    'wind_mph',  ...
    'pressure_in', ...
    'dewpoint_f', ...
    'heat_index_f', ...
    'windchill_f',  ...
    'visibility_mi',...
    };
% Their data types. 
dataTypes = {'s','f','f','f','f','f','f','f'};



%% Locaion of the XML file.  
urlString = ['http://www.weather.gov/data/current_obs/', stID, '.xml'];

%% Use xmlRead to get the DOM object. 
try
    xDoc = xmlread(urlString);
    xRoot = xDoc.getDocumentElement;  %% The root node. 
catch
    fprintf('Could not connect to National Weather Server. Please try again later\n');
    fprintf('URL: %s', urlString);
    wd = [];
    return;
end

%% Scan the DOM and pick up elements of interest. 
for k = 1:length(myAttributes)
    node = xRoot.getElementsByTagName(myAttributes{k});
    if node.getLength > 0,
        if strcmpi(dataTypes{k}, 'f'),
            wd.(myAttributes{k}) = str2double(node.item(0).getTextContent);
        else
            wd.(myAttributes{k}) = char(node.item(0).getTextContent);
        end
    else
        wd.(myAttributes{k}) = nan;
    end
end

