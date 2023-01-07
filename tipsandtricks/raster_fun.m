
% % % % % % % % % % % % % % % % % % 
% % below was in the README in runoff project 

%  also an opportunity to keep track of the simplest and best raster shows

% this one shows up a lot
figure; geoshow(lat,lon,swsd,'DisplayType','texturemap');
figure; worldmap('Greenland'); scatterm(latrs,lonrs,60,swsdrs,'filled');

% this was probably to get vector on top:
figure;
rastersurf(Zq,Rq,'ZData',zeros(size(Zq))); hold on;
mapshow(xin,yin,'Marker','o','MarkerFaceColor','k','MarkerSize',10,'LineStyle','none');
mapshow(x14,y14,'Marker','x','MarkerFaceColor','k','MarkerSize',20);
% came from get_merra_bb, x/yin is the coordinates in teh poly, x/y14 the
% coordinates of ben hills site in 2014

% with textm:
% figure;
% worldmap(latlims,lonlims); hold on;
% geoshow(latrb,lonrb);
% scatterm(latin,lonin,250,swsdin,'filled');
% textm(latin-0.02,lonin+0.06,labels);

% say we make a subplot on a worldmap axis, get the clims:
% clims =   caxis;
% setm(m1,'MLabelLocation',0.3)
% setm(m1,'FontSize',16)
% 
% % then make the next subplot, use clims:
% caxis(clims);


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% nco suggestions:
% https://nicojourdain.github.io/students_dir/students_netcdf_nco/

% this was 'RASTER_MASTER' but i moved it here

% at some point, probably need to just use this:
% https://github.com/GenericMappingTools/gmtmex
% https://agupubs.onlinelibrary.wiley.com/doi/pdf/10.1002/2016GC006723

% but at their github they say osx install is complicated so i dferred

% list all the built-in map data
ls(fullfile(matlabroot, 'toolbox', 'map', 'mapdata'))

cd('/Applications/MATLAB_R2020a.app/toolbox/map/mapdata/')



% this confirms the order in which I flipud/permute/average is identical
% flip/rot first, then average
V       =   ncread(fname,varname);
V       =   squeeze(V);
V       =   flipud(permute(V,[2 1 3]));
V1      =   nanmean(V,3);
% average first, then flip/rot 
V       =   ncread(fname,varname);
V       =   squeeze(V);
V2      =   squeeze(nanmean(V,3));
V2      =   flipud(permute(V2,[2 1]));
Vtest   =   V2-V1;

max(Vtest(:))
min(Vtest(:))
