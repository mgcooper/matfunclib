function [outputArg1,outputArg2] = rasterget(instruct,shapemask)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

% sensor = 'SMAP', 'MODIS', 'ICESat-2', 'ICESat', 'AMSR-E', 'VIIRS';
% instruct = structure with the following fields:
%   instruct.bounding_box = [left bottom right top]
%   instruct.bbox = [left bottom right top]
%   


% The programmatic access structure is as follows:
% https://n5eil02u.ecs.nsidc.org/egi/request?<kvp operands separated with &>

%   Example 1 
%   ---------
%   % SMAP L3 Radiometer Global Daily 36 km EASE-Grid Soil Moisture,
%   % Version 5, GeoTIFF reformatting, spatial subsetting*, parameter
%   % subsetting, and Geographic reprojection for all data collected
%   % 2008-06-06 to 2018-06-07 over Colorado:
%        ['https://n5eil02u.ecs.nsidc.org/egi/request?' ...
%             'short_name=SPL3SMP' ...
%             '&version=005' ...
%             '&format=GeoTIFF' ...
%             '&time=2018-06-06,2018-06-07' ...
%             '&bounding_box=-109,37,-102,41' ...
%             '&bbox=-109,37,-102,41' ...
%             '&Coverage=/Soil_Moisture_Retrieval_Data_AM/soil_moisture' ...
%             '&projection=Geographic' ...
%             '&email=yes' ...
%             '&token=75E5CEBE-6BBB-2FB5-A613-0368A361D0B6'];

%   Example 2 
%   ---------
%   % ATLAS/ICESat-2 L3A Land Ice Height, Version 1, with variable
%   % subsetting % for all data over the Barnes Ice Cap using an uploaded
%   % shapefile* of the % ice cap boundary:
%         ['curl -O -J -F "shapefile=@barnes_shapefile.zip" ' ...
%             '"https://n5eil02u.ecs.nsidc.org/egi/request?' ...
%             'short_name=ATL06' ...
%             '&version=001' ...
%             '&polygon=-74.886,69.408,-71.681,69.408,-71.681,70.62,-74.886,70.62,-74.886,69.408' ...
%             '&coverage=/gt1l/land_ice_segments/h_li,/gtl1/land_ice_segments/latitude,/gtl1/land_ice_segments/longitude,/gtlr/land_ice_segments/h_li,/gtlr/land_ice_segments/latitude,/gtlr/land_ice_segments/longitude,/gt2l/land_ice_segments/h_li,/gt21/land_ice_segments/latitude,/gt21/land_ice_segments/longitude,/gt2r/land_ice_segments/h_li,/gt2r/land_ice_segments/latitude,/gt2r/land_ice_segments/longitude,/gt31/land_ice_segments/h_li,/gt31/land_ice_segments/latitude,/gt31/land_ice_segments/longitude,/gt3r/land_ice_segments/h_li,/gt3r/land_ice_segments/latitude,/gt3r/land_ice_segments/longitude,/quality_assessment' ...
%             '&email=yes' ...
%             '&token=75E5CEBE-6BBB-2FB5-A613-0368A361D0B6"'];
        
% list of available short names
short_names = {'SPL3SMP'; 
    
% user needs curl, and matlab needs to know where curl is
% which curl

% if no token is given, issue instructions for how to make one:
% curl -X POST --header "Content-Type: application/xml" -d
% '<token><username>earthdata_login_user_name</username><password>earthdata_login_password</password><client_id>NSIDC_client_id</client_id><user_ip_address>your_origin_ip_address</user_ip_address>
% </token>' https://api.echo.nasa.gov/echo-rest/tokens

basestr = 'https://n5eil02u.ecs.nsidc.org/egi/request?';
str1 = 'short_name=';
str2 = '&version=';
str3 = '&format=';
str4 = '&time=';
str5 = '&bounding_box=';
str6 = '&bbox=';
str7 = '&Coverage=';
str8 = '&projection=';
str9 = '&email=';
str0 = '&token=';

short_name = 'SPL3SMP';
version = '005';
format = 'GeoTIFF';
time = '2018-06-06,2018-06-07';
bounding_box = '-109,37,-102,41';
bbox = '-109,37,-102,41';
coverage = '/Soil_Moisture_Retrieval_Data_AM/soil_moisture';
projection = 'Geographic';
email = 'yes';
token = '75E5CEBE-6BBB-2FB5-A613-0368A361D0B6';



str = [basestr str1 short_name str2 version str3 format str4 time str5 ...
        bounding_box str6 bbox str7 coverrage str8 projection str9 email ...
        str0 token];
    
outputArg1 = inputArg1;
outputArg2 = inputArg2;
end

