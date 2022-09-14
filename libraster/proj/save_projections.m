pathsave    = '/Users/coop558/Dropbox/CODE/MATLAB/myFunctions/raster/proj/';

% for sipsn, note that 3411 is the older version, 3413 is the new WGS84 
projease        = projcrs(3408,'Authority','EPSG');
% projsipsnold    = projcrs(3411,'Authority','EPSG');
projsipsn       = projcrs(3413,'Authority','EPSG');
projutm22n      = projcrs(32622,'Authority','EPSG');
projpsn         = projcrs(102018,'Authority','ESRI');

save([pathsave 'projease'],'projease');
save([pathsave 'projsipsn'],'projsipsn');
save([pathsave 'projutm22n'],'projutm22n');
save([pathsave 'projpsn'],'projpsn');
