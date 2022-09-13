% I need a script that finds the ncdf coordinates
clean

svdata  =   0;
basin   =   'upper_basin';

% the issue with racmo is that the bounding box captures an irregular grid
% of points because the lat/lon are not vertical/horizontal in map
% coordinates, and there is no x,y variable in the file, just the rotated
% pole grid, which I don't want to figure out, and although I can project
% the lat/lon to x,y, when it comes time to verify by reading in the data,
% I have to use the 

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    set paths
p.data  =   '/Users/coop558/mydata/racmo2.3/surface/';
p.obs   =   setpath(['GREENLAND/runoff/data/icemodel/evaluation/' basin '/']);
list    =   dir(fullfile([p.data '*.nc']));

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    load the catchment boundary
load('projsipsn')
load([p.obs 'Q_' basin],'sf');
mappoly     =   sf.med.spsn.poly;
geopoly     =   polyshape(sf.med.spsn.lon,sf.med.spsn.lat);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    read in one data file
fname       =   [p.data 'swsd.RACMO23p3_no_subsurf_en_FGRN11_2012_2015.3H.nc'];
vars        =   ncparse(fname);
info        =   ncinfo(fname);
LON         =   flipud(permute(ncread(fname,'lon'),[2 1]));
LAT         =   flipud(permute(ncread(fname,'lat'),[2 1]));
swsd        =   squeeze(ncread(fname,'swsd'));
[X,Y]       =   projfwd(projsipsn,LAT,LON);
swsd        =   rot90_3D(swsd,3,1);
swsdavg     =   mean(swsd,3);

figure; worldmap([min(LAT(:)) max(LAT(:))],[min(LON(:)) max(LON(:))]);
scatterm(LAT(:),LON(:),20,swsdavg(:)); colorbar

figure; geoshow(LAT,LON,swsdavg,'DisplayType','texturemap')

%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~ create a search region using polybuffer
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    
mapbuffer   =   12000;
mappolyb    =   polybuffer(mappoly,mapbuffer);
xpolyb      =   mappolyb.Vertices(:,1);
ypolyb      =   mappolyb.Vertices(:,2);

% create a box instead of a circular area
minx        = min(xpolyb(:));
maxx        = max(xpolyb(:));
miny        = min(ypolyb(:));
maxy        = max(ypolyb(:));
xv          = [minx maxx maxx minx minx]; 
yv          = [miny miny maxy maxy miny];
mappolyb    = polyshape(xv,yv);             % this overrides the polybuffer
xpolyb      = mappolyb.Vertices(:,1);
ypolyb      = mappolyb.Vertices(:,2);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    find points in the region with inpolygon
inmappolyb  =   inpolygon(X,Y,xv,yv); sum(inmappolyb(:))
swsdinmap   =   swsdavg(inmappolyb);
xin         =   X(inmappolyb);
yin         =   Y(inmappolyb);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    find points in the region with dsearchn
Pmap    =   [X(:) Y(:)];
PQmap   =   [xpolyb ypolyb];
kmap    =   dsearchn(Pmap,PQmap);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    plot it
figure;
scatter(Pmap(:,1),Pmap(:,2)); hold on;
plot(mappoly.Vertices(:,1),mappoly.Vertices(:,2));
plot(xv,yv)
scatter(X(kmap),Y(kmap),50,'filled');
scatter(xin,yin,200,'LineWidth',2)
legend('points','target','search region','dsearchn','inpolygon')
set(gca,'XLim',[minx-10000 maxx+10000],'YLim',[miny-10000 maxy+10000]);
%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~ repeat for geo
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    
geobuffer   =   0.15;
geopolyb    =   polybuffer(geopoly,geobuffer);
lonpolyb    =   geopolyb.Vertices(:,1);
latpolyb    =   geopolyb.Vertices(:,2);

% create a box instead of a circular area
minlon      = min(lonpolyb(:));
maxlon      = max(lonpolyb(:));
minlat      = min(latpolyb(:));
maxlat      = max(latpolyb(:));
lonv        = [minlon maxlon maxlon minlon minlon]; 
latv        = [minlat minlat maxlat maxlat minlat]; 
geopolyb    = polyshape(lonv,latv);       % this overrides the polybuffer
lonpolyb    = geopolyb.Vertices(:,1);
latpolyb    = geopolyb.Vertices(:,2);

ingeopolyb  =   inpolygon(LON,LAT,lonpolyb,latpolyb); sum(ingeopolyb(:))
lonin       =   LON(ingeopolyb);
latin       =   LAT(ingeopolyb);
swsdingeo   =   swsdavg(ingeopolyb);
Pgeo        =   [LON(:) LAT(:)];
PQgeo       =   [lonpolyb latpolyb];
kgeo        =   dsearchn(Pgeo,PQgeo);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    plot it


figure; m = worldmap([min(LAT(:)) max(LAT(:))],[min(LON(:)) max(LON(:))]);
h(1) = scatterm(LAT(:),LON(:)); hold on;
h(2) = plotm(geopoly.Vertices(:,2),geopoly.Vertices(:,1));
h(3) = plotm(latv,lonv,'Color','g');
h(4) = scatterm(LAT(kgeo),LON(kgeo),50,'r','filled');
h(5) = scatterm(latin,lonin,40,'filled');
legend(h,'points','target','search region','dsearchn','inpolygon')

setm(m,'MapLatLimit',[minlat-0.2 maxlat+0.2],               ...
    'MapLonLimit',[minlon-0.2 maxlon+0.2]);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~    find the row/col in the ncdf file

% the inds are rotated but the netcdf files are not, so rotate back
[r,c]       =   ind2sub(size(ingeopolyb),find(ingeopolyb));
ingeorot    =   rot90(ingeopolyb,3);
[rgeo,cgeo] =   ind2sub(size(ingeorot),find(ingeorot));
rgeounique  =   unique(rgeo);
cgeounique  =   unique(cgeo);

% find the indices on the 1-d lat/lon vectors

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    check that it worked, using geo coordinates
ncstart2d   =   [rgeo(1),cgeo(1)];
ncstart3d   =   [rgeo(1),cgeo(1),1];
ncstart4d   =   [rgeo(1),cgeo(1),1,6000];
nccount2d   =   [length(rgeounique),length(cgeounique)];
nccount3d   =   [length(rgeounique),length(cgeounique),24];
nccount4d   =   [length(rgeounique),length(cgeounique),1,101];

latcheck    =   flipud(ncread(fname,'lat',ncstart2d,nccount2d));
loncheck    =   ncread(fname,'lon',ncstart2d,nccount2d);

sort(latcheck(:))-sort(latin(:))
sort(loncheck(:))-sort(lonin(:))

% with the circular polyb approach, these are not in latin/lonin:
% the last loncheck (sorted) second (unsorted), -49.7061117985211
% and second latcheck (sorted) , first (unsorted), 67.0173602648811

% this happens when the bounding box captures an incomplete grid of points,
% the unique lat/lon pairs captured by the bounding box will bring in a
% complete grid of points. not sure if this is specific to 2-d lat/lon .nc
% variables or if it just didn't happen due to chance wiht the merra test

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    check that it worked, using a 3-d var
% swsdcheck1  =   squeeze(swsd(rgeounique,cgeounique,:));
swsdcheck1  =   squeeze(swsd(flipud(unique(r)),unique(c),6000:6100));
swsdcheck2  =   squeeze(ncread(fname,'swsd',ncstart4d,nccount4d));
figure; scatter(swsdcheck1(:),swsdcheck2(:)); addOnetoOne

mean(swsdcheck1(:))
mean(swsdcheck2(:))

%% REPEAT USING MAP COORDINATES
%~~~~~~~~~~~~~~~~~~~~~~~~~~~    check that it worked, using map coordinates

[r,c]       =   ind2sub(size(inmappolyb),find(inmappolyb));
inmaprot    =   rot90(inmappolyb,3);
[rmap,cmap] =   ind2sub(size(inmaprot),find(inmaprot));
rmapunique  =   unique(rmap);
cmapunique  =   unique(cmap);

ncstart2d   =   [rmap(1),cmap(1)];
ncstart3d   =   [rmap(1),cmap(1),1];
ncstart4d   =   [rmap(1),cmap(1),1,6000];
nccount2d   =   [length(rmapunique),length(cmapunique)];
nccount3d   =   [length(rmapunique),length(cmapunique),24];
nccount4d   =   [length(rmapunique),length(cmapunique),1,101];

% the lat/lon vectors in this file are 1-d so use the appropriate 2-d indices
latcheck    =   ncread(fname,'lat',ncstart2d,nccount2d);
loncheck    =   ncread(fname,'lon',ncstart2d,nccount2d);

[xcheck, ...
    ycheck] = projfwd(projsipsn,latcheck,loncheck);

xcheck(:)-xin(:)
ycheck(:)-yin(:)

sort(xcheck(:))-sort(xin(:))
sort(ycheck(:))-sort(yin(:))

% compare with the function
% NOTE: THE BENEFIT OF THE FUNCTION IS THAT IT GETS START/COUNT STRAIGHT
% FROM THE X/Y, AND DOESN'T REQURE ALL THE EXTRA STUFF ABOVE
[slat,clat] =   ncrowcol(LAT,rot90(X,3),rot90(Y,3),xpolyb,ypolyb);
[slon,clon] =   ncrowcol(LON,rot90(X,3),rot90(Y,3),xpolyb,ypolyb);
[sswd,cswd] =   ncrowcol(swsd,rot90(X,3),rot90(Y,3),xpolyb,ypolyb);

latcheck    =   ncread(fname,'lat',slat,clat);
loncheck    =   ncread(fname,'lon',slon,clon);

[xcheck, ...
    ycheck] = projfwd(projsipsn,latcheck,loncheck);

xcheck(:)-xin(:)
ycheck(:)-yin(:)

sort(xcheck(:))-sort(xin(:))
sort(ycheck(:))-sort(yin(:))

swsdcheck1  =   squeeze(swsd(flipud(unique(r)),unique(c),6000:6100));
swsdcheck2  =   squeeze(ncread(fname,'swsd',ncstart4d,nccount4d));
figure; scatter(sort(swsdcheck1(:)),sort(swsdcheck2(:))); addOnetoOne


% it's not ideal that they come in 


% these are what I tried before figureing it out with map coords
% [slat,clat] =   ncrowcol(LAT,flipud(X),flipud(Y),xpolyb,ypolyb);
% [slon,clon] =   ncrowcol(LON',flipud(X),flipud(Y),xpolyb,ypolyb);
% [slat,clat] =   ncrowcol(LAT,X,Y,xpolyb,ypolyb);
% [slon,clon] =   ncrowcol(LON',X,Y,xpolyb,ypolyb);
% [slat,clat] =   ncrowcol(LAT,LON,LAT,xpolyb,ypolyb);
% [slon,clon] =   ncrowcol(LON,LON,LAT,xpolyb,ypolyb);
% [slat,clat] =   ncrowcol(LAT,rot90(LON,3),rot90(LAT,3),lonpolyb,latpolyb);
% [slon,clon] =   ncrowcol(LON,rot90(LON,3),rot90(LAT,3),lonpolyb,latpolyb);


% % this confirms the lat/lon are oriented correctly
% figure;
% geoshow(lt,ln,swsd,'DisplayType','texturemap');
% figure;
% worldmap('Greenland')
% scatterm(latrs,lonrs,60,swsdrs,'filled');

