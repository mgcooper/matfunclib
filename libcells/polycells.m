function [latcells,loncells] = polycells(lat,lon)
%POLYCELLS Convert nan-separated polygon parts from vectors to cell arrays
%
%   [LATCELLS,LONCELLS] = POLYCELLS(LAT,LON) returns the NaN-delimited
%   segments of the vectors LAT and LON as N-by-1 cell arrays with one
%   polygon segment per cell.  LAT and LON must be the same size and have
%   identically-placed NaNs.  The polygon segments are column vectors if
%   LAT and LON are column vectors, and row vectors otherwise.
%
%   See also POLYVEC

if isempty(lat) && isempty(lon)
   latcells = reshape({}, [0 1]);
   loncells = latcells;
else
   validateattributes(lat,{'numeric'},{'real','vector'},mfilename,'LAT',1)
   validateattributes(lon,{'numeric'},{'real','vector'},mfilename,'LON',2)

   [lat, lon] = rmnansep(lat, lon);

   % Find NaN locations.
   I = find(isnan(lat(:)));

   % Simulate the trailing NaN if it's missing.
   if ~isempty(lat) && ~isnan(lat(end))
      I(end+1,1) = numel(lat) + 1;
   end

   %  Extract each segment into pre-allocated N-by-1 cell arrays, where N is
   %  the number of polygon segments.  (Add a leading zero to the indx array
   %  to make indexing work for the first segment.)
   N = numel(I);
   I = [0; I];
   latcells = arrayfun(@(n) lat( I(n)+1:I(n+1)-1 ), 1:N, 'un', 0);
   loncells = arrayfun(@(n) lon( I(n)+1:I(n+1)-1 ), 1:N, 'un', 0);
   
end

function [x,y,v] = rmnansep(x,y,v)
n = isnan(x(:));
extranan = n & [true; n(1:end-1)];
x(extranan) = [];
y(extranan) = [];
if nargin >= 3
   v(extranan) = [];
end
