function varargout = raster_tricks(varargin)
%RASTER_TRICKS raster tips and tricks

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

% just in case this is called by accident
narginchk(0,0)

%% From R2Grid

% Regarding the construction of the grid from the R object. From the
% documentation for MapCellsReference: "The Mapping Toolbox™ and Image
% Processing Toolbox™ use the convention for the location of the origin
% relative to the raster cells or sampling points such that, at a sample
% location or at the center of a cell, x has an integer value equal to the
% column index. Likewise, at a sample location or at the center of a cell,
% y has an integer value equal to the row index.". This is why we construct
% the grid by adding the cell size /2 to the first X world coordinate, and
% subtracting the cells size/2 from the last X world coordinate (m+0.5)
% ____________________
% HORIZONTAL DIMENSION
% 
% center of first cell                 center of last cell
%           |                                   |
%           v                                   v
% 0   0.5   1   1.5   2   2.5  m-1.5 m-1 m-0.5  m  m+0.5
%       ___________________       ___________________
%      |         |         |     |         |         |
% o    |    o    |    o    | ... |    o    |    o    |    o
%      |         |         |     |         |         | 
%       -------------------       -------------------
% ^    ^                                             ^
% |    |                                             |
% |     \                                             \
%  \    raster left edge = R.XWorldLimits(1)           raster right edge = R.XWorldLimits(2)
%   \
%    origin
% __________________
% VERTICAL DIMENSION
% 
%     o <- origin
%
%  -------  <- raster top edge ( R.YWorldLimits(1) )
% |       |
% |   o   | <- center of first cell
% |       |
%  -------
%     .
%     .
%     .
%  -------  <- raster top edge ( R.YWorldLimits(1) )
% |       |
% |   o   | <- center of last cell
% |       |
%  -------  <- raster bottom edge ( R.YWorldLimits(2) )
%
%     o <- phantom point mirroring origin on other end
% 
% 
% The default R = maprefcells() is equivalent to:
% xlimits = [0.5 2.5];
% ylimits = [0.5 2.5];
% rasterSize = [2 2];
% R = maprefcells(xlimits, ylimits, rasterSize)
% 
% This defines a 2x2 raster with four grid cells.
% 
% This is why when starting with an R object, creating a grid involves adjusting
% the X/YWorldLimits (or Latitude/LongitudeLimits) INWARD by 1/2 cell size.
% 
% If instead, the raster cell centers are used to construct an R object, the
% opposite is true - the min/max cell centers are adjusted OUTWARD by 1/2 cell
% size to create the xlimits/ylimits inputs to MAPREFCELLS or GEOREFCELLS

%%

% % % % % % % % % % % % % % % % % % 
% % below was in the README in runoff project 

%  also an opportunity to keep track of the simplest and best raster shows

% this one shows up a lot
figure; geoshow(lat,lon,swsd,'DisplayType','texturemap');
figure; worldmap('Greenland'); scatterm(latrs,lonrs,60,swsdrs,'filled');

% this was probably to get vector on top:
figure;
rastersurf(Zq,Rq,'ZData',zeros(size(Zq))); hold on;
mapshow(xin,yin,'Marker','o','MarkerFaceColor','k','MarkerSize',10,'LineStyle','none');
mapshow(x14,y14,'Marker','x','MarkerFaceColor','k','MarkerSize',20);
% came from get_merra_bb, x/yin is the coordinates in teh poly, x/y14 the
% coordinates of ben hills site in 2014

% with textm:
% figure;
% worldmap(latlims,lonlims); hold on;
% geoshow(latrb,lonrb);
% scatterm(latin,lonin,250,swsdin,'filled');
% textm(latin-0.02,lonin+0.06,labels);

% say we make a subplot on a worldmap axis, get the clims:
% clims =   caxis;
% setm(m1,'MLabelLocation',0.3)
% setm(m1,'FontSize',16)
% 
% % then make the next subplot, use clims:
% caxis(clims);


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% nco suggestions:
% https://nicojourdain.github.io/students_dir/students_netcdf_nco/

% this was 'RASTER_MASTER' but i moved it here

% at some point, probably need to just use this:
% https://github.com/GenericMappingTools/gmtmex
% https://agupubs.onlinelibrary.wiley.com/doi/pdf/10.1002/2016GC006723

% but at their github they say osx install is complicated so i dferred

% list all the built-in map data
ls(fullfile(matlabroot, 'toolbox', 'map', 'mapdata'))

cd('/Applications/MATLAB_R2020a.app/toolbox/map/mapdata/')



% this confirms the order in which I flipud/permute/average is identical
% flip/rot first, then average
V = ncread(fname,varname);
V = squeeze(V);
V = flipud(permute(V,[2 1 3]));
V1 = nanmean(V,3);

% average first, then flip/rot 
V = ncread(fname,varname);
V = squeeze(V);
V2 = squeeze(nanmean(V,3));
V2 = flipud(permute(V2,[2 1]));
Vtest = V2-V1;

max(Vtest(:))
min(Vtest(:))

