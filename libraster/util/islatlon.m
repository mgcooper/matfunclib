function tf = islatlon(lat,lon)
% islatlon determines whether lat,lon is likely to represent geographical
% coordinates. 
% 
%% Citing Antarctic Mapping Tools
% This function was developed for Antarctic Mapping Tools for Matlab (AMT).
% If AMT is useful for you, please cite our paper:
% 
% Greene, C. A., Gwyther, D. E., & Blankenship, D. D. Antarctic Mapping
% Tools for Matlab. Computers & Geosciences. 104 (2017) pp.151-157.
% http://dx.doi.org/10.1016/j.cageo.2016.08.003
% 
% @article{amt,
%   title={{Antarctic Mapping Tools for \textsc{Matlab}}},
%   author={Greene, Chad A and Gwyther, David E and Blankenship, Donald D},
%   journal={Computers \& Geosciences},
%   year={2017},
%   volume={104},
%   pages={151--157},
%   publisher={Elsevier}, 
%   doi={10.1016/j.cageo.2016.08.003}, 
%   url={http://www.sciencedirect.com/science/article/pii/S0098300416302163}
% }
%   
%% Syntax
% 
% tf = islatlon(lat,lon) returns true if all values in lat are numeric
% between -90 and 90 inclusive, and all values in lon are numeric between 
% -180 and 360 inclusive. 
% 
%% Example 1: A single location
% 
% islatlon(110,30)
%    = 0
% 
% because 110 is outside the bounds of latitude values. 
% 
%% Example 2: A grid
% 
% [lon,lat] = meshgrid(-180:180,90:-1:-90); 
% 
% islatlon(lat,lon)
%    = 1 
% 
% because all values in lat are between -90 and 90, and all values in lon
% are between -180 and 360.  What if it's really, really close? What if
% just one value violates these rules? 
% 
% lon(1) = -180.002; 
% 
% islatlon(lat,lon)
%    = 0
% 
%% Author Info
% This function was written by Chad A. Greene of the University of Texas at
% Austin's Institute for Geophysics (UTIG). http://www.chadagreene.com. 
% March 30, 2015. 
% 
% See also wrapTo180, wrapTo360, projfwd, and projinv.  

% Make sure there are two inputs:
narginchk(2,2)

% Set default output:
tf = true;

%% If *any* inputs don't look like lat,lon, assume none of them are lat,lon.

% islatlon is the shared geographic-BOUNDS predicate: it answers only "do these
% values fall within geographic coordinate ranges", with no check that they carry
% a geographic SIGNATURE (that stricter test is isGeoGrid, which calls this for
% its bounds stage so the two share one bounds definition).

if ~isnumeric(lat) || ~isnumeric(lon)
    tf = false;
    return
end

% Latitude must be within [-90, 90].
if any(abs(lat(:)) > 90)
    tf = false;
    return
end

% Longitude must lie entirely within ONE convention -- [-180, 180] or [0, 360] --
% rather than the looser [-180, 360] (which would accept a nonsensical mix such as
% -50 and 200 together).
lonInRange = (all(lon(:) >= -180) && all(lon(:) <= 180)) || ...
             (all(lon(:) >= 0)    && all(lon(:) <= 360));
if ~lonInRange
    tf = false;
end