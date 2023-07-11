function save_world_borders(varargin)

if nargin < 2
   pathsave = fullfile(getenv('MATLABFUNCTIONPATH'),'libraster','data');
end

if nargin < 1
   pathfile = which('TM_WORLD_BORDERS-0.3.shp');
   % for example:
   % pathfile = '/Volumes/GoogleDrive/My Drive/GIS/TM_WORLD_BORDERS-0/TM_WORLD_BORDERS-0.3.shp';
end
borders = shaperead(pathfile);
save(fullfile(pathsave, 'world_borders.mat'), 'borders');

if plotfig == true
   figure; 
   mapshow(borders)
end