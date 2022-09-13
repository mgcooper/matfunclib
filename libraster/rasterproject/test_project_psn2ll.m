% This script I am trying to unproject from polar sterographic north into
% lat lon using matlabs minvtran. I compare the output to chad greene's
% psn2ll. I get close, but the latitude is off by a few tenths of a degree.
% The .prj file for psn contains the following information:

% PROJCS["Polar_Stereographic",GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",
%     SPHEROID["WGS_1984",6378137.0,298.257223563]],
%     PRIMEM["Greenwich",0.0],
%     UNIT["Degree",0.0174532925199433]],
%     PROJECTION["Stereographic_North_Pole"],
%     PARAMETER["false_easting",0.0],
%     PARAMETER["false_northing",0.0],
%     PARAMETER["central_meridian",-45.0],
%     PARAMETER["standard_parallel_1",70.0],
%     UNIT["Meter",1.0]]

% looking at psn2ll, the spheroid parameters are correct. 

% WGS84 - radius: 6378137.0 eccentricity: 0.08181919
%   in Matlab: axes2ecc(6378137.0, 6356752.3142)
% Hughes ellipsoid - radius: 6378.273 km eccentricity: 0.081816153
%   Used for SSM/I  http://nsidc.org/data/polar_stereo/ps_grids.html
% International ellipsoid (following Snyder) - radius: 6378388.0 eccentricity: 0.0819919 

% phi_c = 70;   % standard parallel - this is different from Andy Bliss' function, which uses -70! 
% a = 6378137.0; % radius of ellipsoid, WGS84
% e = 0.08181919;% eccentricity, WGS84
% lambda_0 = -45;  % meridian along positive Y axis

% I know that the standard parallel = 70, central meridian = -45 but when I
% use 70 e.g. in the mstruct.origin = [70 -45 0] or [-70 -45 0] I get
% wildly icorrect, and when I use [90 -45 0] it is almost equivlent to
% psn2ll but the lat is off by a few tenths of a degree

% setting mstruct.mapparallels = 70 doesnt' change anything

% psnstruct.geoid gives:

% Code: 7030
%                  Name: 'World Geodetic System 1984'
%            LengthUnit: 'meter'
%         SemimajorAxis: 6378137
%         SemiminorAxis: 6356752.31424518
%     InverseFlattening: 298.257223563
%          Eccentricity: 0.0818191908426215
%          

% UPDATE 4/21/2020

% origin is [

% To understand projections in Matlab, pay attention to the section
% "Properties That Control the Map Projection" in the Map Axes Properties
% documentation:

% https://www.mathworks.com/help/map/ref/axesm-properties.html

% The properties that typically must be set to get the behavior you expect include:
% MapProjection
% Origin
% MapParallels
% Geoid

% in some cases you will need to set these:
% FalseEasting
% FalseNorthing
% Zone

% That's about it. The other features are either vary rarely needed or are
% srictly for display. 

% No doubt, the Mathworks engineers thought they were being really smart
% when they designed the Map Axis, but somehow they managed to make it way
% more complic

% Basically, Mathworks designed the Mapping Toolbox for true experts who
% have time to either learn or keep track of all the intricacies 




%%

wq7                     =   shaperead(['/Users/mattcooper/Google UCLA/ArcGIS/' ...
                                'Greenland/WQ7/15JUL18_WQ7_basin.shp']);

                      
psnstruct               =   defaultm('ups');
psnstruct.geoid         =   wgs84Ellipsoid;
psnstruct               =   defaultm(psnstruct);
psnstruct.falseeasting  =   0;
psnstruct.falsenorthing =   0;
psnstruct.origin        =   [90 -45 0];
psnstruct.mapparallels  =   90;

[wq7lat,wq7lon]         =   minvtran(psnstruct,wq7.X,wq7.Y);
[testlat,testlon]       =   psn2ll(wq7.X,wq7.Y);

geoshow(testlat,testlon)
hold on;
geoshow(wq7lat,wq7lon,'Color','r','LineStyle','--')


%% UPDATE 4/21/2020

% at some point, I think when I was making rasterfromscatter and digging
% into the in-built functions surfm, I noticed an undocumented
% feature of mfwdtran:

% NOTE: I went through every file in raster to find my notes when I was
% digging deep into surfacem but did not find any. This is a good example
% of when I do a deep dive into the mapping toolbox and lose the work
% because I do not properly document it. I need a single working script for
% experimenting with mapping toolbox. Whatever I learned is probably
% commented out at the end of one of the scripts, probably MAR

% this is copied from setm lines 239-251
vertices = get(hChild,'Vertices');
x = vertices(:,1);
y = vertices(:,2);
alt = vertices(:,3);
oldz = alt;
savepts = getm(hChild);
[lat,lon,alt] = minvtran(oldstruct,x,y,alt,'surface',savepts);                  
r = unitsratio(newstruct.angleunits, oldstruct.angleunits);
lat = r * lat;
lon = r * lon;

%  New projection
[x,y,z,savepts] = mfwdtran(newstruct,lat,lon,alt,'surface');  


% from line 80 of surfacem:

%  Project the surface data
[x, y, z, savepts] = mfwdtran(mstruct, lat, lon, alt, 'surface');

% note that 'alt' is zeros(size(lat))


%% Lets try it
clean

lat                     =   [70 69 68];
lon                     =   [-44 -43 -42];
[LON,LAT]               =   meshgrid(lon,lat);
Z                       =   magic(3);
mstruct                 =   defaultm('eqaazim');
mstruct.geoid           =   wgs84Ellipsoid;
mstruct.origin          =   [90 0 0];
mstruct                 =   defaultm(mstruct);

% [X,Y]                   =   mfwdtran(mstruct,LAT,LON);
% X                       =   roundn(X,0);
% Y                       =   roundn(Y,0);

[X,Y,Z,savepts]         =   mfwdtran(mstruct,LAT,LON,Z,'surface');
Y                       =   roundn(Y,0)
X                       =   roundn(X,0)
Z

% reshape X, Y, and Z for plotting later
Xrs                     =   reshape(X,size(X,1)*size(X,2),1);
Yrs                     =   reshape(Y,size(X,1)*size(X,2),1);
Zrs                     =   reshape(Z,size(X,1)*size(X,2),1);

xdiffs                  =   diff(X(1,:));
ydiffs                  =   diff(Y(:,1));

% this shows that the x,y data are separated by about 30,000 meters in the
% x-direction and about 80,000 meters in the y-direction

% you can build a new grid and interpolate to it
xres                    =   30000;
yres                    =   80000;
xhalf                   =   xres/2;
yhalf                   =   yres/2;
xmin                    =   min(X(:));
xmax                    =   max(X(:));
ymin                    =   min(Y(:));
ymax                    =   max(Y(:));
xlims                   =   [xmin-xhalf xmax+xhalf];
ylims                   =   [ymin-yhalf ymax+yhalf];

% 
xq                      =   xmin:xres:xmax;
yq                      =   ymin:yres:ymax;
if xmax>xq(end)
    xq(end+1)           =   xq(end)+xres;
end

if ymax>yq(end)
    yq(end+1)           =   yq(end)+yres;
end

% build a regular 'query' grid to interpolate onto
[Xq,Yq]                 =   meshgrid(xq,yq);
Yq                      =   flipud(Yq);
% reshape X, Y, and Z for 
Xqrs                    =   reshape(Xq,size(Xq,1)*size(Xq,2),1);
Yqrs                    =   reshape(Yq,size(Xq,1)*size(Xq,2),1);

% grid the data
method                  =   'linear';
Zqrs                    =   griddata(Xrs,Yrs,Zrs,Xqrs,Yqrs,method);
Zq                      =   reshape(Zqrs,size(Xq,1),size(Xq,2));

% this is what your re-projected data look like on top of the query grid 
figure;
scatter(Xqrs,Yqrs,200); hold on;
scatter(Xrs,Yrs,200,Zrs,'filled'); colorbar
clims = caxis;
xlims = get(gca,'XLim');
ylims = get(gca,'YLim');
title('Reprojected data and empty query grid')

%% 
figure;
scatter(Xqrs,Yqrs,200); hold on;
scatter(Xrs,Yrs,200,Zrs,'filled'); 
scatter(Xqrs(~isnan(Zqrs)),Yqrs(~isnan(Zqrs)),100,Zqrs(~isnan(Zqrs)),'filled')
scatter(Xqrs(~isnan(Zqrs)),Yqrs(~isnan(Zqrs)),200,Zqrs(~isnan(Zqrs)), ...
        'MarkerEdgeColor','r','LineWidth',2);
colorbar
caxis(clims);
title('Reprojected data and interpolated values on query grid')
%%
% figure
% mapshow(Xq,Yq,Zq,'DisplayType','texturemap','FaceAlpha','texturemap', ...
%     'AlphaData',double(~isnan(Zq))); hold on
% scatter(Xqrs,Yqrs,200);
% scatter(Xrs,Yrs,200,Zrs,'filled','MarkerEdgeColor','k'); 
% set(gca,'XLim',xlims,'YLim',ylims);
% scatter(Xqrs(~isnan(Zqrs)),Yqrs(~isnan(Zqrs)),200,Zqrs(~isnan(Zqrs)), ...
%         'MarkerEdgeColor','k','LineWidth',2);
% colorbar
% caxis(clims)

%% to get mapshow to display correctly, use rasterref
R                       =   rasterref(Xq,Yq,'cell');
figure
mapshow(Zq,R,'DisplayType','texturemap','FaceAlpha','texturemap', ...
    'AlphaData',double(~isnan(Zq))); hold on
scatter(Xqrs,Yqrs,200);
scatter(Xrs,Yrs,200,Zrs,'filled','MarkerEdgeColor','k'); 
set(gca,'XLim',xlims,'YLim',ylims);
scatter(Xqrs(~isnan(Zqrs)),Yqrs(~isnan(Zqrs)),200,Zqrs(~isnan(Zqrs)), ...
        'MarkerEdgeColor','k','LineWidth',2);
colorbar
caxis(clims)
axis normal
title('Reprojected data and interpolated values as grid cells')

%% use scatteredInterpolant instead to extrapolate
emethod                 =   'linear';
F                       =   scatteredInterpolant(Xrs,Yrs,Zrs,method,emethod);
Zq                      =   F(Xq,Yq);
Zqrs                    =   reshape(Zq,size(Xq,1)*size(Xq,2),1);

figure
mapshow(Zq,R,'DisplayType','texturemap','FaceAlpha','texturemap', ...
    'AlphaData',double(~isnan(Zq))); hold on
scatter(Xqrs,Yqrs,200);
scatter(Xrs,Yrs,200,Zrs,'filled','MarkerEdgeColor','k'); 
set(gca,'XLim',xlims,'YLim',ylims);
scatter(Xrs,Yrs,200,Zrs,'filled','MarkerEdgeColor','k'); 
colorbar
caxis(clims)
axis normal
title('Reprojected data and gridded interpolation + extrapolation')
% title('ScatteredInterpolant, nearest neighbor extrapolation');
%%
R               =   rasterref(lon,lat,'cell');
Z               =   nan(R.RasterSize);
Z               =   imbedm(lat,lon,z,Z,R);

figure;
scatter(lon,lat,200,z,'filled'); hold on;
axis image
set(gca,'XLim',lonlims,'YLim',latlims); 

figure;
geoshow(Z,R,'DisplayType','texturemap'); hold on;
geoshow(lat,lon,'Marker','o','LineStyle','none','MarkerFaceColor','k','MarkerEdgeColor','k')


% now you have a 

% this defines the cell edges, but we want the cell centers
% xq                      =   xlims(1):xres:xlims(2);
% yq                      =   ylims(1):yres:ylims(2);

% now I need to regularize the output
% xmin                    =   min(X2(:))
% xmax                    =   max(X2(:))
% 
% ymin                    =   min(Y2(:))
% ymax                    =   max(Y2(:))
% 
% xdiffs                  =   diff(X2(:))

% gradient

% cellextX                =   
%%
% it appears with minvtran I can have savepts in the input 

[LON,LAT,Z]            =   minvtran(mstruct,X,Y,Z,'surface',savepts);




%%
% In addition to illuminating some aspects of axesm and worldmap, this
% shows why Rio Behar appears to be oriented N-S when I reproject to polar
% azimuthal

%%
landareas = shaperead('landareas.shp','UseGeoCoords',true);

% With this one, I have to set the origin or i get an error
figure;
ax = worldmap('Greenland');
setm(ax,'MapProjection','eqaazim','Origin',[90 0 0],'MapLatLimit',[60 90])
geoshow(landareas)
title('worldmap then setm(eqaazim, Origin, MapLatLimit) then geoshow');

% if I just use default eqaazim, I seem to be centered on the equator
figure;
axesm('MapProjection','eqaazim');
geoshow(landareas)
title('axesm(eqaazim) then geoshow');

% but I can set the MapLatLimit without setting the origin
figure;
axesm('MapProjection','eqaazim','MapLatLimit',[60 90]);
geoshow(landareas)
title('axesm(eqaazim, MapLatLimit) then geoshow');

% if I use my mstruct, I get centered on the pole
figure;
axesm(mstruct)
geoshow(landareas)
title('axesm(mstruct) then geoshow');

% 
figure;
axesm(mstruct,'MapLatLimit',[60 90]);
geoshow(landareas)
title('axesm(mstruct, MapLatLimit) then geoshow');

%% try changing the origin

og = [45 0 0];
ogstr = [int2str(og(1)) ',' int2str(og(2)) ',' int2str(og(3))];
figure;
axesm('MapProjection','eqaazim','Origin',og)
geoshow(landareas)
title(['Origin = [' ogstr ']']);

og = [90 0 0];
ogstr = [int2str(og(1)) ',' int2str(og(2)) ',' int2str(og(3))];

figure;
axesm('MapProjection','eqaazim','Origin',og)
geoshow(landareas)
title(['Origin = [' ogstr ']']);

%% 4/24/2020

% another crack at the MAR data ... this time I had a moment of clarity
% regarding geoloc2grid. It turns out that this basically is the function I
% was looking for. I think I was confused about the cell size parameter, I
% thought it pertained to the input data, but it sets the spacing of the
% output data. 

% maybe I realized this all along. There is evidence of this in the fact
% that rasterfromscatter says it is an improved version of geoloc2grid. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clean

%%
path.data               =   '/Volumes/GDRIVE/DATA/mar3.11/old_data/RUH2/';
path.save               =   '/Volumes/GDRIVE/DATA/mar3.11/old_data/matfiles/';
fnames                  =   {'MARv3.11-ERA5-15km-2015.nc'; ...
                                'MARv3.11-ERA5-15km-2016.nc'};

%% 
list                    =   dir(fullfile([path.data '*.nc']));
fname                   =   [path.data list(1).name];
info                    =   ncinfo(fname);
lon                     =   double(flipud(permute(ncread(fname,'LON'),[2 1])));
lat                     =   double(flipud(permute(ncread(fname,'LAT'),[2 1])));
ymar                    =   double(ncread(fname,'Y21_199'));
xmar                    =   double(ncread(fname,'X10_105'));
swsd                    =   double(ncread(fname,'SWD'));
swsd                    =   squeeze(nanmean(swsd,3));
swsd                    =   flipud(permute(swsd,[2 1]));
swsdrs                  =   reshape(swsd,size(swsd,1)*size(swsd,2),1);
latrs                   =   reshape(lat,size(lat,1)*size(lat,2),1);
lonrs                   =   reshape(lon,size(lon,1)*size(lon,2),1);

% convert the intrincis x,y to a grid
[Xmar,Ymar]             =   meshgrid(xmar,ymar);
Ymar                    =   flipud(Ymar);

% convert the lat lon to psn
[xpsn,ypsn]             =   ll2psn(lat,lon);

%%

% convert to regular grid using geoloc2grid and compare with rasterfromscatter
method                  =   'natural'; % for comparison with geoloc default
methodextrap            =   'none';
cellsize                =   0.5;
tic
% [Z1,refvec1]            =   geoloc2grid(lat, lon, swsd, cellsize,method);
% R1                      =   refvecToGeoRasterReference(refvec1,size(Z1));
[Z1,R1]                 =   mygeoloc2grid(lat,lon,swsd,cellsize,method,methodextrap);
toc

tic
[Z2,R2,X2,Y2]           =   rasterfromscatter(lon,lat,swsd,size(Z1),method);
toc

Z3 = Z1-Z2;
max(Z3(:))

figure;
worldmap('Greenland')
geoshow(Z1,R1,'DisplayType','surface');
colorbar

figure;
worldmap('Greenland')
geoshow(Z2,R2,'DisplayType','surface');
colorbar

figure;
worldmap('Greenland')
geoshow(Z3,R2,'DisplayType','surface');
colorbar

R1
R2

%%

[lat,lon,alt] = minvtran(oldstruct,x,y,alt,'surface',savepts);   

% if i first project x,y to lat lon then pass those to savepts?

% load the racmo grid as a test
load('/Users/mattcooper/Dropbox/CODE/MATLAB/GREENLAND/runoff/data/racmo/racmo_grid');
% ... no ... savepts is 
[x,y,swsd] = mfwdtran(mstruct,lat,lon,swsd,'surface',savepts);


%% make figures to compare

% this confirms the lat/lon are oriented correctly
figure;
geoshow(lat,lon,swsd,'DisplayType','surface');

figure;
worldmap('Greenland')
scatterm(latrs,lonrs,12,swsdrs,'filled');

% intrinsic x,y
figure;    
mapshow(Xmar,Ymar,swsd,'DisplayType','surface')

% polar stereographic
figure;    
mapshow(xpsn,ypsn,swsd,'DisplayType','surface')

%%

% so i guess I got stuck because I could not spatially reference MAR since
% it does not have a regular x,y spacing, and all the tools I built are
% based on having R ...

% so that must have led me to 

% maptrims, mapcrop, mapinterp, ll2val, and mapresize all depend on R
% geoloc2grid does not depend on R, but it requires constant cellsize
% embedm depends on R

% so what is needed is a method to construct R from irregularly spaced x,y
% coordinates

% that is what rasterfromscatter accomplishes

% 

%% try pulling out a handful of xpsn, ypsn to see the spacing 

lonmin                  =   -46;
lonmax                  =   -42;
latmin                  =   60;
latmax                  =   62;

BBlon                   =   [lonmax lonmin lonmin lonmax lonmax];
BBlat                   =   [latmin latmin latmax latmax latmin];

[in,~]                  =   inpolygon(lon,lat,BBlon,BBlat);
swsdin                  =   swsd(in);
latin                   =   lat(in);
lonin                   =   lon(in);

[xpsnin,ypsnin]         =   ll2psn(latin,lonin);

figure;
scatter(lonin,latin,60,swsdin,'filled');

figure;
scatter(xpsnin,ypsnin,60,swsdin,'filled');

isxyregular(xpsnin,ypsnin)

xu                      =   unique(xpsnin(:),'sorted');
yu                      =   unique(ypsnin(:),'sorted');
xres                    =   diff(xu);
yres                    =   diff(yu);

% construct a regular grid



%% try making a map projection using the information JJ provided

% load this for reference if needed
% load('proj_nps.mat')

% build a ups projection and add info from JJ 
mstruct                 =   defaultm('ups');
mstruct.mapparallels    =   [71 90];
mstruct.geoid           =   wgs84Ellipsoid;

% I confirmed the geoid.




% out of these factors
% Map Projection:Polar Stereographic Ellipsoid - Map Reference Latitude: 90.0 - Map Reference Longitude:
% -39.0 - Map Second Reference Latitude: 71.0 - Map Eccentricity: 0.081819190843 ;
% wgs84 - Map Equatorial Radius: 6378137.0 ;
% wgs84 meters - Grid Map Origin Column: 160 - Grid Map Origin Row: -120 - Grid Map Units per Cell: 5000 - Grid Width: 301 - Grid Height: 561" ;


%% load the racmo data for X,Y comparison
load('/Users/mattcooper/Dropbox/CODE/MATLAB/GREENLAND/runoff/data/racmo/racmo_grid');





%%

clean

load mapmtx lt1 lg1 map1 
load topo

[aspect,slope,gradN,gradE] = gradientm(topo,topolegend);

slope1 = ltln2val(slope,topolegend,lt1,lg1);














