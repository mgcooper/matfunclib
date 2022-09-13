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

%% apply rasterref
R = rasterref(LON,LAT);
Rpost = rasterref(LON,LAT,'Postings');
Rcell = rasterref(LON,LAT,'Cells');

%%
latmax = max(lat);
latmin = min(lat);
lonmax = max(lon);
lonmin = min(lon);
latcellsize = lat(2)-lat(1);
loncellsize = lon(2)-lon(1);
nlatcells = (latmax-latmin)*(1/latcellsize) + 1;
nloncells = (lonmax-lonmin)*(1/loncellsize) + 1;

%% Kang's lat/lon
lat = 66.896;
lon = -48.68;

[rpost,cpost] = latlon2pix(Rpost,lat,lon);
[rcell,ccell] = latlon2pix(Rcell,lat,lon);

redge = 1 + (latmax - lat)/latcellsize
rcentroid = redge + 0.5

cedge = 1 + abs(lonmin-lon)/loncellsize
ccentroid = cedge + 0.5

%% More complicated - use both lat/lons for duplicate

lat1 = 66.896;
lon1 = -48.68;

lat2 = 67.164;
lon2 = -48.551;

[r1post,c1post] = latlon2pix(Rpost,lat1,lon1);
[r1cell,c1cell] = latlon2pix(Rcell,lat1,lon1);
[r2post,c2post] = latlon2pix(Rpost,lat2,lon2);
[r2cell,c2cell] = latlon2pix(Rcell,lat2,lon2);

% by my calculation it should be:
% if the lat/lon values are the grid cell centroids, then:
% r1 = (latmax - lat1)/latcellsize - latcellsize/2
r1edge = (latmax - lat1)/latcellsize
r1centroid = (latmax + latcellsize/2 - lat1)/latcellsize

r1edge - r1cell
r1edge - r1post % -1

r1centroid - r1cell % -0.12835
r1centroid - r1post % -0.5

r1cellerror = r1 - r1cell % just about the cell size

val1 = ltln2val(albedo, R, lat1, lon1)
val2 = ltln2val(albedo, R, lat2, lon2)

%
c1edge = abs(lonmin-lon1)/loncellsize
c1centroid = c1edge + loncellsize/2

%%

% note: R.CellExtentInLongitude should equal:
        % (R.LongitudeLimits(2)-R.LongitudeLimits(1))/R.RasterSize(2)
        % but unless pre-processing is performed on standard netcdf or h5
        % grid to adjust for edge vs centroid, a 'cells' interpretation
        % gets it wrong
        
% the Merra 2 grid extends from -180 to 179.375, where -180 is the center 
% of the grid cell, which could be interpreted as a posting. I would like
% to avoid the need to think about this every time I read in a netcdf or h5
% gridded dataset. If i use georefpostings, it all comes out fine but
% subsequent functions 
        
% Summary of this issues;
% If I use georefcells, it gets RasterSize correct but cell extent wrong
% because it thinks lat/lon limits are the outer edges of the cells

% If I use georefpostings, it gets it all correct but R is a georefpostings
% object which presents some other compatibility issues 

% One way to get around it is to adjust the lat/lonlims by 1/2*cellsize
% but this becomes an error for lat/lon limits -90:90 because the cell
% edges cannot extend beyond those values

% The basic issue is that most global gridded datasets have wrap-around
% grids such that for latitude -90:cellsize:90 you have 
% (latmax-latmin)*1/cellsize+1 cells

latmax = max(lat);
latmin = min(lat);
lonmax = max(lon);
lonmin = min(lon);
latcellsize = lat(2)-lat(1);
loncellsize = lon(2)-lon(1);
nlatcells = (latmax-latmin)*(1/latcellsize) + 1;

% it's that +1 that causes the trouble. 

% grid spacing is 0.5 lat and 0.625 lon but Rtest 
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

%%