function filelist = getgisfilelist
% GETGISFILELIST get a list of all spatial data files in USERGISPATH
% 
%     filelist = getgisfilelist() returns a list of files in USERGISPATH
% 
% Matt Cooper, 2022, https://github.com/mgcooper
% 
% See also:

exts = {'.shp','.tif','.tiff','.csv','.geojson','.json'};
filelist = [];
for n = 1:numel(exts)
   filelist = [filelist; getlist(getenv('USERGISPATH'),exts{n},'subdirs',true)];
end

% keep unique files
[~,ok] = sort(unique({filelist.name}));
filelist = {filelist(ok).name}';

% should probably just use getlist with .shp, .tif, and any other gis
% extensions, which can be stored in another list or passed in.
% filelist = dir(fullfile(getenv('USERGISPATH')));
% filelist = rmdotfolders(filelist);
% filelist = filelist(~[filelist.isdir]);