clean

save_data = 0;
%%
path.data = '/Volumes/GDRIVE/DATA/raster_test/data/';
path.save = '/Volumes/GDRIVE/DATA/raster_test/test_output/';

%% load the list of files
list            =   dir(fullfile([path.data '*']));
list(1)         =   [];
list(1)         =   [];
%%
n               =   6;

fname           =   [path.data list(n).name];
[~,~,ext]       =   fileparts(list(n).name);


if strcmp(ext,'.nc')
    info        =   ncinfo(fname);
elseif strcmp(ext,'.tif')
    info        =   geotiffinfo(fname);
elseif strcmp(ext,'.hdf') || strcmp(ext,'.h5')
    info        =   h5info(fname);
end

%% 

% this section shows how the rasterref function can return a correct
% referencing object but the mapshow doesn't work because the data needs to
% be oriented correctly

% n = 6 has uniform grid spacing
mask            =   ncread(fname,'MSK');

% options 1-4 give the same result which is that the data is oriented
% upside down, so mapshow works correctly with x,y and X,Y because Y is
% also upside down in those, but mapshow does not work correctly with the R
% because it is oriented correctly

% option 1 - rotate once and flip upside down
% mask            =   flipud(rot90(mask,1));

% option 2 - rotate thrice and flip left right
% mask            =   fliplr(rot90(mask,3));

% option 3 - permute once (no need to flip)
% mask            =   permute(mask,[2,1]);

% option 4 - transpose - identical to permute([2,1])
mask            =   transpose(mask);

% note: permute and flip upside down is same as rot90(1)
% mask            =   flipud(permute(mask,[2 1]));
% mask            =   rot90(mask,1);

% get the referencing info
x               =   ncread(fname,'x');
y               =   ncread(fname,'y');
[X,Y]           =   meshgrid(x,y);
R               =   grid2R(X,Y);

% make a test figure
figure; mapshow(x,y,mask)
figure; mapshow(X,Y,mask)
figure; mapshow(mask,R);

%% Now flip the data and Y upside down
close all

mask            =   ncread(fname,'MSK');
% mask            =   rot90(mask,3);
mask            =   flipud(permute(mask,[2 1]));
x               =   ncread(fname,'x');
y               =   ncread(fname,'y');
[X,Y]           =   meshgrid(x,y);
Y               =   flipud(Y);
R               =   grid2R(X,Y);

figure; mapshow(X,Y,mask)
figure; mapshow(mask,R);


% apply the function


% lat             =   ncread(fname,'latitude');
% lon             =   ncread(fname,'longitude');
% % convert to psn 
% [x,y]           =   ll2psn(lat,lon);

%%

A = [1 2 3;
     4 5 6;
     7 8 9;
     10 11 12];
A' 
permute(A,[2,1])
transpose(A)
rot90(A)

A = [10 7 4 1;
    11 8 5 2;
    12 9 6 3]

rot90(A)
