% I'LL BE DAMNED. It is possible this entire time that geoloc2grid is what
% I needed, and I misinterpreted the cell size argument to mean that the
% input data had to have a regularly spaced cell size, when in fact the
% cell size sets the OUTPUT gridded cell size

% I compared geoloc2grid to rasterfromscatter. They get the same reuslt

%%
% rasterref and rasterfromscatter were designed with netcdf files from
% climate models in mind, where the x,y or lat,lon coordinates would be
% provided either as vectors of unique lat/lon values or arrays. First I
% built rasterref to deal with the arrays, then when I realized some .nc
% files have the vectors I added the meshgrid statement at the top of
% rasterref. 

% when i was extracting the lat/lon values in the bounding box around rio
% behar i came across another possibility which is the vector of lat/lon
% coordinate pairs. these are actually quite common, e.g.:

% 60 -48
% 60 -46
% 60 -44
% 55 -48
% 55 -46
% 55 -44
% 50 -48
% 50 -46
% 50 -44

% in addition to making a regular X,Y grid, there is also the issue of
% gridding the z-values

% for this case, Matlab has the following functions:
% vec2mtx (requires constant cell density - really this is designed for
% converting vector data to raster, where it doesn't matter what the cell
% size is other than for display)
% geoloc2grid (requires scalar cell size i.e. constant in x/y)
% imbedm (requires pre-existing Z,R, and fills in Z based on lat/lon/z)
% encodem (requires pre-existing Z, and fills in Z based on row/col/z)

clean

latlims         =   [66.6 67.8];
lonlims         =   [-50 -47.5];

lon             =   ([-49.375 -49.375 -48.75 -48.75 -48.125 -48.125])';
lat             =   ([67.5 67 67.5 67 67.5 67])';
z               =   ([162 176 120 141 111 121])';

% this does not give me what I want
% [LON,LAT]       =   meshgrid(lon,lat);

% this does not give me what I want
% [LON,LAT,Z]     =   meshgrid(lon,lat,z);

% this works, but how to put Z? 
[LON,LAT]       =   meshgrid(unique(lon),unique(lat)); 

% if you search for an answer you find this, but it only works if LON and
% LAT are linear indices
% Z               =   accumarray([LON(:),LAT(:)],z(:),size(LON));
% UPDATE see chad greene's approach below

% this works, but what if lat/lon are oriented incorrectly? I guess i could
% just do whatever is done to LAT LON to Z also ...
[LON,LAT]       =   meshgrid(unique(lon),unique(lat));
Z               =   reshape(z,size(LAT,1),size(LAT,2));

% Surprisingly, there does not seem to be a function for this

% I can use rasterref to get the R and imbedm to fill it
R               =   rasterref(lon,lat,'cell');
Z               =   nan(R.RasterSize);
Z               =   imbedm(lat,lon,z,Z,R);

figure;
scatter(lon,lat,200,z,'filled'); hold on;
axis image
set(gca,'XLim',lonlims,'YLim',latlims); 

figure;
geoshow(Z,R,'DisplayType','texturemap'); hold on;
geoshow(lat,lon,'Marker','o','LineStyle','none','MarkerFaceColor','k','MarkerEdgeColor','k')

% I am not showing examples for geoloc2grid since it uses
% scatteredInterpolant on a regular grid i.e. it is less useful than
% rasterfromscatter (and is why I had to build rasterfromscatter). encodem
% is basically the same as imbedm but with intrinsic coordinates. vec2mtx
% is also so far away from what is needed that i am not bothering with it

% SO - I might need to add a statement to rasterfromscatter such as:
% isregular = % check for regular lat/lon spacing
% if isregular, do the thing above
% if not, griddata

% I could also rename it 'rasterize' and explain that for regularly gridded
% data, it grids it uniformly, and for irregular data, it interpolates it
% to a regular grid. Also, if it is regularly gridded but the user requests
% a finer resolution, it uses griddedInterpolant

%% this is the original test I had in get_MERRA_bb. 

% I think I just realized that since merra is regular, i shouldn't need to
% use rasterfromscatter, so i was tring to figure out why I can't just 

% I know ... I had observed that the grid points ARE in fact regular, even
% for MAR and RACMO, but that they aren't oriented N-S, so when I do my
% test for regularity by going down the columns and across the rows and
% checking for diff, I get irregular, but in fact there is regularity. 

% The mistake I made is by testing with MERRA, since it is in fact regular

% If you use MERRA, the solution above, where I take unique(lat) and lon I
% get the lat/lon basis, but 

% [lontest,lattest,ztest] =   meshgrid(unique(lonin),unique(latin),swsdin);
% lontest                 =   lontest(:,:,1);
% lattest                 =   lattest(:,:,1);
% ztest                   =   squeeze(ztest(1,:,:));
% 
% Rtest                   =   rasterref(lonin,latin,'cell');
% Ztest                   =   nan(Rtest.RasterSize);
% Ztest                   =   imbedm(latin,lonin,swsdin,Ztest,Rtest);
% 
% % first plot the raw values with scatterm
% figure;
% worldmap(latlims,lonlims)
% scatterm(latin,lonin,200,swsdin,'filled')
% 
% figure;
% worldmap(latlims,lonlims)
% surfacem(lattest,lontest,ztest)
% now plot the reshp

%% this is how Chad Greene does it using the accumarray function

% here I set x,y to lat,lon, below that is from Chad's xyz2grid
x = lon;
y = lat;

%Get unique values of x and y: 
[xs,~,xi] = unique(x(:),'sorted'); 
[ys,~,yi] = unique(y(:),'sorted'); 

% Before we go any further, we better make sure we're not gridding scattered data. 
% This is not a perfect assessor, but it's at least some kind of check: 
if numel(xs)==numel(z)
   warning 'It does not seem like the xyz dataset is gridded. You may be attempting to grid scattered data, but I will try to put it into a 2D matrix anyway. Check the output spacing of X and Y.';
end

% Sum up all the Z values that in each x,y grid point: 
Z = accumarray([yi xi],z(:),[],[],NaN); 

% Flip Z to match X,Y and to be correctly oriented in ij image coordinates: 
Z = flipud(Z); 

[X,Y] = meshgrid(xs,flipud(ys));

Z               =   accumarray([LON(:),LAT(:)],z(:),size(LON));

