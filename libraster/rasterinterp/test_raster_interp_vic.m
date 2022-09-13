clean

path1 = '/Users/MattCooper/Google UCLA/ArcGIS/Geog207/SWE_mask/';
path2 = '/Users/MattCooper/Google UCLA/ArcGIS/Geog207/PPT_mask/';

addpath(path1);
addpath(path2);

[Z1,R1] = geotiffread([path1 'vic_swe_data_sample.tif']);
[Z2,R2] = geotiffread([path2 'Prec_Sample.tif']);

Ztest = rasterinterp(Z1,R1,R2);

figure;geoshow(Z1,R1,'DisplayType','texturemap')
figure;geoshow(Z2,R2,'DisplayType','texturemap')
figure;geoshow(Ztest,R2,'DisplayType','texturemap')