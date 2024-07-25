function save_world_borders(varargin)

   if nargin < 1
      pathfile = which('TM_WORLD_BORDERS-0.3.shp');
      % for example:
      % pathfile = '/Volumes/GoogleDrive/My Drive/GIS/TM_WORLD_BORDERS-0/TM_WORLD_BORDERS-0.3.shp';
   else
      pathfile = varargin{1};
   end

   if nargin < 2
      pathsave = fullfile(getenv('MATLABFUNCTIONPATH'),'libraster','data');
   else
      pathsave = varargin{2};
   end

   borders = shaperead(pathfile);
   save(fullfile(pathsave, 'world_borders.mat'), 'borders');

   plotfig = false;
   if plotfig
      figure
      mapshow(borders)
   end
end
