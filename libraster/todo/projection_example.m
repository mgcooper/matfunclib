clean

path = '/Users/MattCooper/Google UCLA/ArcGIS/Greenland/Greenland/';
 
% raster example of sipsn projection
gimp_sipsn = [path 'GIMP/IceMask/tif/GimpIceMask_90m_sipsn.tif'];
[~,Rsipsn] = geotiffread(gimp_sipsn);
Rinfosipsn = geotiffinfo(gimp_sipsn);

% shapefile example of sipsn projection
gl_sipsn = [path 'Borders/greenland_adm2_nsidc_sea_ice_north.shp'];
Ssipsn = shaperead(gl_sipsn);
Sinfosipsn = shapeinfo(gl_sipsn);

% North Pole stereographic

% raster example of nps projection
gimp_nps = [path 'GIMP/IceMask/tif/GimpIceMask_90m.tif'];
[~,Rnps] = geotiffread(gimp_nps);
Rinfonps = geotiffinfo(gimp_nps);

% shapefile example of nps projection
gl_nps = [path 'Borders/greenland_adm2_nps.shp'];
Snps = shaperead(gl_nps);
Sinfonps = shapeinfo(gl_nps);

open Rnps
open Rinfonps
open Rsipsn
open Rinfosipsn

open Snps
open Sinfonps
open Ssipsn
open Sinfosipsn

% the only one that has any projection info is Rinfo, which is provided by
% geotiffinfo

% Map projections supported by projfwd and projinv
plist = projlist('all');

% Matlab uses the following nomenclature for projections:
% GeoTIFF ? GeoTIFF projection ID 
% MapProjection ? Projection ID

% for NSIDC sea ice polar stereographic north the values are:
% GeoTIFF projection ID = 'CT_PolarStereographic'
% MapProjection = 'ups'

% for north polar stereographic thevalues are:
% GeoTIFF projection ID = 'CT_PolarStereographic'
% MapProjection = 'ups'

Rinfosipsn.GeoTIFFCodes
Rinfonps.GeoTIFFCodes

% comparing these you see they are basically identical
Rcomp = [Rinfosipsn;Rinfonps];
TiffCodescomp = [Rinfosipsn.GeoTIFFCodes;Rinfonps.GeoTIFFCodes];

