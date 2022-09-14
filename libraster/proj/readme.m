% May 2021: matlab now has projcrs function, but it's annoying to remember
% the codes/authorities. I created a folder 'mapstructs' where I put the
% older proj_nps and proj_sipsn mapstructs i had made, and a script
% save_projections where I made new ones using projcrs

% April 2021 update. There is a TLDR below, but this is the true TLDR

% psn has two versions - what I call psn and sipsn
% psn uses Hughes Ellipsoid, which has Greenland vertical when I map it
% sipsn uses WGS84 Ellipsoid, and has Greenland slightly angled
% ease is altogether different - it is an equal area (psn is equal angle)

% for what I call psn and sipsn:
% https://nsidc.org/data/polar-stereo/ps_grids.html
% SIPSN, Hughes 1980, EPSG 3411 (SIPSS = 3412)  (I call this 'psn')
% SIPSN, WGS 84, EPSG 3413 (SIPSS = 3976)       (I call this 'sipsn')

% for EASE:
% https://nsidc.org/data/ease

% (sipsn 2 and psn below are nearly identical, but have different
% 'projection method'. sipsn 1 is what I used to call psn) 

sipsn1   =   projcrs(3411,'Authority','EPSG');
sipsn2   =   projcrs(3413,'Authority','EPSG');
psn      =   projcrs(102018,'Authority','ESRI');
ease     =   projcrs(3408,'Authority','EPSG');


psn.Name        % North_Pole_Stereographic
sipsn1.Name     % NSIDC Sea Ice Polar Stereographic North
sipsn2.Name     % WGS 84 / NSIDC Sea Ice Polar Stereographic North
ease.Name       % NSIDC EASE-Grid North

sipsn1.GeographicCRS.Spheroid.Name  % Hughes 1980
sipsn2.GeographicCRS.Spheroid.Name  % WGS 84
psn.GeographicCRS.Spheroid.Name     % WGS 84
ease.GeographicCRS.Spheroid.Name    % International 1924 Authalic Sphere

sipsn1.GeographicCRS.Datum  % Not specified (based on Hughes 1980 ellipsoid)
sipsn2.GeographicCRS.Datum  % World Geodetic System 1984
psn.GeographicCRS.Datum     % World Geodetic System 1984
ease.GeographicCRS.Datum    % Not specified (based on International 1924 Authalic Sphere)

sipsn1.ProjectionMethod     % Polar Stereographic (variant B)
sipsn2.ProjectionMethod     % Polar Stereographic (variant B)
psn.ProjectionMethod        % Polar Stereographic (variant A)
ease.ProjectionMethod       % Lambert Azimuthal Equal Area (Spherical)

%
% I am not sure where I made these. I think i just read in the gimp dem in
% psn and sipsn and saved what matlab made. 

% I am nearly certain that proj_nps is incorrect. The polar stereographic
% north projection is very confusing, in part because of the NSIDC "sea
% ice" polar stereographic, which also has a WGS 84 version, and the EASE
% projection. 

% TLDR:

% for polar stereographic north, what I call psn:
% https://nsidc.org/data/polar-stereo/ps_grids.html

% for EASE:
% https://nsidc.org/data/ease

% psn has two versions - what I call psn and sipsn
% psn is the one based on the Hughes Ellipsoid, which has Greenland
% vertical when I map it
% sipsn is WGS84 ellipsoid, and has Greenland slightly angled
% ease is altogether different - it is an equal area (psn is equal angle)

% polar stereographic north definitely has a 

load('proj_nps.mat')
load('proj_sipsn.mat')
% the EPSG code is saved here:
proj_nps.GeoTIFFCodes.PCS
proj_sipsn.GeoTIFFCodes.PCS

% the proj_nps had 32627 for PCS, which is 'user defined', meaning matlab
% probably wasn't able to figure out what it was, so here I reset proj_nps
% and resaved: 
proj_nps.GeoTIFFCodes.PCS = 3411;
proj_nps.GCS = 'Unspecified datum based upon the Hughes 1980 ellipsoid';
proj_nps.Datum = 'Not_specified_based_on_Hughes_1980_ellipsoid';
proj_nps.Ellipsoid = 'Hughes 1980';
proj_nps.SemiMajor = 6378273;

% this is the degree units 0.01745329251994328
% this should be the flattening 298.279411123064
% radius: 6378.273 km eccentricity: 0.081816153

% for now i am not going to save it

% 32627 is user defined projection. This is the PCS for nps
% 3413 is WGS 84 / NSIDC Sea Ice Polar Stereographic North (sipsn)
% 3411 is NSIDC Sea Ice Polar Stereographic North (note absence of WGS 84).
% this is the polar stereographic north that I am used to using, that I
% call nps and chad greene calls psn

% see https://spatialreference.org/ref/epsg/3411/

% I also found better info here, because it verified the detail about the
% Hughes ellipsoid, which is how i know 3411 is nps
% https://epsg.io/3411

% this also alerted me to the fact that Chad Greene's default fucntion is
% ot convert to sipsn

% to convert using gdal warp I used 32622 for utm22n and 3411 for psn