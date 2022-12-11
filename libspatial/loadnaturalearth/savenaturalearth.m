
% this would have been alot easier than what I did for loadstateshapefile! (I
% found a list of states and had to copy and then convert to cell by hand)

pathdata = '/Users/coop558/work/data/naturalearth/';

% S = shaperead(fullfile(pathdata,'ne_50m_rivers_lake_centerlines.shp'), 'UseGeoCoords', true);
S = shaperead(fullfile(pathdata,'ne_110m_rivers_lake_centerlines.shp'), 'UseGeoCoords', true);

naturalearthrivers = {S.name};

save('naturalearthrivers.mat','naturalearthrivers');