function [ hyps_mean ] = gridHypsometricMean( fineGrid,coarseGrid )

% NOTE STILL IN PROGRESS, NEED TO FIGURE OUT HOW TO INDEX IN TO THE COARSE
% RES GRID IN THE NESTED FOR LOOPS THAT CORRESPONDS TO THE FINE RES CELL,
% NEED TO EITHER FLIP THE GRIDS OR FLIP THE XPOS1R AND YPOS1R VECTORES

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
xstart  =   xll2+cell2/2;
ystart  =   yll2+cell2/2;
xend    =   xstart + cell2*(ncols2-1);
yend    =   ystart + cell2*(nrows2-1);
x2      =   xstart:cell2:xend;
y2      =   ystart:cell2:yend;

% find the fine res cell that holds the centroid of the coarse res
% cell, in units of grid cells rounded down so that we can sample the
% values from the grid

xpos1 = (x2 - xul1)./cell1;
ypos1 = (yul1 - y2)./cell1;

xpos1r = ceil((x2 - xul1)./cell1); % this gives vector of x positions on fine grid
ypos1r = ceil((yul1 - y2)./cell1);

for n = 1:length(xpos1r);
    
    x = xpos1r(n); % the row indici on the fine res gridcell at the center of the coarse cell
    
    for m = 1:length(ypos1r); 
        
        y = ypos1r(m); % the column indici on the fine res gridcell at the center of the coarse cell
        
        if mod(numCells,2) == 1; %odd number
            
            
            cellsFine               =   z1(y-inc:y+inc,x-inc:x+inc);            % simple case
            cellCoarse              =   z2(m,n)                             % The grids are read in upside down, so indexing

        
        elseif mod(numCells,2) == 0 % even number, more complicated, need to figure out which direction to move in each dimension based on location of centroid on fine res grid
            
            if rem(x,1) > .5 && rem(y,1) > .5; % four cases, one for each quadrant
                
                cellsFine           =   z1(y-inc+1:y+inc,x-inc+1:x+inc); 
                cellsFine           =   reshape(cellsFine,numCells*numCells,1);
                [F,X]           =   ecdf(cellsFine);
                ind             =   find(min(abs(F - .5)) == abs(F - .5));       % find the cell closest to 50% on the ecdf
                hyps_mean(m,n)  =   X(ind);   
                
            elseif rem(x,1) > .5 && rem(y,1) < .5;
                
                cellsFine           =   z1(y-inc:y+inc-1,x-inc+1:x+inc)
                cellsFine           =   reshape(cellsFine,numCells*numCells,1);
                [F,X]           =   ecdf(cellsFine);
                ind             =   find(min(abs(F - .5)) == abs(F - .5));       % find the cell closest to 50% on the ecdf
                hyps_mean(m,n)  =   X(ind); 
            
            elseif rem(x,1) < .5 && rem(y,1) > .5;
                
                cellsFine           =   z1(y-inc+1:y+inc,x-inc:x+inc-1);
                cellsFine           =   reshape(cellsFine,numCells*numCells,1);
                [F,X]           =   ecdf(cellsFine);
                ind             =   find(min(abs(F - .5)) == abs(F - .5));       % find the cell closest to 50% on the ecdf
                hyps_mean(m,n)  =   X(ind); 
            
            elseif rem(x,1) < .5 && rem(y,1) < .5;
                
                cellsFine           =   z1(y-inc:y+inc-1,x-inc:x+inc-1);
                cellsFine           =   reshape(cellsFine,numCells*numCells,1);
                [F,X]           =   ecdf(cellsFine);
                ind             =   find(min(abs(F - .5)) == abs(F - .5));       % find the cell closest to 50% on the ecdf
                hyps_mean(m,n)  =   X(ind); 
            
            end
        end
    end
end

hyps_mean = flipud(hyps_mean);           
end

