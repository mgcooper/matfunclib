% this website was helpful in stating clearly what I deduced on my own that
% raster reprojection is a two-step process - 1) reproject the cell
% coordinates and 2) resample the cell values to the new coordinates.

% https://geocompr.robinlovelace.net/reproj-geo-data.html

% so where I was going previously with rasterfromscatter/rasterize is the
% correct way to approach the problem. The next problem I ran into, though,
% was getting the image aligned vertically and represented in a matrix of
% regular x/y spacing. For that, I may have found the answer with my linear
% regression approach need to pick up on that. It may also be that imwarp
% and projective2d is the right method. 

% one clue is to look at what tools like projectRaster require. Everything
% i need should be in them. The answer is it requires a proj4string

% I went to this folder:
% /Applications/MATLAB_R2020a.app/toolbox/map/mapproj/projdata/proj

% right clicked on esri and 'show in finder' then opened in textmate and
% resaved here. I searched for UTM zone 22N and got the one for NAD83:
    
% <26922> +proj=utm +zone=22 +ellps=GRS80 +datum=NAD83 +units=m +no_defs  no_defs <>

% I could use this in a function to look these up. This might be what the
% new functionality in 2020b does. 


% this is also useful:
% https://kartoweb.itc.nl/geometrics/Coordinate%20transformations/coordtrans.html

% it clarifies that one goes from projected to geo, then geo to new
% projected, which is how I've been doing it. 

% so to project a raster, I wonder if converting the lat/lon coords of the
% map limits, and then applying a projective transformation is correct, or
% if I need to project all cell centers, then interpolate to the new grid I
% want it on? 

%% I feel like I got real close here. See my make map script in runoff

% crop the DEM to the lat/lon limits of the landsat imagery
delta               =   0.0;
latcrop             =   latlims + [-delta delta];
loncrop             =   lonlims + [-delta delta];
[xcrop,ycrop]       =   ll2psn(latcrop,loncrop);
[Zelev,Relevpsn]    =   mapcrop(Zelev,Relevpsn,xcrop,ycrop);

% convert the R spatial reference to UTM 22N
xworldlims          =   Relevpsn.XWorldLimits;
yworldlims          =   Relevpsn.YWorldLimits;
[latwlims,lonwlims] =   psn2ll(xworldlims,yworldlims);
[xwlims,ywlims]     =   mfwdtran(utmstruct,latwlims,lonwlims);

Relevutm                =   Relevpsn;
Relevutm.XWorldLimits   =   xwlims;
Relevutm.YWorldLimits   =   ywlims;

% this is where I think I need to warp the image into UTM 22N
xlimspsn            =   Relevpsn.XWorldLimits;
ylimspsn            =   Relevpsn.YWorldLimits;
xlimsutm            =   Relevutm.XWorldLimits;
ylimsutm            =   Relevutm.YWorldLimits;

imrefpsn            =   imref2d(size(Zelev),xlimspsn,ylimspsn);
imrefutm            =   imref2d(size(Zelev),xlimsutm,ylimsutm);

test = imwarp(Zelev,imrefpsn,imrefutm);
% AHA! The world file matrix might be the answer
% The world file IS the affine transformation matrix 

% I want to warp from psn to utm. 

% let's try building an affine T
T                   =   zeros(3,3);
Rpsn                =   Relevpsn.worldFileMatrix';
Rutm                =   Relevutm.worldFileMatrix';
T(1:2,1:2)          =   Rutm(1:2,1:2)./Rpsn(1:2,1:2);
T(1,2)              =   0;
T(2,1)              =   0;
T(3,1)              =   Rutm(3,1)-Rpsn(3,1);
T(3,2)              =   Rutm(3,2)-Rpsn(3,2);
T(3,3)              =   1;

% T                   =   ([Relevutm.worldFileMatrix ;[0 0 1]])';
% tform               =   affine2d(T);
tform               =   projective2d(T);

% tform               =   Rutm.worldFileMatrix;
% [B,RB]              =   imwarp(Zelev,imrefpsn,tform,'OutputView',imrefutm);
% [B,RB]              =   imwarp(Zelev,imrefpsn,tform);

test = refmatToMapRasterReference(RB)

Rtest               =   Relevutm;
Rtest.XWorldLimits  =   RB.XWorldLimits;
Rtest.YWorldLimits  =   RB.YWorldLimits;
Rtest.RasterSize    =   RB.ImageSize;
Rtest


Rout = affineOutputView(size(Zelev),tform);


