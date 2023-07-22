% test_ingeobox

% note; this doesn't test ingeobox, it might be a good start for testing
% enclosedGridCells 

%%
function [IB,IX,IY] = ingeobox(X,Y,PX,PY)
%INGEOBOX 
% Reduce the cell-search space by finding cells inside a minimum bounding box.
% This assumes the data referenced by X,Y is oriented N-S, E-W.

% this is experimental, it needs to check date line crossing and maybe pole
% crossing, goal is fast in box method, see convhull stuff below

% this is only here for testing with X,Y grid vectors, the point of this
% function is to avoid generating the full grids 
% if isvector(X) && isvector(Y) 
%    [X,Y] = fastgrid(X,Y);
% end

IX = ...
   ( xgridvec(X) >= min(PX)-median(abs(CellSizeX))/2 ) & ...
   ( xgridvec(X) <= max(PX)+median(abs(CellSizeX))/2 ) ;

IY = ...
   ( ygridvec(Y) >= min(PY)-median(abs(CellSizeY))/2 ) & ...
   ( ygridvec(Y) <= max(PY)+median(abs(CellSizeY))/2 ) ;

IB = IY' & IX;


% this works with full grids or grid vectors, but only produces full-grid IB:
% IB = ...
%    ygridvec(Y) >= min(PY) - median(abs(CellSizeY))/2 & ...
%    ygridvec(Y) <= max(PY) + median(abs(CellSizeY))/2 ...
%    & ...
%    xgridvec(X) >= min(PX) - median(abs(CellSizeX))/2 & ...
%    xgridvec(X) <= max(PX) + median(abs(CellSizeX))/2 ;

% Note: see enclosedGridCells for how this is somewhat limiting ... if X and Y
% are grid vectors, then we need full grids to use IB, so I might want the
% explicit version:

% % this only works with grid vectors
% IB = ...
%    transpose( ...
%    Y >= min(PY)-median(abs(CellSizeY))/2 & ...
%    Y <= max(PY)+median(abs(CellSizeY))/2 ...
%    ) & ...
%    X >= min(PX)-median(abs(CellSizeX))/2 & ...
%    X <= max(PX)+median(abs(CellSizeX))/2 ;



% kp = convhull([PX,PY]); % convhull([PX,PY],'Simplify',true);
% kg = convhull(x,y);
% 
% figure; plot(PX,PY); hold on; plot(PX(kp),PY(kp));
% figure; plot(x(kg),y(kg),'s');
% 
% kg = convhull(xtest,ytest);
% tg = delaunay(xtest,ytest);
% figure; trimesh(tg,xtest,ytest);
% 
% 
% Xlim = [min(PX) max(PX)] + [-median(abs(CellSizeX))/2 +median(abs(CellSizeX))/2];
% Ylim = [min(PY) max(PY)] + [-median(abs(CellSizeY))/2 +median(abs(CellSizeY))/2];
% 
% IB = ...
%    ( x(:) >= Xlim(1) ) & ...
%    ( x(:) <= Xlim(2) ) & ...
%    ( y(:) >= Ylim(1) ) & ...
%    ( y(:) <= Ylim(2) ) ;
% 
% IX = ...
%    ( X >= Xlim(1) ) & ...
%    ( X <= Xlim(2) ) ;
% 
% IY = ...
%    ( Y >= Ylim(1) ) & ...
%    ( Y <= Ylim(2) ) ;
% 
% 
% % below ere was me figrueing out how to create a logical matrix from grid
% % vectors expanded to full grid without actually creating full grids
% 
% numel(X(IX)'*Y(IY)');
% 
% [xtest,ytest] = meshgrid(X(IX),Y(IY));
% 
% x = unique(x(IB));
% y = unique(y(IB));
% [xtest2,ytest2] = meshgrid(x,y);
% 
% isequal(xtest,xtest2)
% isequal(ytest,ytest2)
% 
% 
% 
% % Initialize to include all points.
% tf = true(size(lat));
% 
% % Eliminate points that fall outside the latitude limits.
% inlatzone = (Ylim(1) <= lat) & (lat <= Ylim(2));
% tf(~inlatzone) = false;
% 
% % Eliminate points that fall outside the longitude limits.
% londiff = Xlim(2) - Xlim(1);  % No need to wrap here
% inlonzone = (R.WrapToCycleFcn(lon - Xlim(1)) <= londiff);
% tf(~inlonzone) = false;
% 
% 
