function [lat2,lon2,data2] = reducegeodata(lat,lon,data)
%REDUCEGEODATA reduce the density of geographic data
%
%  [lat2,lon2,data2] = reducegeodata(lat,lon,data) reduces the density of
%  geographic data. lat and lon are 1-d vectors of equal size. data is an array
%  with one and only one dimension that matches the size of lat/lon, meaning an
%  array of data values can be passed in where each element of either rows or
%  columns of data represents values at each lat/lon pair. 
%
%
%
% See also: reducem

% find which dimension of data matches the size of lat/lon
sizedata = size(data);
for n = 1:numel(sizedata)
   if sizedata(n) == numel(lat)
      idim = n;
   end
end

[lat2,lon2] = reducem(lat,lon);
[~,idx] = intersect(lat,lat2,'stable');

% this deals with the case where data is an array and 
switch idim
   case 1
      data2 = data(idx,:);
   case 2
      data2 = data(:,idx);
end

