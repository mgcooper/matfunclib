
% this would have been alot easier than what I did for loadstateshapefile! (I
% found a list of states and had to copy and then convert to cell by hand)
load world_borders.mat borders
borders = {borders.NAME};

save('borderslist.mat','borders');