clean

%% build an X,Y grid and fake Z data

x = 0:10:100;
y = 0:5:50;
[X,Y,CellSizeX,CellSizeY,GridType,tfGeoCoords] = prepareMapGrid(x,y);
Z = ndgrid(x,x,x);

% % compute the cell edges using gridCentroidsToEdges
% [Xedges, Yedges] = gridCentroidsToEdges(X, Y);
% 
% % compute the cell edges by hand
% xedge = [x-CellSizeX/2 x(end)+CellSizeX/2];
% yedge = [y-CellSizeY/2 y(end)+CellSizeY/2];
% 
% [Xedge,Yedge] = prepareMapGrid(xedge,yedge);

%% build a polyshape that encloses the grid points 

% build a box around the grid points
[xrect,yrect] = mapbox([min(X(:)), max(X(:))],[min(Y(:)), max(Y(:))]);

% convert to polyshape - this poly encloses the grid CENTROIDS
P = polyshape(xrect,yrect);

% buffer the poly so it encloses the grid CELLS
B = polybuffer(P,norm([CellSizeX,CellSizeY])/2);

% use P (not B) to ensure that some cells are outside for testing
PX = P.Vertices(:,1);
PY = P.Vertices(:,2);
enclosed = enclosedGridCells(X, Y, PX, PY);

%% plot it

plotMapGrid(X,Y); hold on;
plot(P)
plot(B)

% it works to plot into the ax but not the fig
% figure;
% plot(P); hold on; 
% plot(B); ax = gca;
% plotMapGrid(ax,X,Y); 

%%

[Z2,I] = clipRasterByPoly(Z,X,Y,P,'areasum','TestPlot',true);

%%

I = inpolygon(X(:),Y(:),P.Vertices(:,1),P.Vertices(:,2));
sum(I) - numel(X) % should = 0

% Check the function
[Z,I] = clipRasterByPoly(Z,X,Y,P);

% Artificially move one x,y pair outside the box boundary
X(3,2) = - 5;
I = inpolygon(X(:),Y(:),P.Vertices(:,1),P.Vertices(:,2));
sum(I) - numel(X) % should = -1
Z(~I) = NaN;
[row,col] = find(isnan(Z)) % should return 3,2

% but if Z is > 2 dimensional, only the first entry is set nan
[Irow,Icol] = ind2sub(size(Z),find(~I));
Z(Irow,Icol,:) = NaN;
% OR
I = repmat(I,size(Z,3));

% Check the function
[X, Y] = meshgrid(x, y);
X = [X(:,1)-10 X];
Y = [Y(:,1) Y];
Z = cat(2,Z(:,1,:),Z);
[Z,I] = clipRasterByPoly(Z,X,Y,P);





% % this works
% close all
% f = figure;
% H = plotMapGrid(f,X,Y);
% 
% % this works
% close all
% f = figure; ax = gca;
% H = plotMapGrid(ax,X,Y);
% 
% % this does not work
% close all
% f = figure; 
% plot(P); hold on; ax = gca;
% H = plotMapGrid4(f,X,Y);
% 
% % this does not work
% close all
% f = figure; 
% plot(P); hold on; ax = gca;
% H = plotMapGrid4(ax,X,Y); 
% 
% % thsi works
% close all
% H = plotMapGrid4(X,Y,'edges'); hold on;
% H = plotMapGrid4(X,Y,'centroids');
% 
% % thsi works
% close all
% f1 = figure;
% H1 = plotMapGrid4(f1,X,Y,'edges'); hold on;
% 
% f2 = figure;
% H2 = plotMapGrid4(f2,X,Y,'centroids');
% 
% % now update f1
% H3 = plotMapGrid4(f1,X,Y,'centroids');
% 
% % now update f2 - doesn't work
% H4 = plotMapGrid4(f2,X,Y,'edges');
% 
% % what about using H2 fig handle? no
% % H5 = plotMapGrid4(H2(1),X,Y,'edges');
% 
% % what about using H2 ax handle? no
% H5 = plotMapGrid4(H2(2),X,Y,'edges');
