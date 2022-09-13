clean

save_data = 0;
%%
path.data = '/Users/MattCooper/Dropbox/CODE/MATLAB/GREENLAND/Merra/data/';
path.save = '/Users/MattCooper/Dropbox/CODE/MATLAB/GREENLAND/Merra/data/';

%% load the list of files
list = dir(fullfile([path.data '*.nc4']));

%% notes on netcdf
% netcdf longitude is always in units degrees_east and degrees_north
% 

%% get ncinfo
info = ncinfo([path.data list(1).name]);

lat = ncread([path.data list(1).name],'lat');
lon = ncread([path.data list(1).name],'lon');
albedo = ncread([path.data list(1).name],'SNICEALB');
albedo = rot90_3D(albedo,3,1);
albedo = mean(albedo,3);
[LON,LAT] = meshgrid(lon,lat);
LAT = flipud(LAT);
contourf(LON,LAT,albedo)

% grid spacing is 0.5 lat and 0.625 lon
%%
lonlim = [min(lon) max(lon)];
latlim = [min(lat) max(lat)];
R = georefcells(latlim,lonlim,size(albedo));
figure; geoshow(albedo,R,'DisplayType','surface');

% for some reason it ends up upside down, whereas built-in topo dataset
% plots correctly. 

% compare to built in topo example, topo must be oriented S-N
load topo;
Rtopo = georefcells(topolatlim,topolonlim,size(Z));
figure; geoshow(topo,Rtopo,'DisplayType','surface');