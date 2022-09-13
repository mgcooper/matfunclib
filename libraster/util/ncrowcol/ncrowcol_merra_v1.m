clean

fliprot     =   true;           % true for v1

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
[r,c]       =   ind2sub(size(ingeopolyb),find(ingeopolyb));
ingeorot    =   rot90(ingeopolyb,3);
[rgeo,cgeo] =   ind2sub(size(ingeorot),find(ingeorot));
rgeounique  =   unique(rgeo);
cgeounique  =   unique(cgeo);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    check that it worked, using geo coordinates

% FEB 2022 - theere might be an error using rgeo(1),cgeo(1) as the start,
% they might need to be rgeounique(1), cgeounique(1). I swear I remember
% fixing that here, and I independently discovered it in writing
% saveMerraData and looking back at teh behar scripts I didnt' do it that
% way but coincidentally it worked anyway for the og behar bbox, but in my
% arbitrary bbox in saveMerraData, rgeo(1) is not the first row index, e.g.
% it was 39, 40, 41, 42, and rgeo(1) was 40

% find the indices on the 1-d lat/lon vectors stored in the nc file
ncstart2d   =   [rgeo(1),cgeo(1)];
ncstart3d   =   [rgeo(1),cgeo(1),1];
nccount2d   =   [length(rgeounique),length(cgeounique)];
nccount3d   =   [length(rgeounique),length(cgeounique),24];

latcheck    =   flipud(ncread(fname,'lat',ncstart2d(2),nccount2d(2)));
loncheck    =   ncread(fname,'lon',ncstart2d(1),nccount2d(1));

latcheck(:)-latin(:)
loncheck(:)-lonin(:)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    repeat, using the function
% see notes at end about slat/slon not matching ncstart/count

[slat,clat] =   ncrowcol(lat,LON,flipud(LAT),lonpolyb,latpolyb);
[slon,clon] =   ncrowcol(lon',LON,LAT,lonpolyb,latpolyb);

[slat slon; clat clon] 
[ncstart2d; nccount2d]

latcheck    =   flipud(ncread(fname,'lat',slat,clat));
loncheck    =   ncread(fname,'lon',slon,clon);

latcheck(:)-latin(:)
loncheck(:)-lonin(:)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    check that it worked, using a 3-d var
swsdcheck1  =   squeeze(swsd(flipud(unique(r)),unique(c),:));
swsdcheck2  =   squeeze(ncread(fname,'SWGNT',ncstart3d,nccount3d));

% plot it to check if the manual process worked
figure; 
scatter(swsdcheck1(:),swsdcheck2(:)); 
addOnetoOne;
% WORKS UP TO HERE

% using the function
[sswd,cswd] =   ncrowcol(swsd,LON,flipud(LAT),lonpolyb,latpolyb);

% for v1, we want the first two indices to be swapped
[sswd; cswd]
[ncstart3d; nccount3d]

% NOTE: since the check above uses ncstart3d, and we know that ncstart3d
% doesn't match sswd, we can't use the same flipud(unique(r) to get
% swsdcheck1, but i tried various versions of rgeounique w/wo flippng and
% they don't work
swsdcheck1  =   squeeze(swsd(flipud(rgeounique),cgeounique,:));
swsdcheck2  =   squeeze(ncread(fname,'SWGNT',sswd,cswd));

% plot it to check if the function worked
figure; 
scatter(swsdcheck1(:),swsdcheck2(:)); 
addOnetoOne;

% I THINK THIS IS WHERE IT MAKES SENSE TO STOP AND JUST USE V2



% Note: I use the rotated row/col, meaning the row/col found on inmappolyb
% to extract from swsd b/c swsd is rotated in the same way as inmappolyb.
% however, i also use the non-rotated row col, meaning the row/col found on
% inmaprot, to find the start, count, so i need both if i am using fliprot,
% whereas i don't need both without fliprot

% TEST - copied from v2
%~~~~~~~~~~~~~~~~~~~~~~~~~~~    repeat, using the function
% using the function

% This is where it stops working. I think we want sswd == ncstart3d
% swsd, LAT, and LON are all the same size. what comes out of ncrowcol is
% simply the row,col 

% LAT has been flipped. LON has not. ingeopoly has been rotated. SWSD has
% been rotated. ncstart2d and 3d are based on the rotated ingeopoly. 

% If LAT is not flipped and ingeopoly is not rotated, then the rgeo/cgeo,
% which is the key step, are relative to LAT/SWSD as they come from the nc
% file i.e. as matlab reads them in. This is because rgeo/cgeo are from
% inpolygon, which just searches the input LAT/LON coord's to find whether
% they are inside the polygon, so the true/false are relative to the
% orientation of LAT/LON. That way, they can be used directly to get 
% IT IS ALSO CRITICAL TO REMEMBER that in the nc file, lat/lon are 1-d, but
% the data is 2-d or 3-d, so we're using the LAT/LON meshgrids to find the
% indices on the gridded data. 


[sswd,cswd] =   ncrowcol(swsd,LON,flipud(LAT),lonpolyb,latpolyb);
sswd
ncstart3d

[sswd,cswd] =   ncrowcol(swsd,flipud(LON),LAT,lonpolyb,latpolyb);
sswd
ncstart3d

[sswd,cswd] =   ncrowcol(swsd,flipud(LON),flipud(LAT),lonpolyb,latpolyb);
sswd
ncstart3d




% try with 2-d lat/lon
[slat,clat] =   ncrowcol(LAT,LON,LAT,lonpolyb,latpolyb);
[slon,clon] =   ncrowcol(LON,LON,LAT,lonpolyb,latpolyb);

% can't check b/c the file doesn't have the 2-d var, but compare slat/slon
% with sswd and you can see it would work if it did have them
% latcheck    =   ncread(fname,'lat',slat,clat); latcheck(:)-latin(:)
% loncheck    =   ncread(fname,'lon',slon,clon); loncheck(:)-lonin(:)

% TEST - copied from v2 end


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% PART 2 - GEO COORDS
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% the inds are rotated but the netcdf files are not, so rotate back
[r,c]       =   ind2sub(size(inmappolyb),find(inmappolyb));
inmaprot    =   rot90(inmappolyb,3);
[rmap,cmap] =   ind2sub(size(inmaprot),find(inmaprot));
rmapunique  =   unique(rmap);
cmapunique  =   unique(cmap);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    check that it worked, using map coordinates

% so the alternative is to use map coordinates, and then project

ncstart2d   =   [rmap(1),cmap(1)];
ncstart3d   =   [rmap(1),cmap(1),1];
nccount2d   =   [length(rmapunique),length(cmapunique)];
nccount3d   =   [length(rmapunique),length(cmapunique),24];

% the lat/lon vectors in this file are 1-d so use the appropriate 2-d indices
latcheck    =   ncread(fname,'lat',ncstart2d(2),nccount2d(2));
loncheck    =   ncread(fname,'lon',ncstart2d(1),nccount2d(1));

[xcheck, ...
    ycheck] = projfwd(projsipsn,latcheck,loncheck);

xcheck(:)-xin(:)
ycheck(:)-yin(:)

% compare with the function
[slat,clat] =   ncrowcol(lat,flipud(X),flipud(Y),xpolyb,ypolyb);
[slon,clon] =   ncrowcol(lon',flipud(X),flipud(Y),xpolyb,ypolyb);
[sswd,cswd] =   ncrowcol(swsd,X,Y,xpolyb,ypolyb);

latcheck    =   ncread(fname,'lat',slat,clat);
loncheck    =   ncread(fname,'lon',slon,clon);

[xcheck, ...
    ycheck] = projfwd(projsipsn,latcheck,loncheck);

xcheck(:)-xin(:)
ycheck(:)-yin(:)

% % this confirms the lat/lon are oriented correctly
% figure;
% geoshow(lt,ln,swsd,'DisplayType','texturemap');
% figure;
% worldmap('Greenland')
% scatterm(latrs,lonrs,60,swsdrs,'filled');







% the LAT is flipped in this workspace, but not in the file, so to locate
% the start index slat, flip LAT back. But, it's necessary to flip the
% output lat as well, since latin was located on the flipped LAT. I think
% this complication is what motivated v2, where I don't do any
% flipping/rotating before applying ncrowcol. The disadvantage is that the
% sanity-check maps don't work

% it's possible there is no perfect solution because of different rotations
% within .nc files, and the only way is to first read in the lat/lon,
% figure out the rotation, and then run ncrowcol, or some other search on
% the rotated grids.

% ncrowcol is using the shape of lat/lon (first input) to decide whether
% start/count are referened on the rows or columns of LON/LAT. The
% orientation of LON/LAT mainly determines 

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % below this are a bunch of different versions where if igured out how to
% % get slat/slon clat/clon to match ncstart/nccount, but the end result is
% % that the extracted data doesn't match because of the rotating/flipping,
% % so this is here for reference 
% 
% % this gets slat/slon to match ncstart2d/nccount2d, but the extracted
% % values are wrong b/c we actually don't want them to match
% [slat,clat] =   ncrowcol(lat',LON,LAT,lonpolyb,latpolyb);
% [slon,clon] =   ncrowcol(lon',rot90(LON,3),rot90(LAT,3),lonpolyb,latpolyb);
% 
% [slat slon]
% ncstart2d
% 
% [clat clon]
% nccount2d
% 
% latcheck    =   ncread(fname,'lat',slat,clat);
% loncheck    =   ncread(fname,'lon',slon,clon);
% 
% latcheck(:)-latin(:)
% loncheck(:)-lonin(:)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % standard:
% [slat,clat] =   ncrowcol(lat,LON,flipud(LAT),lonpolyb,latpolyb);
% [slon,clon] =   ncrowcol(lon',LON,LAT,lonpolyb,latpolyb);
% 
% % both are wrong here (they're swapped)
% [slat slon]     % 15 39
% ncstart2d       % 39 15
% 
% % try making lat a row
% [slat,clat] =   ncrowcol(lat',LON,LAT,lonpolyb,latpolyb);
% [slon,clon] =   ncrowcol(lon',LON,LAT,lonpolyb,latpolyb);
% 
% % slat is correct here
% [slat slon]     % 39 39
% ncstart2d       % 39 15
% 
% % try making lat a row
% [slat,clat] =   ncrowcol(lat',LON,LAT,lonpolyb,latpolyb);
% [slon,clon] =   ncrowcol(lon',LON,flipud(LAT),lonpolyb,latpolyb);
% 
% [slat slon]     % 39 39
% ncstart2d       % 39 15
% 
% % try flipping LON
% [slat,clat] =   ncrowcol(lat',LON,LAT,lonpolyb,latpolyb);
% [slon,clon] =   ncrowcol(lon',flipud(LON),LAT,lonpolyb,latpolyb);
% 
% [slat slon]     % 39 39
% ncstart2d       % 39 15
% 
% % try flipping LON and LAT
% [slat,clat] =   ncrowcol(lat',LON,LAT,lonpolyb,latpolyb);
% [slon,clon] =   ncrowcol(lon',flipud(LON),flipud(LAT),lonpolyb,latpolyb);
% 
% [slat slon]     % 39 39
% ncstart2d       % 39 15
% 
% % try rotating LON and LAT
% [slat,clat] =   ncrowcol(lat',LON,LAT,lonpolyb,latpolyb);
% [slon,clon] =   ncrowcol(lon',rot90(LON,3),rot90(LAT,3),lonpolyb,latpolyb);
% 
% [slat slon]     % 39 15
% ncstart2d       % 39 15
% 
% [clat clon]     % 1 2
% nccount2d       % 1 2
% 
% % THIS FINALLY WORKS
% 
