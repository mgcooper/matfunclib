function A = geoarea(lat,lon,ellips)
% A = geoarea(lat,lon) returns twice the area of the simple
% closed polygonal curve with vertices specified by vectors x and y.
% The result is:
%
%    Positive for clockwise vertex order
%    Negative for counter-clockwise vertex order
%    Zero if there are fewer than 3 vertices
%
% Reference:
% https://geometryalgorithms.com/Archive/algorithm_0101/algorithm_0101.html
% (with sign change in order to use clockwise-is-positive convention.)

% IF THE GEOPOLYGONAREA FUNCTION AT THE END IS REPLACED BY A CORRECT FUNCTION
% THIS SHOULD WORK BUT I AM NOT SURE IT IS PREFERABLE TO THE SIMPLER ONE IN
% SIGNED POLYGONAREA ... THIS REPLICATES HOW AREAINT WORKS, ... WAIT ACTUALLY
% THAAT'S IS WAHTS MISSING ... THIS REPLICATES ISPOLYCW THEN I JUST NEED THE
% FUNCTION TO GET THE LAT LON BASED AREA WHICH IS AREAINT, SO SUB THAT IN FOR
% GEOPOLYGONAREA

if nargin == 2
   ellips = referenceEllipsoid('wgs84','meter');
end

% this is ispolycw, with tf replaced by A, and the logical check if the result
% of simplePolygonArea is < 0
if iscell(lon)
   A = zeros(size(lon));
   for k = 1:numel(lon)
      if simplePolygonArea(lon{k}, lat{k}) >= 0
         %A(k) = geopolygonarea(lat, lon);
         A(k) = areaint(lat, lon, ellips);
      else
         % A(k) = -geopolygonarea(lat, lon);
         A(k) = -areaint(lat, lon, ellips);
      end
   end
else
   % checkxy(lon, lat, mfilename, 'X', 'Y', 1, 2)
   [first, last] = findFirstLastNonNan(lon);
   numParts = numel(first);
   if isrow(lon)
      A = zeros(1,numParts);
   else
      A = zeros(numParts,1);
   end
   for k = 1:numParts
      s = first(k);
      e = last(k);
      if simplePolygonArea(lon(s:e), lat(s:e)) >= 0
         % A(k) = geopolygonarea(lat(s:e), lon(s:e));
         A(k) = areaint(lat(s:e), lon(s:e), ellips);
      else
         % A(k) = -geopolygonarea(lat(s:e), lon(s:e));
         A(k) = -areaint(lat(s:e), lon(s:e), ellips);
      end
   end
end



function A = simplePolygonArea(lon,lat)

[lon, lat] = removeDuplicates(lon, lat);
lon = lon - mean(lon);
n = numel(lon);
if n <= 2
   A = 0;
else
   i = [2:n 1];
   j = [3:n 1 2];
   k = (1:n);
   A = sum(lon(i) .* (lat(k) - lat(j)));
end
A = A/2;


%----------------------------------------------------------------------

function [lon, lat] = removeDuplicates(lon, lat)
% ... including duplicate start and end points.

is_closed = ~isempty(lon) && (lon(1) == lon(end)) && (lat(1) == lat(end));
if is_closed
   lon(end) = [];
   lat(end) = [];
end

dups = [false; (diff(lon(:)) == 0) & (diff(lat(:)) == 0)];
lon(dups) = [];
lat(dups) = [];


function [first, last] = findFirstLastNonNan(x)
% Given a vector X containing NaN-delimited sequences of numbers, find the
% indices of the first and last element of each sequence.  X may contain
% runs of multiple NaNs, and X may start or end with one or more NaNs.

% Copyright 2008-2009 The MathWorks, Inc.

n = isnan(x(:));

firstOrPrecededByNaN = [true; n(1:end-1)];
first = find(~n & firstOrPrecededByNaN);

lastOrFollowedByNaN = [n(2:end); true];
last = find(~n & lastOrFollowedByNaN);



function area = geopolygonarea(lat, lon)
R = 6371000; % Earth's radius in meters
lat = deg2rad(lat);
lon = deg2rad(lon);
dlat = diff([lat; lat(1)]);
dlon = diff([lon; lon(1)]);
a = sin(dlat/2).^2 + cos(lat(1:end-1)).*cos(lat(2:end)).*sin(dlon/2).^2;
c = 2 * atan2(sqrt(a), sqrt(1-a));
e = R * c;
area = abs(0.5 * sum(lon(1:end-1).*lat(2:end) - lon(2:end).*lat(1:end-1)));

