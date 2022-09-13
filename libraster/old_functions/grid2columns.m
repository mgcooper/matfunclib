function [ columnData ] = grid2columns( griddedData )
%UNTITLED5 Converts gridded data i.e. a lat/lon grid of values to a list
%i.e. column format. 
%   Inputs: 
%            GRID_DATA = m x n x p dataset. m and n must be > n, p can be 0
%                        m is number of points in latitudinal direction, n
%                        is in longitudinal, p is time axis.
%            
%   Outputs: 
%            COL_DATA = p x (m*n) matrix, i.e. timeseries of each point.
%            COL_DATA (:,1) is the timeseries for GRID_DATA(m,n,:) i.e. the
%            lower right most point in GRID_DATA becomes the first column
%            of values in COL_DATA. COL_DATA(:,(m*n)) = GRID_DATA(1,1,:);
%
%   Author: Matt Cooper
%   Data: 2/28/14

[a,b,c] = size(griddedData);
columnData = zeros(c,a*b);
for n = 1:length(griddedData);
    data = griddedData(:,:,n);
    data = rot90(data);
    data = fliplr(data);
    data = reshape(data,a*b,1)';
    columnData(n,:) = data;
end

