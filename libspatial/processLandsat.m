function [Image, R] = processLandsat(filelist, cropimage, enhanceimage, testplot)

if nargin < 4; testplot = false; end
if nargin < 3; enhanceimage = false; end
if nargin < 2; cropimage = false; end

filenames = {filelist.name}';
idx = contains(filenames,"B1.TIF");
testfile = fullfile(filelist(1).folder, filelist(idx).name);
[filepath,~,fileext] = fileparts(testfile);
[~,R1] = readgeoraster(testfile); % set to 'postings'

xlimits = R1.XWorldLimits + [-1 +1].*R1.SampleSpacingInWorldX/2;
ylimits = R1.YWorldLimits + [-1 +1].*R1.SampleSpacingInWorldX/2;
R = maprefcells(xlimits,ylimits,R1.RasterSize);
R.ColumnsStartFrom = 'north';
R.ProjectedCRS = R1.ProjectedCRS;

% kang uses band 5 (NIR), 4 (Red), and 3 (Green)
fprfx = filelist(idx).name(1:end-6); % works if .TIF
bands = {'B2','B3','B4'};                                % True color RGB
Image = uint16(nan([R.RasterSize,3]));                   % preallocate
for n = 1:length(bands)                                  % read in the bands
   bandn = bands{n};
   fname = [fprfx,bandn,fileext];
   Image(:,:,n) = uint16(imread(fullfile(filepath,fname)));
end
Image = cat(3,Image(:,:,3),Image(:,:,2),Image(:,:,1));   % put in RGB order

% crop the image if requested
if cropimage == true
   [Image,rect] = imcrop(Image);
   R = refcrop(Image,R,rect);
end

% apply adaptive histogram equilization
if enhanceimage == true
   dist = 'uniform';
   climit = 0.002;  % og: 0.004,
   bright = 0.5;    % og: 0.3
   for n = 1:3
      Image(:,:,1) = adapthisteq(Image(:,:,1),'Distribution',dist,'clipLimit',climit);
      Image(:,:,2) = adapthisteq(Image(:,:,2),'Distribution',dist,'clipLimit',climit);
      Image(:,:,3) = adapthisteq(Image(:,:,3),'Distribution',dist,'clipLimit',climit);
   end
   % denoise and brighten the image
   Image = imlocalbrighten(medfilt3(Image),bright,'AlphaBlend',true);
else
   % brighten the image
   Image = imadjustn(Image);
end

% figure; imshow(Jimg); title('imadjustn'); figontop;
% figure; imshow(Jcrop); title('enhanced'); figontop;

if testplot == 1
   figure; mapshow(Image,Rimg); title('Full Image');
   figure; mapshow(Image,Rcrop); title('Cropped Image'); hold on;
end


function Rcrop = refcrop(Jimg, Rimg, rect)

% spatially reference the cropped image, rect is [xmin ymin width height]
[xmin,ymax] = intrinsicToWorld(Rimg,rect(1),rect(2));
xmax = xmin + size(Jimg,2)*30;
ymin = ymax - size(Jimg,1)*30;
xlim = [xmin xmax];
ylim = [ymin ymax];
imgSize = [size(Jimg,1) size(Jimg,2)];
Rcrop = maprefcells(xlim,ylim,imgSize);
Rcrop.ProjectedCRS = Rimg.ProjectedCRS;
Rcrop.ColumnsStartFrom = 'North';

% Rtest = imref2d(size(Jcrop),rect(1),rect(2));


%% reproject using gdal
% 
% % note, I could replace the multiple loops below with something like this
% % gdalwarp -q -t_srs EPSG:32611 -of vrt input_file.tif /vsistdout/ |
% % gdal_translate -co compress=lzw  /vsistdin/ output_file.tif
% 
% % define the gdal options to perform (-q = quiet)
% func = '/usr/local/bin/gdalwarp ';
% opts = ['-s_srs EPSG:32622 -t_srs EPSG:3413 -r near -q -overwrite -of ' ...
%    'GTiff -co "TFW=YES" '];
% 
% % NOTE: use 'tmp_' because the files need to run through gdal_translate to
% % set the cell interpretation property and there is no overwrite option
% 
% for n = 1:length(filelist)
%    fin = fullfile(pathdata,filelist(n).name);
%    fout = fullfile(pathsave,['tmp_' strrep(filelist(n).name,'.TIF','.TIFF')]);
%    command = [func opts fin ' ' fout];
%    status  = system(command);
% end
% 
% % set cell interpretation to 'AREA'. get a new file list
% filelist = getlist(pathsave,'*.TIFF');
% 
% % define the gdal options to perform
% func = '/usr/local/bin/gdal_translate ';
% opts = '-mo AREA_OR_POINT=AREA -co "TFW=YES" ';
% 
% for n = 1:length(filelist)
%    fin     = [pathsave filelist(n).name];
%    fout    = [pathsave strrep(filelist(n).name,'tmp_','')];
%    command = [func opts fin ' ' fout];
%    status  = system(command);
% end
% 
% % delete the tmp files
% filelist = getlist(pathsave,'tmp*');
% for n = 1:length(filelist)
%    f = [pathsave filelist(n).name];
%    command = ['rm ' f];
%    status  = system(command);
% end

% projlam = projcrs(9820,'Authority','EPSG')
% projlam = projcrs(102009,'Authority','ESRI')
% projpsn = projcrs(3413,'Authority','EPSG')

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

% [test1a,R1a] = readgeoraster([pathsave 'test.TIFF']);
%
% [test1a,R1a] = geotiffread([pathdata 'sipsn/test.TIFF']);
% [test1b,R1b] = readgeoraster([pathdata 'sipsn/test.TIFF']);
% [test2a,R2a] = geotiffread([pathdata 'sipsn/test2.TIFF']);
% [test2b,R2b] = readgeoraster([pathdata 'sipsn/test2.TIFF']);

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

