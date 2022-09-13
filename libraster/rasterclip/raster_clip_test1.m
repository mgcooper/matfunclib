% Arctic mapping tools example, with modification

clean

% the issue is that the inset map is not clipped to the ice

%%
save_figs           =   0;

%%
homepath            =   pwd;

if strcmp(homepath(2:6),'Users')
    delim           =   '/';
    path.mask       =   ['/Users/MattCooper/Dropbox/CODE/MATLAB/GREENLAND/' ...
                            'GIMP/data/'];
    path.save       =   ['/Users/MattCooper/Dropbox/CODE/MATLAB/GREENLAND/' ...
                            'CryoSat2/figs/helm_dem/'];
elseif strcmp(homepath(10:16),'mcooper')
    delim           =   '\';
end

%%

% load the GIMP ice mask
% load([path.mask 'GimpIceMask_geo_noZ_bend_simplified_min_area_10km2']);
load([path.mask 'GimpIceMask_90m']);

% load the cryosat2 helm dem
% [lat,lon,Zgeo,info] =   cryosat2_data;
% [y,x,Zups,info]     =   cryosat2_data('xy');

% I think I can give it the x,y limits of gimp
[lat,lon,Zgeo,info] =   cryosat2_data;
[y,x,Zups,info]     =   cryosat2_data('xy');

%% test section to try to create clip raster function
xlim1       =   [mask.info.BoundingBox(1,1) mask.info.BoundingBox(2,1)];
ylim1       =   [mask.info.BoundingBox(1,2) mask.info.BoundingBox(2,2)];

xlim2       =   [info.BoundingBox(1,1) info.BoundingBox(2,1)];
ylim2       =   [info.BoundingBox(1,2) info.BoundingBox(2,2)];

% figure out which raster is most NW 
