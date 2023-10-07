
clean
[X, Y, Z, R] = defaultGridData();
[x, y] = gridvec(X, Y);

% compute the contours
cm = contourc(x, y, Z, 10);

% fig = imagesc(x, y, Z); % or any other command that generates an image
fig = plotraster(Z, x, y); % or any other command that generates an image

% overlay the figure with contours.
coverlay(cm, fig, 'LineWidth', 5, 'Color', 'r') 

% This fails
% clabel(cm, fig) % label the contours

figure
rastercontour(Z, R)

%%

% This doesn't work b/c mapmtx does not return a proper full grid or grid vec
% i.e. the number of unique x,y equals the number of z, which is good for other
% examples but not contour

% load mapmtx.mat
% 
% x = lg1;
% y = lt1;
% z = map1;
% n = 10;
% [xvec, yvec] = gridvec(x, y);
% cm = contourc(xvec,yvec,z,n);
% 
% [X, Y] = meshgrid(1:100, 1:100);
% 
% % R = rasterref(x, y);
% % [X, Y] = prepareMapGrid(x, y);
% 
% [X, Y] = fullgrid(x, y);
% rastersurf(x, y, z)
