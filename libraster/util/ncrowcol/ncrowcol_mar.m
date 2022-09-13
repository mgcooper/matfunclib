clean

% mar has swdh which is 4-d :
% (179 x 96  x 24 x 366) if rotated
% (96  x 179 x 24 x 366) if not rotated
% and swd which is same without the 366

% NOTE that what this does is read in the LAT/LON, convert them to XY, then
% uses a known x,y point (or polygon) to find the indices, and i confirmed
% this works

% for sampling the swdh, i use day 175, so that is the 4th index
doy         =   175;

fliprot     =   false;
searchmaps  =   false;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    load the data
if fliprot == true
    load('mar_fliprot');
else
    load('mar');
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% PART 1 - GEO COORDS
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    find the row/col in the ncdf file
[rgeo,cgeo] =   ind2sub(size(ingeopolyb),find(ingeopolyb));
rgeounique  =   unique(rgeo);
cgeounique  =   unique(cgeo);

% there are 24 grid cells defined by rgeounique/cgeounique, but 18 grid
% cells that are actually within the polygon

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    check that it worked, using geo coordinates

% I think it might be necessary to supply the variable name to ncrowcol,
% let it determine the size, and then set the values below accordingly

% find the indices on the 1-d lat/lon vectors stored in the nc file
ncstart2d   =   [rgeounique(1),cgeounique(1)];
ncstart3d   =   [rgeounique(1),cgeounique(1),1];
ncstart4d   =   [rgeounique(1),cgeounique(1),1,1];
nccount2d   =   [length(rgeounique),length(cgeounique)];
nccount3d   =   [length(rgeounique),length(cgeounique),24];
nccount4d   =   [length(rgeounique),length(cgeounique),24,366];

latcheck    =   tocolumn(ncread(fname,'LAT',ncstart2d,nccount2d));
loncheck    =   tocolumn(ncread(fname,'LON',ncstart2d,nccount2d));

% i need to find the ones in latcheck/loncheck that are actually within the
% polygon and compare them to latin/lonin
incheck     =   inpolygon(loncheck,latcheck,lonpolyb,latpolyb);
sum(incheck)

if searchmaps == true
    figure; worldmap([min(LAT(:)) max(LAT(:))],[min(LON(:)) max(LON(:))]);
    h(1) = scatterm(LAT(:),LON(:)); hold on;
    h(2) = plotm(latpolyb,lonpolyb,'Color','g');
    h(3) = scatterm(latin,lonin,40,'filled');
    h(4) = scatterm(latcheck,loncheck,40,'r','filled');
end

% changing these is risky b/c we want to know the order is correct
latcheck    = latcheck(incheck);
loncheck    = loncheck(incheck);

% but this seems to confirm that it works
[latcheck(:)-latin(:)  loncheck(:)-lonin(:)]

% NOTE: what the test below shows is that I can use ncrowcol with the
% LAT/LON that come straight out of the mar nc files and pass in a poly and
% get the right values

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    repeat, using the function
[slat,clat] =   ncrowcol(LAT,LON,LAT,lonpolyb,latpolyb);
[slon,clon] =   ncrowcol(LON,LON,LAT,lonpolyb,latpolyb);

[slat; clat] 
[ncstart2d; nccount2d]

[slon; clon] 
[ncstart2d; nccount2d]

latcheck    =   tocolumn(ncread(fname,'LAT',slat,clat));
loncheck    =   tocolumn(ncread(fname,'LON',slon,clon));
incheck     =   inpolygon(loncheck,latcheck,lonpolyb,latpolyb);
sum(incheck)

if searchmaps == true
    figure; worldmap([min(LAT(:)) max(LAT(:))],[min(LON(:)) max(LON(:))]);
    h(1) = scatterm(LAT(:),LON(:)); hold on;
    h(2) = plotm(latpolyb,lonpolyb,'Color','g');
    h(3) = scatterm(latin,lonin,40,'filled');
    h(4) = scatterm(latcheck,loncheck,40,'r','filled');
end

% changing these is risky b/c we want to know the order is correct
latcheck    = latcheck(incheck);
loncheck    = loncheck(incheck);

% but this seems to confirm that it works
[latcheck(:)-latin(:)  loncheck(:)-lonin(:)]

% the only issue is that latin/lonin are equal length but latcheck,
% loncheck are not ... but the important thing is reading in the 3-d var so
% make sure that works and it should be ok

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    check that it worked, using a 4-d var
varcheck1  =   squeeze(swdh(rgeounique,cgeounique,:,doy));
varcheck2  =   squeeze(ncread(fname,'SWDH',ncstart4d,nccount4d));
varcheck2  =   squeeze(varcheck2(:,:,:,doy));

% plot it to check if the manual process worked
figure; myscatter(varcheck1(:),varcheck2(:)); addOnetoOne;
xlabel('known indices'); ylabel('ncstart from known indices')

% using the function
[svar,cvar] =   ncrowcol(swdh,LON,LAT,lonpolyb,latpolyb);

% if equal, it means the indices returned by ncrowcol match the manual ones
[svar; cvar]
[ncstart4d; nccount4d]

varcheck1  =   squeeze(swdh(rgeounique,cgeounique,:,doy));
varcheck2  =   squeeze(ncread(fname,'SWDH',svar,cvar));
varcheck2  =   squeeze(varcheck2(:,:,:,doy));

% plot it to check if the function worked
figure; myscatter(varcheck1(:),varcheck2(:)); addOnetoOne;
xlabel('known indices'); ylabel('ncstart from ncrowcol')

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% PART 2 - MAP COORDS using the nc GEO coords
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% the inds are rotated but the netcdf files are not, so rotate back
[rmap,cmap] =   ind2sub(size(inmappolyb),find(inmappolyb));
rmapunique  =   unique(rmap);
cmapunique  =   unique(cmap);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    check that it worked, using map coordinates
ncstart2d   =   [rmap(1),cmap(1)];
ncstart3d   =   [rmap(1),cmap(1),1];
ncstart4d   =   [rmap(1),cmap(1),1,1];
nccount2d   =   [length(rmapunique),length(cmapunique)];
nccount3d   =   [length(rmapunique),length(cmapunique),24];
nccount4d   =   [length(rmapunique),length(cmapunique),24,366];

% the lat/lon vectors in this file are 1-d so use the appropriate 2-d indices
latcheck    =   ncread(fname,'LAT',ncstart2d,nccount2d);
loncheck    =   ncread(fname,'LON',ncstart2d,nccount2d);

[xcheck, ...
    ycheck] = projfwd(projsipsn,latcheck,loncheck);

[xcheck(:) xin(:)]
[ycheck(:) yin(:)]

round(xcheck(:)-xin(:),0)
round(ycheck(:)-yin(:),0)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    check that it worked, using a 4-d var
varcheck1   =   squeeze(swdh(rmapunique,cmapunique,:,doy));
varcheck2   =   squeeze(ncread(fname,'SWDH',ncstart4d,nccount4d));
varcheck2   =   squeeze(varcheck2(:,:,:,doy));

% plot it to check if the manual process worked
figure; myscatter(varcheck1(:),varcheck2(:)); addOnetoOne;
xlabel('known indices'); ylabel('ncstart from known indices')

% using the function
[svar,cvar] =   ncrowcol(swdh,X,Y,xpolyb,ypolyb);

varcheck1   =   squeeze(swdh(rmapunique,cmapunique,:,doy));
varcheck2   =   squeeze(ncread(fname,'SWDH',svar,cvar));
varcheck2   =   squeeze(varcheck2(:,:,:,doy));

[svar ; cvar]
[ncstart4d; nccount4d]

figure; myscatter(varcheck1(:),varcheck2(:)); addOnetoOne;
xlabel('known indices'); ylabel('ncstart from known indices')

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% PART 3 - MAP COORDS using the nc MAP coords
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% NOTE: if there was an X/Y variable, I could just re-do the xcheck/ycheck
% % extraction and that would be further confrimation it works, but mar
% % doesn't have it
% 
% % the lat/lon vectors in this file are 1-d so use the appropriate 2-d indices
% ycheck      =   ncread(fname,'Y',ncstart2d,nccount2d);
% xcheck      =   ncread(fname,'X',ncstart2d,nccount2d);
% 
% [xcheck(:) xin(:)]
% [ycheck(:) yin(:)]
% 
% round(xcheck(:)-xin(:),0)
% round(ycheck(:)-yin(:),0)


% below this is not relevant, but it could be modified to use the x/y
% vectors provided with mar

% % looks like here i was trying to see if it works with the original lat/lon
% % arrays from the nc file WITH the X/Y instead of the LAT/LON
% 
% %~~~~~~~~~~~~~~~~~~~~~~~~~~~    check that it worked, using map coordinates
% [slat,clat] =   ncrowcol(lat,X,Y,xpolyb,ypolyb);
% [slon,clon] =   ncrowcol(lon',X,Y,xpolyb,ypolyb);
% [svar,cvar] =   ncrowcol(swsd,X,Y,xpolyb,ypolyb);
% 
% % works
% [slat slon; clat clon] 
% [ncstart2d; nccount2d]
% 
% % works
% [svar; cvar]
% [ncstart3d; nccount3d]
% 
% 
% latcheck    =   ncread(fname,'lat',slat,clat);
% loncheck    =   ncread(fname,'lon',slon,clon);
% 
% [xcheck, ...
%     ycheck] =   projfwd(projsipsn,latcheck,loncheck);
% 
% xcheck(:)-xin(:)
% ycheck(:)-yin(:)

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
