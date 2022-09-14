clean
p.data  = '/Volumes/GDRIVE/DATA/landsat8/greenland/20160726/';
p.data  = [p.data 'LC08_L2SP_007013_20160726_20200906_02_T1/'];
p.save  = [p.data 'sipsn/'];
list    = getlist(p.data,'*.TIF');

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% reproject
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% define the gdal options to perform
func    = '/usr/local/bin/gdalwarp ';
opts    = '-s_srs EPSG:32622 -t_srs EPSG:3413 -r near -overwrite -of GTiff -co "TFW=YES" ';

for i = 1:length(list)
    
    fin     = [p.data list(i).name];
    fout    = [p.save strrep(list(i).name,'.TIF','.TIFF')];
    command = [func opts fin ' ' fout];
    status  = system(command);
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% set cell interpretation to 'AREA'
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% define the gdal options to perform
func    = '/usr/local/bin/gdal_translate ';
opts    = '-s_srs EPSG:32622 -t_srs EPSG:3413 -r near -overwrite -of GTiff -co "TFW=YES" ';

for i = 1:length(list)
    
    fin     = [p.data list(i).name];
    fout    = [p.save strrep(list(i).name,'.TIF','.TIFF')];
    command = [func opts fin ' ' fout];
    status  = system(command);
end

projlam = projcrs(9820,'Authority','EPSG')
projlam = projcrs(102009,'Authority','ESRI')
projpsn = projcrs(3413,'Authority','EPSG')

%{ 

for reference, this could also be doen:

!/usr/local/bin/gdalwarp -s_srs EPSG:32622 -t_srs EPSG:3413 -r lanczos -overwrite -of GTiff -co "TFW=YES" LC08_L2SP_007013_20160726_20200906_02_T1_QA_PIXEL.TIF sipsn/test.TIFF
!/usr/local/bin/gdal_translate -mo AREA_OR_POINT=AREA -co "TFW=YES" sipsn/test.TIFF sipsn/test2.TIFF

!/usr/local/bin/gdalwarp -s_srs EPSG:32622 -t_srs ESRI:102009 -of GTiff -co "TFW=YES" LC08_L2SP_007013_20160726_20200906_02_T1_QA_PIXEL.TIF sipsn/test.TIFF

%}

%{ 

matlab will ignore anything in here

!/usr/local/bin/gdalwarp -s_srs EPSG:32622 -t_srs ESRI:102009 -of GTiff -co "TFW=YES" LC08_L2SP_007013_20160726_20200906_02_T1_QA_PIXEL.TIF sipsn/test.TIFF

%}

[test1a,R1a] = readgeoraster([p.save 'test.TIFF']);

[test1a,R1a] = geotiffread([p.data 'sipsn/test.TIFF']);
[test1b,R1b] = readgeoraster([p.data 'sipsn/test.TIFF']);
[test2a,R2a] = geotiffread([p.data 'sipsn/test2.TIFF']);
[test2b,R2b] = readgeoraster([p.data 'sipsn/test2.TIFF']);

% utm22n = 32622 % +proj=utm +zone=22 +ellps=WGS84 +datum=WGS84 +units=m +no_defs 
% psn = 3411 % +proj=stere +lat_0=90 +lat_ts=70 +lon_0=-45 +k=1 +x_0=0 +y_0=0 +a=6378273 +b=6356889.449 +units=m +no_defs

% although these worked, I could have set the proj4 string using -ct:
% gdalwarp -s_srs EPSG:32622 -t_srs EPSG:3411 -ct '+proj=stere +lat_0=90 +lat_ts=70 +lon_0=-45 +k=1 +x_0=0 +y_0=0 +a=6378273 +b=6356889.449 +units=m +no_defs'

% gdalwarp -s_srs EPSG:32622 -t_srs EPSG:3411 LC08_L1TP_007013_20160726_20180130_01_T1_sr_band1.tif psn/LC08_L1TP_007013_20160726_20180130_01_T1_sr_band1_psn.tif
% gdalwarp -s_srs EPSG:32622 -t_srs EPSG:3411 LC08_L1TP_007013_20160726_20180130_01_T1_sr_band2.tif psn/LC08_L1TP_007013_20160726_20180130_01_T1_sr_band2_psn.tif
% gdalwarp -s_srs EPSG:32622 -t_srs EPSG:3411 LC08_L1TP_007013_20160726_20180130_01_T1_sr_band3.tif psn/LC08_L1TP_007013_20160726_20180130_01_T1_sr_band3_psn.tif
% gdalwarp -s_srs EPSG:32622 -t_srs EPSG:3411 LC08_L1TP_007013_20160726_20180130_01_T1_sr_band4.tif psn/LC08_L1TP_007013_20160726_20180130_01_T1_sr_band4_psn.tif
% gdalwarp -s_srs EPSG:32622 -t_srs EPSG:3411 LC08_L1TP_007013_20160726_20180130_01_T1_sr_band5.tif psn/LC08_L1TP_007013_20160726_20180130_01_T1_sr_band5_psn.tif
% gdalwarp -s_srs EPSG:32622 -t_srs EPSG:3411 LC08_L1TP_007013_20160726_20180130_01_T1_sr_band6.tif psn/LC08_L1TP_007013_20160726_20180130_01_T1_sr_band6_psn.tif
% gdalwarp -s_srs EPSG:32622 -t_srs EPSG:3411 LC08_L1TP_007013_20160726_20180130_01_T1_sr_band7.tif psn/LC08_L1TP_007013_20160726_20180130_01_T1_sr_band7_psn.tif
% 
