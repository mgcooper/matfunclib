% Define the three locations:
midl_lat = 32;   midl_lon = -102;
tuls_lat = 36.2; tuls_lon = -96;
newo_lat = 30;   newo_lon = -90;

% Use the distance function to determine great circle distances and
% azimuths of Tulsa and New Orleans from Midland: 
[dist2tuls az2tuls] = distance(midl_lat,midl_lon,...
                               tuls_lat,tuls_lon);

[dist2neworl az2neworl] = distance(midl_lat,midl_lon,...
                                   newo_lat,newo_lon);

% Compute the absolute difference in azimuth, a fact you will use later.
azdif = abs(az2tuls-az2neworl);

% Today, you feel on top of the world, so make Midland, Texas, the north
% pole of a transformed coordinate system. To do this, first determine the
% origin required to put Midland at the pole using newpole:   
origin = newpole(midl_lat,midl_lon);
% The origin of the new coordinate system is (58°N, 78°E). Midland is now
% at a new latitude of 90°. 

% Determine the transformed coordinates of Tulsa and New Orleans using the
% rotatem command. Because its units default to radians, be sure to include
% the degrees keyword:  
[tuls_lat1,tuls_lon1] = rotatem(tuls_lat,tuls_lon,...
                                origin,'forward','degrees');
[newo_lat1,newo_lon1] = rotatem(newo_lat,newo_lon,...
                                origin,'forward','degrees');

% Show that the new colatitudes of Tulsa and New Orleans equal their
% distances from Midland computed in step 2 above: 
tuls_colat1 = 90-tuls_lat1
newo_colat1 = 90-newo_lat1

% Recall from step 4 that the absolute difference in the azimuths of the
% two cities from Midland was 49.7258°. Verify that this equals the
% difference in their new longitudes:  
tuls_lon1-newo_lon1

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

load('projease.mat');
[lt1,ln1]   = projinv(projsipsn,coords.sfland.X,coords.sfland.Y);
[x1,y1]     = projfwd(projease,lt1,ln1);

origin      = newpole(90,nanmedian(ln1));
[lt1r,ln1r] = rotatem(lt1,ln1,origin,'forward','degrees');
[x1r,y1r]   = projfwd(projease,lt1r,ln1r);
[x1r2,y1r2] = rotatexy(x1,y1,45);

figure; mapshow(x1,y1)
figure; mapshow(x1r,y1r)
figure; mapshow(x1r2,y1r2)

% compare on one figure
figure; plot(x1r,y1r); hold on; plot(x1r2,y1r2)

% experiment with fitgeotrans
figure; mapshow(x1,y1)
tform       = fit
[x,y] = transformPointsForward(tform,u,v)




