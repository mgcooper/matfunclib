
% this would have been alot easier than what I did for loadstateshapefile! (I
% found a list of states and had to copy and then convert to cell by hand)

S = shaperead('worldrivers.shp', 'UseGeoCoords', true);
worldrivers = {S.Name};

save('worldriverlist.mat','worldrivers');