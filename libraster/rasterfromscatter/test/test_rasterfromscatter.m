clean

% this function was inspired by my struggles with the MAR data that came on
% an irregular lat/lon grid, and the x/y grid was 'regular' but was in
% intrinsic coordinates not projected (psn) coordinates

%%
homepath            =   pwd;

if strcmp(homepath(2:6),'Users')
    path.data   =   '/Volumes/GDRIVE/DATA/mar3.11/';
    path.save   =   ['/Users/mattcooper/Dropbox/CODE/MATLAB/GREENLAND/' ...
                        'runoff/data/mar/'];
    path.figs   =   ['/Users/mattcooper/Dropbox/CODE/MATLAB/GREENLAND/' ...
                        'runoff/figs/'];
end

%% load the MAR variables
list            =   dir(fullfile([path.data '*.nc']));
info            =   ncinfo([path.data list(1).name]);
data.y          =   double(ncread([path.data list(1).name],'Y21_199'));
data.x          =   double(ncread([path.data list(1).name],'X10_105'));
data.LAT        =   double(flipud(permute(ncread([path.data list(1).name], ...
                    'LAT'),[2 1])));
data.LON        =   double(flipud(permute(ncread([path.data list(1).name], ...
                    'LON'),[2 1])));

%% spatial referencing

% the x,y are intrinsic, so here I have to project the lat/lon to psn
lat             =   reshape(data.LAT,size(data.LAT,1)*size(data.LAT,2),1);
lon             =   reshape(data.LON,size(data.LON,1)*size(data.LON,2),1);

%% test geoloc2grid vs imbedm

% load the runoff and reshape it to an array
runoff          =   double(ncread([path.data list(1).name],'RUH'));
runoff          =   squeeze(runoff(:,:,:,1));
runoff          =   flipud(permute(runoff,[2 1 3]));
runoff          =   mean(runoff,3);
z               =   reshape(runoff,size(runoff,1)*size(runoff,2),1);

% the data includes zeros, which messes with the interpolation
idx             =   (z ~= 0); %logical mask to keep nonzeros in z
loni            =   lon(idx);
lati            =   lat(idx);
zi              =   z(idx);

% Arghh maybe this will not work. The indices that are equal to zero in the
% scattered grid are not the same as the indices in the query grid. I could
% use a nearest neighbor approach that figures out which query grid points
% ARE in the scattered 

% DOUBLE ARGHH I was interpolating onto the original data points

% maybe I could use imbedm to put the zeros back

% in the methods below, I will interpolate the data onto the full grid
% (lon,lat) using only the data ~=0

% there are a number of methods for interpolating the data:
% 1. griddata
% 2. scatteredInterpolant
% 3. geoloc2grid
% 4. imbedm

% there is also interp2 but i will ignore it for now

% For each method, I need the query points, which are the regularly spaced
% gridded coordinates, and the desired cellsize.

% in my case I know the size I want, for the general case, I might want to
% be able to just specify the cell size. I guess rastersize is basicall
rastersize      =   size(data.LAT);

% if I require rastersize, I can use meshgrat. If I allow cellsize, I need
% to deal with different x/y size, which geoloc2grid deals with, and I need
% to build the grid using meshgrid

% Extend limits to even degrees in lat and lon
latlims         =   [floor(min(lat(:))) ceil(max(lat(:)))];
lonlims         =   [floor(min(lon(:))) ceil(max(lon(:)))];
[latg,long]     =   meshgrat(latlims,lonlims,4.*rastersize);

% reshape to arrays for interpolation
latq            =   reshape(latg,size(latg,1)*size(latg,2),1);
lonq            =   reshape(long,size(long,1)*size(long,2),1);

% create a reference object
R               =   georefcells(latlims,lonlims,rastersize);
Rq              =   georefcells(latlims,lonlims,4.*rastersize);
% [latg,long]     =   meshgrat(Ztest3,Rgeo); % option 2 
% I could also use grid2R to inherit functionality 

% for reference i think i wanted to compare these two 
% [latgrat,longrat]     =   meshgrat(Ztest3,Rq);
% [latgrid,longrid]     =   meshgrid(lon,lat);

%% try chad greene's function

% scatter(x,y,5,z,'filled') 
% colorbar
% 
% [X,Y,Z] = xyz2grid(x,y,z);
% 
% figure;
% worldmap('Greenland')
% pcolorm(Y,X,Z);

%% can I just use boundary? or inpolygon?

%% compare the different options

% Reference plot - raw data using projected worldmap
figure;
worldmap('Greenland')
pcolorm(data.LAT,data.LON,runoff);
title('pcolorm, raw data');
colorbar; [cmin, cmax] = caxis;

% 1. griddata. note, only 'natural' preserves edge values. 'v4' is ok but
% very slow
method          =   'natural';
Ztest1          =   griddata(lon,lat,z,lonq,latq,method);
Ztest1          =   reshape(Ztest1,size(long,1),size(long,2));
f1              =   figure;
m1              =   worldmap('Greenland');
p1              =   pcolorm(latg,long,Ztest1);
                    title('griddata');
                    colorbar; caxis([cmin cmax]);

% 2. scatteredInterpolant, no wrapping
% F               =   scatteredInterpolant(loni,lati,zi,'natural');
F               =   scatteredInterpolant(lon,lat,z,method,'none');
Ztest2          =   F(lonq,latq);
Ztest2          =   reshape(Ztest2,size(long,1),size(long,2));
f2              =   figure;
m2              =   worldmap('Greenland');
p2              =   pcolorm(latg,long,Ztest2);
                    title('scatteredInterpolant');
                    colorbar; caxis([cmin cmax]);

% 3. geoloc2grid - no option for 'method' so don't use
% [Ztest3,ref3]   =   geoloc2grid(lat,lon,z,0.1);
% f3              =   figure;
% p3              =   mapshow(Ztest3,ref3,'DisplayType','surface');
%                     title('geoloc2grid');
%                     colorbar; caxis([cmin cmax]);

% At one point I swear I got 
% 4. imbedm - first build a regular lat/lon grid

% 
Ztest4          =   nan(size(runoff));
Ztest4          =   imbedm(lat,lon,z,Ztest4,R);

% make a finer-resolution grid
% Ztest4          =   nan(Rq.RasterSize);
% Ztest4          =   imbedm(lat,lon,z,Ztest4,Rq);
f4              =   figure;
m4              =   worldmap('Greenland');
p4              =   pcolorm(latg,long,Ztest4);
                    title('imbedm');
                    colorbar; caxis([cmin cmax]);

%% test the function

% rastersize and cell extent
rastersize      =   Rq.RasterSize;
cellextentX     =   0.2;
cellextentY     =   0.05;

% raster size, no method
[Z1,R1]         =   rasterfromscatter(lon,lat,z,rastersize);
% cell extents, no method
[Z2,R2]         =   rasterfromscatter(lon,lat,z,cellextentX,cellextentY);
% raster size, 'linear'
[Z3,R3]         =   rasterfromscatter(lon,lat,z,rastersize,'linear');
% cell extents, no method
[Z4,R4]         =   rasterfromscatter(lon,lat,z,cellextentX,cellextentY,'linear');


figure; worldmap('Greenland')
meshm(Z1,R1);
title('Raster Size, default method');

figure; worldmap('Greenland')
meshm(Z2,R2);
title('Cell Extent, default method');

figure; worldmap('Greenland')
meshm(Z3,R3);
title('Raster Size, optional method');

figure; worldmap('Greenland')
meshm(Z4,R4);
title('Cell Extent, optional method');

%% now try with map data

load('Rracmo');

% get x,y, rastersize and cell extent
[x,y]           =   ll2psn(lat,lon);
rastersize      =   [500 800];
cellextentX     =   1000;
cellextentY     =   1000;

% raster size, no method
[Z1,R1]         =   rasterfromscatter(x,y,z,rastersize);
% cell extents, no method
[Z2,R2]         =   rasterfromscatter(x,y,z,cellextentX,cellextentY);
% raster size, 'linear'
[Z3,R3]         =   rasterfromscatter(x,y,z,rastersize,'linear');
% cell extents, no method
[Z4,R4]         =   rasterfromscatter(x,y,z,cellextentX,cellextentY,'linear');

figure;
rastersurf(Z1,R1);
title('Raster Size, default method');

figure;
rastersurf(Z2,R2);
title('Cell Extent, default method');

figure;
rastersurf(Z3,R3);
title('Raster Size, optional method');

figure;
rastersurf(Z4,R4);
title('Cell Extent, optional method');

%%  notes on the different mthods

% Z = imbedm(lat, lon, value, Z, R)
% F = scatteredInterpolant(lon,lat,v)
% Vq = geointerp(V,R,latq,lonq)

% imbedm accepts scattered lat/lon/values and imbeds them into the grid
% Z/R using nearest neighbor

% geointerp accepts grid V/R and returns interpolated values at latq/lonq

% scatteredInterpolant accepts scattered x/y/v values and creates an
% interpolant object F which can be evaluated at gridded values in Z/R

% The imbedm method could work, but since it uses nearest neighbor it is
% suboptimal. I figured 

% geointerp and mapinterp both use griddedInterpolant

% I have scattered lat/lon/z values. I want to grid them using bilinear
% interpolation onto a regular grid. 
