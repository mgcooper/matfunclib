% the original script that saved the world_borders.mat file

f   = '/Volumes/GoogleDrive/My Drive/GIS/TM_WORLD_BORDERS-0/';
f   = [f 'TM_WORLD_BORDERS-0.3.shp'];
borders = shaperead(f);
save('/Volumes/GoogleDrive/My Drive/MATLAB/myFunctions/raster/data/world_borders','borders');
figure; mapshow(borders)