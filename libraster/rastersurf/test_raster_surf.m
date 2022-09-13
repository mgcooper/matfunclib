%%

% one issue is if there is a no data value. do I want to deal with it or
% make the user deal with it? Also nan.

%%
% subset global topographic data to northern hemisphere
load topo; Z = topo; clear topo
R = georefcells(topolatlim,topolonlim,size(Z));
newlatlim = [0 90];
newlonlim = [0 360];
newsize = [newlatlim(2) newlonlim(2)];
Rq = georefcells(newlatlim,newlonlim,newsize);
Zq = rasterinterp(Z,R,Rq);
figure; geoshow(Z,R,'DisplayType','surface'); title('Original');
figure; geoshow(Zq,Rq,'DisplayType','surface'); title('Subset');
  
  %%
[Z, R] = sdtsdemread('9129CATD.DDF');
R = refmatToMapRasterReference(R,size(Z));

figure;
rastershow(Z,R)

figure;
rastermesh(Z,R)

figure;
rastercontour(Z,R)


refvec
refmat

refvecToGeoRasterReference

refmatToGeoRasterReference
refmatToMapRasterReference

maprefcells

maprasterref is deprecated, use maprefcells

%% for rastersurf3
R=info.SpatialRef;
mapshow(Z,R,'DisplayType','contour','ShowText','on');
view(2)
axis normal
box off
c=colorbar;
c.Location = 'southoutside';

% decide if I want this
set(gca, 'DataAspectRatio', [diff(get(gca, 'XLim')) diff(get(gca, 'XLim')) diff(get(gca, 'ZLim'))])
% also shading flat

%% if i want to keep this

epsg.nsidc_sipsn = 3411;
epsg.wgs84_nsidc_sipsn = 3413;

load('/toolbox/map/mapproj/projdata/epsg_csv/epsg.csv')




