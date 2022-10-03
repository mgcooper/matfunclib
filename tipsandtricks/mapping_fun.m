
% pretty sure symbolspec only works when plotting a geo/mapstruct, not x,y
% i.e. mapshow(x,y,'SymbolSpec',S) doesn't wokr

% to clarify the comment below, the 'Metadata' field is not the attributes,
% the Metadata field is for the entire shapefile, the attributes pertain to
% each feature, and are referred to as 'vertex properties' by matlab. see
% hexjson2shp for an example of how to build a shapefile from a structure
% of attributes. a key issue figured out there is initializing the
% geoshape by adding the 'Geometry' field to an attributes structure, usign
% that structure and a set of lat/lon values to init the geoshpae, then
% using append to add new features

% when making a mapshape or geoshpae, if the structure passed in has
% multiple fields, they will not be in the 'metadata' strcuture where
% expected, but they can be accessed via dot notation, and when shapewrite
% is sued they will be in teh attributes as expected

% I NEED TO ADD MEHTODS TO DEAL WITH BAD SHAPEFILE POLYGON GEOMETRY I know
% i've ahd some success in the past, 

% change the extent of a worldmap (or map axes)
setm(h.hworldmap,'MapLatLimit',[45 75])
setm(h.hworldmap,'MapLonLimit',[-170 -50])

% moved from /Code/tips_tricks here

% see how rot90_3D and flipud(permute( do the same thing:
fname   =   [p.data 'swsd.RACMO23p3_no_subsurf_en_FGRN11_2012_2015.3H.nc'];
info    =   ncinfo(fname);
LON     =   flipud(permute(ncread(fname,'lon'),[2 1]));
LAT     =   flipud(permute(ncread(fname,'lat'),[2 1]));
swsd    =   squeeze(ncread(fname,'swsd'));
[X,Y]   =   projfwd(projsipsn,LAT,LON);
swsd1   =   rot90_3D(swsd,3,1);
swsd2   =   flipud(permute(swsd,[2 1 3]));

figure; scatter(X(:),Y(:),12,swsdavg1(:))
figure; scatter(X(:),Y(:),12,swsdavg2(:))

% Adding some notes here:
% maprefcells
% maprasterref
% refmatToMapRasterReference
% 
% refmat
% 
% 'RefMatrix', referred to referencing matrix
% map raster reference object
% 
% 1. Contruct a 3x2 "affine transformation" matrix aka spatial referencing
% matrix from known lat/lon limits and cell size 

% R = makerefmat(x11, y11, dx, dy)
% R = makerefmat(lon11, lat11, dlon, dlat)
% R = makerefmat(param1, val1, param2, val2, ...)

% Note: R transforms pixel i.e. row/column subscripts to map coordinates:

% [x,y] = [row col 1]*R;

% or transforms pixel subscripts to/from geographic coordinates according to

% [lon,lat] = [row col 1] * R;

% 2. convert a 3x2 'refmat' referencing matrix to a GeoRasterReference
% object (the R structure) aka a map.rasterref.GeographicCellsReference 

% R = refmatToGeoRasterReference(refmat,rasterSize);

% 3. Make your own geographic raster reference object:

% R = georefcells()
% R = georefcells(latlim,lonlim,rasterSize)
% R = georefcells(latlim,lonlim,cellExtentInLatitude,cellExtentInLongitude)
% R = georefcells(latlim,lonlim,___,Name,Value)

% I could contruct one of these, for example, if I have a netcdf file or some other grid of geographic data that isn't saved as a geotiff or arcgrid and therefore cannot be read into matlab with geotiffread or arcgridread, but it does have the lat/lon info so I can figure out lat lim, lon lim, etc. Note, however, that the lat/lon values in a netcdf lat and lon matrix are the cell centers, and for georefcells, the latlim/lonlim values are the cell edges, so need to adjust accordingly. I have an example in the Geog 207 folder SWE_extract_daily_region_props 
% 
% 4. Do the same as above with regularly spaced samples i.e. 'postings'. The only difference as far as I can tell would be the R.RasterInterpretation field would be set to 'postings' instead of 'cells':

% R = georefpostings()
% R = georefpostings(latlim,lonlim,rasterSize)
% R = georefpostings(latlim,lonlim,sampleSpacingInLatitude,sampleSpacingInLongitude)
% R = georefpostings(latlim,lonlim,___,Name,Value)

% 5. Do the same but with a world file

% R = georasterref()
% R = georasterref(Name,Value)
% R = georasterref(W,rasterSize,rasterInterpretation)


% Each of the above has a corresponding 'map' version i.e. maprefcells()


% Now, what do I do if I have two rasters and I have the R matrices, and I
% want to clip one raster to the size of the other?   
% 
% You could ALMOST get it done using maptrims:

% [Z_trimmed] = maptrims(Z,R,latlim,lonlim)
% [Z_trimmed] = maptrims(Z,R,latlim,lonlim,cellDensity)
% [Z_trimmed, R_trimmed] = maptrims(...)

% the latlim and lonlim would be obtained from the R matrix for the raster
% you are using as the trim template. The problem is that matlab does not
% deal with partial cells, so the only way Z_trimmed will be coregistered
% with the template raster is if latlim and lonlim fall exactly on one of
% the cell edges as the Z raster    
% 
% So, after this trimming, we would have to do some additional steps to
% make them coregister ...   
% 
% One possibility might be to use geointerp. In this case it might not even
% be necessary to use the trim function at all. Just make a grid of lat/lon
% values that correspond to the template and interpolate the Z data to each
% point and build a grid up from scratch ...   
% 
% Or, use griddedInterpolant. The answer is probably in here:
% 
% https://www.mathworks.com/help/matlab/math/resample-image-with-gridded-interpolation.html
% 
% I would build grid vectors for the trimming template and then use them.
% For now, i am going to build my mask in Arc and use that so I  
% 
% 6. Instead of a 3x2 'refmat', convert a 1x3 'refvec' to a geographic
% raster reference object, R: 

% R = refvecToGeoRasterReference(refvec,rasterSize)
% R = refvecToGeoRasterReference(refvec,rasterSize,funcName,varName,argIndex)
% R = refvecToGeoRasterReference(Rin,rasterSize,___)
% 
% refvec(1) = 1/(cell size) 
% refvec(2) = northwest corner latitude
% refvec(3) = northwest corner longitude

% NOTE: this replaces refvec2mat(refvec,s) 

% 7. Use R (either the 3x2 or the structure version) to get the pixel
% coordinates row col from lat/lon coordinates. 

% [row, col ] = latlon2pix(R,lat,lon)

% or lat/lon from row/col:

% [lat, lon] = pix2latlon(R,row,col)

% same functions exist for map coordinates

[x,y] = pix2map(R,row,col);
[row,col] = map2pix(R,x,y);


% 8. Make a 3d map
f = figure;

% 9. Write a shapefile


% 10. Figure out if a vector of lat/lon points is inside or outside a
% shapefile - very slow for complex shapefiles 

[in,on] = inpolygon(xq,yq,xv,yv);

% 11. Control the spacing of a worldmap (or axesm) object graticule:

ax1 =   worldmap([latmin latmax],[lonmin lonmax]); hold on;
setm(ax1,'PLineLocation',2); % change the Parallel line locations to be 2 degrees apart
setm(ax1,'PLabelLocation',2) % similarly for the labels

% a few other useful properties:
setm(ax1,'GLineStyle','-')
setm(ax1,'GColor','k');
setm(ax1,'FontSize',12)


% 12. Plotting big shapefiles

% see code plot_shapefiles in gimp asa folder, she has shapefiles for the
% surface classification with a separate x,y entry for each ice cap stored
% within the main shapefile structure, where x,y are long vectors, when I
% try to plot all at once e.g. mapshow(sf) it takes FOREVER, this is
% because matlab is creating a plot object for each x,y whereas see notes
% below:     

% try pulling out all the lat lon and putting them in one vector then
% plot Commenting this out because the vector becomes way too big, but
% indeed the map drawing is WAY faster, so I think the problem is with
% drawing each individual shapefile as explained at the link below:
% https://blogs.mathworks.com/graphics/2015/06/09/object-creation-performance/

% Note: I think the key to displaying large shapefiles quickly in Matlab is
% to have the data properly formatted with nan separating the multiparts,
% as explained in doc Geographic Data Structures. The question is, how do
% we convert a shapefile that is not formatted this way, such as those
% provided here?

% MAKE NAN TRANSPARAENT
set(h1,'FaceAlpha','texturemap','AlphaData',double(~isnan(Zsmb)));


% PLOT VECTOR DATA ON SURFACE 
load('/Users/coop558/mydata/e3sm/topo/ifsar_region_160m');
load('sag_basin');
HS      = DEM.HS;
R       = DEM.R;
zHS     = zeros(size(HS));

figure;
mapshow(zHS,R,'CData',HS,'DisplayType','surface'); hold on;
mapshow(sag);


% use two different colormaps on a single figure
% https://www.mathworks.com/matlabcentral/answers/194554-how-can-i-use-and-display-two-different-colormaps-on-the-same-figure
%%Create two axes
ax1 = axes;
[x,y,z] = peaks;
surf(ax1,x,y,z)
view(2)
ax2 = axes;
scatter(ax2,randn(1,120),randn(1,120),50,randn(1,120),'filled')
%%Link them together
linkaxes([ax1,ax2])
%%Hide the top axes
ax2.Visible = 'off';
ax2.XTick = [];
ax2.YTick = [];
%%Give each one its own colormap
colormap(ax1,'hot')
colormap(ax2,'cool')
%%Then add colorbars and get everything lined up
set([ax1,ax2],'Position',[.17 .11 .685 .815]);
cb1 = colorbar(ax1,'Position',[.05 .11 .0675 .815]);
cb2 = colorbar(ax2,'Position',[.88 .11 .0675 .815]);





