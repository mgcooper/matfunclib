clean

% v1 flips/rots, v2 doesn't

% what i need to finish is to confirm that the manual row/col matches
% ncrowcol without any special flipping / rotating unless it can be shown
% to be always the case, AND the 3d data extraction works

% I am 99% certain this shows that this is true. SO, I can use ncrowcol to
% extract 3-d variables as long as i don't do any special flipping
% (beforehand? reading this feb 2022 not sure if I meant special flipping
% before, but pretty sure that must be what it means)

fliprot     =   false;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    load the data
if fliprot == true
    load('merra_fliprot');
else
    load('merra');
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% PART 1 - GEO COORDS
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    find the row/col in the ncdf file
[rgeo,cgeo] =   ind2sub(size(ingeopolyb),find(ingeopolyb));
rgeounique  =   unique(rgeo);
cgeounique  =   unique(cgeo);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    check that it worked, using geo coordinates

% find the indices on the 1-d lat/lon vectors stored in the nc file
ncstart2d   =   [rgeounique(1),cgeounique(1)];
ncstart3d   =   [rgeounique(1),cgeounique(1),1];
nccount2d   =   [length(rgeounique),length(cgeounique)];
nccount3d   =   [length(rgeounique),length(cgeounique),24];

latcheck    =   ncread(fname,'lat',ncstart2d(1),nccount2d(1));
loncheck    =   ncread(fname,'lon',ncstart2d(2),nccount2d(2));

latcheck(:)-latin(:)
loncheck(:)-lonin(:)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    repeat, using the function
[slat,clat] =   ncrowcol(lat,LON,LAT,lonpolyb,latpolyb);
[slon,clon] =   ncrowcol(lon',LON,LAT,lonpolyb,latpolyb);

[slat slon; clat clon] 
[ncstart2d; nccount2d]

latcheck    =   ncread(fname,'lat',slat,clat);
loncheck    =   ncread(fname,'lon',slon,clon);

latcheck(:)-latin(:)
loncheck(:)-lonin(:)

% the only issue is that latin/lonin are equal length but latcheck,
% loncheck are not ... but the important thing is reading in the 3-d var so
% make sure that works and it should be ok

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    check that it worked, using a 3-d var
varcheck1   =   squeeze(swsd(rgeounique,cgeounique,:));
varcheck2   =   squeeze(ncread(fname,'SWGNT',ncstart3d,nccount3d));

% plot it to check if the manual process worked
figure; 
scatter(varcheck1(:),varcheck2(:)); 
addOnetoOne;

% using the function
[svar,cvar] =   ncrowcol(swsd,LON,LAT,lonpolyb,latpolyb);

% if equal, it means the indices returned by ncrowcol match the manual ones
[svar; cvar]
[ncstart3d; nccount3d]

% this was the only difference found in a cleanup. what this shows is that
% slat/slon don't work, which isn't surprising b/c those are the 1d
%swsdcheck1  =   squeeze(swsd(slat,slon,:)); 
varcheck1  =   squeeze(swsd(rgeounique,cgeounique,:));
varcheck2  =   squeeze(ncread(fname,'SWGNT',svar,cvar));

% plot it to check if the function worked
figure; 
scatter(varcheck1(:),varcheck2(:)); 
addOnetoOne;


% % try with 2-d lat/lon
% [slat,clat] =   ncrowcol(LAT,LON,LAT,lonpolyb,latpolyb);
% [slon,clon] =   ncrowcol(LON,LON,LAT,lonpolyb,latpolyb);
% 
% can't check b/c the file doesn't have the 2-d var, but compare slat/slon
% with sswd and you can see it would work if it did have them
% latcheck    =   ncread(fname,'lat',slat,clat); latcheck(:)-latin(:)
% loncheck    =   ncread(fname,'lon',slon,clon); loncheck(:)-lonin(:)


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% PART 2 - MAP COORDS
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% the inds are rotated but the netcdf files are not, so rotate back
[rmap,cmap] =   ind2sub(size(inmappolyb),find(inmappolyb));
rmapunique  =   unique(rmap);
cmapunique  =   unique(cmap);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    check that it worked, using map coordinates
ncstart2d   =   [rmapunique(1),cmapunique(1)];
ncstart3d   =   [rmapunique(1),cmapunique(1),1];
nccount2d   =   [length(rmapunique),length(cmapunique)];
nccount3d   =   [length(rmapunique),length(cmapunique),24];

% the lat/lon vectors in this file are 1-d so use the appropriate 2-d indices
latcheck    =   ncread(fname,'lat',ncstart2d(1),nccount2d(1));
loncheck    =   ncread(fname,'lon',ncstart2d(2),nccount2d(2));

[xcheck, ...
    ycheck] = projfwd(projsipsn,latcheck,loncheck);

xcheck(:)-xin(:)
ycheck(:)-yin(:)

% using the function
[svar,cvar] =   ncrowcol(swsd,X,Y,xpolyb,ypolyb);

varcheck1  =   squeeze(swsd(rmapunique,cmapunique,:));
varcheck2  =   squeeze(ncread(fname,'SWGNT',svar,cvar));

[svar ; cvar]
[ncstart3d; nccount3d]

figure; 
scatter(varcheck1(:),varcheck2(:)); 
addOnetoOne;


% looks like here i was trying to see if it works with the original lat/lon
% arrays from the nc file WITH the X/Y instead of the LAT/LON

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    check that it worked, using map coordinates
[slat,clat] =   ncrowcol(lat,X,Y,xpolyb,ypolyb);
[slon,clon] =   ncrowcol(lon',X,Y,xpolyb,ypolyb);
[svar,cvar] =   ncrowcol(swsd,X,Y,xpolyb,ypolyb);

% works
[slat slon; clat clon] 
[ncstart2d; nccount2d]

% works
[svar; cvar]
[ncstart3d; nccount3d]


latcheck    =   ncread(fname,'lat',slat,clat);
loncheck    =   ncread(fname,'lon',slon,clon);

[xcheck, ...
    ycheck] =   projfwd(projsipsn,latcheck,loncheck);

xcheck(:)-xin(:)
ycheck(:)-yin(:)

% WORKS UP TO HERE


% % this confirms the lat/lon are oriented correctly
% figure;
% geoshow(lt,ln,swsd,'DisplayType','texturemap');
% figure;
% worldmap('Greenland')
% scatterm(latrs,lonrs,60,swsdrs,'filled');

% _v2 doesn't flipud/rot90. i think the idea was to figure out if the
% function can be generic i.e. work on any netcdf with or without rotation
% and not worry about rotation PRIOR to applying ncrowcol, but still have
% to check afterward or somehow be sure 

% It seems unambiguously better to NOT flip/rotate anything prior to
% calling ncrowcol. I want to just pass in the x/y or lat/lon and get back
% the row/col, meaning I don't want to pass in the X/Y grids from the nc
% file, those should be extracted within the function (or they could be
% passed in to improve performance). The key then is to be 100% clear that
% first X/Y should be read in, then use them to get row/col, then do any
% rotations needed for making figures. 

% commented code means it was in v1 but not here. I moved everything over
% from v1 as commented code, so i can have 1 version, not two
