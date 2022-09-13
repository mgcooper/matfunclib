clean

plot_figs       =   0;
save_data       =   0;

% See the 'grid_data section near the end - this is how I could construct a
% clipping function, not sure if it's the best method

% RACMO data is annual, but this script is a template for how to extract
% the rio behar data:

% 1. clip racmo to the rio behar bounding box
% 2. resample to 100 m
% 3. clip to the watershed boundary

%%
homepath            =   pwd;

if strcmp(homepath(2:6),'Users')
    path.data   =   '/Volumes/GDRIVE/DATA/racmo_noel/';
    path.save   =   ['/Users/mattcooper/Dropbox/CODE/MATLAB/GREENLAND/' ...
                        'racmo/data/'];
end

%% load variables. Units are Kg/m2/s for all vars
load([path.data 'SMB_Racmo']);

%% load the Rio Behar outline
rb              =   shaperead(['/Users/mattcooper/Google UCLA/ArcGIS/' ...
                                'Greenland/WQ7/final_catchment_WQ7_bestguess.shp']);
rbinfo          =   shapeinfo(['/Users/mattcooper/Google UCLA/ArcGIS/' ...
                                'Greenland/WQ7/final_catchment_WQ7_bestguess.shp']);

%% get an initial sense of the size of the watershed vs the racmo resolution
rbbb            =   rb.BoundingBox;
rbwidth         =   rbbb(2,1) - rbbb(1,1);
rbheight        =   rbbb(2,2) - rbbb(1,2);

% rio behar bb is 8 km wide by 14 km tall (112 km2), the catchment is 63 km2
rbarea          =   (rbwidth*rbheight)/(1000*1000);

% the racmo resolution is 1 km2, so there are about 8*14 = 112 grid values
data.R.CellExtentInWorldX;
data.R.CellExtentInWorldY;

% racmo bounding box
racmobb         =   mapbbox(data.R,size(data.Topography));

%% clip racmo to the bounding box

% make an R object for Rio Behar for use with rasterinterp
grid_res        =   100;
Rrb             =   bb2R(rbbb,grid_res);

% clip Racmo to the watershed boundary
runoff          =   data.runoff(:,:,1);
runoff          =   rasterinterp(runoff,data.R,Rrb,'nearest');

% reshape the runoff for compatibility with inpolygon
runoffrs        =   reshape(runoff,size(runoff,1)*size(runoff,2),1);

%%
[polyx,polyy]   =   closePolygonParts(rb.X,rb.Y);
pgon            =   polyshape(polyx,polyy);
% pgon            =   polyshape(testx,testy,'Simplify',true);

% get a list of x,y coord's for all the grid cells
[X,Y]           =   R2grid(Rrb);
X               =   reshape(X,size(X,1)*size(X,2),1);
Y               =   reshape(Y,size(Y,1)*size(Y,2),1);
% TFin            =   isinterior(pgon,X,Y); % takes forever

% try inpolygon instead
[in,on]         =   inpolygon(X,Y,polyx,polyy);
runoff_in       =   double(runoffrs(in));
x_in            =   X(in);
y_in            =   Y(in);

%% griddata works but it's not what I want
% vq              =   griddata(x_in,y_in,runoff_in,X,Y);
% Zrunoff         =   reshape(vq,size(runoff,1),size(runoff,2));
% 
% figure;
% rastersurf(Zrunoff,Rrb);