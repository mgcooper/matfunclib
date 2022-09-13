% I need a script that finds the ncdf coordinates
clean

save_data   =   true;
basin       =   'upper_basin';

fliprot     =   true;
searchmaps  =   false;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    set paths
p.data  =   '/Users/coop558/mydata/merra2/1hrly/ncfiles/rad/';
p.obs   =   setpath(['GREENLAND/runoff/data/icemodel/eval/' basin '/']);
p.save  =   setpath('GREENLAND/runoff/data/ice_temperature/hills2018/data/');
list    =   dir(fullfile([p.data '*.nc4']));

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    load the catchment boundary
load('projsipsn')
load([p.obs 'Q_' basin],'sf');
mappoly     =   sf.med.spsn.poly;
geopoly     =   polyshape(sf.med.spsn.lon,sf.med.spsn.lat);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    read in one data file
fname       =   [p.data list(155).name];
vars        =   ncparse(fname);
info        =   ncinfo(fname);
lon         =   ncread(fname,'lon');
lat         =   ncread(fname,'lat');
swsd        =   ncread(fname,'SWGNT');
[LON,LAT]   =   meshgrid(lon,lat);

% test whether it is necessary to flip/rotate
if fliprot == true
    LAT         =   flipud(LAT);
    swsd        =   rot90_3D(swsd,3,1);
end

% these depend on fliprot so must come after
[X,Y]       =   projfwd(projsipsn,LAT,LON);
swsdavg     =   mean(swsd,3);

% % This won't look right if no flipud/rot90
% figure; worldmap([min(LAT(:)) max(LAT(:))],[min(LON(:)) max(LON(:))]);
% scatterm(LAT(:),LON(:),20,swsdavg(:)); colorbar
% 
% figure; geoshow(LAT,LON,swsdavg,'DisplayType','texturemap')

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    create a search region using polybuffer
mapbuffer   =   18000;
geobuffer   =   0.5;
geopolyb    =   polybuffer(geopoly,geobuffer);
mappolyb    =   polybuffer(mappoly,mapbuffer);
lonpolyb    =   geopolyb.Vertices(:,1);
latpolyb    =   geopolyb.Vertices(:,2);
xpolyb      =   mappolyb.Vertices(:,1);
ypolyb      =   mappolyb.Vertices(:,2);

% % this was in v2 but not v1
% [slat,clat] =   ncrowcol(lat,X,Y,xpolyb,ypolyb);
% [slon,clon] =   ncrowcol(lon,X,Y,xpolyb,ypolyb);
% [sswd,cswd] =   ncrowcol(swsd,X,Y,xpolyb,ypolyb);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    find points in the region with inpolygon

ingeopolyb  =   inpolygon(LON,LAT,lonpolyb,latpolyb); sum(ingeopolyb(:))
inmappolyb  =   inpolygon(X,Y,xpolyb,ypolyb); sum(inmappolyb(:))
swsdin      =   swsd(inmappolyb);
xin         =   X(inmappolyb);
yin         =   Y(inmappolyb);
lonin       =   LON(ingeopolyb);
latin       =   LAT(ingeopolyb);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    find points in the region with dsearchn
Pmap    =   [X(:) Y(:)];
Pgeo    =   [LON(:) LAT(:)];
PQmap   =   [xpolyb ypolyb];
PQgeo   =   [lonpolyb latpolyb];
kmap    =   dsearchn(Pmap,PQmap);
kgeo    =   dsearchn(Pgeo,PQgeo);

if searchmaps == true
%~~~~~~~~~~~~~~~~~~~~~~~~~~~    plot it using geo coordinates
figure; worldmap([min(LAT(:)) max(LAT(:))],[min(LON(:)) max(LON(:))]);
h(1) = scatterm(LAT(:),LON(:)); hold on;
h(2) = plotm(geopoly.Vertices(:,2),geopoly.Vertices(:,1));
h(3) = plotm(latpolyb,lonpolyb,'Color','g');
h(4) = scatterm(LAT(kgeo),LON(kgeo),50,'r','filled');
h(5) = scatterm(latin,lonin,40,'filled');
legend(h,'points','target','search region','dsearchn','inpolygon')

%~~~~~~~~~~~~~~~~~~~~~~~~~~~    plot it using map coordinates
figure;
scatter(Pmap(:,1),Pmap(:,2)); hold on;
plot(mappoly.Vertices(:,1),mappoly.Vertices(:,2));
scatter(PQmap(:,1),PQmap(:,2),50,'filled')
scatter(X(kmap),Y(kmap),50,'filled');
scatter(xin,yin,200,'LineWidth',2)
legend('points','target','search region','dsearchn','inpolygon')
end

% save the data
if save_data == true
    if fliprot == true
        fsave = 'merra_fliprot'; 
    else
        fsave = 'merra'; 
    end
    
    save(fsave,'inmappolyb','ingeopolyb','latin','lonin',               ...
                'xin','yin','swsdin','swsd','lat','lon',                ...
                'LAT','LON','X','Y','xpolyb','ypolyb',                  ...
                'latpolyb','lonpolyb','fname','projsipsn')
end
