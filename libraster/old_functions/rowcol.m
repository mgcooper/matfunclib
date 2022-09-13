function [ row,col ] = rowcol( x,y,xll,yll,ncols,nrows,cellsize,option)
%ROWCOL returns the cartesian (matlab style) row col indices for points on
%a grid. For example, you have meteorological stations with utm
%coordinates, and you want to know what cell on a regular utm grid holds
%those stations, so you can extract the data from the grid at that
%location. The xll and yll need to be for the edge of the grid cells. A
%standard arcgis header will have the xll and yll for the grid edge. The
%Matlab function arcgridread will adjust these to be 0.5*cellsize to the 
%left of the lower left x coord and above the upper right y coord, and
%stores those values in the referencing matrix R. the modified funtion
%arcgridread3 will return the header info exactly as it is stored in the
%file header, thus if it's a standard arc grid it will return the xll and
%yll of the grid edge. the modified function arcgridread2 will return the
%same information but instead of a structure it will return each value as a
%unique variable. The xllcorner and yllcorner variables will be the actual
%value in the header same as arcgridread3, thus again for a standard arc
%grid header the coords will be for the lower left grid edge, which is what
% we want for this function to work properly. In other words DO NOT USE
% ARCGRIDREAD TO GET XLL AND YLL!! USE EITHER ARCGRIDREAD2 or ARCGRIDREAD3

%   Inputs:
%          X: a vector of the x locations in UTM or other regular grid
%          Y: a vector of y locations in UTM or other regular grid
%          XLL: the x coordinate of the edge of the lower left grid cell
%          YLL: the y coordinate of the edge of the lower left grid cell
%          

if nargin == 7
    
%     disp(['The 8th input argument ''option'' is either ''round'' or is ' ...
%                 'to be left blank'])
            
    yul = yll + nrows*cellsize;

    row = (yul - y)./cellsize;
    col = (x - xll)./cellsize;

elseif nargin == 8
    
    if strcmp(option,'round') == 1
        row = ceil(row);
        col = ceil(col);
    else
        disp(['The 8th input argument ''option'' is either ''round'' or is ' ...
                'to be left blank']);
    end
    
end


