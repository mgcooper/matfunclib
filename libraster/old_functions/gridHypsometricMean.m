function [ hyps_mean, list ] = gridHypsometricMean( fineGrid,coarseGrid )

%GRIDAVERAGE This function calculates the average value of fine gridded
%data within a coarser resolution grid cell.
%   D

% Add geotif or projected coords options

% read in the two grids. Fine grid will be called grid 1, coarse grid 2
[z1,r1,ncols1,nrows1,xll1,yll1,cell1] = arcgridread2(fineGrid);
[z2,r2,ncols2,nrows2,xll2,yll2,cell2] = arcgridread2(coarseGrid);

xul1 = xll1;
yul1 = yll1 + cell1*nrows1;

xul2 = xll2;
yul2 = yll2 + cell2*nrows2;

%% checks

% check to make sure the datasets fully intersect each other

% if xll1 > xll2 || yll1 > yll2
%     error(['It appears the fine resolution data does not fully intersect the'... 
%         ' coarse resolution data']);
% end
%% code
% figure out how many fine res grid list(m,n) are inside the coarse res grid,
% but round it to the nearest odd integer so that you can average an even
% number of grid list(m,n) on either side of the center

numlist(m,n) = round(cell2/cell1);
if mod(numlist(m,n),2) == 1;
    inc = (numlist(m,n) - 1)/2;                                                 % inc is the number of fine res grid list(m,n) that fit in either direction in the coarse list(m,n)
else
    inc = numlist(m,n)/2;
end

% find the centroids of the coarse res list(m,n) in units of latitude
xstart = xll2+cell2/2;
ystart = yll2+cell2/2;
xend = xstart + cell2*(ncols2-1);
yend = ystart + cell2*(nrows2-1);
x2 = xstart:cell2:xend;
y2 = ystart:cell2:yend;

% find the fine res cell that holds the centroid of the coarse res
% cell, in units of grid list(m,n) rounded down so that we can sample the
% values from the grid

xpos1 = (x2 - xul1)./cell1;
ypos1 = (yul1 - y2)./cell1;

xpos1r = ceil((x2 - xul1)./cell1); % this gives vector of x positions on fine grid
ypos1r = ceil((yul1 - y2)./cell1);

for n = 1:length(xpos1r);
    
    x = xpos1r(n); % the row indici on the fine res gridcell at the center of the coarse cell
    
    for m = 1:length(ypos1r); 
        
        y = ypos1r(m); % the column indici on the fine res gridcell at the center of the coarse cell
        
        if mod(numlist(m,n),2) == 1; %odd number
            
            list(m,n)               =   z1(y-inc:y+inc,x-inc:x+inc);            % simple case
            list(m,n)               =   reshape(list(m,n),numlist(m,n)*numlist(m,n),1);
            [F,X]               =   ecdf(list(m,n));
            ind                 =   find(min(abs(F - .5)) == abs(F - .5));       % find the cell closest to 50% on the ecdf
            hyps_mean(m,n)      =   X(ind);                                 % grab the elevation of that cell - this is the hypsometric mean elevation of the coarse cell 
        
        elseif mod(numlist(m,n),2) == 0 % even number, more complicated, need to figure out which direction to move in each dimension based on location of centroid on fine res grid
            
            if rem(x,1) > .5 && rem(y,1) > .5; % four cases, one for each quadrant
                
                list(m,n)           =   z1(y-inc+1:y+inc,x-inc+1:x+inc); 
                list(m,n)           =   reshape(list(m,n),numlist(m,n)*numlist(m,n),1);
                [F,X]           =   ecdf(list(m,n));
                ind             =   find(min(abs(F - .5)) == abs(F - .5));       % find the cell closest to 50% on the ecdf
                hyps_mean(m,n)  =   X(ind);   
                
            elseif rem(x,1) > .5 && rem(y,1) < .5;
                
                list(m,n)           =   z1(y-inc:y+inc-1,x-inc+1:x+inc)
                list(m,n)           =   reshape(list(m,n),numlist(m,n)*numlist(m,n),1);
                [F,X]           =   ecdf(list(m,n));
                ind             =   find(min(abs(F - .5)) == abs(F - .5));  % find the cell closest to 50% on the ecdf
                hyps_mean(m,n)  =   X(ind); 
            
            elseif rem(x,1) < .5 && rem(y,1) > .5;
                
                list(m,n)           =   z1(y-inc+1:y+inc,x-inc:x+inc-1);
                list(m,n)           =   reshape(list(m,n),numlist(m,n)*numlist(m,n),1);
                [F,X]           =   ecdf(list(m,n));
                ind             =   find(min(abs(F - .5)) == abs(F - .5));  % find the cell closest to 50% on the ecdf
                hyps_mean(m,n)  =   X(ind); 
            
            elseif rem(x,1) < .5 && rem(y,1) < .5;
                
                % the following 4 if statements check to see if the fine
                % grid and coarse grid don't fully overlap, and adjusts the
                % algorithm so only the fine res list(m,n) that do overlap with
                % the coarse res cell are used in the averaging
                
                if y-inc <= 0                                               % the coarse res cell is bigger in the south direction  
                    dif      =   -1*(y-inc);                                % how many grid list(m,n) are we talking here?
                    inc1     =   inc - dif - 1;
                else
                    inc1     =   inc;
                end
                                      
                if y+inc-1 > size(z1,1)                                     % the coarse res cell is bigger in the north direction
                    dif      =   (y+inc-1) - size(z1,1);
                    inc2     =   inc - dif;
                else
                    inc2     =   inc;
                end
                    
                if x-inc <= 0                                               % the coarse res cell is bigger in the west direction
                    dif      =   -1*(x - inc);
                    inc3     =   inc - dif - 1;
                else
                    inc3     =   inc;
                end
                    
                if x+inc - 1 > size(z1,2);                                  %  the coarse res cell is bigger in the east direction
                    dif      =   (x+inc-1) - size(z1,2);
                    inc4     =   inc - dif;
                else 
                    inc4     =   inc;
                end
                    
                list(m,n)        =   z1(y-inc1:y+inc2-1,x-inc3:x+inc4-1);       % all the fine list(m,n) fit in the coarse cell. Normal case.
                list(m,n)        =   reshape(list(m,n),size(list(m,n),1)*size(list(m,n),2),1);
                [F,X]        =   ecdf(list(m,n));
                ind          =   find(min(abs(F - .5)) == abs(F - .5));     % find the cell closest to 50% on the ecdf
                        
                hyps_mean(m,n)  =   mean(X(ind),1);  %#ok<*AGROW>           % take the mean in case there are more than one cell 
            
            end
        end
    end
end

hyps_mean = flipud(hyps_mean);           
end

