
% what i ended up doing: I saved the lat/lon cell lists and for one region i
% saved the bbox, S, T, etc see below. The fucntion is reasonably fast as-is but
% I can test the following:
% - ogr2ogr see syntax below
% - datastore
% - tall arrays
% - using the bounding boxes instead of latlon cell arrays
% - 

% here's how I think this should be done:
% option 1: matfile
% save the entire hydrorivers file as a matfile v7.3
% ultimately, use the matfile function to read in parts of the file
% but to determine what part, we need a look-up table or some method to find
% which river reaches are within a bounding box

addpath(genpath(getenv('USERDATAPATH')))

% system(['ogr2ogr -clipsrc ' geomfile ' ' tmpfile ' ' sourcefile])

% I could get the bboxes and save them as singles with the following format:
% LATXXXLONXXX where XXX is three decimal places, so a bounding box like 

% another approach is to learn the hydrosheds attributes and filter reaches by level


% the lat/lon fields have nan at the end of each entry so we can convert
% to lists without worrying about inserting them, but we could also remove them
% for the purpose of finding which ones are in the user supplied bounding box.
% for now I am not doing that.


%% reference notes

% the bbox is [xmin,ymin;xmax,ymax], for map coordinates, or [lonmin,latmin;lonmax,latmax] 

% for ingeoquad:
% latlim is a vector of the form [southern-limit northern-limit]
% lonlim is a vector of the form [western-limit eastern-limit].

% cellfun goes cell by cell, so the first call to cell fun is basically doing this:
ingeoquad(latc{1}',lonc{1}',latlims,lonlims);
ingeoquad(latc{2}',lonc{2}',latlims,lonlims);


%% save the lat/lon coordinates of all hydrorivers for each region
clean

savedata = true;

cd('/Users/coop558/work/data/hydrosheds/')

% save the region files
% regions = {'Africa','Arctic','Asia','Australasia','Europe', ...
%    'Greenland','NorthAmerica','SouthAmerica','Siberia'};
suffixes = {'','_af','_ar','_as','_au','_eu','_gr','_na','_sa','_si'};

for n = 1:numel(suffixes)
   f = fullfile(strcat('HydroRIVERS_v10',suffixes{n},'.shp'));
   [S,A] = shaperead(f, 'UseGeoCoords', true);
   
   A = struct2table(A);
   latc = {S.Lat};
   lonc = {S.Lon};
   clear S % don't do this if saving the test files as below
   
   if savedata == true
      f1 = strrep(f,'.shp','_Atts.mat');
      f2 = strrep(f,'.shp','.mat');
      save(f1,'A'); clear A
      save(f2,'latc','lonc'); clear latc lonc
   end
   
%    % for testing, save S, bbox, and Lat/Lon separately, then later we can test
%    % loading / processing speed
%    if testsave == true
%       S = rmfield(S,'Geometry');
%       T = struct2table(S);
%       bbox = T.BoundingBox;
%       ff = strrep(f,'.shp','_T.mat');
%       save(ff,'T'); clear T
%       ff = strrep(f,'.shp','_bbox.mat');
%       save(ff,'bbox'); clear bbox
%       ff = strrep(f,'.shp','_S.mat');
%       save(ff,'S'); clear S
%    end
end

%% resave the Global data using my new convention

% 
% load('hydroriversLatLonlist.mat')
% lat = hydroriversLat; lon = hydroriversLon; clear hydroriversLat hydroriversLon
% [latc,lonc] = polysplit(lat,lon); clear lat lon
% save('HydroRIVERS_v10_v73.mat','latc','lonc','-v7.3');
% save('HydroRIVERS_v10.mat','latc','lonc'); clear latc lonc
% load('hydroriversatts.mat','hydroriversatts'); 
% A = hydroriversatts; clear hydroriversatts
% save('HydroRIVERS_v10_Atts.mat','A'); clear A


%% resave as cells

% load('hydroriversLatLon_ar_clip.mat','lat','lon');
% [latc,lonc] = polysplit(lat,lon);
% save('hydroriversLatLonCells_ar_clip.mat','latc','lonc');

%% minimal example

clean

load('HydroRIVERS_v10_ar.mat','latc','lonc');
ca = loadworldborders('Canada');
ak = loadstateshapefile('Alaska');

latlims = [50 55];
lonlims = [-125 -120];
func = @(x,y) transpose(ingeoquad(x.',y.',latlims,lonlims));

test = cellfun(func,latc,lonc,'Uni',0);
lat2 = cellfun(@(x,y) vertcat(x(y)),latc,test,'Uni',0);
lon2 = cellfun(@(x,y) vertcat(x(y)),lonc,test,'Uni',0);
keep = ~cellfun('isempty',lat2); sum(keep) % WORKS!
lat3 = lat2(keep);
lon3 = lon2(keep);
[lat3,lon3] = polyjoin(lat3,lon3);
figure; worldmap([45 60],[-130 -115]); hold on; plotm(lat3,lon3);

% can I combine any cellfun calls?
lat = cellfun(@(x,y)vertcat(x(y)),latc,cellfun(func,latc,lonc,'Uni',0),'Uni',0);
lon = cellfun(@(x,y)vertcat(x(y)),lonc,cellfun(func,latc,lonc,'Uni',0),'Uni',0);
keep = ~cellfun('isempty',lat2); sum(keep) % WORKS!

%% this shows it works using the Arctic '_ar' file

[lat,lon] = polyjoin(latc,lonc);
figure; 
worldmap([45 90],[-180 180]); 
plotm(lat,lon); hold on;
geoshow(ca,'FaceColor','none','EdgeColor','r');
geoshow(ak,'FaceColor','none','EdgeColor','r');

%% even more minimal

clean

load('hydroriversLatLonCells_ar_clip.mat','latc','lonc');

latlims = [50 55];
lonlims = [-125 -120];

fnc1 = @(x,y) transpose(ingeoquad(x.',y.',latlims,lonlims));
fnc2 = @(x,y) vertcat(x(y));

[lat,lon] = polyjoin(latc(~cellfun('isempty',cellfun(fnc2,latc,cellfun(fnc1,latc,lonc,'Uni',0),'Uni',0))), ...
   lonc(~cellfun('isempty',cellfun(fnc2,lonc,cellfun(fnc1,latc,lonc,'Uni',0),'Uni',0))));

figure; worldmap([45 60],[-130 -115]); hold on; plotm(lat,lon);

%% test saving as Tall array

% ARCTIC 
f = 'HydroRIVERS_v10_ar.shp';
S = shaperead(f, 'UseGeoCoords', true);
T = struct2table(S);
T = tall(T); 
save('hydroriversarTall.mat','T','-v7.3');

% now try selecting rows of 

%% test fileDatastore

% fds = fileDatastore('HydroRIVERS_v10_ar.shp',"ReadFcn",@(x) shaperead(x,);

%% load the saved ar bbox lat/lon

% it only takes 0.15 seconds to load the lat/lon arrays, so it might work to
% just load them and find all rivers in the bounding box, but then I will end up
% with clipping issues because they're 


% this demonstrates / tests the clipping issue. we used shaperead to select the
% rivers in latlims/lonlims, but when we read in the lat/lon arrays and use the
% same latlims/lonlims, we clip rivers because the data is in nan-sep lists, so
% I see two options: 1) save the boudning boxes as nan-sep lists and /or use
% known 1:4 indexing to work with them, and see if it si fast to find all
% bounding boxes inside a user-provided one, or 2) see if reading in the lat/lon
% nan-sep lists, polyjoin, find in box, etc is faster ...

idx = lat<latlims(2) & lat>latlims(1) & lon<lonlims(2) & lon>lonlims(1);
figure; worldmap(latlims,lonlims); plotm(lat(idx),lon(idx));

%% test matfile

exampleObject = matfile('hydroriversLatLon_ar_clip.mat','Writable',true);
firstRowB = exampleObject.hydroriversLat(1,:); 
firstRowB = 2 * firstRowB;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 




%% workign with the global shapefile

% NOTE: i moved the lists creted below into the data/hydrosheds folder b/c
% they're too large 

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % EXTREMELY SLOW
% % I SAVED THE files in this block but not sure they are going to be useful

% S = shaperead('HydroRIVERS_v10.shp', 'UseGeoCoords', true);
% 
% hydroriversID = [S.HYRIV_ID];
% save('hydroriversIDlist.mat','hydroriversID'); clear hydroriversID
% 
% % Lat/Lon for all borders (vectors end with nan so simple concatenation works)
% hydroriversLat = [S(:).Lat];
% hydroriversLon = [S(:).Lon];
% save('hydroriversLatLonlist.mat','hydroriversLat','hydroriversLon'); clear hydroriversLat hydroriversLon
% 
% S = rmfield(S,{'Geometry','BoundingBox','Lon','Lat'});
% hydroriversatts = struct2table(S);
% save('hydroriversatts.mat','hydroriversatts'); clear hydroriversatts

% % based on this, I think I need to download the regional files and/or merge
% the latlon records int

% % see if I can load by BoundingBox quickly NOPE
% latlims = [50 75];
% lonlims = [-170 -120];
% bbox = [lonlims' latlims'];
% 
% S = shaperead('HydroRIVERS_v10.shp', 'UseGeoCoords', true, 'BoundingBox',bbox);



















