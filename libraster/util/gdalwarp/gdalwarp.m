function [status,cmdout,str] = gdalwarp(opts)
%GDALWARP Wrapper for gdalwarp command line utility
% 
% [status,cmdout,str] = gdalwarp(opts)
% 
% Not currently functional
% 
% example:
%     opts.s_srs      = 'source_proj';
%     opts.t_srs      = 'dest_proj';
%     opts.cutline    = 'cutline.shp';
%     opts.srcfile    = 'source_raster.tiff';
%     opts.dstfile    = 'dest_raster.tiff';
%
%     [status,cmdout] = gdalwarp(opts)

% note:
%  cutline accepts ogr supported vector file formats

% Not sure, might work
error('gdalwarp is not currently functional')

providedFields = fieldnames(opts);
hasSourceFile = any(ismember(providedFields,'srcfile'));
hasDestFile = any(ismember(providedFields,'dstfile'));

if ~hasSourceFile | ~hasDestFile
   error('source file and dest file must be provided')
else
   srcfile = opts.srcfile;
   dstfile = opts.dstfile;
end

% remove srcfile and dstfile from the opts structure
opts = removestructfields(opts,{'srcfile','dstfile'});
iRemove = ismember(providedFields,{'srcfile','dstfile'});
providedFields(iRemove) = [];

% init the string
str = 'gdalwarp ';

for n = 1:numel(providedFields)

   thisField = cell2mat(providedFields(n));
   thisValue = opts.(providedFields{n});

   str = [str,'-',thisField,' ',thisValue,' '];
end

str = [str,srcfile,' ',dstfile];


[status,cmdout] = system(str);


% this might be useful:

% possibleFields  = { 's_srs', 't_srs', 'ct', 'to', 'vshift', 's_coord',  ...
%                     't_coord', 'order', 'tps', 'rpc', 'geoloc', 'et',   ...
%                     'refine_gcps', 'te', 'te_srs', 'tr', 'tap', 'ts',   ...
%                     'ovr', 'wo', 'ot', 'wt', 'srcnodata', 'dstnodata',  ...
%                     'srcalpha', 'nosrcalpha', 'dstalpha', 'r',          ...
%                     'wm memory_in_mb', 'multi', 'q', 'cutline', 'cl',   ...
%                     'cwhere', 'csql', 'cblend', 'crop_to_cutline', 'if',...
%                     'of', 'co', 'overwrite', 'nomd', 'cvmd', 'setci',   ...
%                     'oo','doo'};
%
% providedFields = fieldnames(opts);
%
% % hasField = ismember(possibleFields,providedFields);
% idxFields  = find(ismember(possibleFields,providedFields));

% gdalwarp [--help-general] [--formats]
%     [-s_srs srs_def] [-t_srs srs_def] [-ct string] [-to "NAME=VALUE"]* [-vshift | -novshift]
%     [[-s_coord_epoch epoch] | [-t_coord_epoch epoch]]
%     [-order n | -tps | -rpc | -geoloc] [-et err_threshold]
%     [-refine_gcps tolerance [minimum_gcps]]
%     [-te xmin ymin xmax ymax] [-te_srs srs_def]
%     [-tr xres yres] [-tap] [-ts width height]
%     [-ovr level|AUTO|AUTO-n|NONE] [-wo "NAME=VALUE"] [-ot Byte/Int16/...] [-wt Byte/Int16]
%     [-srcnodata "value [value...]"] [-dstnodata "value [value...]"]
%     [-srcalpha|-nosrcalpha] [-dstalpha]
%     [-r resampling_method] [-wm memory_in_mb] [-multi] [-q]
%     [-cutline datasource] [-cl layer] [-cwhere expression]
%     [-csql statement] [-cblend dist_in_pixels] [-crop_to_cutline]
%     [-if format]* [-of format] [-co "NAME=VALUE"]* [-overwrite]
%     [-nomd] [-cvmd meta_conflict_value] [-setci] [-oo NAME=VALUE]*
%     [-doo NAME=VALUE]*
%     srcfile* dstfile


% OLDER SYNTAX:
% gdalwarp [--help-general] [--formats]
%     [-s_srs srs_def] [-t_srs srs_def] [-ct string] [-to "NAME=VALUE"]* [-novshiftgrid]
%     [-order n | -tps | -rpc | -geoloc] [-et err_threshold]
%     [-refine_gcps tolerance [minimum_gcps]]
%     [-te xmin ymin xmax ymax] [-te_srs srs_def]
%     [-tr xres yres] [-tap] [-ts width height]
%     [-ovr level|AUTO|AUTO-n|NONE] [-wo "NAME=VALUE"] [-ot Byte/Int16/...] [-wt Byte/Int16]
%     [-srcnodata "value [value...]"] [-dstnodata "value [value...]"]
%     [-srcalpha|-nosrcalpha] [-dstalpha]
%     [-r resampling_method] [-wm memory_in_mb] [-multi] [-q]
%     [-cutline datasource] [-cl layer] [-cwhere expression]
%     [-csql statement] [-cblend dist_in_pixels] [-crop_to_cutline]
%     [-of format] [-co "NAME=VALUE"]* [-overwrite]
%     [-nomd] [-cvmd meta_conflict_value] [-setci] [-oo NAME=VALUE]*
%     [-doo NAME=VALUE]*
%     srcfile* dstfile


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% here's how someone on the fileexchange went about it:

% makeGeoTiff(path,filename,image,topLat,LeftLon,bottomLat,rightLon)
% path = directory to store file
% filename = name of file to create
% lattop = lat top left in WGS84 decimal deg.
% lonleft = long top left in WGS84 decimal deg.
% latbottom = lat bottom right in WGS84 decimal deg.
% lonright = long bottom right in WGS84 decimal deg.

% function [im  topLat LeftLon bottomLat rightLon ] =makeGeoTiff(path,filename,image,topLat,LeftLon,bottomLat,rightLon)
%     gdalpath = 'C:\Program Files (x86)\FWTools2.4.6\bin\'; % edit this to point at your install of GDAL
%     tempfile = [path '\temp.tif'];
%     imwrite(image,tempfile);
%     dos([ '"' gdalpath 'gdal_translate" ' tempfile ' ' filename 'vrt -of GTiff  -a_srs wgs84 -a_ullr ' ...
%         num2str(LeftLon) ' ' num2str(topLat) ' ' num2str(rightLon) ' ' num2str(bottomLat)])
%     dos(['del ' tempfile]);
% end



% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% below here is the og function probably before i learned about 'system'


% NOTES: I didn't get far with this, but I'd like to build some functions
% to use the gdal utilities. I did brew upgrade gdal, path to updated bin
% is below. The gdal wiki is here https://gdal.org/programs/gdal_merge.html
% I think gdal_merge may be the right approach instead of gdal_warp. I need
% to figure out how to build the required inputs to gdal

%GDALWARP Wrapper for gdalwarp function
%   Detailed explanation goes here

% % add the path to gdal
% homepath=pwd;
% if strcmp(homepath(2:6),'Users')
%     delim='/';
%     addpath('/usr/local/Cellar/gdal/');
% elseif strcmp(homepath(10:16),'mcooper')
%     delim='\';
% end

%%

% gdalwarp [--help-general] [--formats]
%     [-s_srs srs_def] [-t_srs srs_def] [-ct string] [-to "NAME=VALUE"]* [-novshiftgrid]
%     [-order n | -tps | -rpc | -geoloc] [-et err_threshold]
%     [-refine_gcps tolerance [minimum_gcps]]
%     [-te xmin ymin xmax ymax] [-te_srs srs_def]
%     [-tr xres yres] [-tap] [-ts width height]
%     [-ovr level|AUTO|AUTO-n|NONE] [-wo "NAME=VALUE"] [-ot Byte/Int16/...] [-wt Byte/Int16]
%     [-srcnodata "value [value...]"] [-dstnodata "value [value...]"]
%     [-srcalpha|-nosrcalpha] [-dstalpha]
%     [-r resampling_method] [-wm memory_in_mb] [-multi] [-q]
%     [-cutline datasource] [-cl layer] [-cwhere expression]
%     [-csql statement] [-cblend dist_in_pixels] [-crop_to_cutline]
%     [-of format] [-co "NAME=VALUE"]* [-overwrite]
%     [-nomd] [-cvmd meta_conflict_value] [-setci] [-oo NAME=VALUE]*
%     [-doo NAME=VALUE]*
%     srcfile* dstfile

% % this is my text
% cmd     =   sprintf(['gdalwarp -srcnodata -99 -dstnodata 157 ' ...
%                         '-tr 3.6 3.6 -multi -te %f %f %f %f'],...
%                         path_data, path_extent, gt.BoundingBox(1),...
%                         gt.BoundingBox(3), gt.BoundingBox(2), ...
%                         gt.BoundingBox(4));
%
% % this is ethan's text
% cmd     =   sprintf(['gdalwarp "%s" "%s" -srcnodata -99 -dstnodata 157 ' ...
%                         '-tr 3.6 3.6 -multi -te %f %f %f %f'],...
%                         path_data, path_extent, gt.BoundingBox(1),...
%                         gt.BoundingBox(3), gt.BoundingBox(2), ...
%                         gt.BoundingBox(4));
% system(cmd) % note this produces an uncompressed tif
%
%     % gdal translate
% cmd=sprintf('gdal_translate "%s" "%s" -a_nodata 157 -co COMPRESS=LZW',...
%     tmp_path, rs_path);
% system(cmd)
%
%  % build the gdalwarp command
%     txt             =   [   '"' path.exif '"' ...
%                             ' -GPSLatitude=' num2str(lat) ...
%                             ' -GPSLongitude=' num2str(lon) ...
%                             ' -GPSLatitudeRef=N -GPSLongitudeRef=W' ...
%                             ' -GPSAltitude=' num2str(elev) ...
%                             ' -GPSDateStamp=' datestamp ...
%                             ' -GPSTimeStamp=' timestamp ...
%                             ' "' fread '"'];
%
% [stat(n),msg{n}]    =   system(txt);
%
% outputArg1 = inputArg1;
% outputArg2 = inputArg2;
% end

