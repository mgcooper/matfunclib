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
filelist = transpose(unique({filelist.name}));
[~,ok] = sort(filelist);
filelist = filelist(ok);

% should probably just use getlist with .shp, .tif, and any other gis
% extensions, which can be stored in another list or passed in.
% filelist = getlist(getenv('USERGISPATH'),exts);
% filelist = rmdotfolders(filelist);
% filelist = filelist(~[filelist.isdir]);

% custom modification to also search in other GIS paths
p = '/Users/coop558/work/data/icom/GIS/';

filelist_n = [];
for n = 1:numel(exts)
   filelist_n = [filelist_n; getlist(p,exts{n},'subdirs',true)];
end

% keep unique files
filelist_n = transpose(unique({filelist_n.name}));
filelist = sort([filelist; filelist_n]);

% list1 = getlist(getenv('MATLABFUNCTIONPATH'),'*m','subdirs',true);
% list2 = getlist(getenv('FEXFUNCTIONPATH'),'*m','subdirs',true);
% list3 = getlist(getenv('MATLABPROJECTPATH'),'*m','subdirs',true);
% list1 = list1(~contains({list1.name},'readme'));
% list2 = list2(~contains({list2.name},'readme'));
% list3 = list3(~contains({list3.name},'readme'));
% list = [{list1.name} {list2.name} {list3.name}];