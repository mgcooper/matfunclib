clean

%%
save_data           =   1;
%%

% this was copied from 'projection_example' when I realized it would be
% useful to save the geotiffinfo structures for the main projections I use.
% Note, Matlab calls the geotiffinfo structure a GeoTIFF projection
% structure, proj, and uses mstruct = geotiff2mstruct(proj) to convert to a
% map projection structure, the difference being that mstruct strips out a
% bunch of ancillary metadata that is not relevant to the spatial reference

%%
homepath            =   pwd;

if strcmp(homepath(2:6),'Users')
    path.data       =   ['/Users/MattCooper/Google UCLA/ArcGIS/Greenland/' ...
                            'Greenland/GIMP/IceMask/tif/'];
    path.save       =   ['/Users/mattcooper/Dropbox/CODE/MATLAB/' ...
                            'myFunctions/raster/proj/'];
elseif strcmp(homepath(10:16),'mcooper')    
end

%% 

% Sea Ice Polar Stereographic North
gimp_sipsn          =   [path.data 'GimpIceMask_90m_sipsn.tif'];
[~,Rsipsn]          =   geotiffread(gimp_sipsn);
proj_sipsn          =   geotiffinfo(gimp_sipsn);
mstruct_sipsn       =   geotiff2mstruct(proj_sipsn);

% North Pole stereographic
gimp_nps            =   [path.data 'GimpIceMask_90m.tif'];
[~,Rnps]            =   geotiffread(gimp_nps);
proj_nps            =   geotiffinfo(gimp_nps);
mstruct_nps         =   geotiff2mstruct(proj_nps);

%% save them 

if save_data == 1
    save([path.save 'proj_nps'],'proj_nps','Rnps','mstruct_nps');
    save([path.save 'proj_sipsn'],'proj_sipsn','Rsipsn','mstruct_sipsn');
end

% Matlab uses the following nomenclature for projections:
% GeoTIFF ? GeoTIFF projection ID 
% MapProjection ? Projection ID

% for NSIDC sea ice polar stereographic north the values are:
% GeoTIFF projection ID = 'CT_PolarStereographic'
% MapProjection = 'ups'

% for north polar stereographic thevalues are:
% GeoTIFF projection ID = 'CT_PolarStereographic'
% MapProjection = 'ups'

