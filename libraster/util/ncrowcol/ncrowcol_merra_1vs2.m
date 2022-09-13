clean

% The main outcome of this and the v1/v2 scripts are that ncrowcol extracts
% the data correctly if the following syntax is used:

% [slat,clat] =   ncrowcol(lat,LON,LAT,lonpolyb,latpolyb);
% [slon,clon] =   ncrowcol(lon',LON,LAT,lonpolyb,latpolyb);

% the plan was to make this script replicte v2 for both map and geo, but v1
% doesn't work, or is not worth figureing out. 

% this appears to work correctly for fliprot = false (v2)
% the problem might be lat' vs lat in the function check

fliprot     =   false;          % v2 = false, v1 = true

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    load the data
if fliprot == true
    load('merra_fliprot');
else
    load('merra');
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% PART 1 - GEO COORDS
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    find the row/col in the ncdf file in geo

% TEST START - see if this fixes fliprot = true
% the inds are rotated but the netcdf files are not, so rotate back
[rrotgeo,crotgeo] =   ind2sub(size(ingeopolyb),find(ingeopolyb));
rrotgeounique  =   unique(rrotgeo);
crotgeounique  =   unique(crotgeo);
% TEST END

if fliprot == true
    ingeorot    =   rot90(ingeopolyb,3);
    [rgeo,cgeo] =   ind2sub(size(ingeorot),find(ingeorot));
else
    [rgeo,cgeo] =   ind2sub(size(ingeopolyb),find(ingeopolyb));
end

rgeounique  =   unique(rgeo);
cgeounique  =   unique(cgeo);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    check that it worked, using geo coordinates

% find the indices on the 1-d lat/lon vectors stored in the nc file
ncstart2d   =   [rgeo(1),cgeo(1)];
ncstart3d   =   [rgeo(1),cgeo(1),1];
nccount2d   =   [length(rgeounique),length(cgeounique)];
nccount3d   =   [length(rgeounique),length(cgeounique),24];

if fliprot == true
    latcheck =   flipud(ncread(fname,'lat',ncstart2d(2),nccount2d(2)));
    loncheck =   ncread(fname,'lon',ncstart2d(1),nccount2d(1));
else
    latcheck =   ncread(fname,'lat',ncstart2d(1),nccount2d(1));
    loncheck =   ncread(fname,'lon',ncstart2d(2),nccount2d(2));
end

latcheck(:)-latin(:)
loncheck(:)-lonin(:)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    repeat, using the function

if fliprot == true
    [slat,clat] =   ncrowcol(lat,LON,flipud(LAT),lonpolyb,latpolyb);
    [slon,clon] =   ncrowcol(lon',LON,LAT,lonpolyb,latpolyb);
    latcheck    =   flipud(ncread(fname,'lat',slat,clat));
    loncheck    =   ncread(fname,'lon',slon,clon);
else
    [slat,clat] =   ncrowcol(lat,LON,LAT,lonpolyb,latpolyb);
    [slon,clon] =   ncrowcol(lon',LON,LAT,lonpolyb,latpolyb);
    latcheck    =   ncread(fname,'lat',slat,clat);
    loncheck    =   ncread(fname,'lon',slon,clon);
end

% NOTE: for fliprot = true, index 1/2 will be swapped, but for fliprot =
% false, they should be equal
[slat slon; clat clon] 
[ncstart2d; nccount2d]

latcheck(:)-latin(:)
loncheck(:)-lonin(:)

% the only issue is that latin/lonin are equal length but latcheck,
% loncheck are not ... but the important thing is reading in the 3-d var so
% make sure that works and it should be ok (copied from v2)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    check that it worked, using a 3-d var
% Note: I use the rotated row/col to extract from swsd b/c swsd is rotated

if fliprot == true
    swsdcheck1  =   squeeze(swsd(flipud(rrotgeounique),crotgeounique,:));
    swsdcheck2  =   squeeze(ncread(fname,'SWGNT',ncstart3d,nccount3d));
else
    swsdcheck1  =   squeeze(swsd(rgeounique,cgeounique,:));
    swsdcheck2  =   squeeze(ncread(fname,'SWGNT',ncstart3d,nccount3d));
end

% plot it to check if the manual process worked
figure; 
scatter(swsdcheck1(:),swsdcheck2(:)); 
addOnetoOne;

% WORKS UP TO HERE with and without fliprot, but only without after here

% using the function
if fliprot == true
    [sswd,cswd] =   ncrowcol(swsd,LON,flipud(LAT),lonpolyb,latpolyb);
else
    [sswd,cswd] =   ncrowcol(swsd,LON,LAT,lonpolyb,latpolyb);
end

% for v1, we want the first two indices to be swapped
[sswd; cswd]
[ncstart3d; nccount3d]

% since this is using the function to extract sswd, we know that it
% shouldn't work for fliprot=true to use the same flipud(rrotgeounique),
% but other options I tried don't work either. Should work for fliprot
% false
if fliprot == true
    swsdcheck1  =   squeeze(swsd(flipud(rrotgeounique),crotgeounique,:));
else
    swsdcheck1  =   squeeze(swsd(rgeounique,cgeounique,:));
end

swsdcheck2  =   squeeze(ncread(fname,'SWGNT',sswd,cswd));
    

% plot it to check if the function worked
figure; 
scatter(swsdcheck1(:),swsdcheck2(:)); 
addOnetoOne;

% try with 2-d lat/lon - note: can't check b/c the file doesn't have the
% 2-d var, but compare slat/slon with sswd and you can see it would work if
% it did have them 
% [slat,clat] =   ncrowcol(LAT,LON,LAT,lonpolyb,latpolyb);
% [slon,clon] =   ncrowcol(LON,LON,LAT,lonpolyb,latpolyb);
% latcheck    =   ncread(fname,'lat',slat,clat); latcheck(:)-latin(:)
% loncheck    =   ncread(fname,'lon',slon,clon); loncheck(:)-lonin(:)

% UP TO HERE IDENTICAL TO V2

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% PART 2 - MAP COORDS
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% TEST - see if this fixes fliprot = true
% the inds are rotated but the netcdf files are not, so rotate back
[rrotmap,crotmap] =   ind2sub(size(inmappolyb),find(inmappolyb));
rrotmapunique  =   unique(rrotmap);
crotmapunique  =   unique(crotmap);
% TEST END

if fliprot == true
    inmaprot    =   rot90(inmappolyb,3);
    [rmap,cmap] =   ind2sub(size(inmaprot),find(inmaprot));
else
    [rmap,cmap] =   ind2sub(size(inmappolyb),find(inmappolyb));
end

rmapunique  =   unique(rmap);
cmapunique  =   unique(cmap);



%~~~~~~~~~~~~~~~~~~~~~~~~~~~    check that it worked, using map coordinates
ncstart2d   =   [rmap(1),cmap(1)];
ncstart3d   =   [rmap(1),cmap(1),1];
nccount2d   =   [length(rmapunique),length(cmapunique)];
nccount3d   =   [length(rmapunique),length(cmapunique),24];

% the lat/lon vectors in this file are 1-d so use the appropriate 2-d indices

if fliprot == true
    latcheck    =   ncread(fname,'lat',ncstart2d(2),nccount2d(2));
    loncheck    =   ncread(fname,'lon',ncstart2d(1),nccount2d(1));
else
    latcheck    =   ncread(fname,'lat',ncstart2d(1),nccount2d(1));
    loncheck    =   ncread(fname,'lon',ncstart2d(2),nccount2d(2));
end

[xcheck, ...
    ycheck] = projfwd(projsipsn,latcheck,loncheck);

xcheck(:)-xin(:)
ycheck(:)-yin(:)


%~~~~~~~~~~~~~~~~~~~~~~~~~~~    compare with the function 
if fliprot == true
    [slat,clat] =   ncrowcol(lat,flipud(X),flipud(Y),xpolyb,ypolyb);
    [slon,clon] =   ncrowcol(lon',flipud(X),flipud(Y),xpolyb,ypolyb);
    [sswd,cswd] =   ncrowcol(swsd,X,Y,xpolyb,ypolyb);
else
    [slat,clat] =   ncrowcol(lat,X,Y,xpolyb,ypolyb);
    [slon,clon] =   ncrowcol(lon',X,Y,xpolyb,ypolyb);
    [sswd,cswd] =   ncrowcol(swsd,X,Y,xpolyb,ypolyb);
end

latcheck    =   ncread(fname,'lat',slat,clat);
loncheck    =   ncread(fname,'lon',slon,clon);

[xcheck, ...
    ycheck] = projfwd(projsipsn,latcheck,loncheck);

xcheck(:)-xin(:)
ycheck(:)-yin(:)

% check the extracted variable
swsdcheck1  =   squeeze(swsd(rmapunique,cmapunique,:));
swsdcheck2  =   squeeze(ncread(fname,'SWGNT',sswd,cswd));

figure; 
scatter(swsdcheck1(:),swsdcheck2(:)); 
addOnetoOne;


% % this confirms the lat/lon are oriented correctly
% figure;
% geoshow(lt,ln,swsd,'DisplayType','texturemap');
% figure;
% worldmap('Greenland')
% scatterm(latrs,lonrs,60,swsdrs,'filled');

