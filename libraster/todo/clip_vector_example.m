
% for complex shapefiles, this method converts the shapefile ouline to a
% rasterized grid with 1 inside the shapefile and 0 outside. You can then
% use imbedm to embed vector point values and 

% the reason this is not a good solution is because when the ice sat point
% values are embedded into the grid using imbedm, the grid size resolution
% (created using vec2mtx) is too big, so a lot of the individual ice sat
% measurements get lost inside the grids and the output elevmasked contains
% many fewer points. The way to solve this would be to create a grid with
% grid spacing smaller than the smallest lat/lon distance increment between
% points but that would be way too big. 

% NEvertheless, there is some good info in here to keep for future
% reference
clean

%%
save_figs       =   0;

%%
homepath        =   pwd;

if strcmp(homepath(2:6),'Users')
    path.data   =   ['/Users/MattCooper/Dropbox/CODE/MATLAB/GREENLAND/' ...
                        'IceSat2/data/processed/'];
    path.save   =   ['/Users/MattCooper/Dropbox/CODE/MATLAB/GREENLAND/' ...
                        'IceSat2/figs/'];
elseif strcmp(homepath(10:16),'mcooper')    
    path.data   =   ['C:\Users\mcooper\Dropbox\CODE\MATLAB\GREENLAND\' ...
                        'IceSat2\data\processed\'];
    path.save   =   ['C:\Users\mcooper\Dropbox\CODE\MATLAB\GREENLAND\' ...
                        'IceSat2\figs\'];
end

%%
elev2r      =   [];
lat2r       =   [];
lon2r       =   [];

%%
load([path.data 'icesat2_20181014.mat']); 
elev2r      =   [elev2r;gt2r_hl];
lat2r       =   [lat2r;gt2r_lat];
lon2r       =   [lon2r;gt2r_lon];

load([path.data 'icesat2_20181015.mat']); 
elev2r      =   [elev2r;gt2r_hl];
lat2r       =   [lat2r;gt2r_lat];
lon2r       =   [lon2r;gt2r_lon];

load([path.data 'icesat2_20181016.mat']); 
elev2r      =   [elev2r;gt2r_hl];
lat2r       =   [lat2r;gt2r_lat];
lon2r       =   [lon2r;gt2r_lon];

load([path.data 'icesat2_20181017.mat']); 
elev2r      =   [elev2r;gt2r_hl];
lat2r       =   [lat2r;gt2r_lat];
lon2r       =   [lon2r;gt2r_lon];

load([path.data 'icesat2_20181018.mat']); 
elev2r      =   [elev2r;gt2r_hl];
lat2r       =   [lat2r;gt2r_lat];
lon2r       =   [lon2r;gt2r_lon];

clear gt2r_hl gt2r_lat gt2r_lon gt3r_hl gt3r_lat gt3r_lon
%%
[h,ax,n,s,sf]       =   greenlandmapgeo; close all;
inLat               =   sf.Y;
inLon               =   sf.X;
gridDensity         =   40;

% make the vec2mtx grid
[borderGrid,rvec]   =   vec2mtx(inLat,inLon,gridDensity);
R                   =   refvecToGeoRasterReference(rvec,size(borderGrid));
maskVal             =   1;
borderVal           =   1; % note - this is auto from vec2mtx
clear inLat inLon

% create a seed, this one uses the center pixel and 3 for maskVal so I can
% make a figure below to demonsrate the rasterized border, but in general i
% want to use maskVal = 1 so I can multiply
inPt                =   round([size(borderGrid)/2,3]);
testGrid            =   encodem(borderGrid,inPt,borderVal);

% fill cells inside the border with maskVal
inPt                =   round([size(borderGrid)/2,maskVal]);
maskGrid            =   encodem(borderGrid,inPt,borderVal);

% embed the ice sat point values into the grid
dataGrid            =   imbedm(lat2r,lon2r,elev2r,maskGrid,R);

% multiply the mask by the embedded data grid to set values outside the
% border to zero
dataGrid            =   maskGrid.*dataGrid;

% extract remaining values that are >maskVal
datamasked          =   dataGrid(dataGrid>maskVal);

% get the lat/lon values for these points
[X,Y]               =   R2grid(R);
latmasked           =   Y(dataGrid>maskVal);
lonmasked           =   X(dataGrid>maskVal);

%% plot the extracted values
figure
geoscatter(latmasked,lonmasked,8,datamasked,'filled');

%% plot the mask
figure
axesm flatplrp
meshm(borderGrid,R)
meshm(borderGrid,R)
plotm(sf.Y, sf.X,'k')

%%
% I could also convert the inGrid3 to a polyshape, if I can get the
% lat/lon values of each grid cell
xkeep               =   X(borderGrid==1);
ykeep               =   Y(borderGrid==1);
gs                  =   geoshape(ykeep,xkeep);

ps                  =   polyshape(xkeep,ykeep,'Simplify',true);
% tf                  =   intersect(

%% try converting the ice sat data to a geopoint object
geotrack            =   geoshape(gt2r_lat,gt2r_lon,'Geometry','Point');
test                =   polyshape(sf.X,sf.Y,'Simplify',true);
testint             =   intersect(sf,geotrack);
%%
[h,ax,n,s,sf]       =   greenlandmapgeo; hold on;
m                   =   scatterm(ax,lat2r(tf),lon2r(tf),8,elev2r(tf),'filled');
tightmap
