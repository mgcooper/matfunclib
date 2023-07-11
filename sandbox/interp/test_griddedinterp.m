clean

% Not sure where to put this but one of the most critical lessons from this was
% the latlims/lonlims property of map/georefcells, which is the map edges, see
% R2Grid, and how to get a correct rasterref. The mapinterp comparison in this
% test script shows how I can interpolate a grid correctly. I think i could just
% use the method from mapinterp which just creates intrinsic coordinates from
% the R object to adapt it to a non-mapping toolbox function. But, I need to
% check the coordinates and make sure matlab is interpreting the cell boundaries
% correctly. IMPORTANT DETAIL - since mapinterp does not support extrapolation,
% the test confirms that creating the R object by extedning outward 1/2 cell
% size from the min/max x/y pixel centers is the key.

%%
% % here i was trying to see if griddedInterpolant does in fact accept incomplete
% % grids as long as they are regular i.e. coordinate lists, but it doesn't seem
% % to ... however, I think I could modify interpolationPoints and/or gridxyz or
% % map2grid or whatever to first create a regular data grid from the found grid
% % points, set them to nan, then embed the values I captured, then use
% % griddedInterpolant, since below I show it works with nan ... the key thing is
% % that while griddedInterpolant wont gap-fill the nan's, it will still perform
% % the interpolation, so I can capture enough cells to fully bound the polygon
% % wihtout needing to get exactly the right cells to form a rgular grid, then use
% % prepareMapGrid to create a full grid, fill it in with the data for the found
% % cells, leave the rest nan, and do the griddedInterpolant which will use the
% % correct grid cells.
% 
% % UPDATE: turns out resamplingCoords (called by interpolationPoints) does create
% % a regular grid by calliing R2grid, but I reshape to column vectors coordinate
% % lists. The actual issue tho is the rcm cells captured by pointsInPoly. I could
% % create a regular grid from them, assign the data, reference the grid, then use
% % imbedm to set the empty cells NaN. Then I could use griddedInterpolant. Note
% % that gridgeodata/gridmapdata uses scatteredInterpolant.
% 
% % UPDATE UPDAT: ACTUALLY mapinterp may not be ideal b/c it uses the same method
% % for extrapolation and does not allow changing it, and 'linear' extrapolation
% % appears problematic, esp. since it is sued for the cell edges whcih aren't
% % even extrapolation, and should be 'nearest' by default
% 
% % doesnt work
% xtest = [1:4 1:4 1:3];
% ytest = [1:4 1:4 1:3];
% vtest = 1:numel(xtest);
% F = griddedInterpolant(xtest(:), ytest(:), vtest)
% 
% % doesnt work
% xtest = [1:4 1:4 1:4];
% ytest = [1:4 1:4 1:4];
% vtest = 1:numel(xtest)
% F = griddedInterpolant(xtest(:), ytest(:), vtest)
% 
% 
% % xtest = [1:4; 1:4; 1:4];
% % ytest = [1:4; 1:4; 1:4];
% 
% % works
% [xtest, ytest] = ndgrid(1:4, 1:3);
% vtest = reshape(1:numel(xtest), size(xtest, 1), []);
% F = griddedInterpolant(xtest, ytest, vtest)
% 
% % doesnt work
% F = griddedInterpolant(xtest(:), ytest(:), vtest(:))
% 
% % doesnt work
% F = griddedInterpolant(xtest(:), ytest(:)', vtest(:))
% 
% % works
% F = griddedInterpolant({sort(xgridvec(xtest)), sort(ygridvec(ytest))}, vtest)
% 
% % now try putting nan in
% % works
% vtest(2) = nan;
% F = griddedInterpolant({sort(xgridvec(xtest)), sort(ygridvec(ytest))}, vtest)
% 
% % works
% [xtest, ytest] = ndgrid(1:4, 1:3);
% vtest = reshape(1:numel(xtest), size(xtest, 1), []);
% vtest(2) = nan;
% F = griddedInterpolant(xtest, ytest, vtest)


%%
clean

% WHERE TO PICK UP : this clarifies that scatteredInterpolant doesn't really do
% what I want b/c it triangulates and doesn't include the outer pixels in the
% interpolation, what I want is griddedInterpolant, for that see the notes up
% top for how to build a regular grid with nan's and interpolate as needed ...
% it might all be moot anyway given exactremap, but for cases where I don't want
% exactremap, e.g. maybe I want to use linear for tair, I could use
% griddedInterp, and maybe adapt the conservative regrid method with the nan
% pixels. COULD ALSO USE GRIDFIT

% Interpolation
% -------------

% TLDR: all support linear, nearest. gridded ones support cubic, but ONLY FOR
% UNIFORMLY SPACED DATA

% next, previous, and pchip are for 1D only, so I removed them from
% griddedInterpolant.

% main methods: linear, nearest, cubic, spline, makima, natural, v4
% grid methods: linear, nearest, cubic, spline
% scat methods: linear, nearest, natural
% unique methods: v4 for griddata, makima for interp2 and griddedInterpolant,
% pchip for griddedInterpolant

% 5 support linear, nearest
% 4 support cubic (all but scatteredInterpolant)
% 3 support spline (all but griddata and scatteredInterpolant)
% 2 support natural (griddata and scatteredInterpolant)
% 2 support makima (interp2 and griddedInterpolant)

% For linear and natural, griddata calls scatteredInterpolant with extrap off,
% so I can just use scatteredInterpolant in that case
% scatteredInterpolant doesn't support cubic, so I can just use griddata

InterpolationMethods.interp2 = ["linear", "nearest", "cubic", "spline", "makima"];
InterpolationMethods.griddata = ["linear", "nearest", "cubic", "natural", "v4"];
InterpolationMethods.scatteredInterpolant = ["linear", "nearest", "natural"];
InterpolationMethods.griddedInterpolant = ["linear", "nearest", "cubic", "spline", "makima"];
InterpolationMethods.mapinterp = ["linear", "nearest", "cubic", "spline"];

% Extrapolation
% -------------

% TLDR: not as consistent as interpolation, but scattered and griddedInterpolant
% support linear, and griddata calls scatteredInterpolant with extrap off so I
% can just use scatteredInterpolant, and mapinterp calls griddedInterpolant in
% all cases so I can use griddedInterpolant

ExtrapolationMethods.interp2 = ["makima", "spline"];
ExtrapolationMethods.griddata = "v4";
ExtrapolationMethods.scatteredInterpolant = ["linear", "nearest", "none"];
ExtrapolationMethods.griddedInterpolant = ["linear", "nearest", "cubic", "spline", "makima", "none"];
ExtrapolationMethods.mapinterp = [];

%% main test

% Define parameters and constants
funclist = ["interp2"; "griddata"; "griddedInterpolant"; ...
   "scatteredInterpolant"; "mapinterp"; "gridfit"];
method = 'spline';  % Interpolation method. linear, nearest, cubic work for all.
% extrap = method;
extrap = 'nearest'; % for griddedInterpolant and scatteredInterpolant
flipy = true;
flipV = true;
warpxy = false;
test_gridvecs = true;
x = 4:6;
y = 2:4;
V = magic(numel(x));

% assuming uniform spacing
dx = x(2) - x(1);
dy = y(2) - y(1);

% Define scattered and gridded x,y separately to test "warping" x,y
sx = x;
sy = y;

if warpxy == true
   gx = [x-dx/2 x(end)+dx/2];  % expanded by half a cell size on either end
   gy = [y-dy/2 y(end)+dy/2];  % expanded by half a cell size on either end
   % gx = [x(1)-1 x]; % like
   % gy = [y(1)-1 y];
else
   gx = x;
   gy = y;
end

% Flip Y so it is in descending order, to account for a V grid oriented North
% up, East right, which is how most geographic data grids are provided, or if
% not, how I prefer to orient them for intuitive analysis.
if flipy == true
   y = flip(y);
   gy = flip(gy);
   sy = flip(sy);
end

% By flipping V we are pretending V starts out oriented North down i.e. V(1, 1)
% is the SE corner. If V(1, 1) is the NE corner meaning the grid is oriented
% North up, then flipping is not necessary, even though flipping Y might be
% necessary if the provided y- coordinates are in ascending order.
if flipV == true
   V = flipud(V);
end

% Define the data
[X, Y] = meshgrid(x, y);
[GX, GY] = meshgrid(gx, gy);
[SX, SY] = meshgrid(sx, sy);

% Compute interpolation points
% [Xq, Yq] = test_interppoints(x, y, 'insideedge');
[Xq, Yq] = test_interppoints(x, y);

% Compute interpolation points
if warpxy == true
   GXq = Xq + dx/2;  % Adjust the query points as well
   GYq = Yq + dy/2;  % Adjust the query points as well
end

% % % % % % % % % % %
% Compute R
% R1 = georefcells([min(y)-dy/2, max(y)+dy/2], [min(x)-dx/2, max(x)+dx/2], ...
%    size(V), 'ColumnsStartFrom','north');
R1 = maprefcells([min(x)-dx/2, max(x)+dx/2], [min(y)-dy/2, max(y)+dy/2], ...
   size(V), 'ColumnsStartFrom','north');
R2 = rasterref(x, y, 'UseGeoCoords', false);
isequal(R1, R2)
R = R1;
[xtest, ytest] = R.worldGrid;
isequal(xtest, X)
isequal(ytest, Y)
% % % % % % % % % % %

% ---------------------
% ScatteredInterpolant
% ---------------------
if ismember(method, {'cubic', 'v4'})
   % use griddata
   Vq.scatteredInterpolant = griddata(SX(:), SY(:), V(:), Xq, Yq, method);
elseif ismember(method, {'spline', 'makima'})
   % use griddedInterpolant - works for this gridded example, will fail later
   % F = griddedInterpolant(SX(:), SY(:), V(:), method, extrap);
   % Vq.scatteredInterpolant = F(Xq, Yq);
   
   % use interp2 instead, it does not require the special ndgrid adjustments
   Vq.scatteredInterpolant = interp2(X, Y, V, Xq, Yq, method);
else
   F = scatteredInterpolant(SX(:), SY(:), V(:), method, extrap);
   Vq.scatteredInterpolant = F(Xq, Yq);
end

% ---------------------
% Griddata
% ---------------------
if ismember(method, {'spline', 'makima'})
   % use interp2
   Vq.griddata = interp2(X, Y, V, Xq, Yq, method);
else
   Vq.griddata = griddata(SX(:), SY(:), V(:), Xq, Yq, method);
end

% ---------------------
% Interp2
% ---------------------
if ismember(method, {'natural', 'v4'})
   % use griddata
   % Vq.interp2 = griddata(SX(:), SY(:), V(:), Xq, Yq, method);
   
   tmpmethod = 'linear';
else
   tmpmethod = method;
end

if test_gridvecs == true
   Vq.interp2 = interp2(x, y, V, Xq, Yq, tmpmethod);
else
   Vq.interp2 = interp2(X, Y, V, Xq, Yq, tmpmethod);
end

% ---------------------
% GriddedInterpolant
% ---------------------
% NOTE: Override the GX/GY stuff, it doesn't work
GX = X; GY = Y; gx = x; gy = y; GYq = Yq; GXq = Xq;

if ismember(method, {'natural', 'v4'})
   % use griddata
%    Vq.griddedInterpolant = griddata(SX(:), SY(:), V(:), Xq, Yq, method);
% else

   tmpmethod = 'linear';
else
   tmpmethod = method;
end

   if flipy == true && flipV == false
      % The transpose puts them in ndgrid format. The fliplr puts the Y values in
      % ascending order as required by griddedInterpolant (which might also be
      % implied by ndgrid format), and accounts for my desire to orient the Y grid
      % N-S i.e. in descending order downward (or rightward in ndgrid format)
      if test_gridvecs == true
         % This shows how grid vectors can be used to simplify things:
         F = griddedInterpolant({gx, sort(gy)}, fliplr(V'), tmpmethod, extrap);
      else
         F = griddedInterpolant(GX', fliplr(GY'), fliplr(V'), tmpmethod, extrap);
      end
   elseif flipy == true && flipV == true
      % This is the case where the x data comes in oriented W-E, y oriented S-N,
      % and V oriented S-N. We flip y and V to get them oriented N-S, then put them
      % back in ndgrid format for interpolation. Vq is oriented like Xq,Yq, so it
      % DOES NOT NEED TO BE flipped unless Xq, Yq are oriented wrong.
      if test_gridvecs == true
         % This shows how grid vectors can be used to simplify things.
         % F = griddedInterpolant({gx, sort(gy)}, flipud(fliplr(V')), method, extrap);
         F = griddedInterpolant({gx, sort(gy)}, fliplr(V'), tmpmethod, extrap);
      else
         % F = griddedInterpolant(GX', fliplr(GY'), flipud(fliplr(V')), method, extrap);
         F = griddedInterpolant(GX', fliplr(GY'), fliplr(V'), tmpmethod, extrap);
      end
   else
      % If nothing is flipped (Y is ascending), transpose is sufficient to put
      % them in ndgrid format.
      F = griddedInterpolant(GX', GY', V', tmpmethod, extrap);
   end

   if warpxy == true
      Vq.griddedInterpolant = F([GXq GYq]);
   else
      Vq.griddedInterpolant = F([Xq Yq]);
   end
% end

% ---------------------
% mapinterp / geointerp
% ---------------------

if ismember(method, {'natural', 'v4'})
   % % use griddata
   % Vq.mapinterp = griddata(SX(:), SY(:), V(:), Xq, Yq, method);
   
   tmpmethod = 'linear';
else
   tmpmethod = method;
end

Vq.mapinterp = mapinterp(V, R, Xq, Yq, tmpmethod);

% % % % % % % % % % % % % % % % % % %
% % This is what mapinterp is doing:
% [cq, rq] = worldToIntrinsic(R, Xq, Yq);
% 
% % Use same method for extrapolation to account for data points within
% % x and y limits, but beyond 'cells' data points
% F = griddedInterpolant(V, method, method);
% Vq.mapcheck = F(rq, cq);
% 
% isequal(Vq.mapinterp, Vq.griddedInterpolant)
% isequal(Vq.mapcheck, Vq.griddedInterpolant)
% 
% % RELATE THIS TO MY TEST DATA - in my test, I consider x,y the cell centers, and
% % the itnerpolation points Xq Yq
% 
% % The X data extends from 4-6. To test interpolation on cell edges, the Xq
% % interpolation points extend from 3.5 to 6.5. The comparison shows that all
% % functions consider those points "extrapolation". Technically mapinterp does
% % too, but the note above "Use same method for extrapolation to account for data
% % points within x and y limits, but beyond 'cells' data points" shows that the
% % mathworks engineers interpret it the same way as me, and allow for
% % extrapolation within the outer 1/2 cells, but not beyond.
% [min(X(:)), max(X(:))]
% [min(Xq(:)), max(Xq(:))]
% 
% % If R was constructed using the cell centers, mapinterp returns NaN at the cell
% % edges and different values elsewhere:
% Rtest = maprefcells([min(X(:)), max(X(:))], [min(Y(:)), max(Y(:))], size(V));
% [Vq.mapinterp mapinterp(V, Rtest, Xq, Yq, method)]

% % % % % % % % % % % % % % % % % % %

% gridfit
% NOTE: with gridfit, X, Y, V are scattered coordinates/data, whereas
% xnodes/ynodes are the regular grids onto which the scattered data is
% interpolated, so it is not immediately adaptable to this situation
% XYq = sortrows([Xq, Yq]);
% [zgrid,xgrid,ygrid] = gridfit(X,Y,V,XYq(:,1), XYq(:,2));

% Plot the result
% H = test_interpplot(X, Y, V, Xq, Yq, Vq, funclist);
H = test_interpplot(X, Y, V, Xq, Yq, Vq, funclist([5, 3, 2, 4]));

copygraphics(gcf)

%% test rasterinterp

% These should be equal
Zq = rasterinterp(V, R, Xq, Yq, method, method);
isequal(Zq, Vq.mapinterp)

% But these should only be equal if method = extrap
Zq = rasterinterp(V, R, Xq, Yq, method, extrap);
isequal(Zq, Vq.mapinterp)

% Use the cell edges to create an interpolation grid
Rq = maprefcells([min(x)-dx, max(x)+dx], [min(y)-dy, max(y)+dy], ...
   size(V)+1, 'ColumnsStartFrom','north');

[Zq, Rq] = rasterinterp(V,R,Rq,method,extrap);


% R = georefcells([min(y)-dy/2, max(y)+dy/2], [min(x)-dx/2, max(x)+dx/2], ...
%    size(V), 'ColumnsStartFrom','north');
% Rq = georefcells([min(y)-dy, max(y)+dy], [min(x)-dx, max(x)+dx], ...
%    size(V)+1, 'ColumnsStartFrom','north');
% 
% [Zq, Rq] = rasterinterp(V,R,Rq,'linear',extrap);

%% test plotting functions

R = rasterref(x, y);

figure
geomap(gy, gx)
pcolorm(gy, gx, V); colorbar

figure
geomap(y, x)
meshm(V, R);

figure
grid2image(V, R)

figure
geoshow(V, R, 'DisplayType','texturemap'); colorbar

figure
geoshow(V, R, 'DisplayType','surface'); colorbar

figure
geoshow(V, R, 'DisplayType','mesh'); colorbar

% test meshm
figure
geomap(gy, gx)
meshm(V, R);

figure
geomap([gy gy(end)+1], [gx gx(end)+1])
meshm(V, R);

% This actually works ... but i wonder if its only b/c of the custom adjustment
% i do in rasterref, and whether geointerp would be correct?
figure
geomap(R.LatitudeLimits, R.LongitudeLimits)
meshm(V, R);


figure
plotraster(V, x, y)
plotraster(V, R)

%% Notes

% TLDR: this clarifies how to use the different interp functions and recover the
% "same" or "correct" results - but the important thing it shows is how
% scatteredInterpolant DOES NOT USE ALL OF THE GRID POINTS in particular near
% the edges, it uses a triangulation, and the differences are especially
% pronounced w/ extrapolation, so this very well could be a big problem with the
% interpolated/extrapolated met forcing for ak4.

% NOte: I need to test the effect of including an extra row/column esp w/
% gridded/scatteredInterpolant like conservative_regrid

% I only test linear here. Need to try others.

% Remember, interp2 and griddedInterpolant should produce same values, but
% interp2 expects meshgrid format, griddedInterpolant ndgrid

% More detailed notes:

% Note: no adjustment is required w/ interp2 for flipy or flipV. The reason is
% because interp2 assumes meshgrid, so flipping the y coordinate just means we
% know that the data in V is referenced to y flipped (descending order), not
% standard y which is in ascending order. Similarly, when we flip V, we are
% assuming that V needs to be flipped to be correctly referenced to flipped y.
% The interpolation points Xq, Yq should not require any adjustment, since they
% should still fall around the center pixel. But if the interpolated values are
% flipped, then Xq, Yq need to flipped too in order to plot them correctly.

% Similarly, no adjustment is needed with griddata or scatteredInterpolant
% because they just expect a list of coordinates. The orientation then only
% matters for how the data is displayed.

% Only griddedInterpolant requires special adjustment, because (1) it assumes
% ndgrid format, and (2), it requires the sample points are ordered in
% descending order.

%%
% Interp2 and griddedInterpolant return the average of the four adjacent
% corners, which is the expected result for linear.
% griddata and scatteredInterpolant seem to return the average of the
% diagonal-adjacent corners, likely because they are based on a delauny
% triangulation.

% These indices define the quadrants of the array whether it is flipped or not,
% but how they are displayed when Y is flipped to be descending order changes.


%% no flip:
V([1 2 4 5]) % bottom left displayed (top left of V)
V([3 2 5 6]) % top left displayed (bottom left of V)
V([4 5 7 8]) % bottom right displayed (top right of V)
V([5 6 8 9]) % top right displayed (bottom right of V)

mean(V([1 2 4 5])) % bottom left displayed (top left of V)
mean(V([3 2 5 6])) % top left displayed (bottom left of V)
mean(V([4 5 7 8])) % bottom right displayed (top right of V)
mean(V([5 6 8 9])) % top right displayed (bottom right of V)

%% y flipped, V is not

V([1 2 4 5]) % top left displayed (top left of V)
V([3 2 5 6]) % bottom left displayed (bottom left of V)
V([4 5 7 8]) % top right displayed (top right of V)
V([5 6 8 9]) % bottom right displayed (bottom right of V)

% if y is flipped, but V is not
mean(V([1 2 4 5])) % top left displayed (top left of V)
mean(V([3 2 5 6])) % bottom left displayed (bottom left of V)
mean(V([4 5 7 8])) % top right displayed (top right of V)
mean(V([5 6 8 9])) % bottom right displayed (bottom right of V)

%% y and V are flipped

% This is identical to y flipped in terms of the descriptions below, but the
% values are flipped i.e. the actual V array is flipped so the numbers displayed
% are upside down

V([1 2 4 5]) % top left displayed (top left of V)
V([3 2 5 6]) % bottom left displayed (bottom left of V)
V([4 5 7 8]) % top right displayed (top right of V)
V([5 6 8 9]) % bottom right displayed (bottom right of V)

% if y is flipped, but V is not
mean(V([1 2 4 5])) % top left displayed (top left of V)
mean(V([3 2 5 6])) % bottom left displayed (bottom left of V)
mean(V([4 5 7 8])) % top right displayed (top right of V)
mean(V([5 6 8 9])) % bottom right displayed (bottom right of V)

%% test the reorientation of griddedInterpolant data

% % to test the reorientation, the indexing should produce the same data
% X2 = X';
% Y2 = fliplr(Y');
% V2 = fliplr(V');
%
% [X X2]
% [Y Y2]
% [V V2]
%
% [V(1, 1), V2(X2==X(1,1) & Y2==Y(1,1))]
% [V(1, 2), V2(X2==X(1,2) & Y2==Y(1,2))]
% [V(1, 3), V2(X2==X(1,3) & Y2==Y(1,3))]
% [V(2, 1), V2(X2==X(2,1) & Y2==Y(2,1))]
% [V(2, 2), V2(X2==X(2,2) & Y2==Y(2,2))]
% [V(2, 3), V2(X2==X(2,3) & Y2==Y(2,3))]


%%

% arrayfun(@(f) scatter(Xq, Yq, 500, Vq.(f), 'o'), funclist)



% The expected values for linear by averaging the four corners:
mean(V([1 2 4 5]))
mean(V([1 2 4 5]))

% Plot profile data
figure
subplot(2, 1, 1)
plot(X(1,:), V(1,:), 'ko-', Xq, Vq.interp2, 'r*', Xq, Vq.scatteredInterpolant, 'g*', Xq, Vq.griddedInterpolant, 'b*', Xq, Vq.griddata, 'c*')
title('X Profiles')
xlabel('X')
ylabel('V')
legend('Original', 'interp2', 'scatteredInterpolant', 'griddedInterpolant', 'griddata')

subplot(2, 1, 2)
plot(Y(:,1), V(:,1), 'ko-', Yq, Vq.interp2, 'r*', Yq, Vq.scatteredInterpolant, 'g*', Yq, Vq.griddedInterpolant, 'b*', Yq, Vq.griddata, 'c*')
title('Y Profiles')
xlabel('Y')
ylabel('V')
legend('Original', 'interp2', 'scatteredInterpolant', 'griddedInterpolant', 'griddata')


%% Create figure

maxfig

% Plot original data
subplot(1, 2, 1)
scatter(X(:), Y(:), 100, V(:), 'filled')
title('Original Data')
xlabel('X')
ylabel('Y')
axis square

% Plot interpolated data
subplot(1, 2, 2)
scatter(Xq, Yq, 100, Vq.interp2, 'filled')
title('Interpolated Data')
xlabel('X')
ylabel('Y')
axis square
axis([1 3 1 4])
colorbar
