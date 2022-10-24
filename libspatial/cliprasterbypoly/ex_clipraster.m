
% this came from an answer:
% https://www.mathworks.com/matlabcentral/answers/355126-determine-area-inside-a-polygon-on-a-map
% 

loaded = load( 'regrid.mat' ) ;
regrid = loaded.regrid ;

% note if i have a grid and find the cells inside a polygon and then make a
% mask with true for cells inside a polygon i can use areamat to find the area
% of all the cells

% check kearney's mask2poly, and topotoolbox GRIDobj2polygon