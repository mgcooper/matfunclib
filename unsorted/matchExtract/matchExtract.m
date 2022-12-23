function [ X,Y,values ] = matchExtract( fineGrid,coarseGrid )

%MATCHEXTRACT This function finds the location of the value of fine gridded
%data within a coarser resolution grid cell that most closely matches the
%value of the coarse resolution grid cell. The matrices X and Y are the x
%and y coordinates of the fine gridded point that most closely matches the
%value of the coarse gridded cell it lies within.
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
% cell, in units of grid cells rounded down so that we can sample the
% values from the grid

xpos1 = (x2 - xul1)./cell1;
ypos1 = (yul1 - y2)./cell1;

xpos1r = ceil((x2 - xul1)./cell1); % this gives vector of x positions on fine grid
ypos1r = ceil((yul1 - y2)./cell1);
ypos1r = fliplr(ypos1r); % this flips it so the indexing starts correctly


%%

for n = 1:length(xpos1r)
    x = xpos1r(n);
    for m = 1:length(ypos1r)
        y = ypos1r(m); % x,y is the fine grid coordinates at coarse centroid
        if mod(numCells,2) == 1 %case 1: odd number of fine cells in coarse grid
            xvec = x-inc:x+inc;
            yvec = y-inc:y+inc; % xvec,yvec are x,y pairs of all fine cells in coarse grid
            for p = 1:length(xvec) % loop through and get the value at all of these fine cells, so we can find the value closest to the coarse value
                xtemp = xvec(p);
                for o = 1:length(yvec)
                    ytemp = yvec(o);
                    candidates(o,p) = z1(ytemp,xtemp);
                end
            end
        elseif mod(numCells,2) == 0 % even number, more complicated, need to figure out which direction to move in each dimension based on location of centroid on fine res grid
            if rem(x,1) > .5 && rem(y,1) > .5 % four cases, one for each quadrant
                xvec = x-inc+1:x+inc;
                yvec = y-inc+1:y+inc;
                for p = 1:length(xvec)
                    xtemp = xvec(p);
                    for o = 1:length(yvec)
                    ytemp = yvec(o);
                    candidates(o,p) = z1(ytemp,xtemp);
                    end
                end
                
            elseif rem(x,1) > .5 && rem(y,1) < .5 % case 2; quadrant II
                xvec = x-inc+1:x+inc;
                yvec = y-inc:y+inc-1;
                for p = 1:length(xvec)
                    xtemp = xvec(p);
                    for o = 1:length(yvec)
                    ytemp = yvec(o);
                    candidates(o,p) = z1(ytemp,xtemp);
                    end
                end
                
            elseif rem(x,1) < .5 && rem(y,1) > .5 % case 3; quadrant III
                xvec = x-inc:x+inc-1;
                yvec = y-inc+1:y+inc
                for p = 1:length(xvec)
                    xtemp = xvec(p);
                    for o = 1:length(yvec)
                    ytemp = yvec(o);
                    candidates(o,p) = z1(ytemp,xtemp);
                    end
                end
                
            elseif rem(x,1) < .5 && rem(y,1) < .5 % case 4; quadrant IV
                xvec = x-inc:x+inc-1;
                yvec = y-inc:y+inc-1;
                for p = 1:length(xvec)
                    xtemp = xvec(p);
                    for o = 1:length(yvec)
                    ytemp = yvec(o);
                    candidates(o,p) = z1(ytemp,xtemp);
                    end
                end
            end
        end


        % now we have the candidates, need to select the one that most
        % closely matches the coarse res cell value
        coarseValue = z2(m,n);
        diffs = abs(candidates - coarseValue);
        [Ytemp,Xtemp] = find(diffs == min(diffs(:)));
        Ymatch = yvec(1) + Ytemp(1) - 1; % note here that Xtemp and Ytemp might have found multiple cells that are equally close, so pick the first one
        Xmatch = xvec(1) + Xtemp(1) - 1;
        
        matchCoordsX(m,n) = Xmatch;
        matchCoordsY(m,n) = Ymatch;
        
        values(m,n) = z1(Ymatch,Xmatch);
    end
end

X = matchCoordsX;
Y = matchCoordsY;

end

        

            
            
            
            
        
 
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        

