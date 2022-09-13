function [ average ] = fine2coarseRatios( fineGrid,coarseGrid )

%GRIDAVERAGE This function calculates the average value of fine gridded
%data within a coarser resolution grid cell.
%   D

% read in the two grids. Fine grid will be called grid 1, coarse grid 2
[z1,r1,ncols1,nrows1,xll1,yll1,cell1] = arcgridread2(fineGrid);
[z2,r2,ncols2,nrows2,xll2,yll2,cell2] = arcgridread2(coarseGrid);

xul1 = xll1;
yul1 = yll1 + cell1*nrows1;

xul2 = xll2;
yul2 = yll2 + cell2*nrows2;

%% checks

% check to make sure the datasets fully intersect each other

if xll1 > xll2 || yll1 > yll2
    error(['It appears the fine resolution data does not fully intersect the'... 
        ' coarse resolution data']);
end
%% code
% figure out how many fine res grid cells are inside the coarse res grid,
% but round it to the nearest odd integer so that you can average an even
% number of grid cells on either side of the center

numCells = round(cell2/cell1);
if mod(numCells,2) == 1;
    inc = (numCells - 1)/2;
else
    inc = numCells/2;
end

% find the centroids of the coarse res cells in units of latitude
xstart = xll2+cell2/2;
ystart = yll2+cell2/2;
xend = xstart + cell2*(ncols2-1);
yend = ystart + cell2*(nrows2-1);
x2 = xstart:cell2:xend;
y2 = ystart:cell2:yend;

% find the fine res cell that holds the centroid of the coarse res
% cell, in units of grid cells rounded up so that we can sample the
% values from the grid

xpos1 = (x2 - xul1)./cell1; % before rounding
ypos1 = (yul1 - y2)./cell1; % before rounding
% now round up
xpos1r = ceil((x2 - xul1)./cell1); % this gives vector of x positions on fine grid
ypos1r = ceil((yul1 - y2)./cell1);

for n = 1:length(ncols1);
    x = xpos1r(n);
    for m = 1:length(nrows1);
        y = ypos1r(m);
        if mod(numCells,2) == 1; %odd number
            avgvalues1(m,n) = mean2(z1(y-inc:y+inc,x-inc:x+inc)); % simple case
        elseif mod(numCells,2) == 0 % even number, more complicated, need to figure out which direction to move in each dimension based on location of centroid on fine res grid
            if rem(x,1) > .5 && rem(y,1) > .5; % four cases, one for each quadrant
                avgvalues1(m,n) = mean2(z1(y-inc+1:y+inc,x-inc+1:x+inc));
            elseif rem(x,1) > .5 && rem(y,1) < .5;
                avgvalues1(m,n) = mean2(z1(y-inc:y+inc-1,x-inc+1:x+inc));
            elseif rem(x,1) < .5 && rem(y,1) > .5;
                avgvalues1(m,n) = mean2(z1(y-inc+1:y+inc,x-inc:x+inc-1));
            elseif rem(x,1) < .5 && rem(y,1) < .5;
                avgvalues1(m,n) = mean2(z1(y-inc:y+inc-1,x-inc:x+inc-1));
            end
        end
    end
end

average = flipud(avgvalues1);           
end